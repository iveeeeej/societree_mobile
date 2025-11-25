<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/mailer/mailer_config.php';
@require_once __DIR__ . '/sms/config_sms.php';
header('Content-Type: application/json');

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

function normalize_phone($raw) {
  $p = preg_replace('/\s+/', '', (string)$raw);
  // If starts with +, keep
  if (strpos($p, '+') === 0) { return $p; }
  // If starts with 09XXXXXXXXX (PH local), convert to +639XXXXXXXXX
  if (preg_match('/^09\d{9}$/', $p)) { return '+63' . substr($p, 1); }
  // If starts with 9 digits w/o leading 0 and length 10, assume PH mobile and add +63
  if (preg_match('/^9\d{9}$/', $p)) { return '+63' . $p; }
  // If starts with 63 and 11 digits total, add +
  if (preg_match('/^63\d{10}$/', $p)) { return '+' . $p; }
  return $p; // fallback as-is
}

function send_mail_otp($toEmail, $subject, $htmlBody, &$err) {
  $err = null;
  $mail = new_configured_mailer($err);
  if ($mail === null) { return false; }
  try {
    $mail->addAddress($toEmail);
    $mail->Subject = $subject;
    $mail->Body = $htmlBody;
    $mail->AltBody = strip_tags($htmlBody);
    $mail->send();
    return true;
  } catch (Exception $e) {
    $err = $e->getMessage();
    return false;
  }
}

function send_sms_otp($phone, $text, &$err) {
  $err = null;
  if (!defined('SMSCHEF_API_URL')) { $err = 'SMS config missing'; return false; }
  $payload = [
    'secret' => SMSCHEF_SECRET,
    'mode' => 'devices',
    'device' => SMSCHEF_DEVICE,
    'sim' => defined('SMSCHEF_SIM') ? SMSCHEF_SIM : '1',
    'priority' => defined('SMSCHEF_PRIORITY') ? SMSCHEF_PRIORITY : '1',
    'phone' => $phone,
    'message' => $text,
  ];
  $ch = curl_init(SMSCHEF_API_URL);
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($payload));
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  if (defined('EMERGENCY_TIMEOUT')) curl_setopt($ch, CURLOPT_TIMEOUT, EMERGENCY_TIMEOUT);
  $res = curl_exec($ch);
  if ($res === false) { $err = curl_error($ch) ?: 'curl'; curl_close($ch); return false; }
  $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
  curl_close($ch);
  if ($code >= 200 && $code < 300) { return true; }
  $err = 'http_' . $code . ' ' . substr((string)$res, 0, 200);
  return false;
}

// Accept POST (JSON) and GET (for quick manual testing)
$student_id = '';
$method = 'email';
$phoneOverride = '';
$emailOverride = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $payload = read_json_body();
  if (!is_array($payload)) { http_response_code(400); echo json_encode(['success'=>false,'message'=>'Invalid JSON']); exit(); }
  $student_id = isset($payload['student_id']) ? trim($payload['student_id']) : '';
  if (isset($payload['method'])) { $method = strtolower(trim((string)$payload['method'])); }
  if (isset($payload['phone'])) { $phoneOverride = trim((string)$payload['phone']); }
  if (isset($payload['email'])) { $emailOverride = trim((string)$payload['email']); }
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
  $student_id = isset($_GET['student_id']) ? trim($_GET['student_id']) : '';
  if (isset($_GET['method'])) { $method = strtolower(trim((string)$_GET['method'])); }
  if (isset($_GET['phone'])) { $phoneOverride = trim((string)$_GET['phone']); }
  if (isset($_GET['email'])) { $emailOverride = trim((string)$_GET['email']); }
} else {
  http_response_code(405);
  echo json_encode(['success' => false, 'message' => 'Method not allowed']);
  exit();
}
if ($student_id === '' && $phoneOverride === '' && $emailOverride === '') {
  http_response_code(422);
  echo json_encode(['success'=>false,'message'=>'Provide student_id or phone or email']);
  exit();
}

$mysqli = db_connect();

// Choose lookup strategy
$lookup = '';
$uid = null; $email = null; $dbPhone = null;
if ($student_id !== '') {
  $lookup = 'student_id';
  if ($sel = $mysqli->prepare('SELECT id, email, phone FROM users WHERE student_id = ?')) {
    $sel->bind_param('s', $student_id);
    $sel->execute();
    $sel->bind_result($uid, $email, $dbPhone);
    $found = $sel->fetch();
    $sel->close();
    if (!$found) { $uid = null; }
  }
  // If user also supplied an override contact, it must match the record of this student
  if ($uid !== null) {
    if ($method === 'sms' && $phoneOverride !== '') {
      $prov = normalize_phone($phoneOverride);
      $dbn = normalize_phone((string)$dbPhone);
      $alt = ($dbn && strpos($dbn, '+63') === 0) ? ('0' . substr($dbn, 3)) : (string)$dbPhone;
      if (!in_array($prov, [$dbn, $alt, (string)$dbPhone], true)) {
        http_response_code(422);
        echo json_encode(['success'=>false,'message'=>'Phone number does not match the student ID on record']);
        $mysqli->close();
        exit();
      }
    }
    if ($method !== 'sms' && $emailOverride !== '') {
      $provE = strtolower(trim($emailOverride));
      $dbE = strtolower(trim((string)$email));
      if ($provE !== $dbE) {
        http_response_code(422);
        echo json_encode(['success'=>false,'message'=>'Email does not match the student ID on record']);
        $mysqli->close();
        exit();
      }
    }
  }
} elseif ($method === 'sms' && $phoneOverride !== '') {
  $lookup = 'phone';
  $p1 = $phoneOverride;
  $p2 = normalize_phone($phoneOverride);
  // try local 0-start if normalized produced +63
  $p3 = ($p2 && strpos($p2, '+63') === 0) ? ('0' . substr($p2, 3)) : $phoneOverride;
  if ($sel = $mysqli->prepare('SELECT id, email, phone FROM users WHERE phone IN (?, ?, ?) LIMIT 1')) {
    $sel->bind_param('sss', $p1, $p2, $p3);
    $sel->execute();
    $sel->bind_result($uid, $email, $dbPhone);
    $found = $sel->fetch();
    $sel->close();
    if (!$found) { $uid = null; }
  }
} elseif ($emailOverride !== '') {
  $lookup = 'email';
  if ($sel = $mysqli->prepare('SELECT id, email, phone FROM users WHERE email = ?')) {
    $sel->bind_param('s', $emailOverride);
    $sel->execute();
    $sel->bind_result($uid, $email, $dbPhone);
    $found = $sel->fetch();
    $sel->close();
    if (!$found) { $uid = null; }
  }
}

if ($uid !== null) {
    // Determine channel and recipient
    if ($method !== 'sms') { $method = 'email'; }
    $channel = $method;
    $recipientEmail = $email;
    $recipientPhone = $phoneOverride !== '' ? $phoneOverride : (string)$dbPhone;
    if ($channel === 'email' && !$recipientEmail) { http_response_code(422); echo json_encode(['success'=>false,'message'=>'No email on file for this user','channel'=>$channel]); $mysqli->close(); exit(); }
    if ($channel === 'sms' && !$recipientPhone) { http_response_code(422); echo json_encode(['success'=>false,'message'=>'No phone on file for this user','channel'=>$channel]); $mysqli->close(); exit(); }
    $otp = str_pad((string)random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    $expires = date('Y-m-d H:i:s', time() + 10 * 60);
    $updated = 0; $perr = null;
    if ($upd = $mysqli->prepare('UPDATE users SET otp_code = ?, otp_expires_at = ? WHERE id = ?')) {
      $upd->bind_param('ssi', $otp, $expires, $uid);
      if (!$upd->execute()) { $perr = $mysqli->error; }
      $updated = $upd->affected_rows;
      $upd->close();
    } else {
      $perr = $mysqli->error ?: 'prepare failed';
    }
    if ($updated <= 0) {
      http_response_code(500);
      echo json_encode(['success'=>false,'message'=>'Failed to store OTP','error'=>$perr,'updated'=>$updated,'user_id'=>$uid]);
      $mysqli->close();
      exit();
    }
    $err = null; $ok = false;
    if ($channel === 'email') {
      $subject = 'Your SocieTree OTP Code';
      $body = '<p>Your OTP code is:</p><h2 style="letter-spacing:3px">' . htmlspecialchars($otp) . '</h2><p>This code expires in 10 minutes.</p>';
      $ok = send_mail_otp($recipientEmail, $subject, $body, $err);
    } else { // sms
      $to = normalize_phone($recipientPhone);
      $text = 'SocieTree OTP: ' . $otp . ' (expires in 10 minutes)';
      $ok = send_sms_otp($to, $text, $err);
    }
    if ($ok) {
      echo json_encode(['success'=>true,'message'=>'OTP sent','updated'=>$updated,'channel'=>$channel,'lookup'=>$lookup,
        'to'=> ($channel === 'email' ? $recipientEmail : normalize_phone($recipientPhone))
      ]);
    } else {
      http_response_code(500);
      echo json_encode(['success'=>false,'message'=>'Failed sending ' . $channel,'error'=>$err,'lookup'=>$lookup,
        'to'=> ($channel === 'email' ? $recipientEmail : normalize_phone($recipientPhone))
      ]);
    }
} else {
  http_response_code(404);
  echo json_encode(['success'=>false,'message'=>'User not found']);
}
$mysqli->close();

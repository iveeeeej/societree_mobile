<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/mailer/mailer_config.php';
header('Content-Type: application/json');

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

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

// Accept POST (JSON) and GET (for quick manual testing)
$student_id = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $payload = read_json_body();
  if (!is_array($payload)) { http_response_code(400); echo json_encode(['success'=>false,'message'=>'Invalid JSON']); exit(); }
  $student_id = isset($payload['student_id']) ? trim($payload['student_id']) : '';
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
  $student_id = isset($_GET['student_id']) ? trim($_GET['student_id']) : '';
} else {
  http_response_code(405);
  echo json_encode(['success' => false, 'message' => 'Method not allowed']);
  exit();
}
if ($student_id === '') { http_response_code(422); echo json_encode(['success'=>false,'message'=>'student_id required']); exit(); }

$mysqli = db_connect();
if ($sel = $mysqli->prepare('SELECT id, email FROM users WHERE student_id = ?')) {
  $sel->bind_param('s', $student_id);
  $sel->execute();
  $sel->bind_result($uid, $email);
  if ($sel->fetch()) {
    $sel->close();
    if (!$email) { http_response_code(422); echo json_encode(['success'=>false,'message'=>'No email on file for this user']); $mysqli->close(); exit(); }
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
    $subject = 'Your SocieTree OTP Code';
    $body = '<p>Your OTP code is:</p><h2 style="letter-spacing:3px">' . htmlspecialchars($otp) . '</h2><p>This code expires in 10 minutes.</p>';
    $err = null;
    $ok = send_mail_otp($email, $subject, $body, $err);
    if ($ok) {
      echo json_encode(['success'=>true,'message'=>'OTP sent','updated'=>$updated]);
    } else {
      http_response_code(500);
      echo json_encode(['success'=>false,'message'=>'Failed sending email','error'=>$err]);
    }
  } else {
    http_response_code(404);
    echo json_encode(['success'=>false,'message'=>'User not found']);
  }
} else {
  http_response_code(500);
  echo json_encode(['success'=>false,'message'=>'DB error: prepare failed','error'=>$mysqli->error]);
}
$mysqli->close();

<?php
require_once __DIR__ . '/config.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  http_response_code(405);
  echo json_encode(['success' => false, 'message' => 'Method not allowed']);
  exit();
}

$payload = read_json_body();
if (!is_array($payload)) { http_response_code(400); echo json_encode(['success'=>false,'message'=>'Invalid JSON']); exit(); }
$student_id = isset($payload['student_id']) ? trim($payload['student_id']) : '';
$otp = isset($payload['otp']) ? trim($payload['otp']) : '';
$new_password = isset($payload['new_password']) ? (string)$payload['new_password'] : '';

if ($student_id === '' || $otp === '' || $new_password === '') {
  http_response_code(422);
  echo json_encode(['success'=>false,'message'=>'student_id, otp and new_password are required']);
  exit();
}

// Normalize OTP to 6 digits if user typed spaces/hyphens
$otp = preg_replace('/\D+/', '', $otp);
if (strlen($otp) !== 6) {
  http_response_code(422);
  echo json_encode(['success'=>false,'message'=>'OTP must be a 6-digit code']);
  exit();
}

$mysqli = db_connect();
if ($sel = $mysqli->prepare('SELECT id, otp_code, otp_expires_at FROM users WHERE student_id = ?')) {
  $sel->bind_param('s', $student_id);
  $sel->execute();
  $sel->bind_result($uid, $otp_code, $otp_expires_at);
  if ($sel->fetch()) {
    $sel->close();
    if (!$otp_code || !$otp_expires_at) {
      http_response_code(400);
      echo json_encode(['success'=>false,'message'=>'No OTP requested']);
      $mysqli->close();
      exit();
    }
    $now = time();
    $exp = strtotime($otp_expires_at);
    if (!password_verify($otp, $otp_code)) {
      http_response_code(401);
      echo json_encode(['success'=>false,'message'=>'Invalid OTP']);
      $mysqli->close();
      exit();
    }
    if ($exp !== false && $now > $exp) {
      http_response_code(401);
      echo json_encode(['success'=>false,'message'=>'OTP expired']);
      $mysqli->close();
      exit();
    }
    $hash = password_hash($new_password, PASSWORD_BCRYPT);
    if ($upd = $mysqli->prepare('UPDATE users SET password_hash = ?, otp_code = NULL, otp_expires_at = NULL WHERE id = ?')) {
      $upd->bind_param('si', $hash, $uid);
      $upd->execute();
      $affected = $upd->affected_rows;
      $upd->close();
      if ($affected > 0) {
        echo json_encode(['success'=>true,'message'=>'Password updated','affected_rows'=>$affected,'student_id'=>$student_id]);
      } else {
        // No row changed (password may be same as before). Report clearly.
        echo json_encode(['success'=>true,'message'=>'Password already set to this value or no change detected','affected_rows'=>0,'student_id'=>$student_id]);
      }
    } else {
      http_response_code(500);
      echo json_encode(['success'=>false,'message'=>'DB error: prepare failed','error'=>$mysqli->error]);
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

<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';
$out = ['success'=>false,'message'=>null];
try {
  $mysqli = db_connect();
  $studentId = '2023304637';
  $pass = '12345678';
  $hash = password_hash($pass, PASSWORD_BCRYPT);
  if ($sel = $mysqli->prepare('SELECT id FROM users WHERE student_id = ?')) {
    $sel->bind_param('s', $studentId);
    $sel->execute();
    $sel->store_result();
    if ($sel->num_rows === 0) {
      $sel->close();
      if ($ins = $mysqli->prepare("INSERT INTO users (student_id, password_hash, role, department, position, phone, email) VALUES (?, ?, 'admin', 'BSIT', 'ElecomChairPerson', '09534181760', 'rpsvcodes@gmail.com')")) {
        $ins->bind_param('ss', $studentId, $hash);
        $ins->execute();
        $ins->close();
        $out['success'] = true;
        $out['message'] = 'Admin seeded';
      } else {
        $out['message'] = 'Prepare insert failed: ' . $mysqli->error;
      }
    } else {
      $out['success'] = true;
      $out['message'] = 'Admin already exists';
      $sel->close();
    }
  } else {
    $out['message'] = 'Prepare select failed: ' . $mysqli->error;
  }
  $mysqli->close();
} catch (Throwable $e) {
  $out['message'] = $e->getMessage();
}
echo json_encode($out);

<?php
require_once __DIR__ . '/config.php';
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
  http_response_code(405);
  echo json_encode(['success' => false, 'message' => 'Method not allowed']);
  exit();
}

$payload = read_json_body();
if (!is_array($payload)) { $payload = $_POST; }
$student_id = isset($payload['student_id']) ? trim((string)$payload['student_id']) : '';
$receipt_id = isset($payload['receipt_id']) ? trim((string)$payload['receipt_id']) : '';
$type = isset($payload['type']) ? trim((string)$payload['type']) : 'info';
$title = isset($payload['title']) ? trim((string)$payload['title']) : '';
$body = isset($payload['body']) ? trim((string)$payload['body']) : '';

if ($student_id === '' || $title === '') {
  http_response_code(400);
  echo json_encode(['success'=>false,'message'=>'student_id and title are required']);
  exit();
}

$mysqli = db_connect();
// Ensure table exists
$ddl = "CREATE TABLE IF NOT EXISTS user_notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_id VARCHAR(64) NOT NULL,
  receipt_id VARCHAR(64) NULL,
  type VARCHAR(32) NOT NULL DEFAULT 'info',
  title VARCHAR(255) NOT NULL,
  body TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_student_receipt (student_id, receipt_id),
  KEY idx_student_created (student_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
$mysqli->query($ddl);

if ($receipt_id !== '') {
  $stmt = $mysqli->prepare("INSERT INTO user_notifications (student_id, receipt_id, type, title, body) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE id = id");
  if (!$stmt) { http_response_code(500); echo json_encode(['success'=>false,'message'=>'DB error']); exit(); }
  $stmt->bind_param('sssss', $student_id, $receipt_id, $type, $title, $body);
} else {
  $stmt = $mysqli->prepare('INSERT INTO user_notifications (student_id, type, title, body) VALUES (?, ?, ?, ?)');
  if (!$stmt) { http_response_code(500); echo json_encode(['success'=>false,'message'=>'DB error']); exit(); }
  $stmt->bind_param('ssss', $student_id, $type, $title, $body);
}
$ok = $stmt->execute();
$id = $stmt->insert_id;
$stmt->close();

if ($ok) {
  echo json_encode(['success'=>true, 'id'=>$id]);
} else {
  http_response_code(500);
  echo json_encode(['success'=>false,'message'=>'Insert failed']);
}

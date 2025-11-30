<?php
require_once __DIR__ . '/config.php';
$mysqli = db_connect();

header('Content-Type: application/json; charset=utf-8');
$studentId = $_GET['student_id'] ?? '';
if ($studentId === '') { echo json_encode(['success'=>false,'error'=>'Missing student_id']); exit; }

$sql = "SELECT receipt_id, selections_text, selections_json, total_selections, created_at
        FROM vote_receipts
        WHERE student_id = ?
        ORDER BY created_at DESC, id DESC
        LIMIT 1";
if (!($stmt = $mysqli->prepare($sql))) {
  http_response_code(500);
  echo json_encode(['success'=>false,'error'=>'Prepare failed']);
  exit;
}
$stmt->bind_param('s', $studentId);
$stmt->execute();
$res = $stmt->get_result();
$row = $res->fetch_assoc();
$stmt->close();

if (!$row) { echo json_encode(['success'=>true, 'data'=>null]); exit; }

$sel = null;
if (!empty($row['selections_json'])) {
  $sel = json_decode($row['selections_json'], true);
}
if ($sel === null) {
  $sel = json_decode($row['selections_text'] ?? '[]', true) ?: [];
}

echo json_encode([
  'success' => true,
  'receipt_id' => $row['receipt_id'],
  'selections' => $sel,
  'total_selections' => (int)$row['total_selections'],
  'created_at' => $row['created_at'],
]);

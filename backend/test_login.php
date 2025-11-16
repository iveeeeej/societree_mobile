<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';
$out = ['ok'=>false,'err'=>null,'rows'=>null];
try {
  $mysqli = db_connect();
  $sql = 'SELECT id, student_id, role FROM users LIMIT 5';
  $res = @$mysqli->query($sql);
  if (!$res) {
    $out['err'] = $mysqli->error;
  } else {
    $rows = [];
    while ($r = $res->fetch_assoc()) { $rows[] = $r; }
    $res->close();
    $out['ok'] = true;
    $out['rows'] = $rows;
  }
  $mysqli->close();
} catch (Throwable $e) {
  $out['err'] = $e->getMessage();
}
echo json_encode($out);

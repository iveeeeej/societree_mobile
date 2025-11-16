<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';
$start = microtime(true);
$out = [
  'success' => false,
  'error' => null,
  'host' => isset($DB_HOST) ? $DB_HOST : null,
  'port' => isset($DB_PORT) ? $DB_PORT : null,
  'elapsed_ms' => 0,
];
try {
  $mysqli = @new mysqli($DB_HOST, $DB_USER, $DB_PASS, null, isset($DB_PORT)?$DB_PORT:null);
  if ($mysqli->connect_errno) {
    $out['error'] = $mysqli->connect_error;
  } else {
    $out['success'] = true;
    $out['server_info'] = $mysqli->server_info;
    $mysqli->close();
  }
} catch (Throwable $e) {
  $out['error'] = $e->getMessage();
}
$out['elapsed_ms'] = (int) round((microtime(true) - $start) * 1000);
http_response_code($out['success'] ? 200 : 500);
echo json_encode($out);

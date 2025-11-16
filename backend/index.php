<?php
header('Content-Type: application/json');
require_once __DIR__ . '/config.php';

$health = [
  'success' => true,
  'service' => 'centralized_societree backend',
  'version' => defined('CONFIG_SCHEMA_VERSION') ? constant('CONFIG_SCHEMA_VERSION') : '1.0',
  'time' => gmdate('c'),
  'db' => [
    'connected' => false,
    'error' => null,
  ],
  'endpoints' => [
    'login' => 'login.php',
    'register' => 'register.php',
    'register_candidate' => 'register_candidate.php',
    'update_candidate' => 'update_candidate.php',
    'delete_candidate' => 'delete_candidate.php',
    'delete_party' => 'delete_party.php',
    'get_parties' => 'get_parties.php',
    'get_candidates' => 'get_candidates.php',
    'get_party_logo' => 'get_party_logo.php',
    'get_candidate_photo' => 'get_candidate_photo.php',
    'test_db' => 'test_db.php'
  ]
];

try {
  $mysqli = @new mysqli($DB_HOST, $DB_USER, $DB_PASS, null, isset($DB_PORT)?$DB_PORT:null);
  if ($mysqli->connect_errno) {
    $health['db']['error'] = $mysqli->connect_error;
  } else {
    $health['db']['connected'] = true;
    $mysqli->close();
  }
} catch (Throwable $e) {
  $health['db']['error'] = $e->getMessage();
}

echo json_encode($health);

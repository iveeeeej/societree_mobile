<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
// Prevent PHP notices/warnings from polluting JSON responses
@ini_set('display_errors', '0');
@error_reporting(0);
// Emit JSON on fatal errors to aid debugging of empty-body 500s
register_shutdown_function(function () {
  $err = error_get_last();
  if ($err && in_array($err['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
    if (!headers_sent()) {
      header('Content-Type: application/json');
    }
    http_response_code(500);
    $msg = 'Server fatal error';
    $detail = isset($err['message']) ? ($err['message'] . ' in ' . ($err['file'] ?? '') . ':' . ($err['line'] ?? '')) : 'fatal';
    echo json_encode([
      'success' => false,
      'message' => $msg . ': ' . $detail,
      'error' => $detail,
      'type' => $err['type'] ?? null,
      'file' => $err['file'] ?? null,
      'line' => $err['line'] ?? null,
    ]);
  }
});
// Ensure updated code is loaded even if OPcache is enabled (safe no-op otherwise)
if (function_exists('opcache_reset')) { @opcache_reset(); }
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit();
}

$DB_HOST = '103.252.118.161';
$DB_USER = 'root';
$DB_PASS = 'ustpServer123!';
$DB_NAME = 'societree_app';
$DB_PORT = 3306;

// Bump this when schema-migration logic changes, so we can verify deployment
define('CONFIG_SCHEMA_VERSION', '2.0-compat-migrations');

function db_connect() {
  global $DB_HOST, $DB_USER, $DB_PASS, $DB_NAME, $DB_PORT;
  $mysqli = new mysqli($DB_HOST, $DB_USER, $DB_PASS, null, $DB_PORT);
  if ($mysqli->connect_error) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'DB connection failed: ' . $mysqli->connect_error]);
    exit();
  }
  // Ensure database exists
  if (!$mysqli->query("CREATE DATABASE IF NOT EXISTS `$DB_NAME` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed creating database']);
    exit();
  }
  $mysqli->select_db($DB_NAME);

  // Ensure users table exists (supports student_id, role, department, position)
  $create = "CREATE TABLE IF NOT EXISTS users (
      id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      student_id VARCHAR(64) UNIQUE,
      password_hash VARCHAR(255) NOT NULL,
      role VARCHAR(32) NOT NULL DEFAULT 'user',
      department VARCHAR(128) NULL,
      position VARCHAR(128) NULL,
      phone VARCHAR(32) NULL,
      email VARCHAR(255) NULL,
      otp_code VARCHAR(16) NULL,
      otp_expires_at DATETIME NULL,
      terms_accepted_at DATETIME NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
  if (!$mysqli->query($create)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed creating table']);
    exit();
  }

  // Ensure votes table exists (one vote per student for direct voting)
  $createVotes = "CREATE TABLE IF NOT EXISTS votes (
      id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      student_id VARCHAR(64) NOT NULL UNIQUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
  if (!$mysqli->query($createVotes)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed creating votes table']);
    exit();
  }

  // Ensure vote_items table exists (one selection per position)
  $createVoteItems = "CREATE TABLE IF NOT EXISTS vote_items (
      id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
      vote_id INT UNSIGNED NOT NULL,
      position VARCHAR(128) NOT NULL,
      candidate_id INT UNSIGNED NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE KEY uniq_vote_position (vote_id, position),
      CONSTRAINT fk_vote_items_vote FOREIGN KEY (vote_id) REFERENCES votes(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
  if (!$mysqli->query($createVoteItems)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Failed creating vote_items table']);
    exit();
  }

  // Helpers to check column and index existence for compatibility (older MySQL/MariaDB)
  $dbNameEsc = $mysqli->real_escape_string($DB_NAME);
  $hasColumn = function($m, $table, $col) use ($dbNameEsc) {
    $t = $m->real_escape_string($table);
    $c = $m->real_escape_string($col);
    $sql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='{$dbNameEsc}' AND TABLE_NAME='{$t}' AND COLUMN_NAME='{$c}' LIMIT 1";
    if ($res = @$m->query($sql)) { $ok = $res->num_rows > 0; $res->close(); return $ok; }
    return false;
  };
  $hasIndex = function($m, $table, $index) use ($dbNameEsc) {
    $t = $m->real_escape_string($table);
    $i = $m->real_escape_string($index);
    $sql = "SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA='{$dbNameEsc}' AND TABLE_NAME='{$t}' AND INDEX_NAME='{$i}' LIMIT 1";
    if ($res = @$m->query($sql)) { $ok = $res->num_rows > 0; $res->close(); return $ok; }
    return false;
  };

  // Ensure expected columns/index exist without using IF NOT EXISTS
  if (!$hasColumn($mysqli, 'users', 'student_id')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN student_id VARCHAR(64) NULL");
  }
  if (!$hasIndex($mysqli, 'users', 'idx_users_student_id')) {
    @$mysqli->query("CREATE UNIQUE INDEX idx_users_student_id ON users (student_id)");
  }
  if (!$hasColumn($mysqli, 'users', 'role')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN role VARCHAR(32) NOT NULL DEFAULT 'user'");
  }
  if (!$hasColumn($mysqli, 'users', 'department')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN department VARCHAR(128) NULL");
  }
  if (!$hasColumn($mysqli, 'users', 'position')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN position VARCHAR(128) NULL");
  }
  if (!$hasColumn($mysqli, 'users', 'phone')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN phone VARCHAR(32) NULL");
  }
  if (!$hasColumn($mysqli, 'users', 'email')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN email VARCHAR(255) NULL");
  }
  if (!$hasColumn($mysqli, 'users', 'otp_code')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN otp_code VARCHAR(16) NULL");
  }
  if (!$hasColumn($mysqli, 'users', 'otp_expires_at')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN otp_expires_at DATETIME NULL");
  }
  if (!$hasColumn($mysqli, 'users', 'terms_accepted_at')) {
    @$mysqli->query("ALTER TABLE users ADD COLUMN terms_accepted_at DATETIME NULL");
  }

  // Ensure candidates_registration has votes tally column
  if ($hasColumn($mysqli, 'candidates_registration', 'id')) {
    if (!$hasColumn($mysqli, 'candidates_registration', 'votes')) {
      @$mysqli->query("ALTER TABLE candidates_registration ADD COLUMN votes INT NOT NULL DEFAULT 0");
    }
  }

  // Seed/ensure default admin user
  $defaultId = '2023304637';
  $defaultPass = '12345678';
  $defaultPassHash = password_hash($defaultPass, PASSWORD_BCRYPT);
  if ($stmt = $mysqli->prepare('SELECT id, password_hash FROM users WHERE student_id = ?')) {
    $stmt->bind_param('s', $defaultId);
    $stmt->execute();
    $stmt->bind_result($uid, $phash);
    if ($stmt->fetch()) {
      $stmt->close();
      // Update password if needed and ensure role/department are correct
      if (!password_verify($defaultPass, $phash)) {
        if ($upd = $mysqli->prepare('UPDATE users SET password_hash = ? WHERE student_id = ?')) {
          $upd->bind_param('ss', $defaultPassHash, $defaultId);
          $upd->execute();
          $upd->close();
        }
      }
      if ($upd2 = $mysqli->prepare("UPDATE users SET role = 'admin', department = 'BSIT', position = 'ElecomChairPerson', phone = '09534181760', email = 'rpsvcodes@gmail.com' WHERE student_id = ? AND (
          role <> 'admin' OR role IS NULL OR
          department <> 'BSIT' OR department IS NULL OR
          position <> 'ElecomChairPerson' OR position IS NULL OR
          phone IS NULL OR phone = '' OR
          email IS NULL OR email = ''
        )")) {
        $upd2->bind_param('s', $defaultId);
        $upd2->execute();
        $upd2->close();
      }
    } else {
      $stmt->close();
      if ($ins = $mysqli->prepare("INSERT INTO users (student_id, password_hash, role, department, position, phone, email) VALUES (?, ?, 'admin', 'BSIT', 'ElecomChairPerson', '09534181760', 'rpsvcodes@gmail.com')")) {
        $ins->bind_param('ss', $defaultId, $defaultPassHash);
        $ins->execute();
        $ins->close();
      }
    }
  }

  return $mysqli;
}

function read_json_body() {
  $raw = file_get_contents('php://input');
  if ($raw === false) { return null; }
  $raw = ltrim($raw);
  if (strncmp($raw, "\xEF\xBB\xBF", 3) === 0) {
    $raw = substr($raw, 3);
  }
  if ($raw === '' || $raw === null) { return null; }
  $data = json_decode($raw, true);
  if (json_last_error() !== JSON_ERROR_NONE || !is_array($data)) {
    return null;
  }
  return $data;
}

define('CLOUDINARY_CLOUD', 'dhhzkqmso');
define('CLOUDINARY_KEY', '871914741883427');
define('CLOUDINARY_SECRET', 'ihwwUCjI92s8tBpm24Vqj2CIWJk');

function cloudinary_upload($filePath, $folder, $publicId = '') {
  if (!is_file($filePath)) { return [false, null, 'file']; }
  $cloud = CLOUDINARY_CLOUD; $key = CLOUDINARY_KEY; $secret = CLOUDINARY_SECRET;
  if (!$cloud || !$key || !$secret) { return [false, null, 'config']; }
  $url = 'https://api.cloudinary.com/v1_1/' . $cloud . '/image/upload';
  $timestamp = time();
  $params = ['folder' => $folder, 'timestamp' => $timestamp];
  if ($publicId !== '') { $params['public_id'] = $publicId; }
  ksort($params);
  $toSign = '';
  foreach ($params as $k => $v) { if ($toSign !== '') { $toSign .= '&'; } $toSign .= $k . '=' . $v; }
  $signature = sha1($toSign . $secret);
  $post = [
    'api_key' => $key,
    'timestamp' => $timestamp,
    'signature' => $signature,
    'folder' => $folder,
  ];
  if ($publicId !== '') { $post['public_id'] = $publicId; }
  if (function_exists('curl_file_create')) {
    $post['file'] = curl_file_create($filePath);
  } else {
    $post['file'] = '@' . $filePath;
  }
  $ch = curl_init($url);
  curl_setopt($ch, CURLOPT_POST, true);
  curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  $res = curl_exec($ch);
  if ($res === false) { $err = curl_error($ch); curl_close($ch); return [false, null, $err ?: 'curl']; }
  $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
  curl_close($ch);
  $data = json_decode($res, true);
  if ($code >= 200 && $code < 300 && isset($data['secure_url'])) { return [true, $data['secure_url'], null]; }
  return [false, null, isset($data['error']['message']) ? $data['error']['message'] : 'upload'];
}

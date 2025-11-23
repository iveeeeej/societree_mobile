<?php
require_once __DIR__ . '/config.php';
$mysqli = db_connect();

function respond($ok, $msg = '', $extra = []) {
  header('Content-Type: application/json');
  echo json_encode(array_merge(['success' => $ok, 'message' => $msg], $extra));
  exit;
}

// Accept form-encoded or raw JSON
$student_id = $_POST['student_id'] ?? '';
$selectionsRaw = $_POST['selections'] ?? '';
if (!$student_id || !$selectionsRaw) {
  $body = read_json_body();
  if (is_array($body)) {
    $student_id = $student_id ?: ($body['student_id'] ?? '');
    $selectionsRaw = $selectionsRaw ?: ($body['selections'] ?? '');
  }
}

if (!$student_id || !$selectionsRaw) {
  respond(false, 'Missing parameters');
}

// selections may already be an array or JSON string
$selections = is_array($selectionsRaw) ? $selectionsRaw : json_decode((string)$selectionsRaw, true);
if (!is_array($selections)) {
  respond(false, 'Invalid selections');
}

// Safety: ensure schema exists in case config bootstrap didn't run yet for this request
$ddl1 = "CREATE TABLE IF NOT EXISTS votes (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  student_id VARCHAR(64) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
if (!$mysqli->query($ddl1)) { respond(false, 'Failed to ensure votes table'); }

$ddl2 = "CREATE TABLE IF NOT EXISTS vote_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  vote_id INT UNSIGNED NOT NULL,
  position VARCHAR(128) NOT NULL,
  candidate_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_vote_position (vote_id, position),
  CONSTRAINT fk_vote_items_vote FOREIGN KEY (vote_id) REFERENCES votes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
if (!$mysqli->query($ddl2)) { respond(false, 'Failed to ensure vote_items table'); }

// Optional tally column (guarded to avoid duplicate-column fatal errors)
try {
  if ($chk = @$mysqli->query("SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'candidates_registration' AND COLUMN_NAME = 'votes' LIMIT 1")) {
    $exists = $chk->num_rows > 0; $chk->close();
    if (!$exists) { @ $mysqli->query("ALTER TABLE candidates_registration ADD COLUMN votes INT NOT NULL DEFAULT 0"); }
  }
} catch (Exception $e) { /* ignore */ }

$mysqli->begin_transaction();
try {
  // Guard: one vote per student
  if ($stmt = $mysqli->prepare('SELECT id FROM votes WHERE student_id = ? LIMIT 1')) {
    $stmt->bind_param('s', $student_id);
    $stmt->execute();
    $stmt->bind_result($existing_id);
    if ($stmt->fetch()) {
      $stmt->close();
      $mysqli->rollback();
      respond(false, 'Already voted');
    }
    $stmt->close();
  } else {
    throw new Exception('Prepare select failed');
  }

  // Insert vote header
  if (!($ins = $mysqli->prepare('INSERT INTO votes (student_id) VALUES (?)'))) {
    throw new Exception('Prepare insert vote failed');
  }
  $ins->bind_param('s', $student_id);
  if (!$ins->execute()) {
    $ins->close();
    throw new Exception('Insert vote failed');
  }
  $vote_id = $ins->insert_id;
  $ins->close();

  // Prepare statements
  $itemStmt = $mysqli->prepare('INSERT INTO vote_items (vote_id, position, candidate_id) VALUES (?, ?, ?)');
  if (!$itemStmt) throw new Exception('Prepare insert item failed');
  $incStmt  = $mysqli->prepare('UPDATE candidates_registration SET votes = votes + 1 WHERE id = ?');
  if (!$incStmt) throw new Exception('Prepare update tally failed');

  foreach ($selections as $position => $candidateId) {
    $pos = trim((string)$position);
    $cid = (int)$candidateId;
    if ($pos === '' || $cid <= 0) continue;

    $itemStmt->bind_param('isi', $vote_id, $pos, $cid);
    if (!$itemStmt->execute()) throw new Exception('Insert vote item failed');

    $incStmt->bind_param('i', $cid);
    if (!$incStmt->execute()) throw new Exception('Update candidate tally failed');
  }
  $itemStmt->close();
  $incStmt->close();

  $mysqli->commit();
  respond(true, 'Vote saved', ['vote_id' => $vote_id]);
} catch (Exception $e) {
  $mysqli->rollback();
  respond(false, 'Server error: ' . $e->getMessage());
}

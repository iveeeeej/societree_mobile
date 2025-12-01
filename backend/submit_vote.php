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

// Accurate tally table for results (maintained automatically)
$ddl3 = "CREATE TABLE IF NOT EXISTS vote_results (
  candidate_id INT UNSIGNED NOT NULL,
  position VARCHAR(128) NOT NULL,
  votes INT NOT NULL DEFAULT 0,
  PRIMARY KEY (candidate_id),
  KEY idx_position (position)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
if (!$mysqli->query($ddl3)) { respond(false, 'Failed to ensure vote_results table'); }

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
      // Try to return latest receipt if available to help client proceed
      if ($q = $mysqli->prepare("SELECT receipt_id FROM vote_receipts WHERE student_id = ? ORDER BY created_at DESC, id DESC LIMIT 1")) {
        $q->bind_param('s', $student_id);
        if ($q->execute()) {
          $q->bind_result($rid);
          if ($q->fetch()) {
            $q->close();
            respond(false, 'Already voted', ['receipt_id' => $rid, 'rid' => $rid]);
          }
        }
        $q->close();
      }
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

    // Also update accurate tally table atomically
    $up = $mysqli->prepare('INSERT INTO vote_results (candidate_id, position, votes) VALUES (?, ?, 1) ON DUPLICATE KEY UPDATE votes = votes + 1, position = VALUES(position)');
    if ($up) {
      $up->bind_param('is', $cid, $pos);
      if (!$up->execute()) { $up->close(); throw new Exception('Update results tally failed'); }
      $up->close();
    } else {
      throw new Exception('Prepare results tally failed');
    }
  }
  $itemStmt->close();
  $incStmt->close();

  // Create a receipt record for quick retrieval
  $receipt_id = 'R' . bin2hex(random_bytes(8));
  $ip = $_SERVER['REMOTE_ADDR'] ?? null;
  $ua = $_SERVER['HTTP_USER_AGENT'] ?? null;
  $total = count($selections);
  $json = json_encode($selections, JSON_UNESCAPED_UNICODE);
  // Try JSON column first; fallback to text only if needed
  if ($insr = $mysqli->prepare('INSERT INTO vote_receipts (receipt_id, student_id, selections_json, selections_text, total_selections, ip_address, user_agent) VALUES (?, ?, CAST(? AS JSON), ?, ?, ?, ?)')) {
    $insr->bind_param('ssssiss', $receipt_id, $student_id, $json, $json, $total, $ip, $ua);
    @$insr->execute();
    $insr->close();
  } else if ($insr2 = $mysqli->prepare('INSERT INTO vote_receipts (receipt_id, student_id, selections_text, total_selections, ip_address, user_agent) VALUES (?, ?, ?, ?, ?, ?)')) {
    $insr2->bind_param('sssiss', $receipt_id, $student_id, $json, $total, $ip, $ua);
    @$insr2->execute();
    $insr2->close();
  }

  // Server-side user notification: inform the student their vote was recorded
  @ $mysqli->query("CREATE TABLE IF NOT EXISTS user_notifications (
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
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
  // Migration: add receipt_id column and unique index on existing installations
  try {
    if ($chk = @$mysqli->query("SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_notifications' AND COLUMN_NAME = 'receipt_id' LIMIT 1")) {
      $hasCol = $chk->num_rows > 0; $chk->close();
      if (!$hasCol) { @ $mysqli->query("ALTER TABLE user_notifications ADD COLUMN receipt_id VARCHAR(64) NULL"); }
    }
    if ($idx = @$mysqli->query("SHOW INDEX FROM user_notifications WHERE Key_name = 'uniq_student_receipt'")) {
      $hasIdx = $idx->num_rows > 0; $idx->close();
      if (!$hasIdx) { @ $mysqli->query("ALTER TABLE user_notifications ADD UNIQUE KEY uniq_student_receipt (student_id, receipt_id)"); }
    }
  } catch (Exception $e) { /* ignore */ }
  if ($n = $mysqli->prepare('INSERT INTO user_notifications (student_id, receipt_id, type, title, body) VALUES (?, ?, "success", "Vote submitted", ?) ON DUPLICATE KEY UPDATE id = id')) {
    $nb = 'Your vote has been recorded. Receipt: ' . $receipt_id;
    $n->bind_param('sss', $student_id, $receipt_id, $nb);
    @$n->execute();
    $n->close();
  }

  $mysqli->commit();
  respond(true, 'Vote saved', ['vote_id' => $vote_id, 'receipt_id' => $receipt_id]);
} catch (Exception $e) {
  $mysqli->rollback();
  respond(false, 'Server error: ' . $e->getMessage());
}

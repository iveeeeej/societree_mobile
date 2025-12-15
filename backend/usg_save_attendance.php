<?php
require_once 'config.php';

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$data = read_json_body();

// Log the incoming request for debugging
error_log("Attendance save request: " . print_r($data, true));

if (!$data || !isset($data['id_number'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false, 
        'message' => 'Missing required fields (id_number)',
        'received_data' => $data
    ]);
    exit();
}

$mysqli = db_connect();

// Extract and sanitize data
$idNumber = $mysqli->real_escape_string($data['id_number']);
$firstName = isset($data['first_name']) ? $mysqli->real_escape_string($data['first_name']) : '';
$lastName = isset($data['last_name']) ? $mysqli->real_escape_string($data['last_name']) : '';
$course = isset($data['course']) ? $mysqli->real_escape_string($data['course']) : '';
$year = isset($data['year']) ? intval($data['year']) : 0;
$section = isset($data['section']) ? $mysqli->real_escape_string($data['section']) : '';
$role = isset($data['role']) ? $mysqli->real_escape_string($data['role']) : 'student';

// Validate required fields
if (empty($firstName) || empty($lastName) || empty($course)) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing student information: first_name, last_name, or course'
    ]);
    $mysqli->close();
    exit();
}

// Check if already attended
$checkSql = "SELECT id_number FROM usg_attendace WHERE id_number = '$idNumber'";
$checkResult = $mysqli->query($checkSql);

if ($checkResult && $checkResult->num_rows > 0) {
    // Student already attended
    echo json_encode([
        'success' => false, // Changed to false to indicate duplicate
        'message' => 'Attendance already recorded for this student',
        'id_number' => $idNumber
    ]);
} else {
    // Insert new attendance record - ALL columns match your table schema
    $insertSql = "INSERT INTO usg_attendace (id_number, first_name, last_name, course, year, section, role) 
                  VALUES ('$idNumber', '$firstName', '$lastName', '$course', $year, '$section', '$role')";
    
    error_log("Insert SQL: $insertSql"); // Debug logging
    
    if ($mysqli->query($insertSql)) {
        echo json_encode([
            'success' => true,
            'message' => 'Attendance recorded successfully',
            'id_number' => $idNumber,
            'name' => "$firstName $lastName"
        ]);
    } else {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Failed to record attendance',
            'sql_error' => $mysqli->error,
            'sql_query' => $insertSql
        ]);
    }
}

$mysqli->close();
?>
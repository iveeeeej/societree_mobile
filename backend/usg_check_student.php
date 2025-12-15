<?php
require_once 'config.php';

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$data = read_json_body();

// Log the request for debugging
error_log("Check student request: " . print_r($data, true));

if (!$data || !isset($data['id_number'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false, 
        'message' => 'Missing id_number',
        'received_data' => $data
    ]);
    exit();
}

$mysqli = db_connect();
$idNumber = $mysqli->real_escape_string($data['id_number']);

// Check if student exists in student table
$sql = "SELECT * FROM student WHERE id_number = '$idNumber'";
error_log("Check SQL: $sql"); // Debug

$result = $mysqli->query($sql);

if ($result && $result->num_rows > 0) {
    $student = $result->fetch_assoc();
    
    // Log found student
    error_log("Student found: " . print_r($student, true));
    
    echo json_encode([
        'success' => true,
        'student' => $student
    ]);
} else {
    // Log not found
    error_log("Student not found with ID: $idNumber");
    
    echo json_encode([
        'success' => false,
        'message' => 'Student not found in records'
    ]);
}

$mysqli->close();
?>
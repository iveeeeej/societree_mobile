<?php
require_once __DIR__ . '/config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed. Only POST requests are accepted.'
    ]);
    exit();
}

// Get the request body
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Validate JSON
if (json_last_error() !== JSON_ERROR_NONE || $data === null) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid JSON data'
    ]);
    exit();
}

// Check if student_id is provided
if (!isset($data['student_id']) || empty(trim($data['student_id']))) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Student ID is required'
    ]);
    exit();
}

$student_id = trim($data['student_id']);
$mysqli = db_connect();

// Prepare and execute query
$stmt = $mysqli->prepare('
    SELECT 
        id_number,
        first_name,
        middle_name,
        last_name,
        course,
        year,
        section,
        email,
        phone_number,
        role
    FROM student 
    WHERE id_number = ?
');

if (!$stmt) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error (prepare)',
        'error' => $mysqli->error
    ]);
    $mysqli->close();
    exit();
}

$stmt->bind_param('s', $student_id);
$stmt->execute();
$stmt->store_result();

// Check if student exists
if ($stmt->num_rows === 0) {
    $stmt->close();
    $mysqli->close();
    
    echo json_encode([
        'success' => false,
        'message' => 'Student not found',
        'student_id' => $student_id
    ]);
    exit();
}

// Bind result variables
$stmt->bind_result(
    $id_number,
    $first_name,
    $middle_name,
    $last_name,
    $course,
    $year,
    $section,
    $email,
    $phone_number,
    $role
);

// Fetch the data
$stmt->fetch();
$stmt->close();
$mysqli->close();

// Prepare response data
$student_data = [
    'id_number' => $id_number,
    'first_name' => $first_name,
    'middle_name' => $middle_name,
    'last_name' => $last_name,
    'course' => $course,
    'year' => $year,
    'section' => $section,
    'email' => $email,
    'phone_number' => $phone_number,
    'role' => $role,
    'full_name' => trim("$first_name " . ($middle_name ? "$middle_name " : "") . $last_name)
];

// Return success response
echo json_encode([
    'success' => true,
    'message' => 'Student profile retrieved successfully',
    'student' => $student_data
]);
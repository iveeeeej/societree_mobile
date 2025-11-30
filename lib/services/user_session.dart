class UserSession {
  static String? studentId;
  static String? role;
  static String? department;
  static String? position;
  static String? lastReceiptId;
  static Map<String, String>? lastReceiptSelections;
  static String? lastReceiptStudentId;

  static void setFromResponse(Map<String, dynamic> res) {
    final newId = (res['student_id'] ?? res['studentId'] ?? res['id'] ?? '').toString();
    final oldId = studentId;
    studentId = newId;
    role = (res['role'] ?? '').toString();
    department = (res['department'] ?? '').toString();
    position = (res['position'] ?? '').toString();
    if (oldId != null && oldId != newId) {
      // Clear any cached receipt from a different account
      lastReceiptId = null;
      lastReceiptSelections = null;
      lastReceiptStudentId = null;
    }
  }

  static void clear() {
    studentId = null;
    role = null;
    department = null;
    position = null;
    lastReceiptId = null;
    lastReceiptSelections = null;
    lastReceiptStudentId = null;
  }

  static void setLastReceipt({required String receiptId, required Map<String, String> selections}) {
    lastReceiptId = receiptId;
    lastReceiptSelections = Map<String, String>.from(selections);
    // Tie the cached receipt to the currently logged-in student
    lastReceiptStudentId = studentId;
  }
}

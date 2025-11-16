class UserSession {
  static String? role;
  static String? department;
  static String? position;

  static void setFromResponse(Map<String, dynamic> res) {
    role = (res['role'] ?? '').toString();
    department = (res['department'] ?? '').toString();
    position = (res['position'] ?? '').toString();
  }

  static void clear() {
    role = null;
    department = null;
    position = null;
  }
}

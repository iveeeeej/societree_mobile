import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IMPORTANT: Replace this with your actual server URL
  // Using your computer's IP address so phone can connect
  // When uploaded to server, change to: 'http://103.125.219.236/backend_examples/api'
  static const String baseUrl = 'http://192.168.101.10/backend_examples/api';
  
  // Get all events
  static Future<List<dynamic>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events.php?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load events');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Get all clubs
  static Future<List<dynamic>> getClubs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clubs.php?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load clubs');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Get all announcements
  static Future<List<dynamic>> getAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements.php?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load announcements');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching announcements: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Submit feedback
  static Future<bool> submitFeedback(String name, String email, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'message': message,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }
  
  // Get messages for a user
  static Future<Map<String, dynamic>> getMessages(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'messages': data['data'],
            'unread_count': data['unread_count'],
          };
        } else {
          throw Exception('Failed to load messages');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Error: $e');
    }
  }
  
  // Mark message as read
  static Future<bool> markMessageAsRead(int messageId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message_id': messageId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking message as read: $e');
      return false;
    }
  }
  
  // Delete message
  static Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/messages.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message_id': messageId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }
  
  // Submit club application
  static Future<bool> submitClubApplication({
    required String userId,
    required int clubId,
    required String fullName,
    required String email,
    String? phone,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/club_applications.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'club_id': clubId,
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'reason': reason,
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error submitting application: $e');
      return false;
    }
  }
  
  // Get user's club applications
  static Future<List<dynamic>> getClubApplications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/club_applications.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception('Failed to load applications');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching applications: $e');
      throw Exception('Error: $e');
    }
  }
}

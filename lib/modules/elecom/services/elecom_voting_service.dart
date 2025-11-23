import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:centralized_societree/config/api_config.dart';

class ElecomVotingService {
  static Future<List<Map<String, dynamic>>> getElections(String studentId) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/get_elections.php?student_id=${Uri.encodeComponent(studentId)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      final decoded = decodeJson(res.body);
      final List<dynamic> list = extractList(decoded, keys: ['elections', 'data', 'items']);
      return list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    } catch (_) {
      return [];
    }
  }

  // Direct voting (no election id). Server should accept student_id and selections JSON
  static Future<(bool ok, String message)> submitDirectVote(String studentId, Map<String, String> selections) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/submit_vote.php');
      final body = {
        'student_id': studentId,
        'selections': jsonEncode(selections),
      };
      final res = await http.post(uri, body: body).timeout(const Duration(seconds: 15));
      final decoded = decodeJson(res.body);
      if (decoded is Map<String, dynamic>) {
        final ok = decoded['success'] ?? decoded['ok'] ?? decoded['status'];
        String msg = (decoded['message'] ?? decoded['error'] ?? '').toString();
        if (ok is bool) return (ok, msg.isNotEmpty ? msg : (ok ? 'OK' : 'Failed'));
        if (ok is num) return (ok != 0, msg.isNotEmpty ? msg : ((ok != 0) ? 'OK' : 'Failed'));
        if (ok is String) {
          final success = ok == '1' || ok.toLowerCase() == 'true' || ok.toLowerCase() == 'success';
          return (success, msg.isNotEmpty ? msg : (success ? 'OK' : 'Failed'));
        }
      }
      // Debug: print server response to help diagnose failures
      // ignore: avoid_print
      print('[submitDirectVote] HTTP ${res.statusCode}: ${res.body}');
      return (false, 'HTTP ${res.statusCode}');
    } catch (e) {
      return (false, 'Network error');
    }
  }

  static Future<(List<Map<String, String>>, List<Map<String, String>>)> getPositionsAndCandidates(String electionId) async {
    try {
      final posUri = Uri.parse('$apiBaseUrl/get_election_positions.php?election_id=${Uri.encodeComponent(electionId)}');
      final candUri = Uri.parse('$apiBaseUrl/get_election_candidates.php?election_id=${Uri.encodeComponent(electionId)}');
      final posRes = await http.get(posUri).timeout(const Duration(seconds: 12));
      final candRes = await http.get(candUri).timeout(const Duration(seconds: 12));
      final posDecoded = decodeJson(posRes.body);
      final candDecoded = decodeJson(candRes.body);
      final posList = extractList(posDecoded, keys: ['positions', 'data', 'items']);
      final candList = extractList(candDecoded, keys: ['candidates', 'data', 'items']);
      final positions = posList.map((p) => {
            'id': (p['id'] ?? p['position_id'] ?? p['pid'] ?? '').toString(),
            'name': (p['name'] ?? p['position'] ?? '').toString(),
          }).where((m) => m['id']!.isNotEmpty).toList();
      final candidates = candList.map((c) => {
            'id': (c['id'] ?? c['candidate_id'] ?? c['cid'] ?? '').toString(),
            'name': (c['name'] ?? c['candidate_name'] ?? '').toString(),
            'position_id': (c['position_id'] ?? c['pid'] ?? '').toString(),
            'position': (c['position'] ?? c['position_name'] ?? '').toString(),
            'photoUrl': (c['photo'] ?? c['photoUrl'] ?? c['image'] ?? c['img_url'])?.toString() ?? '',
            'party': (c['party_name'] ?? c['party'] ?? c['organization'])?.toString() ?? '',
          }).where((m) => m['id']!.isNotEmpty && m['position_id']!.isNotEmpty).toList();
      return (positions, candidates);
    } catch (_) {
      return (const <Map<String, String>>[], const <Map<String, String>>[]);
    }
  }

  static Future<bool> checkAlreadyVoted(String electionId, String studentId) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/check_already_voted.php?election_id=${Uri.encodeComponent(electionId)}&student_id=${Uri.encodeComponent(studentId)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      final decoded = decodeJson(res.body);
      if (decoded is Map<String, dynamic>) {
        final v = decoded['already_voted'] ?? decoded['voted'] ?? decoded['data'];
        if (v is bool) return v;
        if (v is num) return v != 0;
        if (v is String) return v == '1' || v.toLowerCase() == 'true';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<(bool ok, String message)> submitFinalVote(String electionId, String studentId, Map<String, String> selections) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/submit_vote.php');
      final body = {
        'election_id': electionId,
        'student_id': studentId,
        'selections': jsonEncode(selections),
      };
      final res = await http.post(uri, body: body).timeout(const Duration(seconds: 15));
      final decoded = decodeJson(res.body);
      if (decoded is Map<String, dynamic>) {
        final ok = decoded['success'] ?? decoded['ok'] ?? decoded['status'];
        String msg = (decoded['message'] ?? decoded['error'] ?? '').toString();
        if (ok is bool) return (ok, msg.isNotEmpty ? msg : (ok ? 'OK' : 'Failed'));
        if (ok is num) return (ok != 0, msg.isNotEmpty ? msg : ((ok != 0) ? 'OK' : 'Failed'));
        if (ok is String) {
          final success = ok == '1' || ok.toLowerCase() == 'true' || ok.toLowerCase() == 'success';
          return (success, msg.isNotEmpty ? msg : (success ? 'OK' : 'Failed'));
        }
      }
      // Debug: print server response to help diagnose failures
      // ignore: avoid_print
      print('[submitFinalVote] HTTP ${res.statusCode}: ${res.body}');
      return (false, 'HTTP ${res.statusCode}');
    } catch (_) {
      return (false, 'Network error');
    }
  }

  static Future<List<Map<String, dynamic>>> getVotingStatus(String studentId) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/get_voting_status.php?student_id=${Uri.encodeComponent(studentId)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      final decoded = decodeJson(res.body);
      final List<dynamic> list = extractList(decoded, keys: ['status', 'data', 'items']);
      return list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    } catch (_) {
      return [];
    }
  }

  static dynamic decodeJson(String body) {
    try { return jsonDecode(body); } catch (_) { return {}; }
  }
  static List<dynamic> extractList(dynamic decoded, {required List<String> keys}) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final k in keys) {
        final v = decoded[k];
        if (v is List) return v;
      }
    }
    return const [];
  }
}

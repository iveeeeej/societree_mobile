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

  // Admin: reset all votes (clears votes and vote_items tables)
  static Future<(bool ok, String message)> resetVotes() async {
    try {
      final uri = Uri.parse('$apiBaseUrl/reset_votes.php');
      final res = await http.post(uri).timeout(const Duration(seconds: 15));
      final decoded = decodeJson(res.body);
      if (decoded is Map<String, dynamic>) {
        final ok = decoded['success'] ?? decoded['ok'] ?? decoded['status'];
        final msg = (decoded['message'] ?? decoded['error'] ?? '').toString();
        if (ok is bool) return (ok, msg.isNotEmpty ? msg : (ok ? 'OK' : 'Failed'));
        if (ok is num) return (ok != 0, msg.isNotEmpty ? msg : ((ok != 0) ? 'OK' : 'Failed'));
        if (ok is String) {
          final success = ok == '1' || ok.toLowerCase() == 'true' || ok.toLowerCase() == 'success';
          return (success, msg.isNotEmpty ? msg : (success ? 'OK' : 'Failed'));
        }
      }
      return (false, 'HTTP ${res.statusCode}');
    } catch (_) {
      return (false, 'Network error');
    }
  }

  // Direct voting (no election id). Server should accept student_id and selections JSON
  static Future<(bool ok, String message, String? receiptId)> submitDirectVote(String studentId, Map<String, String> selections) async {
    // Quick validation
    if (studentId.isEmpty || selections.isEmpty) {
      return (false, 'Missing data', null);
    }

    // Retry with exponential backoff to handle slow/unstable connections
    final attempts = [Duration(milliseconds: 0), const Duration(milliseconds: 900), const Duration(milliseconds: 1800)];
    for (var i = 0; i < attempts.length; i++) {
      if (attempts[i].inMilliseconds > 0) {
        await Future.delayed(attempts[i]);
      }
      try {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final uri = Uri.parse('$apiBaseUrl/submit_vote.php?_t=$ts');
        final body = {
          'student_id': studentId,
          'selections': jsonEncode(selections),
        };
        final headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json, text/plain, */*',
        };
        final res = await http
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 25));

        final decoded = decodeJson(res.body);
        if (decoded is Map<String, dynamic>) {
          final ok = decoded['success'] ?? decoded['ok'] ?? decoded['status'];
          String msg = (decoded['message'] ?? decoded['error'] ?? '').toString();
          String? voteId = (decoded['vote_id'] ?? decoded['id'])?.toString();
          if (ok is bool) return (ok, msg.isNotEmpty ? msg : (ok ? 'OK' : 'Failed'), voteId);
          if (ok is num) return (ok != 0, msg.isNotEmpty ? msg : ((ok != 0) ? 'OK' : 'Failed'), voteId);
          if (ok is String) {
            final success = ok == '1' || ok.toLowerCase() == 'true' || ok.toLowerCase() == 'success';
            return (success, msg.isNotEmpty ? msg : (success ? 'OK' : 'Failed'), voteId);
          }
        }

        // Debug aid
        // ignore: avoid_print
        print('[submitDirectVote] HTTP ${res.statusCode}: ${res.body}');
        // If server responded but format unexpected, don't retry endlessly
        if (res.statusCode >= 400 && res.statusCode < 500) {
          return (false, 'HTTP ${res.statusCode}', null);
        }
        // Otherwise fallthrough to retry
      } catch (_) {
        // Will retry on next loop iteration
      }
    }
    return (false, 'Network error', null);
  }

  // Direct check if student already voted (no election id)
  static Future<bool> checkAlreadyVotedDirect(String studentId) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/check_already_voted.php?student_id=${Uri.encodeComponent(studentId)}');
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

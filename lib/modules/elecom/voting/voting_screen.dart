import 'package:flutter/material.dart';
import 'package:centralized_societree/services/user_session.dart';
import 'package:centralized_societree/modules/elecom/student_dashboard/services/student_dashboard_service.dart';
import 'package:centralized_societree/modules/elecom/services/elecom_voting_service.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _candidates = const [];
  final Map<String, String> _selections = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await StudentDashboardService.loadCandidates();
      if (!mounted) return;
      setState(() {
        _candidates = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load candidates')));
    }
  }

  Future<void> _submit() async {
    final sid = UserSession.studentId ?? '';
    if (sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to vote.')));
      return;
    }
    final (ok, msg) = await ElecomVotingService.submitDirectVote(sid, _selections);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote submitted successfully.')));
      Navigator.of(context).pop(true);
    } else {
      final text = (msg.isNotEmpty) ? 'Failed to submit vote: ' + msg : 'Failed to submit vote.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build positions list from candidates
    final positions = _candidates
        .map((e) => (e['position'] ?? '').toString())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : positions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No candidates available'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        children: positions.map((pos) {
                          final opts = _candidates.where((c) => (c['position'] ?? '').toString() == pos).toList();
                          final selected = _selections[pos];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? theme.cardColor : const Color(0xFFF1EEF8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pos,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null),
                                      ),
                                    ),
                                    if (selected != null)
                                      TextButton(
                                        onPressed: () => setState(() => _selections.remove(pos)),
                                        child: const Text('Clear'),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...opts.map((c) {
                                  final id = (c['id'] ?? '').toString();
                                  final isSel = id.isNotEmpty && id == selected;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFEAEAEA),
                                      foregroundColor: isDark ? Colors.white70 : Colors.grey,
                                      backgroundImage: ((c['photoUrl'] ?? '') as String).isNotEmpty ? NetworkImage(c['photoUrl'] as String) : null,
                                      child: (((c['photoUrl'] ?? '') as String).isEmpty) ? const Icon(Icons.person) : null,
                                    ),
                                    title: Text((c['name'] ?? '').toString()),
                                    subtitle: ((c['party'] ?? '') as String).isNotEmpty ? Text((c['party'] ?? '').toString()) : null,
                                    trailing: isSel ? const Icon(Icons.radio_button_checked, color: Color(0xFF6E63F6)) : const Icon(Icons.radio_button_off),
                                    onTap: () => setState(() => _selections[pos] = id),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selections.isEmpty ? null : _submit,
                          icon: const Icon(Icons.how_to_vote_outlined),
                          label: const Text('Submit Vote'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

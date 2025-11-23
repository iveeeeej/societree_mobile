import 'package:centralized_societree/main.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/elecom_voting_service.dart';
import 'package:centralized_societree/services/user_session.dart';
import '../services/student_dashboard_service.dart';
import 'package:centralized_societree/modules/elecom/voting/voting_screen.dart';

class StudentBottomNavBar {
  static Widget? build({
    required BuildContext context,
    required bool isElecom,
    required bool isMenuOpen,
    bool isVisible = true,
  }) {
    if (!isElecom) return null;

    final theme = Theme.of(context);

    Widget wrappedNavBar = ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, child) {
        final currentIsDarkMode = themeNotifier.isDarkMode;
        return ClipRect(
          child: AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedSlide(
              offset: isVisible ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                color: currentIsDarkMode
                    ? const Color(0xFF121212)
                    : theme.scaffoldBackgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: currentIsDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[300],
                    ),
                    BottomNavigationBar(
                      backgroundColor: currentIsDarkMode
                          ? const Color(0xFF121212)
                          : theme.scaffoldBackgroundColor,
                      selectedItemColor: currentIsDarkMode
                          ? Colors.white
                          : theme.colorScheme.primary,
                      unselectedItemColor: currentIsDarkMode
                          ? Colors.white70
                          : Colors.grey[600],
                      selectedLabelStyle: TextStyle(
                        color: currentIsDarkMode ? Colors.white : null,
                      ),
                      unselectedLabelStyle: TextStyle(
                        color: currentIsDarkMode ? Colors.white70 : null,
                      ),
                      elevation: 0,
                      currentIndex: 0,
                      onTap: (i) {
                        if (i == 1) {
                          openVoteFlow(context);
                          return;
                        }
                        if (i == 3) {
                          _openStatusSheet(context);
                          return;
                        }
                        if (i != 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                [
                                  'Home',
                                  'Election',
                                  'Poll History',
                                  'Status',
                                ][i],
                              ),
                            ),
                          );
                        }
                      },
                      type: BottomNavigationBarType.fixed,
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home_outlined,
                            color: currentIsDarkMode ? Colors.white70 : null,
                          ),
                          activeIcon: Icon(
                            Icons.home_outlined,
                            color: currentIsDarkMode ? Colors.white : null,
                          ),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.how_to_vote_outlined,
                            color: currentIsDarkMode ? Colors.white70 : null,
                          ),
                          activeIcon: Icon(
                            Icons.how_to_vote_outlined,
                            color: currentIsDarkMode ? Colors.white : null,
                          ),
                          label: 'Election',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.history,
                            color: currentIsDarkMode ? Colors.white70 : null,
                          ),
                          activeIcon: Icon(
                            Icons.history,
                            color: currentIsDarkMode ? Colors.white : null,
                          ),
                          label: 'Poll History',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.check,
                            color: currentIsDarkMode ? Colors.white70 : null,
                          ),
                          activeIcon: Icon(
                            Icons.check,
                            color: currentIsDarkMode ? Colors.white : null,
                          ),
                          label: 'Status',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (isMenuOpen) {
      return Stack(
        children: [
          wrappedNavBar,
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),
            ),
          ),
        ],
      );
    }

    return wrappedNavBar;
  }

  // Public helper to open the election/voting flow from anywhere in the Elecom student UI
  static Future<void> openVoteFlow(BuildContext context) async {
    final sid = UserSession.studentId ?? '';
    if (sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VotingScreen()),
    );
  }

  // ===== Helpers for modal flows =====
  static Future<void> _openDirectVoting(BuildContext context) async {
    final sid = UserSession.studentId ?? '';
    if (sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote.')),
      );
      return;
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: StudentDashboardService.loadCandidates(),
              builder: (context, snap) {
                final body = Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: snap.connectionState != ConnectionState.done
                        ? const Center(child: CircularProgressIndicator())
                        : _DirectVoteContent(
                            controller: controller,
                            candidates: snap.data ?? const [],
                          ),
                  ),
                );
                return body;
              },
            );
          },
        );
      },
    );
  }

  static Future<void> _openElectionList(BuildContext context) async {
    final sid = UserSession.studentId ?? '';
    if (sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to view elections.')),
      );
      return;
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: ElecomVotingService.getElections(sid),
              builder: (context, snap) {
                final body = Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Elections', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: snap.connectionState != ConnectionState.done
                              ? const Center(child: CircularProgressIndicator())
                              : (snap.data == null || snap.data!.isEmpty)
                                  ? Center(child: Text('No elections available', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : null)))
                                  : ListView.builder(
                                      controller: controller,
                                      itemCount: snap.data!.length,
                                      itemBuilder: (c, i) {
                                        final e = snap.data![i];
                                        final title = (e['title'] ?? e['name'] ?? 'Election').toString();
                                        final desc = (e['description'] ?? e['desc'] ?? '').toString();
                                        final start = (e['start'] ?? e['start_date'] ?? e['from'] ?? '').toString();
                                        final end = (e['end'] ?? e['end_date'] ?? e['to'] ?? '').toString();
                                        final votedRaw = e['already_voted'] ?? e['voted'] ?? 0;
                                        final alreadyVoted = votedRaw is bool ? votedRaw : (votedRaw.toString() == '1');
                                        final eid = (e['id'] ?? e['election_id'] ?? '').toString();
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: isDark ? theme.cardColor : const Color(0xFFF1EEF8),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                                              if (desc.isNotEmpty) ...[
                                                const SizedBox(height: 6),
                                                Text(desc, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black87)),
                                              ],
                                              const SizedBox(height: 8),
                                              Text('$start – $end', style: theme.textTheme.labelMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black54)),
                                              const SizedBox(height: 12),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: alreadyVoted
                                                      ? null
                                                      : () async {
                                                          final proceed = await _confirmProceed(context);
                                                          if (proceed != true) return;
                                                          final ok = await _openElectionSelection(context, eid);
                                                          if (ok == true && context.mounted) {
                                                            Navigator.of(context).pop();
                                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote submitted successfully.')));
                                                          }
                                                        },
                                                  child: Text(alreadyVoted ? 'Already Voted' : 'Vote Now'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                );
                return body;
              },
            );
          },
        );
      },
    );
  }

  static Future<bool?> _openElectionSelection(BuildContext context, String electionId) async {
    final sid = UserSession.studentId ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final alreadyVoted = await ElecomVotingService.checkAlreadyVoted(electionId, sid);
    if (alreadyVoted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Already Voted'),
          content: const Text('You have already voted in this election.'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ),
      );
      return false;
    }
    final data = await ElecomVotingService.getPositionsAndCandidates(electionId);
    final positions = data.$1;
    final candidates = data.$2;
    final Map<String, String> selections = {};
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (ctx, setStateSB) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Candidates', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView(
                            controller: controller,
                            children: positions.map((p) {
                              final opts = candidates.where((c) => c['position_id'] == p['id']).toList();
                              final selected = selections[p['id']];
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
                                    Text(p['name'] ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                                    const SizedBox(height: 8),
                                    ...opts.map((c) {
                                      final id = c['id'] ?? '';
                                      final isSel = id == selected;
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFEAEAEA),
                                          foregroundColor: isDark ? Colors.white70 : Colors.grey,
                                          backgroundImage: (c['photoUrl'] as String).isNotEmpty ? NetworkImage(c['photoUrl'] as String) : null,
                                          child: ((c['photoUrl'] as String).isEmpty) ? const Icon(Icons.person) : null,
                                        ),
                                        title: Text(c['name'] ?? ''),
                                        subtitle: (c['party'] as String).isNotEmpty ? Text(c['party'] as String) : null,
                                        trailing: isSel ? const Icon(Icons.radio_button_checked, color: Color(0xFF6E63F6)) : const Icon(Icons.radio_button_off),
                                        onTap: () => setStateSB(() { selections[p['id']!] = id; }),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: selections.isEmpty ? null : () async {
                              final ok = await _openReviewSheet(context, electionId, positions, candidates, selections);
                              if (ok == true && context.mounted) {
                                Navigator.of(context).pop(true); // close selection
                              }
                            },
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Review Vote'),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static Future<bool?> _openReviewSheet(
    BuildContext context,
    String electionId,
    List<Map<String, String>> positions,
    List<Map<String, String>> candidates,
    Map<String, String> selections,
  ) async {
    final sid = UserSession.studentId ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review Your Vote', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        controller: controller,
                        children: positions.map((p) {
                          final selId = selections[p['id']];
                          final cand = candidates.firstWhere(
                            (c) => c['id'] == selId,
                            orElse: () => {'name': '—', 'photoUrl': ''},
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? theme.cardColor : const Color(0xFFF1EEF8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isDark ? Colors.grey[800] : const Color(0xFFEAEAEA),
                                  foregroundColor: isDark ? Colors.white70 : Colors.grey,
                                  backgroundImage: (cand['photoUrl'] as String).isNotEmpty ? NetworkImage(cand['photoUrl'] as String) : null,
                                  child: ((cand['photoUrl'] as String).isEmpty) ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name'] ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                                      const SizedBox(height: 4),
                                      Text((cand['name'] ?? '').toString(), style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Back to Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final (ok, msg) = await ElecomVotingService.submitFinalVote(
                                electionId,
                                sid,
                                selections,
                              );
                              if (ok && context.mounted) {
                                Navigator.of(context).pop(true);
                              } else if (context.mounted) {
                                final text = (msg.isNotEmpty) ? 'Failed to submit vote: ' + msg : 'Failed to submit vote.';
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
                              }
                            },
                            icon: const Icon(Icons.how_to_vote_outlined),
                            label: const Text('Submit Final Vote'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> _openStatusSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sid = UserSession.studentId ?? '';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: ElecomVotingService.getVotingStatus(sid),
              builder: (context, snap) {
                final body = Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voting Status', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: snap.connectionState != ConnectionState.done
                              ? const Center(child: CircularProgressIndicator())
                              : (snap.data == null || snap.data!.isEmpty)
                                  ? Center(child: Text('No data', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : null)))
                                  : ListView.builder(
                                      controller: controller,
                                      itemCount: snap.data!.length,
                                      itemBuilder: (c, i) {
                                        final m = snap.data![i];
                                        final name = (m['election'] ?? m['name'] ?? m['title'] ?? 'Election').toString();
                                        final votedRaw = m['voted'] ?? m['already_voted'] ?? 0;
                                        final voted = votedRaw is bool ? votedRaw : (votedRaw.toString() == '1' || votedRaw.toString().toLowerCase() == 'true');
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: isDark ? theme.cardColor : const Color(0xFFF1EEF8),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                voted ? Icons.check_circle : Icons.cancel,
                                                color: voted ? Colors.green : Colors.red,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? Colors.white : null,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: (voted ? Colors.green : Colors.red).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                                child: Text(
                                                  voted ? 'Voted' : 'Not Yet',
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: voted ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                );
                return body;
              },
            );
          },
        );
      },
    );
  }

  static Future<bool?> _confirmProceed(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Confirm Vote'),
          content: const Text('Proceed to vote?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
          ],
        );
      },
    );
  }
}

class _DirectVoteContent extends StatefulWidget {
  final ScrollController controller;
  final List<Map<String, dynamic>> candidates;
  const _DirectVoteContent({required this.controller, required this.candidates});

  @override
  State<_DirectVoteContent> createState() => _DirectVoteContentState();
}

class _DirectVoteContentState extends State<_DirectVoteContent> {
  final Map<String, String> selections = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final positions = widget.candidates
        .map((e) => (e['position'] ?? '').toString())
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Candidates', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            controller: widget.controller,
            children: positions.map((pos) {
              final opts = widget.candidates.where((c) => (c['position'] ?? '').toString() == pos).toList();
              final selected = selections[pos];
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
                    Text(pos, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white : null)),
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
                        onTap: () => setState(() { selections[pos] = id; }),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: selections.isEmpty ? null : () async {
              final sid = UserSession.studentId ?? '';
              if (sid.isEmpty) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to vote.')));
                return;
              }
              final (ok, msg) = await ElecomVotingService.submitDirectVote(sid, selections);
              if (ok && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vote submitted successfully.')));
              } else if (mounted) {
                final text = (msg.isNotEmpty) ? 'Failed to submit vote: ' + msg : 'Failed to submit vote.';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
              }
            },
            icon: const Icon(Icons.how_to_vote_outlined),
            label: const Text('Submit Vote'),
          ),
        )
      ],
    );
  }
}

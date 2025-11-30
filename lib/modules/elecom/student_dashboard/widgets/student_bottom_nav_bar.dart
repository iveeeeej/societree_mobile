import 'package:centralized_societree/main.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../../services/elecom_voting_service.dart';
import 'package:centralized_societree/services/user_session.dart';
import '../services/student_dashboard_service.dart';
import 'package:centralized_societree/modules/elecom/voting/voting_screen.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:centralized_societree/config/api_config.dart';

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
                        if (i == 2) {
                          _openResultsSheet(context);
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
                                  'Results',
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
                            Icons.analytics_outlined,
                            color: currentIsDarkMode ? Colors.white70 : null,
                          ),
                          activeIcon: Icon(
                            Icons.analytics_outlined,
                            color: currentIsDarkMode ? Colors.white : null,
                          ),
                          label: 'Results',
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

  static Future<void> _openResultsSheet(BuildContext context) async {
    final currentIsDarkMode = themeNotifier.isDarkMode;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final sheetColor = currentIsDarkMode ? const Color(0xFF121212) : theme.scaffoldBackgroundColor;
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withOpacity(0.15)),
              ),
            ),
            DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    color: sheetColor,
                    child: _ResultsChartsSheet(controller: controller),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ResultsChartsSheet extends StatefulWidget {
  final ScrollController controller;
  const _ResultsChartsSheet({required this.controller});
  @override
  State<_ResultsChartsSheet> createState() => _ResultsChartsSheetState();
}

class _ResultsChartsSheetState extends State<_ResultsChartsSheet> {
  bool _loading = true;
  String? _error;
  List<_ResultItem> _items = const [];
  String? _selectedOrg;
  String? _selectedPos;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _startAutoRefresh();
  }

  Future<void> _load() async {
    try {
      final studentId = UserSession.studentId ?? '';
      // Fetch elections to determine context. If none, try direct results.
      final elections = await ElecomVotingService.getElections(studentId);
      String? electionId = elections.isNotEmpty ? (elections.first['id']?.toString() ?? elections.first['election_id']?.toString()) : null;

      // Try to fetch results; backend endpoint assumed as get_election_results.php
      final results = await _fetchResults(electionId: electionId);
      if (!mounted) return;
      setState(() {
        _items = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load results at the moment.';
        _loading = false;
      });
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<List<_ResultItem>> _fetchResults({String? electionId}) async {
    Future<List<_ResultItem>> _tryUri(Uri uri) async {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      final decoded = ElecomVotingService.decodeJson(res.body);
      final list = ElecomVotingService.extractList(decoded, keys: ['results', 'data', 'items']);
      final mapped = list.whereType<Map>().map((e) => e.cast<String, dynamic>()).map((m) {
        final name = (m['candidate'] ?? m['name'] ?? m['candidate_name'] ?? m['fullname'] ?? '').toString();
        final votesRaw = m['votes'] ?? m['vote_count'] ?? m['count'] ?? m['total_votes'] ?? 0;
        final votes = votesRaw is num ? votesRaw.toInt() : int.tryParse(votesRaw.toString()) ?? 0;
        final position = (m['position'] ?? m['position_name'] ?? m['pos'] ?? '').toString();
        final organization = (m['organization'] ?? m['org'] ?? m['organization_name'] ?? '').toString();
        final party = (m['party'] ?? m['party_name'] ?? m['organization_party'] ?? '').toString();
        final photoUrl = (m['photo'] ?? m['photoUrl'] ?? m['image'] ?? m['img_url'] ?? '').toString();
        return _ResultItem(name: name, votes: votes, position: position, organization: organization, party: party, photoUrl: photoUrl);
      }).where((r) => r.name.isNotEmpty).toList();
      return mapped;
    }

    try {
      // Try several common endpoints and pick the first non-empty result
      final List<Uri> candidates = [];
      if (electionId != null && electionId.isNotEmpty) {
        candidates.add(Uri.parse('${apiBaseUrl}/get_election_results.php?election_id=${Uri.encodeComponent(electionId)}'));
        candidates.add(Uri.parse('${apiBaseUrl}/get_results.php?election_id=${Uri.encodeComponent(electionId)}'));
        candidates.add(Uri.parse('${apiBaseUrl}/get_vote_counts.php?election_id=${Uri.encodeComponent(electionId)}'));
      }
      candidates.add(Uri.parse('${apiBaseUrl}/get_election_results.php'));
      candidates.add(Uri.parse('${apiBaseUrl}/get_results.php'));
      candidates.add(Uri.parse('${apiBaseUrl}/get_vote_counts.php'));

      for (final uri in candidates) {
        try {
          final mapped = await _tryUri(uri);
          if (mapped.isNotEmpty) return mapped;
        } catch (_) {
          // continue to next endpoint
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: ListView(
          controller: widget.controller,
          children: [
            Row(
              children: [
                Text('Election Results', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              )
            else
              _buildResultsBody(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBody(ThemeData theme) {
    // Normalize organization keys
    String orgKey(String s) {
      final u = s.toUpperCase();
      if (u.contains('USG')) return 'USG';
      if (u.contains('SITE')) return 'SITE';
      if (u.contains('PAFE')) return 'PAFE';
      if (u.contains('AFPR')) return 'AFPROTECHS';
      return s.isEmpty ? 'OTHER' : s;
    }

    // Orders
    const orgOrder = ['USG', 'SITE', 'PAFE', 'AFPROTECHS'];
    // Normalize positions (e.g., PIO variants)
    String posKey(String s) {
      final u = s.toUpperCase().trim();
      if (u == 'PIO' || u == 'P.I.O' || u.contains('PUBLIC INFORMATION')) {
        return 'Public Information Officer';
      }
      if (u.contains('VICE') && u.contains('PRES')) return 'Vice President';
      if (u.contains('GENERAL') && u.contains('SEC')) return 'General Secretary';
      if (u.contains('ASSOC') && u.contains('SEC')) return 'Associate Secretary';
      if (u.contains('PRES')) return 'President';
      if (u.contains('TREAS')) return 'Treasurer';
      if (u.contains('AUDIT')) return 'Auditor';
      return s.isEmpty ? '—' : s;
    }

    const commonPositions = [
      'President',
      'Vice President',
      'General Secretary',
      'Associate Secretary',
      'Treasurer',
      'Auditor',
      'Public Information Officer',
    ];
    const usgExtra = ['IT Representative', 'BTLED Representative', 'BFPT Representative'];

    // Group items by org->position
    final grouped = <String, Map<String, List<_ResultItem>>>{};
    for (final it in _items) {
      final ok = orgKey(it.organization);
      final pos = posKey(it.position);
      (grouped[ok] ??= <String, List<_ResultItem>>{});
      (grouped[ok]![pos] ??= <_ResultItem>[]).add(it);
    }

    // Build UI sections
    final sections = <Widget>[
      // Summary charts at the top
      _SummaryCharts(items: _items),
      const SizedBox(height: 12),
    ];
    for (final o in orgOrder) {
      final map = grouped[o];
      if (map == null || map.isEmpty) continue;

      final posOrder = o == 'USG' ? [...commonPositions, ...usgExtra] : List<String>.from(commonPositions);

      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(o, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
      );

      // Render positions in specified order first
      final rendered = <String>{};
      for (final pos in posOrder) {
        final items = List<_ResultItem>.from(map[pos] ?? const <_ResultItem>[]);
        items.sort((a, b) => b.votes.compareTo(a.votes));
        if (items.isEmpty) continue;
        final total = items.fold<int>(0, (s, e) => s + e.votes);
        sections.add(_ResultsSectionCard(
          title: pos,
          child: Column(
            children: items.map((it) {
              final percent = total == 0 ? 0.0 : (it.votes / total);
              final isWinner = identical(it, items.first);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CandidateCard(item: it, votes: it.votes, percent: percent, highlight: isWinner),
              );
            }).toList(),
          ),
        ));
        rendered.add(pos);
      }

      // Render any remaining positions not in the predefined order
      final remaining = map.keys.where((k) => !rendered.contains(k)).toList()..sort();
      for (final pos in remaining) {
        final items = List<_ResultItem>.from(map[pos] ?? const <_ResultItem>[]);
        items.sort((a, b) => b.votes.compareTo(a.votes));
        if (items.isEmpty) continue;
        final total = items.fold<int>(0, (s, e) => s + e.votes);
        sections.add(_ResultsSectionCard(
          title: pos,
          child: Column(
            children: items.map((it) {
              final percent = total == 0 ? 0.0 : (it.votes / total);
              final isWinner = identical(it, items.first);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CandidateCard(item: it, votes: it.votes, percent: percent, highlight: isWinner),
              );
            }).toList(),
          ),
        ));
      }
    }

    if (sections.isEmpty) {
      return Center(child: Text('No results available yet.', style: theme.textTheme.bodyMedium));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...sections,
      ],
    );
  }
}

class _ResultItem {
  final String name;
  final int votes;
  final String position;
  final String organization;
  final String party;
  final String photoUrl;
  const _ResultItem({
    required this.name,
    required this.votes,
    required this.position,
    required this.organization,
    this.party = '',
    this.photoUrl = '',
  });
}

class _ResultsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ResultsSectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blue = const Color(0xFF3B82F6);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: blue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: blue,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final _ResultItem item;
  final int votes;
  final double percent;
  final bool highlight;
  const _CandidateCard({required this.item, required this.votes, required this.percent, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = percent.clamp(0.0, 1.0);
    final hasVotes = pct > 0;
    final blue = const Color(0xFF3B82F6);
    final barColor = hasVotes ? blue : theme.colorScheme.onSurface.withOpacity(0.25);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: (item.photoUrl.isNotEmpty)
                      ? Image.network(
                          item.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 24, color: Colors.grey)),
                        )
                      : Container(color: Colors.grey.shade200, child: Center(child: Text(_initials(item.name), style: const TextStyle(fontWeight: FontWeight.w700)))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if (item.party.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(item.party, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Votes label like "3 votes (100.0%)"
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '$votes votes', style: theme.textTheme.titleSmall?.copyWith(color: blue, fontWeight: FontWeight.w700)),
                TextSpan(text: '  (${(pct * 100).toStringAsFixed(1)}%)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
              ],
            ),
          ),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: barColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (!hasVotes)
            Text('No votes yet', style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _SummaryCharts extends StatelessWidget {
  final List<_ResultItem> items;
  const _SummaryCharts({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Totals per organization for pie chart
    Map<String, int> byOrg = <String, int>{};
    for (final r in items) {
      final key = _orgKey(r.organization);
      byOrg[key] = (byOrg[key] ?? 0) + r.votes;
    }
    final pieEntries = byOrg.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top 5 candidates for bar chart
    final topCandidates = <String, int>{};
    for (final r in items) {
      topCandidates[r.name] = (topCandidates[r.name] ?? 0) + r.votes;
    }
    final barEntries = topCandidates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (barEntries.length > 5) barEntries.removeRange(5, barEntries.length);

    final totalVotes = pieEntries.fold<int>(0, (s, e) => s + e.value);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie chart
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votes by Org', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SizedBox(height: 140, child: _PieChart(entries: pieEntries, totalVotes: totalVotes)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Bar chart
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top Candidates', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _BarChart(entries: barEntries, totalVotes: barEntries.fold<int>(0, (s, e) => s + e.value)),
            ],
          ),
        ),
      ],
    );
  }

  static String _orgKey(String s) {
    final u = s.toUpperCase();
    if (u.contains('USG')) return 'USG';
    if (u.contains('SITE')) return 'SITE';
    if (u.contains('PAFE')) return 'PAFE';
    if (u.contains('AFPR')) return 'AFPROTECHS';
    return s.isEmpty ? 'OTHER' : s;
  }
}

class _GuideList extends StatelessWidget {
  final String title;
  final List<String> items;
  const _GuideList({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(e, style: theme.textTheme.bodySmall)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ResultsCharts extends StatelessWidget {
  final List<_ResultItem> items;
  const _ResultsCharts({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Aggregate by candidate across positions (or you could filter by position)
    final totals = <String, int>{};
    for (final r in items) {
      totals[r.name] = (totals[r.name] ?? 0) + r.votes;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalVotes = entries.fold<int>(0, (s, e) => s + e.value);

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No results available yet.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _BarChart(entries: const [], totalVotes: 0),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 220, width: 220, child: _PieChart(entries: const [], totalVotes: 0)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bar Chart', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _BarChart(entries: entries, totalVotes: totalVotes),
          const SizedBox(height: 16),
          Text('Pie Chart', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              height: 220,
              width: 220,
              child: _PieChart(entries: entries, totalVotes: totalVotes),
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map((e) {
            final pct = totalVotes == 0 ? 0.0 : (e.value / totalVotes) * 100.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('${e.key}: ${e.value} votes (${pct.toStringAsFixed(1)}%)'),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  final int totalVotes;
  const _BarChart({required this.entries, required this.totalVotes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVotes = entries.isEmpty ? 1 : (entries.first.value);
    return Column(
      children: entries.map((e) {
        final pct = maxVotes == 0 ? 0.0 : e.value / maxVotes;
        final percentLabel = totalVotes == 0 ? '0.0%' : '${((e.value / totalVotes) * 100).toStringAsFixed(1)}%';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct.clamp(0.0, 1.0),
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 48,
                child: Text(percentLabel, textAlign: TextAlign.right, style: theme.textTheme.labelMedium),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<MapEntry<String, int>> entries;
  final int totalVotes;
  const _PieChart({required this.entries, required this.totalVotes});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PieChartPainter(entries: entries, totalVotes: totalVotes),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final int totalVotes;
  _PieChartPainter({required this.entries, required this.totalVotes});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = radius;
    double start = -math.pi / 2;
    final palette = [
      const Color(0xFF7C4DFF),
      const Color(0xFF03A9F4),
      const Color(0xFFFFC107),
      const Color(0xFF4CAF50),
      const Color(0xFFFF5722),
      const Color(0xFFE91E63),
      const Color(0xFF009688),
      const Color(0xFF9C27B0),
    ];

    final tv = totalVotes == 0 ? 1 : totalVotes;
    for (var i = 0; i < entries.length; i++) {
      final value = entries[i].value.toDouble();
      final sweep = (value / tv) * 2 * math.pi;
      paint.color = palette[i % palette.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
  // Public helper to open the election/voting flow from anywhere in the Elecom student UI
  Future<void> openVoteFlow(BuildContext context) async {
    final sid = UserSession.studentId ?? '';
    if (sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to vote.')),
      );
      return;
    }
    // Prevent navigating if already voted (server-side check)
    final already = await ElecomVotingService.checkAlreadyVotedDirect(sid);
    if (already) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already cast your vote.')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VotingScreen()),
    );
  }

  // ===== Helpers for modal flows =====
  Future<void> _openDirectVoting(BuildContext context) async {
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

  Future<void> _openElectionList(BuildContext context) async {
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

  Future<bool?> _openElectionSelection(BuildContext context, String electionId) async {
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

  Future<bool?> _openReviewSheet(
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

  Future<void> _openStatusSheet(BuildContext context) async {
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

  Future<bool?> _confirmProceed(BuildContext context) async {
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
              final (ok, msg, _) = await ElecomVotingService.submitDirectVote(sid, selections);
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

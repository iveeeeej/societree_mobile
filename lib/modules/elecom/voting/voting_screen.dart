import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:centralized_societree/main.dart';
import 'package:centralized_societree/services/user_session.dart';
import 'package:centralized_societree/modules/elecom/student_dashboard/services/student_dashboard_service.dart';
import 'package:centralized_societree/modules/elecom/services/elecom_voting_service.dart';
import 'package:centralized_societree/modules/elecom/voting/voting_receipt_screen.dart';
import 'package:http/http.dart' as http;
import 'package:centralized_societree/config/api_config.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _candidates = const [];
  final Map<String, String> _selections = {};
  List<String> _allowedOrgs = const ['USG'];
  bool _submitting = false;

  // Normalizers to align backend strings with our canonical labels
  String _normOrg(String s) {
    final u = s.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (u.contains('USG')) return 'USG';
    if (u.contains('SITE')) return 'SITE';
    if (u.contains('PAFE')) return 'PAFE';
    if (u.contains('AFPROTECHS') || u.contains('APFROTECHS')) return 'APFROTECHS';
    return s.toUpperCase().trim();
  }

  String _buildLocalReceiptId(String sid, Map<String, String> selections) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final s = sid.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final short = s.length > 4 ? s.substring(s.length - 4) : s;
    final count = selections.length.toString().padLeft(2, '0');
    return 'RID-${short.isEmpty ? 'USER' : short}-$count-$ts';
  }

  Future<String?> _resolvePhoto(String name, String photoUrl) async {
    final List<String> candidates = [];
    if (photoUrl.isNotEmpty) candidates.add(photoUrl);
    final trimmed = name.trim();
    final noDots = trimmed.replaceAll('.', '');
    final parts = trimmed.split(RegExp(r'\s+'));
    final noInitials = parts.where((p) => p.length > 2).join(' ');
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    String enc(String s) => Uri.encodeComponent(s);
    String encPlus(String s) => enc(s).replaceAll('%20', '+');
    candidates.addAll([
      '$base/get_candidate_photo.php?name=${enc(trimmed)}',
      '$base/get_candidate_photo.php?name=${encPlus(trimmed)}',
      '$base/get_candidate_photo.php?name=${enc(noDots)}',
      '$base/get_candidate_photo.php?name=${encPlus(noDots)}',
      if (noInitials != trimmed) '$base/get_candidate_photo.php?name=${enc(noInitials)}',
      if (noInitials != trimmed) '$base/get_candidate_photo.php?name=${encPlus(noInitials)}',
    ]);
    for (final u in candidates) {
      try {
        final res = await http.head(Uri.parse(u)).timeout(const Duration(seconds: 4));
        if (res.statusCode >= 200 && res.statusCode < 300) return u;
      } catch (_) {}
    }
    return null;
  }

  String _deriveOrg(Map<String, dynamic> c) {
    final orgRaw = (c['organization'] ?? '').toString();
    var org = _normOrg(orgRaw);
    // If org didn't map to known labels, try other hints
    final known = {'USG', 'SITE', 'PAFE', 'APFROTECHS'};
    if (!known.contains(org)) {
      final program = (c['program'] ?? '').toString().toUpperCase();
      final party = (c['party_name'] ?? c['party'] ?? '').toString();
      final ctype = (c['candidate_type'] ?? '').toString();
      final joined = (orgRaw + ' ' + party + ' ' + ctype).toUpperCase();
      if (joined.contains('UNIVERSITY') && joined.contains('STUDENT') && joined.contains('GOVERNMENT')) {
        org = 'USG';
      } else if (program.contains('BSIT') || program.contains('INFORMATION TECHNOLOGY') || joined.contains('SITE') || program.contains('SITE')) {
        org = 'SITE';
      } else if (program.contains('BFPT') || joined.contains('AFPROTECHS') || joined.contains('APFROTECHS') || program.contains('FOOD')) {
        org = 'APFROTECHS';
      } else if (program.contains('BTLED') || joined.contains('PAFE')) {
        org = 'PAFE';
      }
    }
    return org;
  }

  String _normPos(String s) {
    final t = s.toLowerCase().trim();
    if (t.contains('pres') && !t.contains('vice')) return 'President';
    if (t.contains('vice') && t.contains('pres')) return 'Vice President';
    if (t.contains('general') && t.contains('secret')) return 'General Secretary';
    if (t.contains('associate') && t.contains('secret')) return 'Associate Secretary';
    if (t.contains('treas')) return 'Treasurer';
    if (t.contains('audit')) return 'Auditor';
    if (t.contains('pio') || t.contains('public')) return 'P.I.O';
    if (t.contains('it') && t.contains('rep')) return 'IT Representative';
    if (t.contains('btled') && t.contains('rep')) return 'BTLED Representative';
    if (t.contains('bfpt') && t.contains('rep')) return 'BFPT Representative';
    // Fallback to capitalized original
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

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
      final dept = (UserSession.department ?? '').toUpperCase();
      // Map departments to department-level orgs
      String? deptOrg;
      if (dept.contains('BSIT') || dept.contains('SITE')) {
        deptOrg = 'SITE';
      } else if (dept.contains('BFPT') || dept.contains('APFROTECHS') || dept.contains('AFPROTECHS')) {
        deptOrg = 'APFROTECHS';
      } else if (dept.contains('BTLED') || dept.contains('PAFE')) {
        deptOrg = 'PAFE';
      }
      // Allow only canonical labels (normalizer handles variants)
      _allowedOrgs = [
        'USG',
        if (deptOrg != null) deptOrg,
      ];

      // Filter candidates: show USG for everyone + department org if mapped (normalized)
      final allowedSet = _allowedOrgs.map(_normOrg).toSet();
      final filtered = items.where((c) {
        final org = _deriveOrg(c);
        if (org.isEmpty) return false;
        // Also normalize positions now to canonical names for later rendering
        c['position'] = _normPos((c['position'] ?? '').toString());
        c['organization'] = org;
        return allowedSet.contains(org);
      }).toList();

      setState(() {
        _candidates = filtered;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load candidates')));
    }
  }

  Future<void> _submit() async {
    if (_selections.isEmpty) return;
    final proceed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, a1, a2) {
        final shouldUseDark = themeNotifier.isDarkMode;
        final dashboardTheme = shouldUseDark
            ? ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              )
            : Theme.of(ctx);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: Theme(
              data: dashboardTheme,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Material(
                  color: Colors.transparent,
                  child: AlertDialog(
                    title: const Text('Confirm your vote'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Please review your selections:'),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 420),
                            child: Builder(
                              builder: (_) {
                                // Build a single sorted list of selections
                                final sorted = _selections.entries.toList();
                                int orgPri(String org) {
                                  final o = _normOrg(org);
                                  if (o == 'USG') return 0; if (o == 'SITE') return 1; if (o == 'PAFE') return 2; if (o == 'APFROTECHS') return 3; return 99;
                                }
                                const usgPositions = <String>['President','Vice President','General Secretary','Associate Secretary','Treasurer','Auditor','P.I.O','IT Representative','BTLED Representative','BFPT Representative'];
                                const deptPositions = <String>['President','Vice President','General Secretary','Associate Secretary','Treasurer','Auditor','P.I.O'];
                                int posPri(String org, String pos) {
                                  final list = _normOrg(org) == 'USG' ? usgPositions : deptPositions;
                                  final i = list.indexOf(_normPos(pos));
                                  return i >= 0 ? i : 99;
                                }
                                String orgOf(MapEntry<String, String> e) {
                                  final parts = e.key.split('::');
                                  return parts.length == 2 ? parts[0] : '';
                                }
                                String posOf(MapEntry<String, String> e) {
                                  final parts = e.key.split('::');
                                  return parts.length == 2 ? parts[1] : e.key;
                                }
                                sorted.sort((a, b) {
                                  final c1 = orgPri(orgOf(a)).compareTo(orgPri(orgOf(b)));
                                  if (c1 != 0) return c1;
                                  return posPri(orgOf(a), posOf(a)).compareTo(posPri(orgOf(b), posOf(b)));
                                });

                                return ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: sorted.length,
                                  separatorBuilder: (_, i) {
                                    if (i < 0 || i >= sorted.length - 1) return const Divider(height: 1);
                                    final aOrg = orgOf(sorted[i]);
                                    final bOrg = orgOf(sorted[i + 1]);
                                    if (_normOrg(aOrg) != _normOrg(bOrg)) {
                                      return const SizedBox(height: 12);
                                    }
                                    return const Divider(height: 1);
                                  },
                                  itemBuilder: (_, i) {
                                    final e = sorted[i];
                                    final posKey = e.key;
                                    final cid = e.value;
                                    Map<String, dynamic> cand = const {};
                                    for (final c in _candidates) {
                                      final id = (c['id'] ?? '').toString();
                                      if (id == cid) { cand = c; break; }
                                    }
                                    final name = (cand['name'] ?? '').toString();
                                    final org = (cand['organization'] ?? '').toString();
                                    final parts = posKey.split('::');
                                    final prettyPos = parts.length == 2 ? '${parts[0]} — ${parts[1]}' : posKey;
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(prettyPos, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                      subtitle: Text([name, if (org.isNotEmpty) '($org)'].join(' ')),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Submit')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
    if (proceed != true) return;

    final sid = UserSession.studentId ?? '';
    if (sid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to vote.')));
      return;
    }

    if (mounted) setState(() => _submitting = true);
    // Show a small blocking progress dialog while submitting
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          final theme = Theme.of(context);
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 80),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Submitting your vote...',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    try {
      // First attempt
      var (ok, msg, receiptId) = await ElecomVotingService.submitDirectVote(sid, _selections);
      if (!mounted) return;
      if (!ok) {
        final lower = msg.toLowerCase();
        // If backend says already voted, or network failed but server recorded, treat as success
        if (lower.contains('already')) {
          ok = true;
        } else {
          // Network or unknown error: verify status, then retry once
          final already = await ElecomVotingService.checkAlreadyVotedDirect(sid);
          if (already) {
            ok = true;
          } else {
            // Retry once
            final r2 = await ElecomVotingService.submitDirectVote(sid, _selections);
            ok = r2.$1; msg = r2.$2; receiptId = r2.$3 ?? receiptId;
          }
        }
      }

      if (ok) {
        // Navigate to receipt screen with selections snapshot (even if receiptId is missing)
        final snapshot = Map<String, String>.from(_selections);
        final localId = (receiptId == null || receiptId.isEmpty) ? _buildLocalReceiptId(sid, snapshot) : receiptId;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VotingReceiptScreen(
              receiptId: localId ?? '-',
              selections: snapshot,
            ),
          ),
        );
        return;
      }

      // Still failing here
      final text = (msg.isNotEmpty) ? 'Failed to submit vote: ' + msg : 'Failed to submit vote.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      }
    } finally {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // close progress dialog
      }
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Organization -> ordered positions mapping
    const usgPositions = <String>[
      'President',
      'Vice President',
      'General Secretary',
      'Associate Secretary',
      'Treasurer',
      'Auditor',
      'P.I.O',
      'IT Representative',
      'BTLED Representative',
      'BFPT Representative',
    ];
    const deptPositions = <String>[
      'President',
      'Vice President',
      'General Secretary',
      'Associate Secretary',
      'Treasurer',
      'Auditor',
      'P.I.O',
    ];

    final orgOrder = _allowedOrgs.map(_normOrg).toList(); // e.g., ['USG', 'SITE']
    final Map<String, List<String>> orgToPositions = {
      for (final org in orgOrder)
        org: org.toUpperCase() == 'USG' ? usgPositions : deptPositions,
    };

    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        final shouldUseDark = themeNotifier.isDarkMode;
        final dashboardTheme = shouldUseDark
            ? ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              )
            : Theme.of(context);
        return Theme(
          data: dashboardTheme,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Vote'),
            ),
            body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_candidates.isEmpty
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
                        children: [
                          for (final org in orgOrder) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Text(
                                org,
                                style: dashboardTheme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: dashboardTheme.brightness == Brightness.dark ? Colors.white70 : null,
                                ),
                              ),
                            ),
                            Builder(
                              builder: (_) {
                                final theme = dashboardTheme;
                                final isDark = theme.brightness == Brightness.dark;
                                final existingPos = _candidates
                                    .where((c) => _normOrg((c['organization'] ?? '').toString()) == _normOrg(org))
                                    .map((c) => _normPos((c['position'] ?? '').toString()))
                                    .toSet();
                                final orderedExisting = [
                                  ...orgToPositions[org]!.where((p) => existingPos.contains(p)),
                                ];
                                if (orderedExisting.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      'No candidates under ' + org,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    for (final pos in orderedExisting) ...[
                                      Builder(
                                        builder: (_) {
                                          final theme = dashboardTheme;
                                          final isDark = theme.brightness == Brightness.dark;
                                          final opts = _candidates.where((c) {
                                            final o = _normOrg((c['organization'] ?? '').toString());
                                            final p = _normPos((c['position'] ?? '').toString());
                                            return _normOrg(org) == o && p == pos;
                                          }).toList();
                                          if (opts.isEmpty) return const SizedBox.shrink();
                                          final posKey = '$org::$pos';
                                          final selected = _selections[posKey];
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
                                                        style: theme.textTheme.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.w700,
                                                          color: isDark ? Colors.white : null,
                                                        ),
                                                      ),
                                                    ),
                                                    if ((selected ?? '').isNotEmpty)
                                                      TextButton.icon(
                                                        onPressed: () => setState(() {
                                                          _selections.remove(posKey);
                                                        }),
                                                        icon: const Icon(Icons.clear, size: 18),
                                                        label: const Text('Clear'),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                ...opts.map((c) {
                                                  final id = (c['id'] ?? '').toString();
                                                  final isSel = id.isNotEmpty && id == selected;
                                                  return ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    leading: ClipOval(
                                                      child: SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: FutureBuilder<String?>(
                                                          future: _resolvePhoto((c['name'] ?? '').toString(), (c['photoUrl'] ?? '').toString()),
                                                          builder: (context, snap) {
                                                            final url = snap.data;
                                                            if (url != null && url.isNotEmpty) {
                                                              return Image.network(
                                                                url,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.person, size: 24, color: Colors.grey)),
                                                              );
                                                            }
                                                            return Container(color: isDark ? Colors.grey[800] : const Color(0xFFEAEAEA), child: const Icon(Icons.person, size: 24, color: Colors.grey));
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      (c['name'] ?? '').toString(),
                                                      style: theme.textTheme.bodyLarge?.copyWith(
                                                        color: isDark ? Colors.white : null,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    subtitle: ((c['party'] ?? '') as String).isNotEmpty
                                                        ? Text(
                                                            (c['party'] ?? '').toString(),
                                                            style: theme.textTheme.bodySmall?.copyWith(
                                                              color: isDark ? Colors.white70 : null,
                                                            ),
                                                          )
                                                        : (((c['organization'] ?? '') as String).isNotEmpty
                                                            ? Text(
                                                                (c['organization'] ?? '').toString(),
                                                                style: theme.textTheme.bodySmall?.copyWith(
                                                                  color: isDark ? Colors.white70 : null,
                                                                ),
                                                              )
                                                            : null),
                                                    trailing: isSel
                                                        ? const Icon(Icons.radio_button_checked, color: Color(0xFF6E63F6))
                                                        : const Icon(Icons.radio_button_off),
                                                    onTap: () => setState(() {
                                                      if (_selections[posKey] == id) {
                                                        _selections.remove(posKey); // unselect
                                                      } else {
                                                        _selections[posKey] = id; // select
                                                      }
                                                    }),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selections.isEmpty || _submitting ? null : _submit,
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Review & Submit'),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }
}

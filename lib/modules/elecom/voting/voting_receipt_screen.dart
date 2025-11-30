import 'package:flutter/material.dart';
import 'package:centralized_societree/main.dart';
import 'package:centralized_societree/modules/elecom/dashboard.dart';

class VotingReceiptScreen extends StatelessWidget {
  final String receiptId;
  final Map<String, String> selections;

  const VotingReceiptScreen({super.key, required this.receiptId, required this.selections});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = selections.entries.toList();
    int orgPri(String org) {
      final u = org.toUpperCase();
      if (u.contains('USG')) return 0;
      if (u.contains('SITE')) return 1;
      if (u.contains('PAFE')) return 2;
      if (u.contains('AFPROTECHS') || u.contains('APFROTECHS')) return 3;
      return 99;
    }
    const usgPositions = <String>['President','Vice President','General Secretary','Associate Secretary','Treasurer','Auditor','P.I.O','IT Representative','BTLED Representative','BFPT Representative'];
    const deptPositions = <String>['President','Vice President','General Secretary','Associate Secretary','Treasurer','Auditor','P.I.O'];
    String normPos(String s) {
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
      return s;
    }
    int posPri(String org, String pos) {
      final list = (org.toUpperCase().contains('USG')) ? usgPositions : deptPositions;
      final i = list.indexOf(normPos(pos));
      return i >= 0 ? i : 99;
    }
    entries.sort((a, b) {
      final ap = a.key.split('::');
      final bp = b.key.split('::');
      final aOrg = ap.length == 2 ? ap[0] : '';
      final aPos = ap.length == 2 ? ap[1] : a.key;
      final bOrg = bp.length == 2 ? bp[0] : '';
      final bPos = bp.length == 2 ? bp[1] : b.key;
      final c1 = orgPri(aOrg).compareTo(orgPri(bOrg));
      if (c1 != 0) return c1;
      return posPri(aOrg, aPos).compareTo(posPri(bOrg, bPos));
    });

    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) {
        final shouldUseDark = themeNotifier.isDarkMode;
        final receiptTheme = shouldUseDark
            ? ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              )
            : Theme.of(context);
        final theme = receiptTheme;
        return Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Voting Receipt'),
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receiptId.startsWith('RID-') ? 'Local Reference' : 'Receipt ID',
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          receiptId,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (receiptId.startsWith('RID-')) ...[
                          const SizedBox(height: 6),
                          Text(
                            'This reference was generated on your device because the server did not return an ID.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Your selections', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: entries.isEmpty
                        ? Center(child: Text('No selections recorded', style: theme.textTheme.bodyMedium))
                        : ListView.separated(
                            itemCount: entries.length,
                            separatorBuilder: (_, i) {
                              if (i < 0 || i >= entries.length - 1) return const Divider(height: 1);
                              final aOrg = entries[i].key.split('::').first;
                              final bOrg = entries[i + 1].key.split('::').first;
                              if (orgPri(aOrg) != orgPri(bOrg)) return const SizedBox(height: 12);
                              return const Divider(height: 1);
                            },
                            itemBuilder: (_, i) {
                              final e = entries[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(e.key),
                                subtitle: Text('Candidate ID: ${e.value}'),
                              );
                            },
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) {
                            Future.delayed(const Duration(milliseconds: 1000), () {
                              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
                            });
                            return Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF22C55E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 36),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Thank you for voting',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const ElecomDashboard()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

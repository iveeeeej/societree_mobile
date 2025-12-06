import 'package:flutter/material.dart';
import 'package:centralized_societree/services/user_session.dart';
import 'package:centralized_societree/modules/elecom/voting/voting_receipt_screen.dart';
import 'package:centralized_societree/modules/elecom/services/elecom_voting_service.dart';
import 'package:centralized_societree/modules/elecom/voting/voting_screen.dart';
import 'package:centralized_societree/modules/elecom/widgets/voting_action_button.dart';

class ReceiptLandingScreen extends StatefulWidget {
  const ReceiptLandingScreen({super.key});

  @override
  State<ReceiptLandingScreen> createState() => _ReceiptLandingScreenState();
}

class _ReceiptLandingScreenState extends State<ReceiptLandingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sid = UserSession.studentId ?? '';
      final id = (UserSession.lastReceiptStudentId == sid) ? UserSession.lastReceiptId : null;
      final selections = (UserSession.lastReceiptStudentId == sid) ? UserSession.lastReceiptSelections : null;
      bool already = false;
      if (sid.isNotEmpty) {
        try { already = await ElecomVotingService.checkAlreadyVotedDirect(sid); } catch (_) {}
      }
      if (!mounted) return;
      if (already && sid.isNotEmpty && id != null && id.isNotEmpty && selections != null && selections.isNotEmpty) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VotingReceiptScreen(
              receiptId: id,
              selections: selections,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 12),
              Text(
                'No receipt available',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We could not find a local voting receipt for your account. Submit your vote to generate one.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: TextButton.styleFrom(
                      foregroundColor: (theme.brightness == Brightness.dark) ? Colors.white : Colors.black,
                    ),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  VotingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VotingScreen()),
                      );
                    },
                    icon: const Icon(Icons.how_to_vote_outlined),
                    label: 'Vote Now',
                    compact: true,
                    fullWidth: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

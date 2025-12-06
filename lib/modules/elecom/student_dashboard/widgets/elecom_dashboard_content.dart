import 'package:flutter/material.dart';
import 'package:centralized_societree/modules/elecom/student_dashboard/widgets/elecom_button.dart';
import 'package:centralized_societree/modules/elecom/student_dashboard/widgets/glowing_vote_now_button.dart';
import 'package:centralized_societree/modules/elecom/voting/voting_screen.dart';
import '../../omnibus_slideshow.dart';
import '../../parties_candidates_grid.dart';
import '../../things_to_know.dart';
import 'election_info_sheets.dart';
import 'student_bottom_nav_bar.dart';

class ElecomDashboardContent extends StatelessWidget {
  final ThemeData theme;
  final Duration remaining;
  final bool voted;
  final String? selectedCandidate;
  final bool canVote;
  final bool notStarted;
  final List<Map<String, dynamic>> parties;
  final bool loadingParties;
  final bool showAllParties;
  final List<Map<String, dynamic>> candidates;
  final Function(bool) onToggleShowAllParties;
  final Function(bool) onVoteSubmitted;
  final Function(Map<String, dynamic>) onShowPartyDetails;

  const ElecomDashboardContent({
    super.key,
    required this.theme,
    required this.remaining,
    required this.voted,
    required this.canVote,
    required this.notStarted,
    this.selectedCandidate,
    required this.parties,
    required this.loadingParties,
    required this.showAllParties,
    required this.candidates,
    required this.onToggleShowAllParties,
    required this.onVoteSubmitted,
    required this.onShowPartyDetails,
  });

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours; // cumulative hours remaining
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    Widget timePill(String value, String label) {
      return Expanded(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/search',
                  arguments: {
                    'parties': parties,
                    'candidates': candidates,
                    'isElecom': true,
                  },
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search Party/candidates',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    filled: true,
                    fillColor: const Color(0xFFF1EEF8),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              voted ? 'Status' : 'Election Countdown',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            voted
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Already voted',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your vote has been recorded.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF7B6CF6),
                          Color(0xFFB07CF3),
                          Color(0xFFE7B56A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'USTP-OROQUIETA Election',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'General Election to legislative assembly',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            timePill(days.toString().padLeft(2, '0'), 'days'),
                            const SizedBox(width: 8),
                            timePill(hours.toString().padLeft(2, '0'), 'hrs'),
                            const SizedBox(width: 8),
                            timePill(minutes.toString().padLeft(2, '0'), 'mins'),
                            const SizedBox(width: 8),
                            timePill(seconds.toString().padLeft(2, '0'), 'sec'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          notStarted
                              ? 'Voting has not started yet.'
                              : (!canVote
                                  ? 'Voting has ended.'
                                  : (days > 0
                                      ? 'You have $days days left to vote. Don\'t miss your chance!'
                                      : 'Voting closes soon!')),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFFFE4E4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: GlowingVoteNowButton(
                            label: canVote ? 'Vote Now' : (notStarted ? 'Not Started' : 'Voting Closed'),
                            enabled: canVote,
                            onPressed: canVote
                                ? () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const VotingScreen()),
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 16),
            Text(
              'Omnibus Code',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const OmnibusSlideshow(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Parties & Candidates',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (parties.length > 3)
                  ElecomButton.text(
                    label: showAllParties ? 'See Less' : 'See All',
                    onPressed: () => onToggleShowAllParties(!showAllParties),
                    icon: showAllParties ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            PartiesCandidatesGrid(
              parties: showAllParties
                  ? parties
                  : (parties.length > 3 ? parties.take(3).toList() : parties),
              loading: loadingParties,
              onPartyTap: (party) => onShowPartyDetails(party),
            ),
            const SizedBox(height: 24),
            Text(
              'Things to know',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ThingsToKnowGrid(
              onTopManifesto: () => openManifestoHighlights(context),
              onFaqs: () => openFaqsEducation(context),
              onFindPolling: () => openFindPollingStation(context),
            ),
          ],
        ),
        const SizedBox.shrink(),
      ],
    );
  }
}

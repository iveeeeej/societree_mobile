import 'package:flutter/material.dart';

import '../widgets/shared.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RibbonMarker(),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1F2937)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 16)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LogoBadge(size: 46),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, Mae Rodriguez', style: appTextStyle(weight: FontWeight.w700, color: Colors.white)),
                        Text('Wed, 05 Nov • 9:41 AM', style: appTextStyle(color: Colors.white70, size: 13)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Track Request', style: appTextStyle(weight: FontWeight.w700, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('Your request is approved. Final step pending.', style: appTextStyle(color: Colors.white70, size: 13)),
                            const SizedBox(height: 12),
                            Row(
                              children: const [
                                StatusDot(label: 'Pending', isDone: true),
                                Expanded(child: Divider(color: Colors.white24, thickness: 1.2)),
                                StatusDot(label: 'Approved', isDone: true),
                                Expanded(child: Divider(color: Colors.white24, thickness: 1.2)),
                                StatusDot(label: 'Completed', isDone: false),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.timeline, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Progress', actionLabel: 'View all'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ProgressCard(
                  color: Colors.blue.shade500,
                  title: 'Marketing',
                  subtitle: '3 tasks left',
                  percent: 0.55,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProgressCard(
                  color: Colors.pink.shade400,
                  title: 'Onboarding',
                  subtitle: 'Design updates',
                  percent: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressCard(
            color: Colors.teal.shade400,
            title: 'Web Development',
            subtitle: 'Sprint 12',
            percent: 0.78,
            height: 130,
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 12),
          FrostedCard(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                BadgeChip(label: 'Book facility', icon: Icons.meeting_room, color: Colors.indigo),
                BadgeChip(label: 'Raise ticket', icon: Icons.support_agent, color: Colors.teal),
                BadgeChip(label: 'New hire', icon: Icons.person_add_alt, color: Colors.orange),
                BadgeChip(label: 'Marketing kit', icon: Icons.campaign, color: Colors.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


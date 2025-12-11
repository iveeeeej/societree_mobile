import 'package:flutter/material.dart';

import '../widgets/shared.dart';

class LearningHubScreen extends StatelessWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Learning Hub', style: appTextStyle(weight: FontWeight.w700, size: 22)),
              Row(
                children: const [
                  RibbonMarker(),
                  SizedBox(width: 12),
                  BadgeChip(label: 'New modules', icon: Icons.auto_awesome, color: Colors.purple),
                  SizedBox(width: 10),
                  LogoBadge(size: 34, elevation: false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore interactive tutorials, templates, and bite-sized guides.',
                        style: appTextStyle(weight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          BadgeChip(label: 'UI/UX', color: Colors.white, icon: Icons.palette_outlined),
                          BadgeChip(label: 'Web', color: Colors.white, icon: Icons.web),
                          BadgeChip(label: 'Marketing', color: Colors.white, icon: Icons.campaign_outlined),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.extension, size: 44, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Available Learning Materials', actionLabel: 'See all'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: softCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.desktop_windows, color: Colors.white70, size: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Introduction to Web Development', style: appTextStyle(weight: FontWeight.w800, size: 18)),
                const SizedBox(height: 8),
                Text(
                  'Build confidence in HTML, CSS, JS, and deployment best practices.',
                  style: appTextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    BadgeChip(label: '8 hrs', icon: Icons.schedule),
                    BadgeChip(label: 'Beginner', icon: Icons.auto_fix_high),
                    BadgeChip(label: 'Certificate', icon: Icons.verified),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Start Learning'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


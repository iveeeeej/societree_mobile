import 'package:flutter/material.dart';

import '../widgets/feedback_dialog.dart';
import '../widgets/shared.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openFeedback(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const FeedbackDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          const RibbonMarker(),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF111827), Color(0xFF1F2937)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 22, offset: const Offset(0, 14)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _openFeedback(context),
                      icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const LogoBadge(size: 54, elevation: false),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text('Mae Rodriguez', style: appTextStyle(weight: FontWeight.w800, size: 20, color: Colors.white)),
                Text('mae.rodriguez@gmail.com', style: appTextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    BadgeChip(label: 'Premium', icon: Icons.verified, color: Colors.white),
                    SizedBox(width: 8),
                    BadgeChip(label: 'Atlanta, GA', icon: Icons.location_on_outlined, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const ProfileTile(
            icon: Icons.person_outline,
            title: 'Account Information',
            trailing: Text('Mae Rodriguez'),
          ),
          const ProfileTile(
            icon: Icons.phone_outlined,
            title: 'Contact Number',
            trailing: Text('+1 234 567 8990'),
          ),
          const ProfileTile(
            icon: Icons.lock_outline,
            title: 'Security & Password',
            trailing: Icon(Icons.chevron_right),
          ),
          ProfileTile(
            icon: Icons.feedback_outlined,
            title: 'Give Feedback',
            onTap: () => _openFeedback(context),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}


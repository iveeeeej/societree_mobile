import 'package:flutter/material.dart';
import 'dart:ui';

void showUSGTermsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: const Text('USG Terms & Conditions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('By using USG services through SocieTree, you agree to:'),
                const SizedBox(height: 8),
                const Text('• Use the platform responsibly and respectfully.'),
                const Text('• Follow all university policies and guidelines.'),
                const Text('• Provide accurate information for verification.'),
                const Text('• Respect the decisions and rules set by USG.'),
                const SizedBox(height: 12),
                const Text(
                  'Privacy & Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Your student information is processed solely for providing USG services. Data is protected according to university privacy policies.'),
                const SizedBox(height: 12),
                const Text(
                  'Code of Conduct',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('Harassment, misconduct, and platform abuse are prohibited. Violations may lead to sanctions under university policies.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    },
  );
}
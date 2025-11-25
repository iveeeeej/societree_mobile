import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../screens/societree/societree_dashboard.dart';
import '../../../../screens/login_screen.dart';
import '../../../../main.dart';

class StudentDashboardAppBar {
  static PreferredSizeWidget build({
    required BuildContext context,
    required String orgName,
    required bool isElecom,
    required Function(bool) onMenuStateChanged,
  }) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: !isElecom,
      title: isElecom
          ? ListenableBuilder(
              listenable: themeNotifier,
              builder: (context, child) {
                final isDarkMode = themeNotifier.isDarkMode;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Only show icon in light mode
                    if (!isDarkMode) ...[
                      Container(
                        width: 32,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/ELECOM.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Use white text in dark mode, black in light mode
                    Opacity(
                      opacity: isDarkMode ? 1.0 : 0.7,
                      child: Image.asset(
                        isDarkMode
                            ? 'assets/images/img_text/elecom_white1.png'
                            : 'assets/images/img_text/elecom_black.png',
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                );
              },
            )
          : Text(orgName),
      actions: [
        IconButton(
          tooltip: 'Terms & Conditions',
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (ctx) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: AlertDialog(
                    title: const Text('ELECOM Voting Terms & Conditions'),
                    content: const SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('By participating in elections through SocieTree, you agree to:'),
                          SizedBox(height: 8),
                          Text('• Cast only one vote per election using your own verified account.'),
                          Text('• Not tamper with, automate, or interfere with the voting process.'),
                          Text('• Provide accurate information when required by ELECOM for validation.'),
                          Text('• Respect the results and the rules set by ELECOM and your institution.'),
                          SizedBox(height: 12),
                          Text('Privacy & Data'),
                          Text('Your student ID and voting selections are processed solely for managing the election. Aggregated results may be published; individual identities are protected according to ELECOM policy.'),
                          SizedBox(height: 12),
                          Text('Conduct'),
                          Text('Harassment, misinformation, and attempts to disrupt the platform are prohibited. Violations may lead to sanctions under school policies.'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
                    ],
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.help_outline),
        ),
        ListenableBuilder(
          listenable: themeNotifier,
          builder: (context, child) {
            return IconButton(
              onPressed: isElecom
                  ? () {
                      // Toggle dark/light mode for ELECOM
                      themeNotifier.toggleTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            themeNotifier.isDarkMode
                                ? 'Switched to Dark Mode'
                                : 'Switched to Light Mode',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  : () {}, // Empty function for non-ELECOM
              icon: Icon(
                isElecom
                    ? (themeNotifier.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode)
                    : Icons.settings_outlined,
              ),
              tooltip: isElecom
                  ? (themeNotifier.isDarkMode
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode')
                  : 'Settings',
            );
          },
        ),
        ListenableBuilder(
          listenable: themeNotifier,
          builder: (context, child) {
            final isDarkMode = isElecom && themeNotifier.isDarkMode;
            return PopupMenuButton<String>(
              tooltip: 'Menu',
              icon: const Icon(Icons.more_vert),
              offset: const Offset(0, 7),
              position: PopupMenuPosition.under,
              elevation: 4,
              padding: EdgeInsets.zero,
              iconSize: 24,
              color: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Theme.of(context).cardColor,
              surfaceTintColor: Colors.transparent,
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
              onOpened: () => onMenuStateChanged(true),
              onCanceled: () => onMenuStateChanged(false),
              onSelected: (value) async {
                onMenuStateChanged(false);
                if (value == 'home') {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SocieTreeDashboard(),
                    ),
                  );
                } else if (value == 'logout') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (ctx) {
                      final dialogTheme = isDarkMode
                          ? ThemeData(
                              colorScheme: ColorScheme.fromSeed(
                                seedColor: Colors.deepPurple,
                                brightness: Brightness.dark,
                              ),
                              useMaterial3: true,
                            )
                          : Theme.of(ctx);
                      return Theme(
                        data: dialogTheme,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: AlertDialog(
                            backgroundColor: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : dialogTheme.dialogBackgroundColor,
                            title: Text(
                              'Logout',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : null,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : null,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : null,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.deepPurple
                                      : null,
                                  foregroundColor: isDarkMode
                                      ? Colors.white
                                      : null,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  if (confirm == true && context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'home',
                  child: Row(
                    children: [
                      Icon(
                        Icons.park,
                        size: 20,
                        color: isDarkMode ? Colors.white70 : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Societree',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        size: 20,
                        color: isDarkMode ? Colors.white70 : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

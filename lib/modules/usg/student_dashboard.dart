import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centralized_societree/modules/usg/reusables/bottom_navigation.dart';
import 'package:centralized_societree/modules/usg/dialogs/usg_terms_dialog.dart';
import 'package:centralized_societree/modules/usg/dialogs/logout_dialog.dart';
import 'package:centralized_societree/screens/societree/societree_dashboard.dart';
import 'package:centralized_societree/screens/login_screen.dart';
import 'pages/announcement_page.dart';
import 'pages/services_page.dart';
import 'pages/profile_page.dart';
import '../../services/api_service.dart';

class StudentDashboard extends StatefulWidget { 
  final String orgName;
  final String? assetPath;
  final ApiService apiService;

  const StudentDashboard({
    super.key,
    required this.orgName,
    this.assetPath,
    required this.apiService,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isMenuOpen = false;

  void _handleHomeTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SocieTreeDashboard(),
      ),
    );
  }

  Future<void> _handleLogoutTap() async {
    final confirm = await showLogoutDialog(context);
    
    if (confirm == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _handleTermsTap() {
    showUSGTermsDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(context),
      AnnouncementPage(apiService: widget.apiService),
      const ServicesPage(),
      const ProfilePage(),
    ];

    return BottomNavigation(
      orgName: widget.orgName,
      assetPath: widget.assetPath,
      screens: screens,
      backgroundColor: Colors.white,
      onMenuStateChanged: (isOpen) {
        setState(() {
          _isMenuOpen = isOpen;
        });
      },
      onHomeTap: _handleHomeTap,
      onLogoutTap: _handleLogoutTap,
      onTermsTap: _handleTermsTap,
    );
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ${widget.orgName}!',
              style: GoogleFonts.oswald(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Use the bottom navigation to explore',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
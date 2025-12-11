import 'package:flutter/material.dart';

import 'dart:ui';

import '../widgets/shared.dart';
import 'gallery_screen.dart';
import 'home_screen.dart';
import 'inbox_screen.dart';
import 'learning_hub_screen.dart';
import 'profile_screen.dart';
import 'request_service_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    GalleryScreen(),
    RequestServiceScreen(),
    LearningHubScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: SafeArea(child: _pages[_currentIndex]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.78),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTap,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.accentDeep,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.photo_library_outlined), label: 'Gallery'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Request'),
                BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Modules'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Alerts'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'app_bar.dart';

class BottomNavigation extends StatefulWidget {
  final String orgName;
  final String? assetPath;
  final List<Widget> screens;
  final List<BottomNavigationBarItem> navItems;
  final bool showAppBar;
  final Function(bool)? onMenuStateChanged;
  final VoidCallback? onHomeTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onTermsTap;
  final Color? backgroundColor;

  const BottomNavigation({
    super.key,
    required this.orgName,
    this.assetPath,
    required this.screens,
    this.navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.campaign_outlined),
        label: "Announcements",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.handyman_outlined),
        label: "Services",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: "Profile",
      ),
    ],
    this.showAppBar = true,
    this.onMenuStateChanged,
    this.onHomeTap,
    this.onLogoutTap,
    this.onTermsTap,
    this.backgroundColor,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: widget.showAppBar
          ? CustomAppBar(
              title: widget.orgName,
              logoPath: widget.assetPath,
              showBackButton: false,
              onMenuStateChanged: widget.onMenuStateChanged,
              onHomeTap: widget.onHomeTap,
              onLogoutTap: widget.onLogoutTap,
              onTermsTap: widget.onTermsTap,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: widget.screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Color(0xFF1A1A34),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: widget.navItems,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? logoPath;
  final bool showBackButton;
  final List<Widget>? customActions;
  final Function(bool)? onMenuStateChanged;
  final VoidCallback? onHomeTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onTermsTap;
  
  const CustomAppBar({
    Key? key,
    required this.title,
    this.logoPath,
    this.showBackButton = true,
    this.customActions,
    this.onMenuStateChanged,
    this.onHomeTap,
    this.onLogoutTap,
    this.onTermsTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton 
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null,
      title: _buildTitle(),
      backgroundColor: const Color(0xFF1e174a),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      actions: customActions ?? _buildDefaultActions(context),
    );
  }

  Widget _buildTitle() {
    if (logoPath != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo image with white circular background
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // White background for the logo
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                logoPath!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Organization name
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
    
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    List<Widget> actions = [];
    
    // Add Terms button if callback provided
    if (onTermsTap != null) {
      actions.add(
        IconButton(
          tooltip: 'Terms & Conditions',
          onPressed: onTermsTap,
          icon: const Icon(Icons.help_outline, color: Colors.white), // White icon
        ),
      );
    }
    
    // Always add the menu button
    actions.add(_buildPopupMenuButton(context));
    
    return actions;
  }

  PopupMenuButton<String> _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      icon: const Icon(Icons.more_vert, color: Colors.white), // White icon
      offset: const Offset(0, 7),
      position: PopupMenuPosition.under,
      elevation: 4,
      padding: EdgeInsets.zero,
      iconSize: 24,
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      onOpened: () => onMenuStateChanged?.call(true),
      onCanceled: () => onMenuStateChanged?.call(false),
      onSelected: (value) {
        onMenuStateChanged?.call(false);
        switch (value) {
          case 'home':
            onHomeTap?.call();
            break;
          case 'logout':
            onLogoutTap?.call();
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'home',
          child: Row(
            children: [
              const Icon(Icons.park, size: 20),
              const SizedBox(width: 10),
              const Text('Societree'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.exit_to_app, size: 20),
              const SizedBox(width: 10),
              const Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'afprotech_settings.dart';

class AfprotechProfileScreen extends StatefulWidget {
  final bool showHeader;

  const AfprotechProfileScreen({super.key, this.showHeader = true});

  @override
  State<AfprotechProfileScreen> createState() => _AfprotechProfileScreenState();
}

class _AfprotechProfileScreenState extends State<AfprotechProfileScreen> {
  final Color navyBlue = const Color(0xFF000080);
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    Color scaffoldBg = isDarkMode ? Colors.black : Colors.white;
    Color mainColor = isDarkMode ? Colors.white : navyBlue;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    Widget content = widget.showHeader
        ? SafeArea(
            child: Column(
              children: [
                // HEADER AREA
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button (arrow)
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: navyBlue),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Logo & Title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ASSOCIATION OF FOOD PROCESSING",
                            style: TextStyle(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "AND TECHNOLOGY STUDENTS",
                            style: TextStyle(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // MAIN CONTENT SCROLL
                Expanded(child: _buildContent(textColor, mainColor)),
              ],
            ),
          )
        : _buildContent(textColor, mainColor);

    return Scaffold(backgroundColor: scaffoldBg, body: content);
  }

  Widget _buildContent(Color textColor, Color mainColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(textColor, mainColor),
            const SizedBox(height: 20),
            _buildMyOrdersContainer(textColor, mainColor),
            _buildFavoritesContainer(textColor, mainColor),
            _buildSettingsContainer(textColor, mainColor),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: _buildLogoutButton(textColor, mainColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Color textColor, Color mainColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Section
          Row(
            children: [
              // User Icon instead of profile picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: mainColor,
                ),
              ),
              const SizedBox(width: 16),
              
              // Name
              Expanded(
                child: Text(
                  "Lester Bulay",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              
              // Edit Button (moved to right)
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Edit profile coming soon!'),
                      backgroundColor: mainColor,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: mainColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Stats Section
          Row(
            children: [
              // Orders
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "1",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Orders",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Favorites
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "5",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Favorites",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyOrdersContainer(Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long,
            color: mainColor,
            size: 24,
          ),
        ),
        title: Text(
          "My Orders",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          "View All Orders",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('My Orders coming soon!'),
              backgroundColor: mainColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesContainer(Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.favorite,
            color: mainColor,
            size: 24,
          ),
        ),
        title: Text(
          "Favorites",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          "Saves Your Favorites Products!",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Favorites coming soon!'),
              backgroundColor: mainColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContainer(Color textColor, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.settings,
            color: mainColor,
            size: 24,
          ),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          "App Preferences",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AfprotechSettingsScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(Color textColor, Color mainColor) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') {
          _showLogoutDialog(context, mainColor);
        } else if (value == 'societree') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('SocieTree feature coming soon!'),
              backgroundColor: mainColor,
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'societree',
          child: Row(
            children: [
              Icon(Icons.park, color: mainColor, size: 18),
              const SizedBox(width: 12),
              Text('SocieTree', style: TextStyle(color: textColor)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: mainColor, size: 18),
              const SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, Color mainColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add logout functionality here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Logged out successfully!'),
                  backgroundColor: mainColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

}
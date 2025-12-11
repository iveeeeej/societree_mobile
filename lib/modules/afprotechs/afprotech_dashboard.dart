import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'afprotech_services.dart';
import 'afprotech_products.dart';
import 'afprotech_announcements.dart';
import 'afprotech_profile.dart';

class DashboardScreen extends StatefulWidget {
  final String orgName;
  final String assetPath;
  
  const DashboardScreen({
    super.key,
    required this.orgName,
    required this.assetPath,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool isDarkMode = false;

  final Color navyBlue = const Color(0xFF000080);

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color scaffoldBg = isDarkMode ? Colors.black : Colors.white;
    Color mainColor = isDarkMode ? Colors.white : navyBlue;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    // List of widgets for each tab
    final List<Widget> pages = [
      // Home
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCountdownAttendanceContainer(textColor, mainColor),
              const SizedBox(height: 20),
              Text(
                "Events",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildEventContainer(textColor, mainColor),
              const SizedBox(height: 20),
              Text(
                "Announcements",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnnouncementContainer(textColor, mainColor),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular Products",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to products page
                      setState(() {
                        _selectedIndex = 3; // Products tab index
                      });
                    },
                    child: Text(
                      "See More",
                      style: TextStyle(
                        color: mainColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                
              ),
              const SizedBox(height: 16),
              _buildPopularProductsGrid(textColor, mainColor),
            ],
          ),
        ),
      ),
      // Services: Only Events, Attendance, Records
      const AfprotechServicesScreen(),
      // Announcements
      const AfprotechAnnouncementsScreen(showHeader: false),
      // Products Page
      const AfprotechProductsScreen(showHeader: false),
      // Profile Page
      const AfprotechProfileScreen(showHeader: false),
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Image.asset(
                widget.assetPath,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.orgName,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
            ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: navyBlue,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: scaffoldBg,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.wrench),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bullhorn),
            label: "Announcements",
          ),
          BottomNavigationBarItem(
           icon: FaIcon(FontAwesomeIcons.cartShopping),
            label: "Product",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownAttendanceContainer(Color textColor, Color mainColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF000080),
            const Color(0xFF000080).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.clock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "ATTENDANCE COUNTDOWN",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Countdown Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCountdownItem("23", "Hours", Colors.white),
              _buildCountdownItem("45", "Minutes", Colors.white),
              _buildCountdownItem("12", "Seconds", Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProductsGrid(Color textColor, Color mainColor) {
    // Popular products data
    final List<Map<String, String>> products = [
      {
        'name': 'Fresh Bread',
        'price': '₱45.00',
        'image': '🍞',
      },
      {
        'name': 'Cheese',
        'price': '₱120.00',
        'image': '🧀',
      },
      {
        'name': 'Milk',
        'price': '₱65.00',
        'image': '🥛',
      },
      {
        'name': 'Cookies',
        'price': '₱35.00',
        'image': '🍪',
      },
    ];

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 12,
              right: index == products.length - 1 ? 0 : 0,
            ),
            child: SizedBox(
              width: 180,
              child: _buildProductCard(product, textColor, mainColor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product, Color textColor, Color mainColor) {
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
      child: const SizedBox.expand(),
    );
  }

  Widget _buildAnnouncementContainer(Color textColor, Color mainColor) {
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF000080).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.bullhorn,
                  color: Color(0xFF000080),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "ANNOUNCEMENT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000080),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider lines
          Container(
            height: 2,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF000080),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            "Intramurals 2025: Unity in Motion, Excellence in Action",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            "Intramurals 2025 is the annual athletic and team-building celebration bringing together students, faculty, and staff for a week-long showcase of sportsmanship, talent, and school spirit. Opening Ceremony: February 10, 2025. Game Schedule: February 10-15, 2025.",
            style: TextStyle(
              fontSize: 15,
              color: textColor.withValues(alpha: 0.8),
              height: 1.5,
              letterSpacing: 0.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Date
          Text(
            "Posted: Dec 10, 2025",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventContainer(Color textColor, Color mainColor) {
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.calendarDays,
                  color: Color(0xFFF44336),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "EVENT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF44336),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider lines
          Container(
            height: 2,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF44336),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            "Intramurals 2025: Unity in Motion, Excellence in Action",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          
          // Event Details (condensed for dashboard)
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                "November 2025",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                "USTP MOBOD",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            "Join us for the annual Intramurals 2025! A week-long celebration of sportsmanship, talent, and school spirit featuring basketball, volleyball, badminton, and many more exciting events.",
            style: TextStyle(
              fontSize: 15,
              color: textColor.withValues(alpha: 0.8),
              height: 1.5,
              letterSpacing: 0.2,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // Date
          Text(
            "Posted: Dec 10, 2025",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
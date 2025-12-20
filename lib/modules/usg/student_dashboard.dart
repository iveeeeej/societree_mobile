import 'package:centralized_societree/modules/usg/controllers/student_dashboard_controller.dart';
import 'package:centralized_societree/modules/usg/model/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
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
  final StudentDashboardController _controller = Get.put(StudentDashboardController());
  
  // Announcement data state
  int _announcementCount = 0;
  bool _isLoadingAnnouncements = true;
  List<Announcement> _recentAnnouncements = [];

  @override
  void initState() {
    super.initState();
    // Fetch announcements data when dashboard loads
    _fetchAnnouncementsData();
  }

  Future<void> _fetchAnnouncementsData() async {
    try {
      setState(() {
        _isLoadingAnnouncements = true;
      });
      
      // Use your existing ApiService method to get announcements
      final response = await widget.apiService.getAnnouncements();
      
      if (response['success'] == true) {
        // Get the count from the response (from usg_announcement_retrieve.php)
        final count = response['count'] ?? 0;
        
        // Also get the list of announcements for the recent section
        final List<dynamic> data = response['announcements'] ?? [];
        final announcements = data.map((item) {
          return Announcement.fromJson(Map<String, dynamic>.from(item));
        }).toList();
        
        // Take only the most recent 3 for the dashboard preview
        final recentAnnouncements = announcements.take(3).toList();
        
        setState(() {
          _announcementCount = count;
          _recentAnnouncements = recentAnnouncements;
          _isLoadingAnnouncements = false;
        });
      } else {
        // If API call fails, fall back to 0
        setState(() {
          _announcementCount = 0;
          _recentAnnouncements = [];
          _isLoadingAnnouncements = false;
        });
      }
      
    } catch (e) {
      print('Error fetching announcements: $e');
      setState(() {
        _announcementCount = 0;
        _recentAnnouncements = [];
        _isLoadingAnnouncements = false;
      });
    }
  }

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

  Widget _buildHomeScreen(BuildContext context) {
    return Container(
      color: const Color(0xFFf8f9fa),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: GoogleFonts.oswald(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.orgName,
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e174a),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Quick Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildAnnouncementsCard(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.event,
                    value: '0',
                    label: 'Events',
                    color: const Color(0xFF2ecc71),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    value: '0',
                    label: 'Attendance',
                    color: const Color(0xFF9b59b6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.gavel,
                    value: '0',
                    label: 'Violations',
                    color: const Color(0xFFe74c3c),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Vision & Mission Card
            Obx(() => GestureDetector(
              onTap: () => _controller.toggleCardExpansion(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1e174a),
                      Color(0xFFf9a702),
                      Color(0xFF737373),
                    ],
                    stops: [0.2, 0.5, 0.8],
                    transform: GradientRotation(135 * (3.1415926535 / 180)),
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6F42C1).withOpacity(0.4),
                      blurRadius: 20.0,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Vision & Mission',
                          style: GoogleFonts.oswald(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _controller.isCardExpanded.value 
                          ? CrossFadeState.showSecond 
                          : CrossFadeState.showFirst,
                      firstChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vision preview
                          Text(
                            'Vision',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The University Student Government - Oroquieta of University of Science and Technology of Southern Philippines will facilitate Oroquieta Campus organizations...',
                            style: GoogleFonts.oswald(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.justify,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Vision
                          Text(
                            'Vision',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The University Student Government - Oroquieta of University of Science and Technology of Southern Philippines will facilitate Oroquieta Campus organizations and promote the interest of students to further cultivate and engage into a conscientious community of student leaders in achieving the common goal.',
                            style: GoogleFonts.oswald(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 16),
                          
                          // Mission with divider
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          
                          Text(
                            'Mission',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We, the University Student Government – Oroquieta of University of Science and Technology of Southern Philippines, promote the welfare and unity of the student community through advocacy for and representation of the undergraduates\' student bodies\' diverse interests, concerns and needs. As advocates for undergraduate students, we work to facilitate change and respond to the challenges in our community through active outreach to the student body in a productive partnership with the University administration. In order to strengthen the undergraduate students\' community, we encourage students\' involvement and leadership development through accredited students\' organizations, University committee and USG Oroquieta.',
                            style: GoogleFonts.oswald(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                    
                    // View More/Less Button
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _controller.isCardExpanded.value ? 'Show Less' : 'Read More',
                              style: GoogleFonts.oswald(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _controller.isCardExpanded.value 
                                  ? Icons.keyboard_arrow_up 
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 16),

            // Recent Announcements Preview
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Announcements',
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1e174a),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf8f9fa),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _recentAnnouncements.isEmpty ? 'Empty' : '${_recentAnnouncements.length} New',
                          style: TextStyle(
                            color: _recentAnnouncements.isEmpty 
                                ? const Color(0xFF666666)
                                : const Color(0xFFe74c3c),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Actual announcements list or placeholder
                  if (_recentAnnouncements.isEmpty && !_isLoadingAnnouncements)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8f9fa),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No announcements yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                          ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for updates',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_isLoadingAnnouncements)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf8f9fa),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1e174a)),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _recentAnnouncements.map((announcement) {
                        return _buildAnnouncementItem(announcement);
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3498db).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.campaign,
              color: Color(0xFF3498db),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingAnnouncements)
            const SizedBox(
              height: 24,
              width: 40,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1e174a)),
                ),
              ),
            )
          else
            Text(
              '$_announcementCount',
              style: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1e174a),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Announcements',
            style: GoogleFonts.oswald(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1e174a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.oswald(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(Announcement announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  announcement.title,
                  style: GoogleFonts.oswald(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1e174a),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (announcement.type != null && announcement.type!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Announcement.getColorForType(announcement.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.type!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.content.length > 100
                ? '${announcement.content.substring(0, 100)}...'
                : announcement.content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.formattedDate,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Icon(
                Announcement.getIconForType(announcement.type),
                color: Announcement.getColorForType(announcement.type),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
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
        _controller.toggleMenuState(isOpen);
      },
      onHomeTap: _handleHomeTap,
      onLogoutTap: _handleLogoutTap,
      onTermsTap: _handleTermsTap,
    );
  }
}
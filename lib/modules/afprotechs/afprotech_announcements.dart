import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AfprotechAnnouncementsScreen extends StatefulWidget {
  final bool showHeader;

  const AfprotechAnnouncementsScreen({super.key, this.showHeader = true});

  @override
  State<AfprotechAnnouncementsScreen> createState() => _AfprotechAnnouncementsScreenState();
}

class _AfprotechAnnouncementsScreenState extends State<AfprotechAnnouncementsScreen> {
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
            Text(
              "Announcements",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildAnnouncementContainer(textColor, mainColor),
          ],
        ),
      ),
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
            "Intramurals 2025 - Event Content\n\nEvent Title: Intramurals 2025\nTheme: \"Unity in Motion, Excellence in Action\"\n\nEvent Overview\nIntramurals 2025 is the annual athletic and team-building celebration bringing together students, faculty, and staff for a week-long showcase of sportsmanship, talent, and school spirit. This year features new sports, enhanced scoring, and interactive activities for all participants.\n\nObjectives\n• Promote teamwork and camaraderie\n• Encourage physical fitness and healthy competition\n• Strengthen school spirit and community involvement\n• Discover and develop student athletic talent\n\nFeatured Sports & Activities\nMajor Sports: Basketball (Men/Women), Volleyball (Men/Women), Badminton (Singles/Doubles), Table Tennis, Chess, Athletics (Track & Field Events)\n\nFun Games: Tug of War, Obstacle Course, Sack Race, Relay Games\n\nShowcase Events: Cheer Dance Competition, Mr. & Ms. Intramurals 2025, Drum & Lyre Exhibition, Torch Lighting Ceremony\n\nImportant Dates\n• Opening Ceremony: February 10, 2025\n• Game Schedule: February 10-15, 2025\n• Cheerdance Finals: February 12, 2025\n• Championship Day: February 15, 2025\n• Awarding Ceremony: February 15, 2025 (Evening)\n\nScoring System\n1st Place - 100 points\n2nd Place - 70 points\n3rd Place - 50 points\n4th Place - 30 points\nParticipation - 10 points each event\n\nAnnouncements\n• Full game schedule will be posted 1 week before the event\n• All players must present ID and wear official team uniforms\n• Medical staff will be on standby throughout the intramurals\n• Weather delays will be announced on the official page\n\nMedia & Documentation\nA dedicated media team will cover all events. Photos and results will be uploaded daily on the school platform.",
            style: TextStyle(
              fontSize: 15,
              color: textColor.withValues(alpha: 0.8),
              height: 1.5,
              letterSpacing: 0.2,
            ),
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
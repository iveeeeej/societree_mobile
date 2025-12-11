import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventsScreen extends StatefulWidget {
  final bool showHeader;
  
  const EventsScreen({super.key, this.showHeader = true});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final Color navyBlue = const Color(0xFF000080);

  @override
  Widget build(BuildContext context) {
    Widget content = widget.showHeader
        ? SafeArea(
            child: Column(
              children: [
                // HEADER AREA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      Text(
                        "Events",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: navyBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // MAIN CONTENT SCROLL
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          )
        : _buildContent();

    return Scaffold(
      backgroundColor: Colors.white,
      body: content,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Events",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _buildEventContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
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
            "Intramurals 2025",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          
          // Event Details
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "November 2025",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "8:00 AM - 5:00 PM",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                "USTP MOBOD",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            "Join us for the annual Intramurals 2025! A week-long celebration of sportsmanship, talent, and school spirit featuring basketball, volleyball, badminton, and many more exciting events. All students, faculty, and staff are welcome to participate.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withValues(alpha: 0.8),
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
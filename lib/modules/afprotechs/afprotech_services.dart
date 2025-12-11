
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'afprotech_events.dart';
import 'afprotech_qr_attendance.dart';

class AfprotechServicesScreen extends StatelessWidget {
  const AfprotechServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const navyBlue = Color(0xFF000080);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EVENTS: red
              Flexible(
                child: _serviceMenuCard(
                  context: context,
                  icon: FontAwesomeIcons.calendarDays,
                  label: 'Events',
                  color: const Color(0xFFF44336), // Red
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EventsScreen(showHeader: true),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Flexible(
                child: _serviceMenuCard(
                  context: context,
                  icon: FontAwesomeIcons.idBadge,
                  label: 'Attendance',
                  color: navyBlue,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QrScannerPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RECORDS: green
              Flexible(
                child: _serviceMenuCard(
                  context: context,
                  icon: FontAwesomeIcons.chartColumn,
                  label: 'Records',
                  color: const Color(0xFF4CAF50), // Green
                  onTap: () {
                    // Records functionality - can be implemented later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Records feature coming soon!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

Widget _serviceMenuCard({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  VoidCallback? onTap,
  IconData? qrIcon, // Add optional qrIcon
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
    constraints: const BoxConstraints(
      maxWidth: 155,
      minWidth: 120,
      maxHeight: 155,
      minHeight: 120,
    ),
    child: AspectRatio(
      aspectRatio: 1.0,
      child: Material(
        color: Colors.white, // solid white background for the card
        borderRadius: BorderRadius.circular(16),
        elevation: 12,
        shadowColor: Colors.black26.withValues(alpha: 0.07),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: color, // solid color, no blur/opacity
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(17),
                        child: FaIcon(icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (qrIcon != null)
                  Positioned(
                    bottom: 12,
                    right: 18,
                    child: Icon(qrIcon, color: color, size: 28),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Standalone services screen for navigation
class AfprotechServicesPage extends StatelessWidget {
  const AfprotechServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF000080),
      ),
      body: const AfprotechServicesScreen(),
    );
  }
}
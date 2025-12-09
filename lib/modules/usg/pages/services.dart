import 'package:centralized_societree/modules/usg/reusables/qr_scanner.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample services data
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Attendance',
        'description': 'Scan your ID\'s QR to sign in for attendance',
        'icon': Icons.assignment_ind,
        'color': Colors.green,
      },

      {
        'title': 'Violations',
        'description': 'Comming soon!',
        'icon': Icons.warning_rounded,
        'color': Colors.red,
      },
      {
        'title': 'Lost and Found',
        'description': 'Comming soon!',
        'icon': Icons.question_mark_rounded,
        'color': Colors.purple,
      },
      {
        'title': 'Borrow',
        'description': 'Coming soon!',
        'icon': Icons.repeat,
        'color': Colors.grey,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.9, // Height relative to width
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () {
              // For Attendance card only
              if (service['title'] == 'Attendance') {
                // Navigate to QR Scanner page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              } else {
                // For other services, show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: ${service['title']}')),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: service['color'],
                  radius: 30,
                  child: Icon(service['icon'], size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    service['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    service['description'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'club_details_page.dart';

class DiscoverClubsPage extends StatelessWidget {
  const DiscoverClubsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of clubs with their corresponding logo asset paths.
    // Put your logo images in `assets/images/` and ensure the filenames match.
    final List<Map<String, String>> clubs = <Map<String, String>>[
      {
        'name': 'G-CLIFF',
        'logo': 'assets/images/gcliff_logo.png',
      },
      {
        'name': 'Fashion Icon',
        'logo': 'assets/images/fashion_icon_logo.png',
      },
      {
        'name': 'LGDC',
        'logo': 'assets/images/lgdc_logo.png',
      },
      {
        'name': 'Himig Malaya',
        'logo': 'assets/images/himig_malaya_logo.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Clubs'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final club = clubs[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF00B894).withOpacity(0.12),
              // Use the club logo if it exists; otherwise fall back to an icon.
              foregroundImage: AssetImage(club['logo']!),
              child: const Icon(Icons.explore, color: Color(0xFF00B894)),
            ),
            title: Text(
              club['name']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClubDetailsPage(
                    clubName: club['name']!,
                    clubDescription: 'Learn more and join ${club['name']}',
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: clubs.length,
      ),
    );
  }
}



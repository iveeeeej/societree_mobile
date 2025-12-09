import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample announcement data
    final List<Map<String, dynamic>> announcements = [
      {
        'title': 'Campus Clean-up Day',
        'date': 'March 15, 2024',
        'content': 'Join us for campus clean-up day this Saturday!',
        'icon': Icons.clean_hands,
        'color': Colors.green,
      },
      {
        'title': 'Student Council Elections',
        'date': 'March 20, 2024',
        'content': 'Elections for the new student council will be held next week.',
        'icon': Icons.how_to_vote,
        'color': Colors.blue,
      },
      {
        'title': 'Library Extended Hours',
        'date': 'March 10, 2024',
        'content': 'The library will be open until 10 PM during finals week.',
        'icon': Icons.library_books,
        'color': Colors.purple,
      },
    ];

    // Build announcement content
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: announcement['color'],
              child: Icon(announcement['icon'], color: Colors.white),
            ),
            title: Text(
              announcement['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  announcement['date'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(announcement['content']),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected: ${announcement['title']}')),
              );
            },
          ),
        );
      },
    );
  }
}
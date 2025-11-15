import 'package:flutter/material.dart';
import 'package:centralized_societree/config/api_config.dart';

class StudentDashboard extends StatelessWidget {
  final String orgName;
  final String? assetPath;
  const StudentDashboard({super.key, this.orgName = 'USG', this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$orgName Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).pushNamed('/search', arguments: {
                'parties': const <Map<String, dynamic>>[],
                'candidates': const <Map<String, dynamic>>[],
                'isElecom': orgName.toUpperCase() == 'ELECOM',
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetPath != null && assetPath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Image.asset(
                  assetPath!,
                  height: 80,
                  errorBuilder: (c, e, s) => const Icon(Icons.groups, size: 64),
                ),
              ),
            Text(
              'Welcome to $orgName',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'API: $apiBaseUrl',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


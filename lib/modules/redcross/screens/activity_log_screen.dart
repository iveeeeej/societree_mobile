import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Activity> _activities = [
    Activity(
      title: 'Blood Donation Drive',
      description: 'Assisted in organizing blood donation event',
      date: DateTime(2024, 11, 1),
      hours: 4,
      location: 'USTP Court',
      points: 80,
      isVerified: true,
    ),
    Activity(
      title: 'First Aid Training',
      description: 'Completed first aid certification training',
      date: DateTime(2024, 11, 12),
      hours: 4,
      location: 'USTP Court',
      points: 80,
      isVerified: true,
    ),
    Activity(
      title: 'Community Outreach',
      description: 'Volunteered in community service program',
      date: DateTime(2024, 10, 25),
      hours: 6,
      location: 'Community Center',
      points: 100,
      isVerified: false,
    ),
  ];

  List<Activity> get _filteredActivities {
    if (_selectedFilter == 'All') {
      return _activities;
    } else if (_selectedFilter == 'Verified') {
      return _activities.where((a) => a.isVerified).toList();
    } else {
      return _activities.where((a) => !a.isVerified).toList();
    }
  }

  int get _totalHours => _activities.fold(0, (sum, a) => sum + a.hours);
  int get _totalPoints => _activities.fold(0, (sum, a) => sum + a.points);
  int get _verifiedCount => _activities.where((a) => a.isVerified).length;
  int get _pendingCount => _activities.where((a) => !a.isVerified).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Activity Log'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/Red Cross.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDC143C),
                  Color(0xFFE44D6B),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your impact snapshot',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Keep leading with action',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Hours',
                        value: '$_totalHours hrs',
                        accent: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Points',
                        value: '$_totalPoints pts',
                        accent: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search keyword',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterButton(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                ),
                const SizedBox(width: 10),
                _FilterButton(
                  label: 'Verified ($_verifiedCount)',
                  isSelected: _selectedFilter == 'Verified',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Verified';
                    });
                  },
                ),
                const SizedBox(width: 10),
                _FilterButton(
                  label: 'Pending ($_pendingCount)',
                  isSelected: _selectedFilter == 'Pending',
                  onTap: () {
                    setState(() {
                      _selectedFilter = 'Pending';
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Activity List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredActivities.length,
              itemBuilder: (context, index) {
                final activity = _filteredActivities[index];
                final searchQuery = _searchController.text.toLowerCase();

                if (searchQuery.isNotEmpty &&
                    !activity.title.toLowerCase().contains(searchQuery) &&
                    !activity.description.toLowerCase().contains(searchQuery)) {
                  return const SizedBox.shrink();
                }

                return _ActivityCard(activity: activity);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    this.accent = const Color(0xFFFCE4EF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDC143C) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFFDC143C) : Colors.grey[300]!,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFDC143C).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 52,
                decoration: BoxDecoration(
                  color: activity.isVerified ? const Color(0xFF3EB86E) : const Color(0xFFF2994A),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: activity.isVerified ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      activity.isVerified ? Icons.verified : Icons.hourglass_bottom,
                      color: activity.isVerified ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      activity.isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: activity.isVerified ? Colors.green[800] : Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today,
                text: _formatDate(activity.date),
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.access_time,
                text: '${activity.hours} hours',
              ),
              const SizedBox(width: 10),
              _InfoChip(
                icon: Icons.location_on,
                text: activity.location,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+${activity.points} points',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}


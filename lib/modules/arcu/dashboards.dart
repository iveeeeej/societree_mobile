import 'package:flutter/material.dart';
import 'homepage.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select your role',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You can change this later from settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    _RoleButton(
                      label: "I'm a Student",
                      icon: Icons.school,
                      color: const Color(0xFF6C5CE7),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const StudentDashboard(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _RoleButton(
                      label: "I'm an Admin",
                      icon: Icons.admin_panel_settings,
                      color: const Color(0xFFE17055),
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboard(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the existing HomePage as the student dashboard experience.
    return const HomePage();
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _chipIndex = 0;

  final List<_AdminItem> _allItems = const <_AdminItem>[
    _AdminItem(
      title: 'Events',
      subtitle: 'Create, edit and manage',
      icon: Icons.event_note,
      color: Color(0xFF6C5CE7),
      routeBuilder: AdminEventsPage.new,
    ),
    _AdminItem(
      title: 'Clubs',
      subtitle: 'Create, manage and edit',
      icon: Icons.groups,
      color: Color(0xFF00B894),
      routeBuilder: AdminClubsPage.new,
    ),
    _AdminItem(
      title: 'Members',
      subtitle: 'Manage club members',
      icon: Icons.people_alt_outlined,
      color: Color(0xFF74B9FF),
      routeBuilder: AdminMembersPage.new,
    ),
    _AdminItem(
      title: 'Feedback',
      subtitle: 'Hear from students',
      icon: Icons.feedback_outlined,
      color: Color(0xFFAF7AC5),
      routeBuilder: AdminFeedbackPage.new,
    ),
    _AdminItem(
      title: 'Announcements',
      subtitle: 'Post and manage updates',
      icon: Icons.campaign_outlined,
      color: Color(0xFF2ECC71),
      routeBuilder: AdminAnnouncementsPage.new,
    ),
    _AdminItem(
      title: 'Registrations',
      subtitle: 'Event registrations',
      icon: Icons.app_registration,
      color: Color(0xFF6C5CE7),
      routeBuilder: AdminEventRegistrationsPage.new,
    ),
  ];

  final List<String> _chips = const <String>[
    'All',
    'Events',
    'Clubs',
    'Members',
    'Announcements',
    'Registrations',
    'Feedback',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<_AdminItem> _filteredItems() {
    switch (_chips[_chipIndex]) {
      case 'Events':
        return _allItems
            .where((i) => i.title.contains('Event'))
            .toList(growable: false);
      case 'Clubs':
        return _allItems
            .where((i) => i.title.contains('Club'))
            .toList(growable: false);
      case 'Members':
        return _allItems
            .where((i) => i.title.contains('Member'))
            .toList(growable: false);
      case 'Announcements':
        return _allItems
            .where((i) => i.title.contains('Announcement'))
            .toList(growable: false);
      case 'Registrations':
        return _allItems
            .where((i) => i.title.contains('Registration'))
            .toList(growable: false);
      case 'Feedback':
        return _allItems
            .where((i) => i.title.contains('Feedback'))
            .toList(growable: false);
      default:
        return _allItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_AdminItem> items = _filteredItems();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE17055),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE17055), Color(0xFFD35400)],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_chips.length, (index) {
                  final bool selected = _chipIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(_chips[index]),
                      selected: selected,
                      onSelected: (_) => setState(() => _chipIndex = index),
                      selectedColor: const Color(0xFFE17055).withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: selected
                            ? const Color(0xFFE17055)
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                _MiniStat(title: 'Pending', value: '5'),
                SizedBox(width: 12),
                _MiniStat(title: 'Events', value: '12'),
                SizedBox(width: 12),
                _MiniStat(title: 'Clubs', value: '8'),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AdminListTile(
                title: item.title,
                subtitle: item.subtitle,
                icon: item.icon,
                accentColor: item.color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.routeBuilder()),
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _AdminItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget Function() routeBuilder;
  const _AdminItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routeBuilder,
  });
}

class _AdminListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  const _AdminListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: accentColor.withOpacity(0.15), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Simple placeholder pages for admin actions ---
class AdminCreateEventPage extends StatelessWidget {
  const AdminCreateEventPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'Create Event');
  }
}

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'View Events');
  }
}

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'Student Feedback');
  }
}

class AdminClubsPage extends StatelessWidget {
  const AdminClubsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'Clubs');
  }
}

class AdminMembersPage extends StatelessWidget {
  const AdminMembersPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'Members');
  }
}

class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'Announcements');
  }
}

class AdminEventRegistrationsPage extends StatelessWidget {
  const AdminEventRegistrationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _ScaffoldStub(title: 'Event Registrations');
  }
}

class _ScaffoldStub extends StatelessWidget {
  final String title;
  const _ScaffoldStub({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFE17055),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Coming soon...', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

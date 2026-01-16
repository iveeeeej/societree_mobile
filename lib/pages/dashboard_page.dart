import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:societree_mobile/components/button.dart';
import 'package:societree_mobile/pages/login_page.dart';
import 'dart:async';
import 'dart:ui';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final PageController _pageCtrl;
  Timer? _autoTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final total = _bannerAssets.length;
      if (total == 0) return;
      _current = (_current + 1) % total;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          _current,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  List<String> get _bannerAssets => const [
    'assets/org_logos/usg.png',
    'assets/org_logos/elecom.png',
    'assets/org_logos/site.png',
    'assets/org_logos/pafe.png',
    'assets/org_logos/afprotech.png',
    'assets/org_logos/arcu.png',
    'assets/org_logos/access.png',
    'assets/org_logos/redcross.png',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = const Color.fromARGB(115, 89, 98, 105);

    final orgs = <_OrgItem>[
      _OrgItem('USG', 'assets/org_logos/usg.png'),
      _OrgItem('ELECOM', 'assets/org_logos/elecom.png'),
      _OrgItem('SITE', 'assets/org_logos/site.png'),
      _OrgItem('PAFE', 'assets/org_logos/pafe.png'),
      _OrgItem('AFPROTECHS', 'assets/org_logos/afprotech.png'),
      _OrgItem('ARCU', 'assets/org_logos/arcu.png'),
      _OrgItem('ACCESS', 'assets/org_logos/access.png'),
      _OrgItem('REDCROSS', 'assets/org_logos/redcross.png'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF8bc53f),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/org_logos/societree_2.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.park, size: 20, color: Colors.green),
            ),
            const SizedBox(width: 8),
            Text(
              'SocieTREE',
              style: GoogleFonts.oswald(
                color: Color(0xFF5b4c4a),
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle), iconSize: 25, color: Color(0xFF5b4c4a),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('Profile UI Coming Soon')),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_outlined), iconSize: 25, color: Color(0xFF5b4c4a),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                barrierDismissible: true,
                builder: (ctx) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        'Logout',
                        style: GoogleFonts.oswald(
                          fontSize: 25,
                        ),
                      ),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        myButton(context, 'Logout', (){
                          Get.offAndToNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          )
                        )
                        )
                      ],
                    ),
                  );
                },
              );
              if (ok == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About card with slideshow
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 160,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: PageView.builder(
                                controller: _pageCtrl,
                                itemCount: _bannerAssets.length,
                                onPageChanged: (i) =>
                                    setState(() => _current = i),
                                itemBuilder: (context, index) {
                                  final path = _bannerAssets[index];
                                  return Container(
                                    color: Colors.grey.shade100,
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      path,
                                      height: 120,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => const Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              child: Row(
                                children: List.generate(
                                  _bannerAssets.length,
                                  (i) {
                                    final active = i == _current;
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      height: 6,
                                      width: active ? 14 : 6,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? Colors.black54
                                            : Colors.black26,
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'ABOUT',
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                          color: Color(0xFF23176f),
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SocieTREE is an innovative digital ecosystem at the University of Science and Technology of Southern Philippines (USTP) that unites and empowers the diverse student organizations across campus. Acting as both a technological platform and community hub, SocieTREE facilitates seamless collaboration, enhances student engagement, and nurtures the next generation of leaders through integrated digital solutions.\n\nAs the central nexus for USTP\'s vibrant organizational landscape, SocieTREE cultivates a culture of excellence, innovation, and civic responsibility. The platform supports a thriving network of student groups, including:',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'USTP ORGANIZATIONS',
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                          color: Color(0xFF23176f),
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Explore various student organizations in USTP Oroquieta',
                        style: GoogleFonts.oswald(
                          fontSize: 15,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemCount: orgs.length,
                    itemBuilder: (context, index) {
                      final it = orgs[index];
                      return _OrgCard(
                        item: it,
                        onTap: () {
                          final routeMap = {
                            'USG': '/usg',
                            'ELECOM': '/elecom',
                            'SITE': '/site',
                            'PAFE': '/pafe',
                            'AFPROTECHS': '/afprotech',
                            'ARCU': '/arcu',
                            'ACCESS': '/access',
                            'REDCROSS': '/redcross',
                          };
                          final route = routeMap[it.name.toUpperCase()];
                          if (route != null) {
                            Get.toNamed(route);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrgItem {
  final String name;
  final String assetPath;
  const _OrgItem(this.name, this.assetPath);
}

class _OrgCard extends StatelessWidget {
  final _OrgItem item;
  final VoidCallback onTap;
  const _OrgCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromARGB(60, 89, 98, 105),
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Image.asset(
                item.assetPath,
                width: 500,
                height: 500,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.school, size: 28, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                item.name,
                style: GoogleFonts.oswald(
                  fontSize: 15,
                  color: Color(0xFF2e2a2b),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
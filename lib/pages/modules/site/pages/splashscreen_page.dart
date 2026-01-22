import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:societree_mobile/pages/modules/site/pages/home_page.dart';

class SiteSplashscreenPage extends StatefulWidget {
  const SiteSplashscreenPage({super.key});

  @override
  State<SiteSplashscreenPage> createState() => _SiteSplashscreenPageState();
}

class _SiteSplashscreenPageState extends State<SiteSplashscreenPage> {
  @override
  void initState() {
    super.initState();
    // Wait 2 seconds, then go to main dashboard
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/splash_screens/site.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Logo and text in center
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Container(
                    //     height: 220,
                    //     width: 220,
                    //     child: Image.asset(
                    //       'assets/org_logos/site.png',
                    //       fit: BoxFit.fitHeight,
                    //     ),
                    //   ),
                    // ),
                    
                    // Label text
                    Text(
                      'SOCIETY OF INFORMATION TECHNOLOGY ENTHUSIAST',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    
                    // Loading indicator
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
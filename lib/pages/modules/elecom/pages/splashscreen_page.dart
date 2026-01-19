import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:societree_mobile/pages/modules/elecom/pages/home_page.dart';

class ElecomSplashscreenPage extends StatefulWidget {
  const ElecomSplashscreenPage({super.key});

  @override
  State<ElecomSplashscreenPage> createState() => _ElecomSplashscreenPageState();
}

class _ElecomSplashscreenPageState extends State<ElecomSplashscreenPage> {
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
            'assets/splash_screens/usg.png',
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 220,
                        width: 220,
                        child: Image.asset(
                          'assets/org_logos/elecom.png',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    
                    // Label text
                    Text(
                      'Electoral Commission',
                      style: GoogleFonts.oswald(
                        color: Color(0xFF0d0c0a),
                        fontSize: 25,
                      ),
                    ),
                    
                    // Loading indicator
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      color: Color(0xFF0d0c0a),
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
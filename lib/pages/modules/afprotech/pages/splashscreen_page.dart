import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:societree_mobile/pages/modules/afprotech/pages/home_page.dart';

class AfproSplashscreenPage extends StatefulWidget {
  const AfproSplashscreenPage({super.key});

  @override
  State<AfproSplashscreenPage> createState() => _AfproSplashscreenPageState();
}

class _AfproSplashscreenPageState extends State<AfproSplashscreenPage> {
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
                          'assets/org_logos/afprotech.png',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    
                    // Label text
                    Text(
                      'Associaton of Food Processing and Technology Students',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        color: Color(0xFF0d0c0a),
                        fontSize: 22,
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
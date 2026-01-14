// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 2 seconds, then go to login page
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: 200,
                        child: Image.asset(
                          'assets/org_logos/societree_2_transparent.png',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    
                    // Loading indicator
                    CircularProgressIndicator(
                      color: Color(0xFF8bc53f),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
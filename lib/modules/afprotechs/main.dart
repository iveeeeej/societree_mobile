import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'afprotech_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(
        orgName: 'AFPROTECHS',
        assetPath: 'assets/images/AFPROTECH.png',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:societree_mobile/components/qr_scanner.dart';
import 'package:societree_mobile/pages/dashboard_page.dart';
import 'package:societree_mobile/pages/login_page.dart';
import 'package:societree_mobile/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/access/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/afprotech/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/arcu/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/elecom/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/pafe/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/redcross/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/site/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/usg/pages/splashscreen_page.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SocieTREE',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/scanner', page: () => QrScanner()),
        GetPage(name: '/dashboard', page: () => DashboardPage()),
        GetPage(name: '/usg', page: () => UsgSplashscreenPage()),
        GetPage(name: '/elecom', page: () => ElecomSplashscreenPage()),
        GetPage(name: '/site', page: () => SiteSplashscreenPage()),
        GetPage(name: '/pafe', page: () => PafeSplashscreenPage()),
        GetPage(name: '/afprotech', page: () => AfproSplashscreenPage()),
        GetPage(name: '/arcu', page: () => ArcuSplashscreenPage()),
        GetPage(name: '/access', page: () => AccessSplashscreenPage()),
        GetPage(name: '/redcross', page: () => RedSplashscreenPage()),
      ],
    );
  }
}
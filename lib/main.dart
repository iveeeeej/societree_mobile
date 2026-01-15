import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:societree_mobile/pages/dashboard_page.dart';
import 'package:societree_mobile/pages/login_page.dart';
import 'package:societree_mobile/pages/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/access/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/afprotech/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/arcu/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/elecom/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/pafe/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/redcross/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/site/splashscreen_page.dart';
import 'package:societree_mobile/pages/modules/usg/splashscreen_page.dart';

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
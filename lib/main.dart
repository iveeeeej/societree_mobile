import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:societree_mobile/pages/login_page.dart';
import 'package:societree_mobile/pages/splash_screen.dart';


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
      ],
    );
  }
}
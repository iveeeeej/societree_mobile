// import 'package:flutter/material.dart';
// import 'homepage.dart';
// import 'dashboards.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   ThemeMode _themeMode = ThemeMode.light;

//   void _toggleThemeMode() {
//     setState(() {
//       _themeMode = _themeMode == ThemeMode.light
//           ? ThemeMode.dark
//           : ThemeMode.light;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Arts & Culture App',
//       theme: ThemeData(
//         colorSchemeSeed: const Color(0xFFB00020),
//         brightness: Brightness.light,
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData(
//         colorSchemeSeed: const Color(0xFFB00020),
//         brightness: Brightness.dark,
//         useMaterial3: true,
//       ),
//       themeMode: _themeMode,
//       home: HomePage(onToggleTheme: _toggleThemeMode),
//       debugShowCheckedModeBanner: false,
//       routes: {
//         '/student': (_) => const StudentDashboard(),
//         '/admin': (_) => const AdminDashboard(),
//         '/home': (_) => HomePage(onToggleTheme: _toggleThemeMode),
//       },
//     );
//   }
// }

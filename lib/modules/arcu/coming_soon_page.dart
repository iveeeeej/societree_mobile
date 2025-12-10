import 'package:flutter/material.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  const ComingSoonPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 121, 3, 3),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Coming soon...', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}



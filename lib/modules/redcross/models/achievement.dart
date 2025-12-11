import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final int points;
  final Color color;
  final IconData icon;

  Achievement({
    required this.title,
    required this.description,
    required this.points,
    required this.color,
    required this.icon,
  });
}


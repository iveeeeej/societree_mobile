import 'package:flutter/material.dart';

ElevatedButton myButton(
  BuildContext context,
  String label,
  VoidCallback onTap, {
  ButtonStyle? style,
  double fontSize = 16,
  }) {
  return ElevatedButton(
    onPressed: onTap,
    style: style,
    child: Text(
      label,
      style: TextStyle(fontSize: fontSize),
    ),
  );
}
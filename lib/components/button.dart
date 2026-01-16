import 'package:flutter/material.dart';

ElevatedButton myButton(
  BuildContext context,
  String label,
  VoidCallback onTap, {
  ButtonStyle? style,
  }) {
  return ElevatedButton(
    onPressed: onTap,
    style: style,
    child: Text(label),
  );
}
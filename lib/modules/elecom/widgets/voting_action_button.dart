import 'package:flutter/material.dart';

class VotingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String label;
  final bool compact;
  final bool fullWidth;

  const VotingActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.compact = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btn = FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        minimumSize: compact ? const Size(0, 40) : null,
        padding: compact ? const EdgeInsets.symmetric(horizontal: 16) : null,
      ),
      icon: icon ?? const SizedBox.shrink(),
      label: Text(label),
    );
    if (fullWidth && !compact) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}

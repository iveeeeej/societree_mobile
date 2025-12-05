import 'package:flutter/material.dart';

enum ElecomButtonVariant { primary, text }

class ElecomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ElecomButtonVariant variant;
  final bool fullWidth;

  const ElecomButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
  }) : variant = ElecomButtonVariant.primary;

  const ElecomButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  }) : variant = ElecomButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild(context);
    if (!fullWidth) return child;
    return SizedBox(width: double.infinity, child: child);
  }

  Widget _buildChild(BuildContext context) {
    switch (variant) {
      case ElecomButtonVariant.primary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6E63F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: icon == null
              ? Text(label)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
        );
      case ElecomButtonVariant.text:
        final style = TextButton.styleFrom(padding: EdgeInsets.zero);
        return TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.chevron_right, size: 18),
          label: Text(label),
          style: style,
        );
    }
  }
}

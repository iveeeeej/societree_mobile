import 'package:flutter/material.dart';
import 'dart:ui';

class AppColors {
  // Brand-aligned palette (pulled from the logo’s blues / teals / violet)
  static const primary = Color(0xFF0F172A); // text/ink
  static const accent = Color(0xFF19B6D2); // teal ribbon
  static const accentDeep = Color(0xFF2D6CDF); // blue ribbon
  static const accentViolet = Color(0xFF4B2BAE); // violet base
  static const amber = Color(0xFFFFC857);
  static const card = Color(0xFFF8FAFC);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF6B7280);
  static const surface = Color(0xFFFFFFFF);
}

class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 18,
    this.tint = Colors.white,
    this.opacity = 0.18,
    this.stroke = 0.6,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color tint;
  final double opacity;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(stroke)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class RibbonMarker extends StatelessWidget {
  const RibbonMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 26, height: 3, decoration: BoxDecoration(color: AppColors.accentDeep, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Container(width: 18, height: 3, decoration: BoxDecoration(color: AppColors.accentViolet, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Container(width: 12, height: 3, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4))),
      ],
    );
  }
}

class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, this.size = 42, this.elevation = true});

  final double size;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: elevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/ACCESS.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, Color(0xFF22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'A',
                style: appTextStyle(weight: FontWeight.w800, color: Colors.white, size: size * 0.4),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F7FB), Color(0xFFF2F4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -30,
          child: _glowCircle(190, AppColors.accent.withOpacity(0.20)),
        ),
        Positioned(
          bottom: -80,
          left: -40,
          child: _glowCircle(230, AppColors.accentDeep.withOpacity(0.14)),
        ),
        Positioned(
          bottom: 120,
          right: 40,
          child: _glowCircle(110, AppColors.accentViolet.withOpacity(0.16)),
        ),
        child,
      ],
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

TextStyle appTextStyle({double size = 16, FontWeight weight = FontWeight.w500, Color? color}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.text,
    height: 1.3,
    letterSpacing: 0.1,
  );
}

BoxDecoration softCardDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? AppColors.card,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: appTextStyle(size: 18, weight: FontWeight.w700)),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: appTextStyle(size: 14, weight: FontWeight.w600, color: AppColors.accent)),
          ),
      ],
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: isDone
                ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)])
                : const LinearGradient(colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(isDone ? Icons.check : Icons.remove, size: 14, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: appTextStyle(size: 12, color: AppColors.muted)),
      ],
    );
  }
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.color,
    required this.title,
    required this.percent,
    this.height = 110,
    this.subtitle,
  });

  final Color color;
  final String title;
  final String? subtitle;
  final double percent;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: appTextStyle(weight: FontWeight.w700, color: Colors.white)),
          if (subtitle != null) Text(subtitle!, style: appTextStyle(size: 13, weight: FontWeight.w500, color: Colors.white70)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percent,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text('${(percent * 100).round()}%', style: appTextStyle(weight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class BadgeChip extends StatelessWidget {
  const BadgeChip({super.key, required this.label, this.icon, this.color});

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: (color ?? AppColors.accent).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color ?? AppColors.accent),
            const SizedBox(width: 6),
          ],
          Text(label, style: appTextStyle(weight: FontWeight.w700, size: 12, color: color ?? AppColors.accent)),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: softCardDecoration(color: AppColors.surface),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(title, style: appTextStyle()),
        trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}


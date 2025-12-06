import 'dart:async';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class GlowingVoteNowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool compact;

  const GlowingVoteNowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.compact = false,
  });

  @override
  State<GlowingVoteNowButton> createState() => _GlowingVoteNowButtonState();
}

class _GlowingVoteNowButtonState extends State<GlowingVoteNowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Timer _textTimer;
  int _phraseIndex = 0;
  static const List<String> _phrases = <String>[
    'Vote Now',
    'Cast your vote',
    'Make your voice heard',
    'Secure ballot',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _textTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!mounted) return;
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseBg = widget.enabled
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5));
    final textColor = widget.enabled
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.white70 : Colors.black54);

    final height = widget.compact ? 44.0 : 52.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final angle = _ctrl.value * 6.283185307179586; // 2*pi
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.24),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.12),
                      blurRadius: 42,
                      spreadRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: CustomPaint(
            painter: _RotatingBorderPainter(angle: angle, color: isDark ? Colors.white : Colors.black),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(height / 2),
                child: Container(
                  height: height,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: baseBg,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, child) {
                          // Simulate a ballot moving down into a box then lifting back up
                          final t = _ctrl.value; // 0..1
                          double y;
                          if (t < 0.6) {
                            // Insert phase: move from -6px to 0px smoothly
                            y = lerpDouble(-6, 0, Curves.easeInOut.transform(t / 0.6)) ?? 0;
                          } else {
                            // Lift phase: move back up quickly
                            final tt = (t - 0.6) / 0.4; // 0..1
                            y = lerpDouble(0, -6, Curves.easeOut.transform(tt.clamp(0.0, 1.0))) ?? -6;
                          }
                          return Transform.translate(
                            offset: widget.enabled ? Offset(0, y) : Offset.zero,
                            child: child,
                          );
                        },
                        child: Icon(Icons.how_to_vote, color: textColor, size: 20),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: Text(
                          widget.enabled ? _phrases[_phraseIndex] : widget.label,
                          key: ValueKey<int>(_phraseIndex * (widget.enabled ? 1 : 0)),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double angle; // radians
  final Color color;

  _RotatingBorderPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(size.height / 2));

    // Draw rotating glow ring using a sweep gradient
    final rect = r.outerRect.inflate(6);
    final sweep = SweepGradient(
      startAngle: angle,
      endAngle: angle + 6.283185307179586,
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(0.28),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    final glowPaint = Paint()
      ..shader = sweep.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    final path = Path()..addRRect(r);
    canvas.drawPath(path, glowPaint);

    // Inner subtle border
    final inner = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(r, inner);
  }

  @override
  bool shouldRepaint(covariant _RotatingBorderPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color;
}

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ActivityRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color? trackColor;
  final Widget? centerChild;
  final bool showGlow;

  const ActivityRing({
    super.key,
    required this.progress,
    this.size = 140,
    this.strokeWidth = 14,
    this.gradientColors = const [AppColors.primary, AppColors.accent],
    this.trackColor,
    this.centerChild,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTrackColor = trackColor ??
        (isDark ? const Color(0xFF242836) : const Color(0xFFE2E8F0));

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ActivityRingPainter(
                  progress: animatedProgress,
                  strokeWidth: strokeWidth,
                  gradientColors: gradientColors,
                  trackColor: defaultTrackColor,
                  showGlow: showGlow,
                ),
              );
            },
          ),
          ?centerChild,
        ],
      ),
    );
  }
}

class _ActivityRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color trackColor;
  final bool showGlow;

  _ActivityRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.trackColor,
    required this.showGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    final sweepAngle = 2 * pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 2. Draw Glow if enabled
    if (showGlow) {
      final glowPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: gradientColors,
          tileMode: TileMode.clamp,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        rect,
        -pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // 3. Draw Gradient Progress Arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: gradientColors,
        stops: const [0.0, 1.0],
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // 4. Draw End Cap Shadow for realistic 3D Apple ring overlap
    if (progress > 0.95) {
      final endAngle = -pi / 2 + sweepAngle;
      final capCenter = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );
      final capShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(capCenter, strokeWidth / 2, capShadowPaint);

      final capPaint = Paint()
        ..color = gradientColors.last
        ..style = PaintingStyle.fill;
      canvas.drawCircle(capCenter, strokeWidth / 2, capPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hermanos_ledgr/app/theme/text_theme.dart';

/// Custom circular progress ring for Savings Goals.
/// Renders a sleek radial arc with rounded caps and center indicator.
class GoalProgressRing extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;
  final bool showPercentText;

  const GoalProgressRing({
    super.key,
    required this.percentage,
    required this.color,
    this.size = 54,
    this.strokeWidth = 5.0,
    this.centerChild,
    this.showPercentText = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = percentage.clamp(0.0, 1.0);
    final percentInt = (clamped * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percentage: clamped,
              color: color,
              strokeWidth: strokeWidth,
              trackColor: color.withValues(alpha: 0.15),
            ),
          ),
          if (centerChild != null)
            centerChild!
          else if (showPercentText)
            Text(
              '$percentInt%',
              style: moneyStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.percentage,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (percentage > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * percentage;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.percentage != percentage ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

import 'package:flutter/material.dart';

/// Draws a dashed line from the ball toward the launch direction while
/// the player is dragging (the ball will fly the *opposite* way, so the
/// line is drawn from the ball back through the drag point to preview
/// the pull, slingshot style).
class AimLinePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;

  AimLinePainter({required this.from, required this.to, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const dashLength = 10.0;
    const gapLength = 8.0;
    final total = (to - from).distance;
    if (total < 1) return;
    final direction = (to - from) / total;

    var covered = 0.0;
    while (covered < total) {
      final segmentEnd = (covered + dashLength).clamp(0, total);
      canvas.drawLine(
        from + direction * covered,
        from + direction * segmentEnd.toDouble(),
        paint,
      );
      covered += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant AimLinePainter oldDelegate) => true;
}

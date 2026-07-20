import 'package:flutter/material.dart';

/// Draws the rope between two posts with a flag/knot marker whose
/// horizontal position reflects [ropePosition] (-1.0 .. 1.0).
class RopeView extends CustomPainter {
  final double ropePosition;

  RopeView({required this.ropePosition});

  static const _p1Color = Color(0xFF4EA8DE);
  static const _p2Color = Color(0xFFFF5E5E);

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final postMargin = size.width * 0.08;

    final postPaint = Paint()..color = Colors.white24;
    canvas.drawRect(
      Rect.fromLTWH(postMargin - 6, midY - 60, 12, 120),
      postPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - postMargin - 6, midY - 60, 12, 120),
      postPaint,
    );

    // Win-zone markers near each post.
    final zonePaint = Paint()..color = Colors.white10;
    canvas.drawRect(
      Rect.fromLTWH(postMargin, midY - 40, size.width * 0.12, 80),
      zonePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width - postMargin - size.width * 0.12,
        midY - 40,
        size.width * 0.12,
        80,
      ),
      zonePaint,
    );

    // Rope line.
    final ropePaint = Paint()
      ..color = const Color(0xFFD9B382)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(postMargin, midY),
      Offset(size.width - postMargin, midY),
      ropePaint,
    );

    // Knot / flag position: map -1..1 to the usable width between posts.
    final usableWidth = size.width - postMargin * 2;
    final knotX = size.width / 2 + (ropePosition * usableWidth / 2);

    final knotColor = ropePosition >= 0 ? _p1Color : _p2Color;
    final knotPaint = Paint()..color = knotColor;
    canvas.drawCircle(Offset(knotX, midY), 16, knotPaint);

    // Little flag above the knot.
    final flagPaint = Paint()..color = knotColor;
    final path = Path()
      ..moveTo(knotX, midY - 16)
      ..lineTo(knotX, midY - 46)
      ..lineTo(knotX + 22, midY - 36)
      ..lineTo(knotX, midY - 26)
      ..close();
    canvas.drawPath(path, flagPaint);
  }

  @override
  bool shouldRepaint(covariant RopeView oldDelegate) =>
      oldDelegate.ropePosition != ropePosition;
}

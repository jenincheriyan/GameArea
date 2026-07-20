import 'package:flutter/material.dart';

/// A simple hoop graphic: rim + net, centered on the given point.
class BasketWidget extends StatelessWidget {
  final double centerX;
  final double centerY;
  final double width;

  const BasketWidget({
    super.key,
    required this.centerX,
    required this.centerY,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: centerX - width / 2,
      top: centerY - 14,
      child: SizedBox(
        width: width,
        height: 46,
        child: Column(
          children: [
            Container(height: 6, decoration: BoxDecoration(
              color: const Color(0xFFFF5E5E),
              borderRadius: BorderRadius.circular(3),
            )),
            Expanded(
              child: CustomPaint(
                size: Size(width, 40),
                painter: _NetPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.4;
    const strands = 6;
    for (var i = 0; i <= strands; i++) {
      final topX = size.width * i / strands;
      final bottomX = size.width * 0.2 + size.width * 0.6 * i / strands;
      canvas.drawLine(Offset(topX, 0), Offset(bottomX, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NetPainter oldDelegate) => false;
}

/// The ball itself, centered on the given point.
class BallWidget extends StatelessWidget {
  final double centerX;
  final double centerY;
  final double radius;

  const BallWidget({
    super.key,
    required this.centerX,
    required this.centerY,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: centerX - radius,
      top: centerY - radius,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: Color(0xFFFFA630),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

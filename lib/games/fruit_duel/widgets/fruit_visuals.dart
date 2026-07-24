import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pure drawing code for fruit and bombs — no animation, no gameplay
/// logic. [SlicedFruitEffect] and the live idle view both reuse
/// [paintFruitBody] so a cut half looks identical to the whole fruit.

class FruitStyle {
  final Color base;
  final Color shade;
  final Color dot;
  final bool leaf;
  const FruitStyle(this.base, this.shade, this.dot, {this.leaf = true});
}

const Map<String, FruitStyle> fruitStyles = {
  '🍎': FruitStyle(Color(0xFFE6432E), Color(0xFFC22A1B), Color(0xFFB8281A)),
  '🍊': FruitStyle(Color(0xFFFC912E), Color(0xFFE07A1E), Color(0xFFD37417)),
  '🍌': FruitStyle(Color(0xFFFFD23F), Color(0xFFE0B000), Color(0xFFD6A700),
      leaf: false),
  '🍇': FruitStyle(Color(0xFF9B59B6), Color(0xFF7D3C98), Color(0xFF6C3483)),
  '🍓': FruitStyle(Color(0xFFFF5C7A), Color(0xFFE0335A), Color(0xFFC71F45)),
  '🍍': FruitStyle(Color(0xFFF4C430), Color(0xFFCB9600), Color(0xFFB98600),
      leaf: false),
};

FruitStyle styleForEmoji(String emoji) =>
    fruitStyles[emoji] ??
    const FruitStyle(Color(0xFFFC912E), Color(0xFFE07A1E), Color(0xFFD37417));

/// Draws one fruit: soft ground shadow, glossy shaded body, a little
/// peel/seed texture, and a leaf for fruits that have one.
void paintFruitBody(Canvas canvas, Size size, FruitStyle style) {
  final center = size.center(Offset.zero);
  final radius = size.width / 2 - 6;

  canvas.drawOval(
    Rect.fromCenter(
      center: center.translate(0, radius * 0.78),
      width: radius * 1.5,
      height: radius * 0.5,
    ),
    Paint()..color = Colors.black.withOpacity(0.18),
  );

  final bodyPaint = Paint()
    ..shader = RadialGradient(
      colors: [style.base, style.shade],
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
    ).createShader(Rect.fromCircle(center: center, radius: radius));
  canvas.drawCircle(center, radius, bodyPaint);
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );

  final dotPaint = Paint()..color = style.dot.withOpacity(0.55);
  const dotOffsets = [
    Offset(-0.25, -0.05),
    Offset(0.1, -0.3),
    Offset(0.28, 0.05),
    Offset(-0.05, 0.25),
    Offset(0.05, -0.05),
    Offset(-0.3, 0.2),
  ];
  for (final o in dotOffsets) {
    canvas.drawCircle(
        center + Offset(o.dx, o.dy) * radius, radius * 0.05, dotPaint);
  }

  if (style.leaf) {
    final leafPaint = Paint()..color = const Color(0xFF3FA34D);
    final leafPath = Path()
      ..moveTo(center.dx + radius * 0.1, center.dy - radius * 0.95)
      ..quadraticBezierTo(
        center.dx + radius * 0.55,
        center.dy - radius * 1.15,
        center.dx + radius * 0.5,
        center.dy - radius * 0.7,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.25,
        center.dy - radius * 0.75,
        center.dx + radius * 0.1,
        center.dy - radius * 0.95,
      )
      ..close();
    canvas.drawPath(leafPath, leafPaint);
    canvas.drawPath(
      leafPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}

class FruitPainter extends CustomPainter {
  final String emoji;
  const FruitPainter({required this.emoji});

  @override
  void paint(Canvas canvas, Size size) =>
      paintFruitBody(canvas, size, styleForEmoji(emoji));

  @override
  bool shouldRepaint(covariant FruitPainter oldDelegate) =>
      oldDelegate.emoji != emoji;
}

/// Draws the bomb: dark glossy sphere, highlight, fuse and spark. Bombs
/// are never sliced — [ExplosionEffect] takes over entirely on impact.
class BombPainter extends CustomPainter {
  const BombPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, radius * 0.8),
        width: radius * 1.5,
        height: radius * 0.5,
      ),
      Paint()..color = Colors.black.withOpacity(0.18),
    );

    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF4A4A52), Color(0xFF17171B)],
        center: Alignment(-0.3, -0.3),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      center + Offset(-radius * 0.35, -radius * 0.35),
      radius * 0.18,
      Paint()..color = Colors.white.withOpacity(0.35),
    );

    final fusePaint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fusePath = Path()
      ..moveTo(center.dx + radius * 0.15, center.dy - radius * 0.95)
      ..quadraticBezierTo(
        center.dx + radius * 0.6,
        center.dy - radius * 1.3,
        center.dx + radius * 0.35,
        center.dy - radius * 1.55,
      );
    canvas.drawPath(fusePath, fusePaint);

    final sparkCenter =
        Offset(center.dx + radius * 0.35, center.dy - radius * 1.55);
    final sparkPaint = Paint()
      ..color = const Color(0xFFFFC93F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 + math.pi / 4;
      canvas.drawLine(
        sparkCenter,
        sparkCenter + Offset(math.cos(angle), math.sin(angle)) * 8,
        sparkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BombPainter oldDelegate) => false;
}

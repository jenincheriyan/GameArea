import 'dart:math';
import 'package:flutter/material.dart';

/// Draws the snake board on a single canvas — a light grid, the food, and
/// every snake segment (head tinted differently from the body).
class SnakeBoardPainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;

  SnakeBoardPainter({
    required this.snake,
    required this.food,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / gridSize;

    final gridPaint = Paint()..color = Colors.white.withOpacity(0.06);
    for (var i = 0; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(i * cell, 0),
        Offset(i * cell, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cell),
        Offset(size.width, i * cell),
        gridPaint,
      );
    }

    // Food.
    final foodPaint = Paint()..color = const Color(0xFFFF5E5E);
    final foodRect = Rect.fromLTWH(
      food.x * cell,
      food.y * cell,
      cell,
      cell,
    ).deflate(cell * 0.14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(foodRect, Radius.circular(cell * 0.4)),
      foodPaint,
    );

    // Snake body, tail to head, so the head paints on top at any overlap.
    for (var i = snake.length - 1; i >= 0; i--) {
      final segment = snake[i];
      final isHead = i == 0;
      final paint = Paint()
        ..color = isHead ? const Color(0xFF6EE7A0) : const Color(0xFF4EA8DE);
      final rect = Rect.fromLTWH(
        segment.x * cell,
        segment.y * cell,
        cell,
        cell,
      ).deflate(cell * 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.25)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:flutter/material.dart';

/// Draws the shared board for the two-player Snake match: a light grid,
/// both foods, and both snakes (each with its own head/body color pair
/// so players can tell them apart at a glance). A dead snake is drawn
/// dimmed to make its frozen state obvious.
class DualSnakeBoardPainter extends CustomPainter {
  final List<Point<int>> snake1;
  final List<Point<int>> snake2;
  final bool snake1Dead;
  final bool snake2Dead;
  final List<Point<int>> foods;
  final int gridSize;

  DualSnakeBoardPainter({
    required this.snake1,
    required this.snake2,
    required this.snake1Dead,
    required this.snake2Dead,
    required this.foods,
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

    // Foods.
    final foodPaint = Paint()..color = const Color(0xFFFFD166);
    for (final food in foods) {
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
    }

    _drawSnake(
      canvas,
      cell,
      snake1,
      headColor: const Color(0xFF6EE7A0),
      bodyColor: const Color(0xFF4EA8DE),
      dimmed: snake1Dead,
    );
    _drawSnake(
      canvas,
      cell,
      snake2,
      headColor: const Color(0xFFFFB199),
      bodyColor: const Color(0xFFFF5E5E),
      dimmed: snake2Dead,
    );
  }

  void _drawSnake(
    Canvas canvas,
    double cell,
    List<Point<int>> snake, {
    required Color headColor,
    required Color bodyColor,
    required bool dimmed,
  }) {
    final opacity = dimmed ? 0.35 : 1.0;
    for (var i = snake.length - 1; i >= 0; i--) {
      final segment = snake[i];
      final isHead = i == 0;
      final paint = Paint()
        ..color = (isHead ? headColor : bodyColor).withOpacity(opacity);
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
  bool shouldRepaint(covariant DualSnakeBoardPainter oldDelegate) => true;
}

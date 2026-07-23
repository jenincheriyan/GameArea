import 'dart:math';
import 'package:flutter/material.dart';

/// Draws the snake board on a single canvas in the style of a classic
/// monochrome LCD handheld: a faint dot-matrix background, a small plus
/// shaped food marker, and a snake rendered as a single blocky black path
/// with a hollow-circle head.
class SnakeBoardPainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final int gridSize;

  static const Color inkColor = Color(0xFF16210A);
  static const Color screenColor = Color(0xFFA3C000);
  static const Color dimInkColor = Color(0xFF4B5C09);

  /// Fraction of a cell the snake's body actually fills. Lower this to
  /// make the snake thinner; 1.0 fills the whole cell edge-to-edge.
  static const double bodyScale = 0.7;

  SnakeBoardPainter({
    required this.snake,
    required this.food,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    _paintDotGrid(canvas, size, cellWidth, cellHeight);
    _paintFood(canvas, cellWidth, cellHeight);
    _paintSnake(canvas, cellWidth, cellHeight);
  }

  /// Faint recessed squares, like unlit LCD pixels showing through —
  /// the same trick real LCD Snake screens use for their background.
  void _paintDotGrid(
      Canvas canvas,
      Size size,
      double cellWidth,
      double cellHeight,
      ) {
    final dotPaint = Paint()..color = screenColor.withOpacity(0.35);

    final insetX = cellWidth * 0.12;
    final insetY = cellHeight * 0.12;

    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        ).deflate(insetX < insetY ? insetX : insetY);

        canvas.drawRect(rect, dotPaint);
      }
    }
  }

  /// Small plus/cross shape, drawn dim so it barely stands out against
  /// the background — matching the subtle food marker on real LCD units.
  void _paintFood(Canvas canvas, double cellWidth, double cellHeight) {
    final paint = Paint()..color = dimInkColor.withOpacity(0.55);

    final ox = food.x * cellWidth;
    final oy = food.y * cellHeight;

    final armX = cellWidth * 0.34;
    final armY = cellHeight * 0.34;

    final thickX = cellWidth * 0.30;
    final thickY = cellHeight * 0.30;

    final cx = ox + cellWidth / 2;
    final cy = oy + cellHeight / 2;

    // Vertical bar
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: thickX, height: armY * 2),
      paint,
    );

    // Horizontal bar
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: armX * 2, height: thickY),
      paint,
    );
  }

  /// The snake is drawn as one continuous blocky path (not separate
  /// rounded tiles) so corners look like a real pixel line, with thin
  /// scan-line notches inside each segment for a dot-matrix feel. The
  /// head is a hollow ring instead of a filled block.
  ///
  /// Each segment rect is scaled down by [bodyScale] and centered in its
  /// cell (rather than pinned to the top-left corner) so shrinking it
  /// makes an evenly thin line instead of an off-center block.
  void _paintSnake(Canvas canvas, double cellWidth, double cellHeight) {
    if (snake.isEmpty) return;

    final bodyPaint = Paint()..color = inkColor;
    final path = Path();

    final segW = cellWidth * bodyScale;
    final segH = cellHeight * bodyScale;
    final padX = (cellWidth - segW) / 2;
    final padY = (cellHeight - segH) / 2;

    // Draw each segment's centered square...
    for (final segment in snake) {
      final rect = Rect.fromLTWH(
        segment.x * cellWidth + padX,
        segment.y * cellHeight + padY,
        segW,
        segH,
      );
      path.addRect(rect);
    }

    // ...then bridge the gaps between consecutive segments so a thin
    // bodyScale doesn't leave the squares floating apart. Skip the bridge
    // when a wrap-around jump happens (segments aren't grid-adjacent),
    // so the snake still visibly exits one edge and re-enters the other.
    for (var i = 0; i < snake.length - 1; i++) {
      final a = snake[i];
      final b = snake[i + 1];
      final dx = b.x - a.x;
      final dy = b.y - a.y;

      if (dx == 0 && dy.abs() == 1) {
        // Vertically adjacent: bridge the vertical gap between them.
        final topSeg = dy == 1 ? a : b;
        final bridgeTop = topSeg.y * cellHeight + padY + segH;
        final bridgeHeight = cellHeight - segH;
        path.addRect(
          Rect.fromLTWH(
            a.x * cellWidth + padX,
            bridgeTop,
            segW,
            bridgeHeight,
          ),
        );
      } else if (dy == 0 && dx.abs() == 1) {
        // Horizontally adjacent: bridge the horizontal gap between them.
        final leftSeg = dx == 1 ? a : b;
        final bridgeLeft = leftSeg.x * cellWidth + padX + segW;
        final bridgeWidth = cellWidth - segW;
        path.addRect(
          Rect.fromLTWH(
            bridgeLeft,
            a.y * cellHeight + padY,
            bridgeWidth,
            segH,
          ),
        );
      }
      // Otherwise this is a wrap-around jump — leave the gap.
    }

    canvas.drawPath(path, bodyPaint);

    // Scan lines
    canvas.save();
    canvas.clipPath(path);

    final scanPaint = Paint()
      ..color = screenColor.withOpacity(0.18)
      ..strokeWidth = max(1.0, min(cellWidth, cellHeight) * 0.05);

    const divisions = 4;

    for (final segment in snake) {
      final ox = segment.x * cellWidth + padX;
      final oy = segment.y * cellHeight + padY;

      for (var i = 1; i < divisions; i++) {
        final dx = ox + segW * i / divisions;
        final dy = oy + segH * i / divisions;

        // Vertical scan line
        canvas.drawLine(Offset(dx, oy), Offset(dx, oy + segH), scanPaint);

        // Horizontal scan line
        canvas.drawLine(Offset(ox, dy), Offset(ox + segW, dy), scanPaint);
      }
    }

    canvas.restore();

    // Hollow head
    final head = snake.first;

    final centerX = head.x * cellWidth + cellWidth / 2;
    final centerY = head.y * cellHeight + cellHeight / 2;

    final outerRadius = min(segW, segH) * 0.55;
    final innerRadius = min(segW, segH) * 0.26;

    canvas.drawCircle(Offset(centerX, centerY), outerRadius, bodyPaint);

    canvas.drawCircle(
      Offset(centerX, centerY),
      innerRadius,
      Paint()..color = screenColor,
    );
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) => true;
}
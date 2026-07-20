import 'package:flutter/material.dart';
import '../car_race_controller.dart';

/// Paints the lane dividers and scrolling road items (traffic + coins)
/// for a Car Race board of the given logical [boardWidth]/[boardHeight]
/// and [laneCount]; the parent widget scales this to the actual size.
class RoadPainter extends CustomPainter {
  final List<RoadItem> items;
  final double boardWidth;
  final double boardHeight;
  final int laneCount;

  RoadPainter({
    required this.items,
    required this.boardWidth,
    required this.boardHeight,
    required this.laneCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / boardWidth;
    final scaleY = size.height / boardHeight;

    final dividerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3;
    for (var lane = 1; lane < laneCount; lane++) {
      final x = (boardWidth / laneCount) * lane * scaleX;
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, size.height), dividerPaint);
    }

    for (final item in items) {
      final laneWidth = boardWidth / laneCount * scaleX;
      final centerX = (item.lane + 0.5) * boardWidth / laneCount * scaleX;
      final y = item.y * scaleY;

      if (item.kind == RoadItemKind.traffic) {
        final rect = Rect.fromCenter(
          center: Offset(centerX, y),
          width: laneWidth * 0.55,
          height: 46 * scaleY,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          Paint()..color = const Color(0xFFFF5E5E),
        );
      } else {
        canvas.drawCircle(
          Offset(centerX, y),
          14 * scaleX,
          Paint()..color = const Color(0xFFFFD166),
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 14.0;
    const gap = 10.0;
    final total = (end - start).distance;
    final direction = (end - start) / total;
    var covered = 0.0;
    while (covered < total) {
      final segmentEnd = (covered + dash).clamp(0, total);
      canvas.drawLine(
        start + direction * covered,
        start + direction * segmentEnd.toDouble(),
        paint,
      );
      covered += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) => true;
}

/// The player's car, positioned at (carX, carY) in logical coordinates.
class PlayerCarWidget extends StatelessWidget {
  final double carX;
  final double carY;
  final double width;
  final double height;
  final double scaleX;
  final double scaleY;
  final Color color;

  const PlayerCarWidget({
    super.key,
    required this.carX,
    required this.carY,
    required this.width,
    required this.height,
    required this.scaleX,
    required this.scaleY,
    this.color = const Color(0xFF4EA8DE),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: carX * scaleX - (width * scaleX) / 2,
      top: carY * scaleY - (height * scaleY) / 2,
      child: Container(
        width: width * scaleX,
        height: height * scaleY,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12)],
        ),
      ),
    );
  }
}

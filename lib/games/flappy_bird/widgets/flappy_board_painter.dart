import 'package:flutter/material.dart';
import '../flappy_bird_controller.dart';

/// Paints the pipes and bird onto the logical [FlappyBirdController]
/// board; the parent widget scales this to the actual screen size.
class FlappyBoardPainter extends CustomPainter {
  final List<FlappyPipe> pipes;
  final double birdY;

  FlappyBoardPainter({required this.pipes, required this.birdY});

  static const _pipeColor = Color(0xFF89FF8E);
  static const _birdColor = Color(0xFFFF9898);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / FlappyBirdController.boardWidth;
    final scaleY = size.height / FlappyBirdController.boardHeight;

    final pipePaint = Paint()..color = _pipeColor;
    for (final pipe in pipes) {
      final x = pipe.x * scaleX;
      final w = FlappyBirdController.pipeWidth * scaleX;
      final gapTop = (pipe.gapCenterY - pipe.gapHeight / 2) * scaleY;
      final gapBottom = (pipe.gapCenterY + pipe.gapHeight / 2) * scaleY;

      canvas.drawRect(Rect.fromLTRB(x, 0, x + w, gapTop), pipePaint);
      canvas.drawRect(
        Rect.fromLTRB(x, gapBottom, x + w, size.height),
        pipePaint,
      );
    }

    final birdPaint = Paint()..color = _birdColor;
    canvas.drawCircle(
      Offset(FlappyBirdController.birdX * scaleX, birdY * scaleY),
      FlappyBirdController.birdRadius * ((scaleX + scaleY) / 2),
      birdPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FlappyBoardPainter oldDelegate) => true;
}

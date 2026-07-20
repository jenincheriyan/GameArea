import 'dart:math';
import 'package:flutter/material.dart';
import '../ludo_models.dart';

/// Renders the board and every token. The layout is a circular ring for
/// the 52 shared cells (with the 8 safe cells marked by a star), one
/// radial "spoke" per color for its private 6-cell home stretch, and a
/// corner yard per color holding its not-yet-in-play tokens. This keeps
/// full standard-Ludo rule accuracy (shared ring, per-color entry point,
/// safe cells, home stretch) while staying simple to lay out and read
/// on a phone screen, rather than reproducing the classic plus-shaped
/// board pixel-for-pixel.
class LudoBoardView extends StatelessWidget {
  final List<LudoColor> colors;
  final List<List<LudoToken>> tokensByPlayer;
  final List<int> movableTokenIndices;
  final int currentPlayer;
  final void Function(int tokenIndex) onTapToken;

  const LudoBoardView({
    super.key,
    required this.colors,
    required this.tokensByPlayer,
    required this.movableTokenIndices,
    required this.currentPlayer,
    required this.onTapToken,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final ringRadius = size * 0.36;
        final yardRadius = size * 0.46;

        final children = <Widget>[
          CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _TrackPainter(center: center, ringRadius: ringRadius, colors: colors),
          ),
        ];

        // Yard tokens (not yet in play) and in-play tokens.
        for (var p = 0; p < colors.length; p++) {
          final color = colors[p];
          final tokens = tokensByPlayer[p];
          var yardSlot = 0;
          for (var t = 0; t < tokens.length; t++) {
            final token = tokens[t];
            final isMovable = p == currentPlayer && movableTokenIndices.contains(t);
            final position = token.isInYard
                ? _yardSlotPosition(color, yardSlot++, center, yardRadius)
                : _tokenPosition(color, token.progress, center, ringRadius);

            children.add(_TokenDot(
              key: ValueKey('token_${p}_$t'),
              position: position,
              color: color.color,
              isMovable: isMovable,
              onTap: isMovable ? () => onTapToken(t) : null,
            ));
          }
        }

        return Stack(children: children);
      },
    );
  }

  static Offset _tokenPosition(LudoColor color, int progress, Offset center, double ringRadius) {
    if (progress <= 50) {
      final absCell = (color.entryIndex + progress) % LudoBoard.ringLength;
      final angle = (absCell / LudoBoard.ringLength) * 2 * pi;
      return center + Offset(cos(angle), sin(angle)) * ringRadius;
    }
    // Home stretch: walk inward along this color's spoke.
    final homeStep = progress - 50; // 1..6
    final angle = (color.entryIndex / LudoBoard.ringLength) * 2 * pi;
    final r = ringRadius - (ringRadius - 16) * (homeStep / 6);
    return center + Offset(cos(angle), sin(angle)) * r;
  }

  static Offset _yardSlotPosition(LudoColor color, int slot, Offset center, double yardRadius) {
    final baseAngle = ((color.entryIndex + 6.5) / LudoBoard.ringLength) * 2 * pi;
    final slotAngle = baseAngle + (slot - 1.5) * 0.18;
    return center + Offset(cos(slotAngle), sin(slotAngle)) * yardRadius;
  }
}

class _TrackPainter extends CustomPainter {
  final Offset center;
  final double ringRadius;
  final List<LudoColor> colors;

  _TrackPainter({required this.center, required this.ringRadius, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26;
    canvas.drawCircle(center, ringRadius, ringPaint);

    // Safe-cell markers.
    for (final cellIndex in LudoBoard.safeCells) {
      final angle = (cellIndex / LudoBoard.ringLength) * 2 * pi;
      final pos = center + Offset(cos(angle), sin(angle)) * ringRadius;
      canvas.drawCircle(pos, 9, Paint()..color = Colors.white54);
    }

    // Home-stretch spokes, one per color.
    for (final color in colors) {
      final angle = (color.entryIndex / LudoBoard.ringLength) * 2 * pi;
      final outer = center + Offset(cos(angle), sin(angle)) * ringRadius;
      final inner = center + Offset(cos(angle), sin(angle)) * 16;
      canvas.drawLine(
        outer,
        inner,
        Paint()
          ..color = color.color.withOpacity(0.55)
          ..strokeWidth = 14,
      );
    }

    canvas.drawCircle(center, 20, Paint()..color = Colors.white.withOpacity(0.8));
  }

  @override
  bool shouldRepaint(covariant _TrackPainter oldDelegate) => false;
}

class _TokenDot extends StatelessWidget {
  final Offset position;
  final Color color;
  final bool isMovable;
  final VoidCallback? onTap;

  const _TokenDot({
    super.key,
    required this.position,
    required this.color,
    required this.isMovable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const dotSize = 26.0;
    return Positioned(
      left: position.dx - dotSize / 2,
      top: position.dy - dotSize / 2,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMovable ? Colors.white : Colors.black26,
              width: isMovable ? 3 : 1.5,
            ),
            boxShadow: isMovable
                ? [BoxShadow(color: color.withOpacity(0.8), blurRadius: 10)]
                : null,
          ),
        ),
      ),
    );
  }
}

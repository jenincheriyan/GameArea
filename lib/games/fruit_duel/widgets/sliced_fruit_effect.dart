import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'fruit_visuals.dart';

/// Plays once when a fruit is cut: a bright slash flash along the cut
/// line, a brief freeze-frame beat (the "slow motion" moment of impact),
/// then the two halves rotate apart and fall while fading, with a burst
/// of juice-colored droplets.
class SlicedFruitEffect extends StatefulWidget {
  final String emoji;
  const SlicedFruitEffect({super.key, required this.emoji});

  @override
  State<SlicedFruitEffect> createState() => _SlicedFruitEffectState();
}

class _SlicedFruitEffectState extends State<SlicedFruitEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Droplet> _droplets;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();

    final rand = math.Random();
    final style = styleForEmoji(widget.emoji);
    _droplets = List.generate(7, (i) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 30 + rand.nextDouble() * 46;
      return _Droplet(
        angle: angle,
        speed: speed,
        size: 4 + rand.nextDouble() * 4,
        color: style.dot,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = Size(112, 112);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // First ~18% of the timeline is a held "impact" beat (slow-mo
        // feel) before the halves actually start separating.
        final raw = _c.value;
        final separateT =
            Curves.easeOut.transform(((raw - 0.18) / 0.82).clamp(0.0, 1.0));
        final fade = (1 - raw).clamp(0.0, 1.0);
        final spread = separateT * 46;
        final rot = separateT * 0.9;

        return SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (raw < 0.22)
                Opacity(
                  opacity: 1 - (raw / 0.22),
                  child: CustomPaint(
                    size: size,
                    painter: const _SlashFlashPainter(),
                  ),
                ),
              for (final d in _droplets)
                _buildDroplet(d, separateT, fade),
              Transform.translate(
                offset: Offset(-spread, -spread * 0.6),
                child: Transform.rotate(
                  angle: -rot,
                  child: Opacity(
                    opacity: fade,
                    child: ClipPath(
                      clipper: const _DiagonalClipper(topLeft: true),
                      child: CustomPaint(
                        size: size,
                        painter: FruitPainter(emoji: widget.emoji),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(spread, spread * 0.6),
                child: Transform.rotate(
                  angle: rot,
                  child: Opacity(
                    opacity: fade,
                    child: ClipPath(
                      clipper: const _DiagonalClipper(topLeft: false),
                      child: CustomPaint(
                        size: size,
                        painter: FruitPainter(emoji: widget.emoji),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDroplet(_Droplet d, double t, double fade) {
    final dist = d.speed * t + 30 * t * t; // a little gravity-style ease-in
    final dx = math.cos(d.angle) * dist;
    final dy = math.sin(d.angle) * dist + 40 * t * t; // gravity drop
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: fade,
        child: Container(
          width: d.size,
          height: d.size,
          decoration: BoxDecoration(color: d.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Droplet {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  const _Droplet({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _DiagonalClipper extends CustomClipper<Path> {
  final bool topLeft;
  const _DiagonalClipper({required this.topLeft});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (topLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _DiagonalClipper oldClipper) =>
      oldClipper.topLeft != topLeft;
}

class _SlashFlashPainter extends CustomPainter {
  const _SlashFlashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _SlashFlashPainter oldDelegate) => false;
}

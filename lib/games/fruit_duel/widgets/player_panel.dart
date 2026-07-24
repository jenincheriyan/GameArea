import 'package:flutter/material.dart';

/// One player's side of the arena: their score badge and their single
/// large CUT button.
///
/// This same widget is reused for both players — for player 1 the parent
/// screen wraps it in a 180 rotation so the two players can face each
/// other from opposite ends of the phone.
class PlayerPanel extends StatelessWidget {
  final int score;
  final Color color;
  final VoidCallback onCut;

  const PlayerPanel({
    super.key,
    required this.score,
    required this.color,
    required this.onCut,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 190,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Score card behind
            Positioned(
              left: 10,
              child: _AvatarBadge(
                score: score,
                color: color,
              ),
            ),

            // CUT button on top
            _CutButton(
              color: color,
              onCut: onCut,
            ),
          ],
        ),
      ),
    );
  }
}

/// The single control each player has: a big glossy circular button.
/// Fires on tap-down for the snappiest possible reaction time, with a
/// quick squash-and-release press animation.
class _CutButton extends StatefulWidget {
  final Color color;
  final VoidCallback onCut;
  const _CutButton({required this.color, required this.onCut});

  @override
  State<_CutButton> createState() => _CutButtonState();
}

class _CutButtonState extends State<_CutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _press.forward(from: 0);
    widget.onCut();
  }

  @override
  Widget build(BuildContext context) {
    final darker = HSLColor.fromColor(widget.color)
        .withLightness(
            (HSLColor.fromColor(widget.color).lightness - 0.16).clamp(0, 1))
        .toColor();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          // Quick squash on tap, spring back out.
          final t = _press.value;
          final scale =
              1 - (t < 0.35 ? (t / 0.35) * 0.12 : (1 - t) / 0.65 * 0.12);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color, darker],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 12,
                left: 18,
                child: Container(
                  width: 30,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Text(
                'CUT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular colored avatar with a dark score chip tucked behind it,
/// matching the reference art's corner scoreboard.
class _AvatarBadge extends StatelessWidget {
  final int score;
  final Color color;
  const _AvatarBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          Positioned(
            left: 0,
            child: Container(
              height: 30,
              padding: const EdgeInsets.only(left: 10, right: 26),
              decoration: BoxDecoration(
                color: const Color(0xFF262B31),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$score',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Container(
          //   width: 62,
          //   height: 62,
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: color,
          //     border: Border.all(color: Colors.black, width: 3),
          //   ),
          //   child: Center(
          //     child: Container(
          //       width: 40,
          //       height: 40,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: Colors.white.withOpacity(0.18),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

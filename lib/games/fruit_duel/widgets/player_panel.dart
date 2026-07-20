import 'package:flutter/material.dart';
import 'sword_button.dart';

/// One player's side of the game screen: a small label, the live score in
/// the player's own color, and a single glowing sword avatar that is the
/// only tap target — the same score-above-avatar language as Math Duel's
/// PlayerHalf. Used twice in a stacked, face-off layout: the top instance
/// gets wrapped in `Transform.rotate(angle: math.pi, ...)` by the parent
/// screen so it reads right-side up for the player at that end.
class PlayerPanel extends StatelessWidget {
  final String label;
  final int score;
  final List<Color> colors;
  final VoidCallback onCut;

  const PlayerPanel({
    super.key,
    required this.label,
    required this.score,
    required this.colors,
    required this.onCut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: TextStyle(
              color: colors.first,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SwordButton(onCut: onCut, color: colors.first),
      ],
    );
  }
}

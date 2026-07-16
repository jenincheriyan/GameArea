import 'package:flutter/material.dart';
import 'sword_button.dart';

/// One player's side of the game screen: label, live score, sword, and a
/// large CUT button (so the whole lower half of that side is tappable,
/// not just the sword icon).
class PlayerPanel extends StatelessWidget {
  final String label;
  final int score;
  final List<Color> colors;
  final VoidCallback onCut;
  final bool flip;

  const PlayerPanel({
    super.key,
    required this.label,
    required this.score,
    required this.colors,
    required this.onCut,
    this.flip = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCut,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: colors.first.withOpacity(0.8),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SwordButton(onCut: onCut, color: colors.first, flip: flip),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onCut,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.first,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'CUT',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}

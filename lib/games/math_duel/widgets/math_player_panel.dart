import 'package:flutter/material.dart';
import 'tap_button.dart';
import 'equation_view.dart';
import '../math_equation.dart';

/// One player's side of the split screen — label, score, the shared
/// equation (repeated here so it faces this player directly on their own
/// side), and a tap button right below it.
class MathPlayerPanel extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final MathEquation? equation;
  final VoidCallback onTap;

  const MathPlayerPanel({
    super.key,
    required this.label,
    required this.score,
    required this.color,
    required this.equation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Shadow(color: color.withOpacity(0.8), blurRadius: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        EquationView(equation: equation),
        const SizedBox(height: 20),
        TapButton(onTap: onTap, color: color),
        const SizedBox(height: 12),
        Text(
          'TAP IF TRUE',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

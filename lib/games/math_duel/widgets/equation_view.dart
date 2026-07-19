import 'package:flutter/material.dart';
import '../math_equation.dart';

/// Shows the single equation currently in play (or nothing), popping in
/// and fading out the same way Fruit Duel's objects do.
class EquationView extends StatelessWidget {
  final MathEquation? equation;

  const EquationView({super.key, required this.equation});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: equation == null
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : Container(
              key: ValueKey(equation!.id),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Text(
                equation!.expression,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../math_question.dart';

/// The big centered statement the player has to judge as True or False.
class QuestionCard extends StatelessWidget {
  final MathQuestion? question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
        child: FittedBox(
          key: ValueKey(question?.id),
          fit: BoxFit.scaleDown,
          child: Text(
            question?.expression ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

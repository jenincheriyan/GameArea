import 'package:flutter/material.dart';
import '../tic_tac_toe_ai.dart';

/// Shown once, before a single-player match starts, so the player can
/// pick how strong the AI should be.
class DifficultyPicker extends StatelessWidget {
  final ValueChanged<AiDifficulty> onSelected;

  const DifficultyPicker({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CHOOSE DIFFICULTY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Play X against the computer',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _DifficultyButton(
              label: 'EASY',
              subtitle: 'The AI makes mistakes',
              color: const Color(0xFF6EE7A0),
              onTap: () => onSelected(AiDifficulty.easy),
            ),
            const SizedBox(height: 16),
            _DifficultyButton(
              label: 'HARD',
              subtitle: 'Unbeatable — best you can do is draw',
              color: const Color(0xFFFF5E5E),
              onTap: () => onSelected(AiDifficulty.hard),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.7)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

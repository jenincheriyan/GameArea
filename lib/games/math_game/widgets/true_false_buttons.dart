import 'package:flutter/material.dart';

/// The two big answer buttons the player taps to judge the current
/// statement.
class TrueFalseButtons extends StatelessWidget {
  final ValueChanged<bool> onAnswer;
  final bool enabled;

  const TrueFalseButtons({
    super.key,
    required this.onAnswer,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnswerButton(
            label: 'TRUE',
            icon: Icons.check_circle,
            color: const Color(0xFF6EE7A0),
            onTap: enabled ? () => onAnswer(true) : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AnswerButton(
            label: 'FALSE',
            icon: Icons.cancel,
            color: const Color(0xFFFF5E5E),
            onTap: enabled ? () => onAnswer(false) : null,
          ),
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: color.withOpacity(onTap == null ? 0.15 : 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: onTap == null
                ? null
                : [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.black87, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

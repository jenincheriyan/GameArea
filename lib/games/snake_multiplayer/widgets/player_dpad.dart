import 'package:flutter/material.dart';
import '../snake_multiplayer_controller.dart';

/// A compact directional pad tinted with a player's color, used to give
/// each of the two players their own on-screen controls. Same layout
/// idea as the single-player Snake's D-pad, made reusable and colorable
/// so it can appear twice (once per player) on one screen.
class PlayerDPad extends StatelessWidget {
  final Color color;
  final ValueChanged<Direction> onDirection;

  const PlayerDPad({super.key, required this.color, required this.onDirection});

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, Direction dir) {
      return _DPadButton(
        icon: icon,
        color: color,
        onTap: () => onDirection(dir),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.keyboard_arrow_up, Direction.up),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(Icons.keyboard_arrow_left, Direction.left),
            const SizedBox(width: 40),
            button(Icons.keyboard_arrow_right, Direction.right),
          ],
        ),
        const SizedBox(height: 6),
        button(Icons.keyboard_arrow_down, Direction.down),
      ],
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DPadButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.6)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

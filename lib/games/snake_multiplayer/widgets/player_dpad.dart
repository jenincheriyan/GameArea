import 'package:flutter/material.dart';
import '../snake_multiplayer_controller.dart';

/// A compact directional pad tinted with a player's color, used to give
/// each of the two players their own on-screen controls. Same layout
/// idea as the single-player Snake's D-pad, made reusable and colorable
/// so it can appear twice (once per player) on one screen. Buttons use
/// the same solid-fill, glowing-circle language as the sword/avatar tap
/// targets in Fruit Duel and Math Duel.
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

class _DPadButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _DPadButton({required this.icon, required this.color, required this.onTap});

  @override
  State<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<_DPadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(_controller);
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

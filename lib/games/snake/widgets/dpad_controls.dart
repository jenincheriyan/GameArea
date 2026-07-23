import 'package:flutter/material.dart';
import '../snake_controller.dart';

/// Retro handheld-style D-pad: four direction buttons arranged in a plus
/// shape around a center pause/resume button, styled like a physical
/// console's plastic control cluster.
class DpadControls extends StatelessWidget {
  final bool isPaused;
  final void Function(Direction) onDirection;
  final VoidCallback onTogglePause;

  const DpadControls({
    super.key,
    required this.isPaused,
    required this.onDirection,
    required this.onTogglePause,
  });

  static const Color shellColor = Color(0xFF2A2A2E);
  static const Color buttonColor = Color(0xFF3E3E44);
  static const Color buttonHighlight = Color(0xFF57575F);
  static const Color accentColor = Color(0xFFA3C000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        color: shellColor,
        border: Border(top: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Center(
        child: SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _DpadButton(
                alignment: Alignment.topCenter,
                icon: Icons.keyboard_arrow_up,
                onTap: () => onDirection(Direction.up),
              ),
              _DpadButton(
                alignment: Alignment.bottomCenter,
                icon: Icons.keyboard_arrow_down,
                onTap: () => onDirection(Direction.down),
              ),
              _DpadButton(
                alignment: Alignment.centerLeft,
                icon: Icons.keyboard_arrow_left,
                onTap: () => onDirection(Direction.left),
              ),
              _DpadButton(
                alignment: Alignment.centerRight,
                icon: Icons.keyboard_arrow_right,
                onTap: () => onDirection(Direction.right),
              ),
              _CenterButton(isPaused: isPaused, onTap: onTogglePause),
            ],
          ),
        ),
      ),
    );
  }
}

class _DpadButton extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;
  final VoidCallback onTap;

  const _DpadButton({
    required this.alignment,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Material(
        color: DpadControls.buttonColor,
        shape: const CircleBorder(
          side: BorderSide(color: Colors.black54, width: 1.5),
        ),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          splashColor: DpadControls.accentColor.withOpacity(0.4),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              icon,
              color: DpadControls.buttonHighlight,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTap;

  const _CenterButton({required this.isPaused, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPaused ? DpadControls.accentColor : DpadControls.buttonColor,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.black54, width: 1.5),
      ),
      elevation: 5,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: isPaused ? Colors.black : DpadControls.buttonHighlight,
            size: 26,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A tappable sword icon that plays a quick slash animation (rotate + pop)
/// every time it's tapped, regardless of whether the cut actually scored.
class SwordButton extends StatefulWidget {
  final VoidCallback onCut;
  final Color color;
  final bool flip;

  const SwordButton({
    super.key,
    required this.onCut,
    required this.color,
    this.flip = false,
  });

  @override
  State<SwordButton> createState() => _SwordButtonState();
}

class _SwordButtonState extends State<SwordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    final direction = widget.flip ? 1.0 : -1.0;
    _rotation = Tween<double>(begin: 0, end: 0.6 * direction)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_controller);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(_controller);
  }

  void _handleTap() {
    widget.onCut();
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
          return Transform.rotate(
            angle: _rotation.value,
            child: Transform.scale(scale: _scale.value, child: child),
          );
        },
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.55),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Transform.flip(
            flipX: widget.flip,
            child: const Center(
              child: Text('🗡️', style: TextStyle(fontSize: 38)),
            ),
          ),
        ),
      ),
    );
  }
}

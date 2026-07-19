import 'package:flutter/material.dart';

/// A big tappable circular button that pops on every tap, regardless of
/// whether the answer turns out to score. Mirrors [SwordButton]'s feel
/// but with a check icon instead of a sword, since Math Duel is about
/// judging true/false rather than cutting an object.
class TapButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;

  const TapButton({super.key, required this.onTap, required this.color});

  @override
  State<TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<TapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 1),
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
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.55),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }
}

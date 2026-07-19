import 'package:flutter/material.dart';
import '../math_equation.dart';

/// One player's half of the face-off layout: the shared equation centered
/// in plain bold text, and a colored avatar/answer button with an
/// attached score pill tucked into the outer corner.
///
/// This widget always lays itself out "normal" (avatar bottom-right, text
/// upright). To use it for the player standing at the top of the phone,
/// wrap it in `Transform.rotate(angle: math.pi, child: PlayerHalf(...))`
/// in the parent screen — a 180° rotation both moves the avatar to the
/// top-left corner and turns the equation right-side up for someone
/// viewing the phone from the opposite end, which is exactly what a
/// face-off layout needs.
class PlayerHalf extends StatelessWidget {
  final int score;
  final Color color;
  final MathEquation? equation;
  final VoidCallback onTap;
  final IconData icon;

  const PlayerHalf({
    super.key,
    required this.score,
    required this.color,
    required this.equation,
    required this.onTap,
    this.icon = Icons.check_circle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.6), // Move upward
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: FittedBox(
                key: ValueKey(equation?.id),
                fit: BoxFit.scaleDown,
                child: Text(
                  equation?.expression ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AvatarScoreButton(
              score: score,
              color: color,
              icon: icon,
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}

/// The circular colored avatar (the actual tap target) with a dark score
/// pill tucked underneath its left edge — matches the "glove + badge"
/// look of the reference design.
class _AvatarScoreButton extends StatefulWidget {
  final int score;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AvatarScoreButton({
    required this.score,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AvatarScoreButton> createState() => _AvatarScoreButtonState();
}

class _AvatarScoreButtonState extends State<_AvatarScoreButton>
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            '${widget.score}',
            key: ValueKey(widget.score),
            style: TextStyle(
              color: widget.color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value,
                child: child,
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
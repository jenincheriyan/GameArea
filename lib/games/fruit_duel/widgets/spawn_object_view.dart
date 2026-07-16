import 'package:flutter/material.dart';
import '../../../models/game_object.dart';

/// Renders the single object currently in play (or nothing), animating
/// smoothly between states so objects pop in and melt away rather than
/// snapping in/out.
class SpawnObjectView extends StatelessWidget {
  final GameObject? object;

  const SpawnObjectView({super.key, required this.object});

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
      child: object == null
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : Container(
              key: ValueKey(object!.id),
              width: 110,
              height: 110,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 2,
                ),
              ),
              child: Text(
                object!.emoji,
                style: const TextStyle(fontSize: 58),
              ),
            ),
    );
  }
}

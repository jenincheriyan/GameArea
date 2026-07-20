import 'package:flutter/material.dart';
import '../catch_item.dart';

/// Renders one spawned item at an already-computed pixel position
/// (the parent screen converts logical board coordinates to actual
/// widget-space pixels via its own LayoutBuilder around the Stack, so
/// Positioned here resolves directly against that Stack with no
/// RenderObjectWidget in between).
class ItemView extends StatelessWidget {
  final CatchItem item;
  final double left;
  final double top;
  final VoidCallback onTap;

  const ItemView({
    super.key,
    required this.item,
    required this.left,
    required this.top,
    required this.onTap,
  });

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left - size / 2,
      top: top - size / 2,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(item.emoji, style: const TextStyle(fontSize: 34)),
          ),
        ),
      ),
    );
  }
}

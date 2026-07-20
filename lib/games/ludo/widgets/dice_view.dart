import 'package:flutter/material.dart';

/// A tappable die. Shows [value]'s pip layout, or a "?" placeholder
/// when no roll has happened yet this turn.
class DiceView extends StatelessWidget {
  final int? value;
  final VoidCallback? onTap;
  final Color accentColor;

  const DiceView({super.key, required this.value, required this.onTap, required this.accentColor});

  static const _pipLayouts = {
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor, width: onTap != null ? 3 : 1.5),
          boxShadow: onTap != null
              ? [BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 12)]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: value == null
            ? Center(
                child: Text('?',
                    style: TextStyle(
                        color: accentColor, fontSize: 26, fontWeight: FontWeight.w900)))
            : GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(9, (i) {
                  final active = _pipLayouts[value]!.contains(i);
                  return Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.black87 : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
      ),
    );
  }
}

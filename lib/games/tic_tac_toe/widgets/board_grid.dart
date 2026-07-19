import 'package:flutter/material.dart';

/// Renders the 3x3 Tic-Tac-Toe board and reports taps by cell index
/// (0..8, row-major).
class BoardGrid extends StatelessWidget {
  final List<String?> board;
  final ValueChanged<int> onCellTap;
  final bool enabled;

  const BoardGrid({
    super.key,
    required this.board,
    required this.onCellTap,
    this.enabled = true,
  });

  static const _xColor = Color(0xFF4EA8DE);
  static const _oColor = Color(0xFFFF5E5E);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final mark = board[index];
            return _Cell(
              mark: mark,
              color: mark == 'X' ? _xColor : _oColor,
              onTap: enabled && mark == null ? () => onCellTap(index) : null,
            );
          },
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String? mark;
  final Color color;
  final VoidCallback? onTap;

  const _Cell({required this.mark, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: mark == null
                ? const SizedBox.shrink(key: ValueKey('empty'))
                : Text(
                    mark!,
                    key: ValueKey(mark),
                    style: TextStyle(
                      color: color,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

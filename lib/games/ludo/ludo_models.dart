import 'package:flutter/material.dart';

/// The four classic Ludo colors, in clockwise turn order.
enum LudoColor { red, green, yellow, blue }

extension LudoColorX on LudoColor {
  Color get color => switch (this) {
        LudoColor.red => const Color(0xFFFF5E5E),
        LudoColor.green => const Color(0xFF6EE7A0),
        LudoColor.yellow => const Color(0xFFFFD166),
        LudoColor.blue => const Color(0xFF4EA8DE),
      };

  String get label => switch (this) {
        LudoColor.red => 'Red',
        LudoColor.green => 'Green',
        LudoColor.yellow => 'Yellow',
        LudoColor.blue => 'Blue',
      };

  /// Where this color's tokens step onto the shared 52-cell ring.
  int get entryIndex => index * 13;
}

/// One of a player's 4 tokens.
///
/// [progress] encodes its position:
///  * -1           → still in the yard (not yet in play)
///  * 0..50        → on the shared 52-cell ring, at absolute cell
///                   `(color.entryIndex + progress) % 52`
///  * 51..55       → in this color's private 6-cell home stretch
///  * 56           → home stretch cell 5 — finished
class LudoToken {
  final int index; // 0..3, which of the 4 tokens this is
  int progress;

  LudoToken({required this.index, this.progress = -1});

  bool get isInYard => progress == -1;
  bool get isFinished => progress == finishProgress;

  static const int finishProgress = 56;
}

/// Board-wide constants shared by the controller, AI, and painters.
class LudoBoard {
  static const int ringLength = 52;
  static const int mainTrackSteps = 51; // progress 0..50 on the ring
  static const int homeStretchLength = 6; // progress 51..56

  /// Cells where a token can't be captured — each color's own entry
  /// point plus one "star" cell partway around from it, matching the
  /// standard 8 safe squares on a real Ludo board.
  static const Set<int> safeCells = {0, 8, 13, 21, 26, 34, 39, 47};
}

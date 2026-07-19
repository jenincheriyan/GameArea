/// A single question shown to the player, e.g. "25 + 14 > 18 + 20" or
/// "8 x 4 = 35" — [isTrue] says whether the shown statement is actually
/// correct. Each question gets a unique [id] so the controller can tell
/// a stale answer apart from the current question (mirrors the pattern
/// used by [MathEquation] in the Math Duel game).
class MathQuestion {
  final int id;
  final String expression;
  final bool isTrue;

  const MathQuestion({
    required this.id,
    required this.expression,
    required this.isTrue,
  });
}

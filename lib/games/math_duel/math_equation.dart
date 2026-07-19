/// A single spawned equation, e.g. "7 + 5 = 13" — [isTrue] says whether
/// the shown result is actually correct. Each spawn gets a unique [id] so
/// the controller can tell a stale expiry/answer apart from the current one.
class MathEquation {
  final int id;
  final String expression;
  final bool isTrue;

  const MathEquation({
    required this.id,
    required this.expression,
    required this.isTrue,
  });
}

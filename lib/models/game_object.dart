/// The two kinds of object that can appear in a Fruit Duel round.
enum ObjectKind { fruit, bomb }

/// A single spawned object. Each spawn gets a unique [id] so the game
/// engine can tell "this exact object" apart from whatever spawns next —
/// that's what makes it possible to ignore a stale cut/expiry event.
class GameObject {
  final int id;
  final ObjectKind kind;
  final String emoji;

  const GameObject({
    required this.id,
    required this.kind,
    required this.emoji,
  });
}

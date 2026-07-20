/// The three kinds of object that can spawn in Catch the Fish.
enum CatchKind { fish, shark, bomb }

/// A single spawned item. [id] lets a controller ignore a stale
/// expiry/tap event once a new item has already spawned in its place.
class CatchItem {
  final int id;
  final CatchKind kind;
  final double x;
  final double y;

  const CatchItem({
    required this.id,
    required this.kind,
    required this.x,
    required this.y,
  });

  String get emoji => switch (kind) {
        CatchKind.fish => '🐟',
        CatchKind.shark => '🦈',
        CatchKind.bomb => '💣',
      };
}

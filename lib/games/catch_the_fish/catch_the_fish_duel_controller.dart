import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'catch_item.dart';

/// Drives the two-player Catch the Fish duel. The board is visually
/// split into a Player 1 zone and a Player 2 zone, but every item
/// spawns in the shared center strip both zones overlap into — so
/// whichever player's zone registers the tap first claims it, exactly
/// matching "fish appear in the center, first player to tap scores".
class CatchTheFishDuelController extends ChangeNotifier {
  static const double boardWidth = 400;
  static const double boardHeight = 600;
  static const int targetScore = 10;

  final Random _random = Random();

  CatchItem? currentItem;
  int player1Score = 0;
  int player2Score = 0;
  int? winner;

  int _idCounter = 0;
  Timer? _spawnTimer;
  bool _disposed = false;

  void start() {
    player1Score = 0;
    player2Score = 0;
    winner = null;
    currentItem = null;
    _spawnTimer?.cancel();
    _spawnTimer = Timer(const Duration(milliseconds: 500), _spawnNext);
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  CatchKind _randomKind() {
    final roll = _random.nextDouble();
    if (roll < 0.6) return CatchKind.fish;
    if (roll < 0.85) return CatchKind.shark;
    return CatchKind.bomb;
  }

  void _spawnNext() {
    if (winner != null) return;
    _idCounter++;
    const margin = 60.0;
    currentItem = CatchItem(
      id: _idCounter,
      kind: _randomKind(),
      x: boardWidth / 2, // always the shared center strip
      y: margin + _random.nextDouble() * (boardHeight - margin * 2),
    );
    _safeNotify();
  }

  /// Called by either player's tap zone. [player] is 1 or 2.
  void attemptTap(int player, int itemId) {
    if (winner != null || currentItem == null || currentItem!.id != itemId) {
      return;
    }

    final kind = currentItem!.kind;
    currentItem = null; // claimed — locks out the other player's zone

    if (kind == CatchKind.fish) {
      if (player == 1) {
        player1Score++;
      } else {
        player2Score++;
      }
    } else {
      if (player == 1) {
        player1Score = max(0, player1Score - 1);
      } else {
        player2Score = max(0, player2Score - 1);
      }
    }

    if (player1Score >= targetScore || player2Score >= targetScore) {
      winner = player2Score > player1Score ? 2 : 1;
      _safeNotify();
      return;
    }

    _safeNotify();
    _spawnTimer?.cancel();
    _spawnTimer = Timer(
      Duration(milliseconds: 400 + _random.nextInt(500)),
      _spawnNext,
    );
  }
}

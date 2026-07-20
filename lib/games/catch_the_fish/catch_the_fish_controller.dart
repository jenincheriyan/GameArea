import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catch_item.dart';

/// Drives single-player Catch the Fish on a fixed logical board (like
/// [FlappyBirdController]'s board): fish/sharks/bombs spawn one at a
/// time at random positions and auto-expire if not tapped in time.
/// Tapping a fish scores; tapping a shark or bomb costs a life.
class CatchTheFishController extends ChangeNotifier {
  static const double boardWidth = 400;
  static const double boardHeight = 600;
  static const int startingLives = 3;
  static const String _highScoreKey = 'catch_the_fish_high_score';

  final Random _random = Random();

  CatchItem? currentItem;
  int score = 0;
  int highScore = 0;
  int lives = startingLives;
  bool isGameOver = false;
  bool isReady = false;

  int _idCounter = 0;
  Timer? _expiryTimer;
  bool _disposed = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(_highScoreKey) ?? 0;
    isReady = true;
    _startRound();
    _safeNotify();
  }

  void restart() {
    _startRound();
    _safeNotify();
  }

  void _startRound() {
    score = 0;
    lives = startingLives;
    isGameOver = false;
    _spawnNext();
  }

  @override
  void dispose() {
    _disposed = true;
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Difficulty tier: every 5 points shortens how long an item stays on
  /// screen before it despawns untapped, down to a readable minimum.
  Duration get _lifespan {
    final tier = min(score ~/ 5, 6);
    final millis = max(1300 - tier * 130, 650);
    return Duration(milliseconds: millis);
  }

  CatchKind _randomKind() {
    final roll = _random.nextDouble();
    if (roll < 0.62) return CatchKind.fish;
    if (roll < 0.87) return CatchKind.shark;
    return CatchKind.bomb;
  }

  void _spawnNext() {
    _idCounter++;
    const margin = 40.0;
    final item = CatchItem(
      id: _idCounter,
      kind: _randomKind(),
      x: margin + _random.nextDouble() * (boardWidth - margin * 2),
      y: margin + _random.nextDouble() * (boardHeight - margin * 2),
    );
    currentItem = item;

    _expiryTimer?.cancel();
    _expiryTimer = Timer(_lifespan, () {
      if (_disposed || isGameOver) return;
      if (currentItem?.id == item.id) {
        _spawnNext();
        _safeNotify();
      }
    });
  }

  /// Called when the player taps the current item.
  void tapItem(int itemId) {
    if (isGameOver || currentItem == null || currentItem!.id != itemId) return;

    final kind = currentItem!.kind;
    if (kind == CatchKind.fish) {
      score++;
    } else {
      lives--;
    }

    if (lives <= 0) {
      _endGame();
      return;
    }

    _spawnNext();
    _safeNotify();
  }

  Future<void> _endGame() async {
    isGameOver = true;
    currentItem = null;
    _expiryTimer?.cancel();
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, highScore);
    }
    _safeNotify();
  }
}

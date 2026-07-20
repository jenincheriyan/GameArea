import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One pipe pair scrolling across the board.
class FlappyPipe {
  double x;
  final double gapCenterY;
  final double gapHeight;
  bool passed = false;

  FlappyPipe({required this.x, required this.gapCenterY, required this.gapHeight});
}

/// Drives single-player Flappy Bird on a fixed logical coordinate board
/// ([boardWidth] x [boardHeight]) that the screen scales to fit the
/// actual widget size — same "resolution independent logical board"
/// approach as [SnakeController]'s grid.
///
/// Plain Dart [ChangeNotifier]; a [Timer] advances physics every frame.
class FlappyBirdController extends ChangeNotifier {
  static const double boardWidth = 400;
  static const double boardHeight = 700;
  static const double birdX = 110;
  static const double birdRadius = 16;
  static const double pipeWidth = 62;
  static const String _highScoreKey = 'flappy_bird_high_score';

  static const double _gravity = 0.55;
  static const double _flapVelocity = -8.6;
  static const Duration _frameRate = Duration(milliseconds: 16);
  static const double _pipeSpacing = 240;

  final Random _random = Random();

  double birdY = boardHeight / 2;
  double _velocity = 0;
  List<FlappyPipe> pipes = [];

  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isReady = false;
  bool _started = false;

  Timer? _timer;
  bool _disposed = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(_highScoreKey) ?? 0;
    isReady = true;
    _resetState();
    _safeNotify();
  }

  void _resetState() {
    birdY = boardHeight / 2;
    _velocity = 0;
    pipes = [
      FlappyPipe(
        x: boardWidth + 150,
        gapCenterY: _randomGapCenter(),
        gapHeight: 190,
      ),
    ];
    score = 0;
    isGameOver = false;
    _started = false;
    _timer?.cancel();
  }

  double _randomGapCenter() {
    const margin = 90.0;
    return margin + _random.nextDouble() * (boardHeight - margin * 2);
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Restarts the run (keeps the loaded high score).
  void restart() {
    _resetState();
    _safeNotify();
  }

  /// Tap/flap input. The first tap after a (re)start also kicks off the
  /// physics loop, so the bird sits still until the player is ready.
  void flap() {
    if (isGameOver) return;
    if (!_started) {
      _started = true;
      _timer = Timer.periodic(_frameRate, (_) => _tick());
    }
    _velocity = _flapVelocity;
    _safeNotify();
  }

  /// Difficulty tier from score: pipes speed up and the gap narrows,
  /// both clamped so it never becomes unfair-impossible.
  double get _pipeSpeed => min(3.2 + score * 0.08, 6.5);
  double get _gapHeight => max(190 - score * 3.0, 130);

  void _tick() {
    _velocity += _gravity;
    birdY += _velocity;

    for (final pipe in pipes) {
      pipe.x -= _pipeSpeed;
    }
    pipes.removeWhere((p) => p.x < -pipeWidth);

    if (pipes.isEmpty || pipes.last.x < boardWidth - _pipeSpacing) {
      pipes.add(FlappyPipe(
        x: boardWidth + 40,
        gapCenterY: _randomGapCenter(),
        gapHeight: _gapHeight,
      ));
    }

    for (final pipe in pipes) {
      if (!pipe.passed && pipe.x + pipeWidth < birdX) {
        pipe.passed = true;
        score++;
      }
    }

    if (_checkCollision()) {
      _endGame();
      return;
    }

    _safeNotify();
  }

  bool _checkCollision() {
    if (birdY - birdRadius <= 0 || birdY + birdRadius >= boardHeight) {
      return true;
    }
    for (final pipe in pipes) {
      final overlapsX =
          birdX + birdRadius > pipe.x && birdX - birdRadius < pipe.x + pipeWidth;
      if (!overlapsX) continue;
      final gapTop = pipe.gapCenterY - pipe.gapHeight / 2;
      final gapBottom = pipe.gapCenterY + pipe.gapHeight / 2;
      final withinGap = birdY - birdRadius > gapTop && birdY + birdRadius < gapBottom;
      if (!withinGap) return true;
    }
    return false;
  }

  Future<void> _endGame() async {
    isGameOver = true;
    _timer?.cancel();
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, highScore);
    }
    _safeNotify();
  }
}

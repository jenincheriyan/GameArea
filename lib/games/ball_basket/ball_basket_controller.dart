import 'dart:async';
import 'dart:math';
import 'dart:ui' show Offset;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Drives single-player Ball in the Basket on a fixed logical board
/// (same "resolution independent" approach as the other physics games
/// in this project). The player drags away from the ball (slingshot
/// style) and releases to launch it; landing in the basket scores and
/// builds a streak multiplier, missing breaks the streak and costs one
/// of 3 lives.
class BallBasketController extends ChangeNotifier {
  static const double boardWidth = 400;
  static const double boardHeight = 700;
  static const double launchX = 200;
  static const double launchY = 640;
  static const double ballRadius = 16;
  static const double basketY = 130;
  static const double basketHalfWidth = 38;
  static const int startingLives = 3;
  static const String _highScoreKey = 'ball_basket_high_score';

  static const double _gravity = 0.32;
  static const double _dragSensitivity = 4.2;
  static const double _maxSpeed = 22;
  static const Duration _frameRate = Duration(milliseconds: 16);

  final Random _random = Random();

  double ballX = launchX;
  double ballY = launchY;
  double basketX = 200;
  bool isFlying = false;

  int score = 0;
  int streak = 0;
  int lives = startingLives;
  int highScore = 0;
  bool isGameOver = false;
  bool isReady = false;
  bool justMadeBasket = false; // brief flag the UI can flash on a make

  double _vx = 0;
  double _vy = 0;
  Timer? _timer;
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
    streak = 0;
    lives = startingLives;
    isGameOver = false;
    _resetBall();
    _randomizeBasket();
  }

  void _resetBall() {
    ballX = launchX;
    ballY = launchY;
    isFlying = false;
    _vx = 0;
    _vy = 0;
    _timer?.cancel();
  }

  void _randomizeBasket() {
    const margin = 60.0;
    basketX = margin + _random.nextDouble() * (boardWidth - margin * 2);
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

  /// Launches the ball. [dragVector] is the finger's drag displacement
  /// (current position minus start position) — the ball is thrown in
  /// the *opposite* direction, slingshot style.
  void launch(Offset dragVector) {
    if (isFlying || isGameOver) return;

    var vx = -dragVector.dx * _dragSensitivity / 40;
    var vy = -dragVector.dy * _dragSensitivity / 40;
    final speed = sqrt(vx * vx + vy * vy);
    if (speed < 2) return; // too weak a flick to count
    if (speed > _maxSpeed) {
      vx = vx / speed * _maxSpeed;
      vy = vy / speed * _maxSpeed;
    }
    // Always throw upward — a purely sideways/downward flick would never
    // reach the basket and just feels like a dropped input.
    if (vy > -4) vy = -4;

    _vx = vx;
    _vy = vy;
    isFlying = true;
    justMadeBasket = false;
    _timer?.cancel();
    _timer = Timer.periodic(_frameRate, (_) => _tick());
    _safeNotify();
  }

  void _tick() {
    _vy += _gravity;
    ballX += _vx;
    ballY += _vy;

    final inBasketBand = ballY >= basketY - 20 &&
        ballY <= basketY + 20 &&
        (ballX - basketX).abs() <= basketHalfWidth;

    if (inBasketBand) {
      _onMade();
      return;
    }

    final outOfBounds =
        ballY > boardHeight || ballX < -40 || ballX > boardWidth + 40;
    if (outOfBounds) {
      _onMissed();
      return;
    }

    _safeNotify();
  }

  void _onMade() {
    _timer?.cancel();
    streak++;
    final multiplier = min(streak, 5);
    score += multiplier;
    justMadeBasket = true;
    _safeNotify();
    _nextShotSoon();
  }

  void _onMissed() {
    _timer?.cancel();
    streak = 0;
    lives--;
    justMadeBasket = false;
    if (lives <= 0) {
      _endGame();
      return;
    }
    _safeNotify();
    _nextShotSoon();
  }

  void _nextShotSoon() {
    Future.delayed(const Duration(milliseconds: 550), () {
      if (_disposed || isGameOver) return;
      _resetBall();
      _randomizeBasket();
      _safeNotify();
    });
  }

  Future<void> _endGame() async {
    isGameOver = true;
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, highScore);
    }
    _safeNotify();
  }
}


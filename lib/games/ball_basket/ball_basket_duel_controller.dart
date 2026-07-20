import 'dart:async';
import 'dart:math';
import 'dart:ui' show Offset;
import 'package:flutter/foundation.dart';

/// One player's independent ball/basket physics state within the duel.
class _RigState {
  double ballX;
  double ballY;
  double basketX;
  bool isFlying = false;
  double vx = 0;
  double vy = 0;
  int score = 0;

  _RigState({required this.ballX, required this.ballY, required this.basketX});
}

/// Drives the two-player Ball in the Basket duel: both players throw
/// simultaneously on their own half of the board against a shared
/// countdown; whoever has the higher score when time runs out wins.
class BallBasketDuelController extends ChangeNotifier {
  static const double boardWidth = 400; // per-player half width
  static const double boardHeight = 500;
  static const double launchY = 450;
  static const double ballRadius = 14;
  static const double basketY = 100;
  static const double basketHalfWidth = 36;
  static const Duration matchDuration = Duration(seconds: 45);

  static const double _gravity = 0.32;
  static const double _dragSensitivity = 4.2;
  static const double _maxSpeed = 22;
  static const Duration _frameRate = Duration(milliseconds: 16);

  final Random _random = Random();
  late _RigState _p1;
  late _RigState _p2;

  int? winner;
  int secondsRemaining = matchDuration.inSeconds;

  Timer? _physicsTimer;
  Timer? _clockTimer;
  bool _disposed = false;

  int get player1Score => _p1.score;
  int get player2Score => _p2.score;
  double get ball1X => _p1.ballX;
  double get ball1Y => _p1.ballY;
  double get basket1X => _p1.basketX;
  double get ball2X => _p2.ballX;
  double get ball2Y => _p2.ballY;
  double get basket2X => _p2.basketX;

  void start() {
    _p1 = _RigState(ballX: boardWidth / 2, ballY: launchY, basketX: _randomBasketX());
    _p2 = _RigState(ballX: boardWidth / 2, ballY: launchY, basketX: _randomBasketX());
    winner = null;
    secondsRemaining = matchDuration.inSeconds;

    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(_frameRate, (_) => _tick());

    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onClockTick());

    _safeNotify();
  }

  double _randomBasketX() {
    const margin = 60.0;
    return margin + _random.nextDouble() * (boardWidth - margin * 2);
  }

  @override
  void dispose() {
    _disposed = true;
    _physicsTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void launchPlayer1(Offset dragVector) => _launch(_p1, dragVector);
  void launchPlayer2(Offset dragVector) => _launch(_p2, dragVector);

  void _launch(_RigState rig, Offset dragVector) {
    if (rig.isFlying || winner != null) return;
    var vx = -dragVector.dx * _dragSensitivity / 40;
    var vy = -dragVector.dy * _dragSensitivity / 40;
    final speed = sqrt(vx * vx + vy * vy);
    if (speed < 2) return;
    if (speed > _maxSpeed) {
      vx = vx / speed * _maxSpeed;
      vy = vy / speed * _maxSpeed;
    }
    if (vy > -4) vy = -4;
    rig.vx = vx;
    rig.vy = vy;
    rig.isFlying = true;
  }

  void _onClockTick() {
    if (winner != null) return;
    secondsRemaining--;
    if (secondsRemaining <= 0) {
      secondsRemaining = 0;
      _endMatch();
      return;
    }
    _safeNotify();
  }

  void _tick() {
    if (winner != null) return;
    _tickRig(_p1);
    _tickRig(_p2);
    _safeNotify();
  }

  void _tickRig(_RigState rig) {
    if (!rig.isFlying) return;
    rig.vy += _gravity;
    rig.ballX += rig.vx;
    rig.ballY += rig.vy;

    final inBasketBand = rig.ballY >= basketY - 20 &&
        rig.ballY <= basketY + 20 &&
        (rig.ballX - rig.basketX).abs() <= basketHalfWidth;
    final outOfBounds =
        rig.ballY > boardHeight || rig.ballX < -40 || rig.ballX > boardWidth + 40;

    if (inBasketBand) {
      rig.score++;
      _resetRigSoon(rig);
    } else if (outOfBounds) {
      _resetRigSoon(rig);
    }
  }

  void _resetRigSoon(_RigState rig) {
    rig.isFlying = false; // freeze in place until the delayed reset below
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_disposed || winner != null) return;
      rig.ballX = boardWidth / 2;
      rig.ballY = launchY;
      rig.basketX = _randomBasketX();
      rig.vx = 0;
      rig.vy = 0;
      _safeNotify();
    });
  }

  void _endMatch() {
    _physicsTimer?.cancel();
    _clockTimer?.cancel();
    winner = _p2.score > _p1.score ? 2 : 1;
    _safeNotify();
  }
}

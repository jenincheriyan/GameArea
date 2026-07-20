import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'car_race_controller.dart' show RoadItem, RoadItemKind;

/// Drives the two-player Car Race duel. Both players race the exact
/// same generated obstacle course (one shared [items] list scrolling at
/// one shared speed) on a shared 2-lane road — only lane choice and
/// survival differ between them, so the outcome comes down to
/// reactions, not luck of the draw.
class CarRaceDuelController extends ChangeNotifier {
  static const double boardWidth = 200; // per-player half width, 2 lanes
  static const double boardHeight = 500;
  static const int laneCount = 2;
  static const double carY = 420;
  static const double carHeight = 60;
  static const double finishDistance = 400;

  static const Duration _frameRate = Duration(milliseconds: 16);

  final Random _random = Random();

  int player1Lane = 0;
  int player2Lane = 1;
  bool player1Alive = true;
  bool player2Alive = true;
  double player1Distance = 0;
  double player2Distance = 0;
  List<RoadItem> items = [];

  int? winner;

  double _distance = 0; // shared course progress, drives spawn/speed ramp
  double _spawnCooldown = 0;
  int _idCounter = 0;
  final Set<int> _player1CollectedIds = {};
  final Set<int> _player2CollectedIds = {};
  Timer? _timer;
  bool _disposed = false;

  double laneCenter(int lane) => (lane + 0.5) * (boardWidth / laneCount);

  int get player1Score => player1Distance.floor();
  int get player2Score => player2Distance.floor();

  void start() {
    player1Lane = 0;
    player2Lane = 1;
    player1Alive = true;
    player2Alive = true;
    player1Distance = 0;
    player2Distance = 0;
    items = [];
    winner = null;
    _distance = 0;
    _spawnCooldown = 0;
    _timer?.cancel();
    _timer = Timer.periodic(_frameRate, (_) => _tick());
    _safeNotify();
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

  void movePlayer1(int direction) => _move(1, direction);
  void movePlayer2(int direction) => _move(2, direction);

  void _move(int player, int direction) {
    if (winner != null) return;
    if (player == 1 && player1Alive) {
      player1Lane = (player1Lane + direction).clamp(0, laneCount - 1);
    } else if (player == 2 && player2Alive) {
      player2Lane = (player2Lane + direction).clamp(0, laneCount - 1);
    }
  }

  double get _speed => min(4.0 + _distance / 250, 10.0);
  double get _spawnInterval => max(38.0 - _distance / 40, 18.0);

  void _tick() {
    if (winner != null) return;
    if (!player1Alive && !player2Alive) {
      _endRace();
      return;
    }

    _distance += _speed / 12;
    if (player1Alive) player1Distance += _speed / 12;
    if (player2Alive) player2Distance += _speed / 12;

    for (final item in items) {
      item.y += _speed;
    }
    items.removeWhere((i) => i.y > boardHeight + 60);

    _spawnCooldown -= 1;
    if (_spawnCooldown <= 0) {
      _spawnCooldown = _spawnInterval;
      _idCounter++;
      final lane = _random.nextInt(laneCount);
      final kind = _random.nextDouble() < 0.72 ? RoadItemKind.traffic : RoadItemKind.coin;
      items.add(RoadItem(id: _idCounter, lane: lane, y: -60, kind: kind));
    }

    _checkCollision(1);
    _checkCollision(2);

    if (player1Distance >= finishDistance || player2Distance >= finishDistance) {
      _decideWinnerAndEnd();
      return;
    }
    if (!player1Alive && !player2Alive) {
      _endRace();
      return;
    }

    _safeNotify();
  }

  void _checkCollision(int player) {
    final alive = player == 1 ? player1Alive : player2Alive;
    if (!alive) return;
    final lane = player == 1 ? player1Lane : player2Lane;

    for (final item in items) {
      if (item.lane != lane) continue;
      final overlapsY = (item.y - carY).abs() < carHeight * 0.6;
      if (!overlapsY) continue;
      if (item.kind == RoadItemKind.traffic) {
        if (player == 1) {
          player1Alive = false;
        } else {
          player2Alive = false;
        }
        return;
      }
      // Coins award a small distance bonus instead of being removed —
      // the object stays on the shared course so the other player can
      // also reach it, keeping "same obstacle generation" for both.
      // Each player can only claim a given coin once.
      final collected = player == 1 ? _player1CollectedIds : _player2CollectedIds;
      if (collected.contains(item.id)) continue;
      collected.add(item.id);
      if (player == 1) {
        player1Distance += 5;
      } else {
        player2Distance += 5;
      }
    }
  }

  void _decideWinnerAndEnd() {
    winner = player2Distance > player1Distance ? 2 : 1;
    _endRace();
  }

  void _endRace() {
    _timer?.cancel();
    winner ??= player2Distance > player1Distance ? 2 : 1;
    _safeNotify();
  }
}

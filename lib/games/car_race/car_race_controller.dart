import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RoadItemKind { traffic, coin }

class RoadItem {
  final int id;
  final int lane;
  double y;
  final RoadItemKind kind;

  RoadItem({required this.id, required this.lane, required this.y, required this.kind});
}

/// Drives single-player Car Race: a top-down 3-lane endless runner.
/// Traffic and coins scroll down the fixed logical board; the player
/// switches lanes to dodge traffic and grab coins. Score is distance
/// traveled (plus a small coin bonus); speed and spawn rate both ramp
/// up as the score grows.
class CarRaceController extends ChangeNotifier {
  static const double boardWidth = 300;
  static const double boardHeight = 600;
  static const int laneCount = 3;
  static const double carY = 500;
  static const double carHeight = 70;
  static const double carWidth = 56;
  static const String _highScoreKey = 'car_race_high_score';

  static const Duration _frameRate = Duration(milliseconds: 16);

  final Random _random = Random();

  int playerLane = 1;
  double carX = 0; // eased toward the target lane each tick
  List<RoadItem> items = [];

  int score = 0;
  int coins = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isReady = false;

  double _distance = 0;
  double _spawnCooldown = 0;
  int _idCounter = 0;
  Timer? _timer;
  bool _disposed = false;

  double laneCenter(int lane) => (lane + 0.5) * (boardWidth / laneCount);

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
    playerLane = 1;
    carX = laneCenter(1);
    items = [];
    score = 0;
    coins = 0;
    _distance = 0;
    _spawnCooldown = 0;
    isGameOver = false;
    _timer?.cancel();
    _timer = Timer.periodic(_frameRate, (_) => _tick());
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

  void moveLeft() {
    if (isGameOver) return;
    if (playerLane > 0) playerLane--;
  }

  void moveRight() {
    if (isGameOver) return;
    if (playerLane < laneCount - 1) playerLane++;
  }

  double get _speed => min(4.0 + _distance / 250, 11.0);
  double get _spawnInterval => max(38.0 - _distance / 40, 16.0); // ticks between spawns

  void _tick() {
    if (isGameOver) return;

    _distance += _speed / 12; // tuned so score climbs at a readable pace
    score = _distance.floor() + coins * 5;

    // Ease the car horizontally toward its target lane.
    final targetX = laneCenter(playerLane);
    carX += (targetX - carX) * 0.35;

    for (final item in items) {
      item.y += _speed;
    }
    items.removeWhere((i) => i.y > boardHeight + 60);

    _spawnCooldown -= 1;
    if (_spawnCooldown <= 0) {
      _spawnCooldown = _spawnInterval;
      _spawnItem();
    }

    if (_checkCollision()) {
      _endGame();
      return;
    }

    _safeNotify();
  }

  void _spawnItem() {
    _idCounter++;
    final lane = _random.nextInt(laneCount);
    final kind = _random.nextDouble() < 0.72 ? RoadItemKind.traffic : RoadItemKind.coin;
    items.add(RoadItem(id: _idCounter, lane: lane, y: -60, kind: kind));
  }

  bool _checkCollision() {
    for (final item in items.toList()) {
      if (item.lane != playerLane) continue;
      final overlapsY = (item.y - carY).abs() < carHeight * 0.6;
      if (!overlapsY) continue;
      if (item.kind == RoadItemKind.traffic) return true;
      if (item.kind == RoadItemKind.coin) {
        coins++;
        items.remove(item);
      }
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

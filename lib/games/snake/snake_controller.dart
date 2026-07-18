import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Direction { up, down, left, right }

/// Drives a single game of Snake: moving the snake on a fixed tick,
/// spawning food, detecting wall/self collisions, and tracking score.
///
/// Plain Dart (a [ChangeNotifier]) with no widget dependency, same shape
/// as [FruitDuelController] — a screen just listens and rebuilds.
class SnakeController extends ChangeNotifier {
  SnakeController() {
    _loadHighScore();
  }
  static const int gridSize = 16;
  static const Duration _startTickRate = Duration(milliseconds: 220);
  static const Duration _minTickRate = Duration(milliseconds: 90);

  final Random _random = Random();

  late List<Point<int>> snake;
  late Point<int> food;
  Direction _direction = Direction.right;
  Direction _pendingDirection = Direction.right;
  int highScore = 0;
  int score = 0;
  bool isGameOver = false;

  bool _running = false;
  Timer? _timer;
  Duration _tickRate = _startTickRate;
  bool _disposed = false;

  void start() {
    final mid = gridSize ~/ 2;
    snake = [
      Point(mid - 1, mid),
      Point(mid - 2, mid),
      Point(mid - 3, mid),
    ];
    _direction = Direction.right;
    _pendingDirection = Direction.right;
    score = 0;
    isGameOver = false;
    _tickRate = _startTickRate;
    _spawnFood();
    _running = true;
    _scheduleTick();
    _safeNotify();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _scheduleTick() {
    _timer?.cancel();
    _timer = Timer.periodic(_tickRate, (_) => _tick());
  }

  /// Called by swipe gestures or on-screen D-pad buttons. Direct
  /// 180-degree reversals are ignored so the snake can't run into itself
  /// on the very next tick.
  void changeDirection(Direction newDirection) {
    if (!_running || isGameOver) return;
    if (_isOpposite(newDirection, _direction)) return;
    _pendingDirection = newDirection;
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.up && b == Direction.down) ||
        (a == Direction.down && b == Direction.up) ||
        (a == Direction.left && b == Direction.right) ||
        (a == Direction.right && b == Direction.left);
  }

  void _tick() {
    if (!_running || isGameOver) return;
    _direction = _pendingDirection;

    final head = snake.first;
    late Point<int> newHead;
    switch (_direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    // Wall collision.
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      _endGame();
      return;
    }

    final willGrow = newHead == food;
    // The tail cell is safe to move into (it vacates this tick) unless
    // the snake is about to grow, in which case the tail stays put.
    final bodyToCheck = willGrow ? snake : snake.sublist(0, snake.length - 1);
    if (bodyToCheck.contains(newHead)) {
      _endGame();
      return;
    }

    snake = [newHead, ...snake]; // new list instance so the UI can diff it
    if (willGrow) {
      score++;
      if (score > highScore) {
        highScore = score;
        _saveHighScore();
      }
      _spawnFood();
      _speedUp();
    } else {
      snake = snake.sublist(0, snake.length - 1);
    }

    _safeNotify();
  }

  void _speedUp() {
    final newMillis = (_tickRate.inMilliseconds - 6)
        .clamp(_minTickRate.inMilliseconds, _startTickRate.inMilliseconds);
    final newRate = Duration(milliseconds: newMillis);
    if (newRate != _tickRate) {
      _tickRate = newRate;
      _scheduleTick();
    }
  }

  void _spawnFood() {
    Point<int> candidate;
    do {
      candidate = Point(_random.nextInt(gridSize), _random.nextInt(gridSize));
    } while (snake.contains(candidate));
    food = candidate;
  }

  void _endGame() {
    isGameOver = true;
    _running = false;
    _timer?.cancel();
    _safeNotify();
  }
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('snake_high_score') ?? 0;
    _safeNotify();
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('snake_high_score', highScore);
  }
}


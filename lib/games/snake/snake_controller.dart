import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Direction { up, down, left, right }

/// Drives a single game of Snake: moving the snake on a fixed tick,
/// spawning food, detecting self collisions, and tracking score.
///
/// Walls wrap around instead of killing the snake — exiting one edge of
/// the board brings it back in on the opposite edge. The only way to die
/// is running the head into the snake's own body. The game can also be
/// paused/resumed, and the high score is persisted locally.
class SnakeController extends ChangeNotifier {
  static const int gridSize = 16;
  static const Duration _startTickRate = Duration(milliseconds: 220);
  static const Duration _minTickRate = Duration(milliseconds: 90);
  static const String _hiScoreKey = 'snake_hi_score';

  final Random _random = Random();

  late List<Point<int>> snake;
  late Point<int> food;
  Direction _direction = Direction.right;
  Direction _pendingDirection = Direction.right;

  int score = 0;
  int hiScore = 0;
  bool isGameOver = false;
  bool isPaused = false;

  bool _running = false;
  Timer? _timer;
  Duration _tickRate = _startTickRate;
  bool _disposed = false;
  SharedPreferences? _prefs;

  /// Loads the persisted high score. Call once (e.g. in initState) before
  /// [start], so the header shows the real high score right away.
  Future<void> loadHiScore() async {
    _prefs = await SharedPreferences.getInstance();
    hiScore = _prefs?.getInt(_hiScoreKey) ?? 0;
    _safeNotify();
  }

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
    isPaused = false;
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

  /// Toggles pause/resume. This is the only input allowed while paused;
  /// direction changes are ignored until the game is resumed.
  void togglePause() {
    if (!_running || isGameOver) return;
    isPaused = !isPaused;
    _safeNotify();
  }

  /// Called from the on-screen D-pad. Ignored entirely while paused, and
  /// direct 180-degree reversals are ignored so the snake can't be turned
  /// straight back into itself on the very next tick.
  void changeDirection(Direction newDirection) {
    if (!_running || isGameOver || isPaused) return;
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
    if (!_running || isGameOver || isPaused) return;
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

    // Wrap-around: exiting one edge brings the head back on the
    // opposite edge instead of ending the game.
    newHead = Point(
      (newHead.x + gridSize) % gridSize,
      (newHead.y + gridSize) % gridSize,
    );

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
      if (score > hiScore) {
        hiScore = score;
        _persistHiScore();
      }
      _spawnFood();
      _speedUp();
    } else {
      snake = snake.sublist(0, snake.length - 1);
    }

    _safeNotify();
  }

  Future<void> _persistHiScore() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_hiScoreKey, hiScore);
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
}

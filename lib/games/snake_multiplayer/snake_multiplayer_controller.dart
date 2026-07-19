import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

enum Direction { up, down, left, right }

/// Drives a local two-player match of Snake on a single shared board.
///
/// Both snakes move on the same tick (a single [Timer], not one per
/// snake) so the two sides stay perfectly in sync for a fair race — same
/// "plain Dart ChangeNotifier, no widget dependency" shape as
/// [SnakeController] (single-player) and the other duel controllers.
///
/// Rules:
///  * Two foods are on the board at all times; either snake can eat either.
///  * A snake dies on wall collision, self collision, or hitting the
///    other snake's body — it then freezes in place while the other
///    snake (if still alive) keeps playing.
///  * The match ends the instant either score reaches [targetScore], or
///    once both snakes are dead. Whoever has the higher score at that
///    point wins; a tie is broken in favor of player 1.
class SnakeMultiplayerController extends ChangeNotifier {
  static const int gridSize = 18;
  static const int targetScore = 12;
  static const Duration _startTickRate = Duration(milliseconds: 220);
  static const Duration _minTickRate = Duration(milliseconds: 100);

  final Random _random = Random();

  late List<Point<int>> snake1;
  late List<Point<int>> snake2;
  late List<Point<int>> foods; // always length 2

  Direction _dir1 = Direction.right;
  Direction _pending1 = Direction.right;
  Direction _dir2 = Direction.left;
  Direction _pending2 = Direction.left;

  bool snake1Dead = false;
  bool snake2Dead = false;

  int player1Score = 0;
  int player2Score = 0;
  int? winner; // 1, 2, or null while the match is in progress

  Timer? _timer;
  Duration _tickRate = _startTickRate;
  bool _running = false;
  bool _disposed = false;

  void start() {
    final mid = gridSize ~/ 2;
    snake1 = [Point(2, mid), Point(1, mid), Point(0, mid)];
    snake2 = [
      Point(gridSize - 3, mid),
      Point(gridSize - 2, mid),
      Point(gridSize - 1, mid),
    ];
    _dir1 = Direction.right;
    _pending1 = Direction.right;
    _dir2 = Direction.left;
    _pending2 = Direction.left;

    snake1Dead = false;
    snake2Dead = false;
    player1Score = 0;
    player2Score = 0;
    winner = null;
    _tickRate = _startTickRate;

    foods = [];
    _spawnFood();
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

  /// Player 1's control input (e.g. left D-pad).
  void changeDirection1(Direction newDirection) {
    if (!_running || winner != null || snake1Dead) return;
    if (_isOpposite(newDirection, _dir1)) return;
    _pending1 = newDirection;
  }

  /// Player 2's control input (e.g. right D-pad).
  void changeDirection2(Direction newDirection) {
    if (!_running || winner != null || snake2Dead) return;
    if (_isOpposite(newDirection, _dir2)) return;
    _pending2 = newDirection;
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.up && b == Direction.down) ||
        (a == Direction.down && b == Direction.up) ||
        (a == Direction.left && b == Direction.right) ||
        (a == Direction.right && b == Direction.left);
  }

  Point<int> _nextHead(Point<int> head, Direction dir) {
    switch (dir) {
      case Direction.up:
        return Point(head.x, head.y - 1);
      case Direction.down:
        return Point(head.x, head.y + 1);
      case Direction.left:
        return Point(head.x - 1, head.y);
      case Direction.right:
        return Point(head.x + 1, head.y);
    }
  }

  bool _outOfBounds(Point<int> p) {
    return p.x < 0 || p.x >= gridSize || p.y < 0 || p.y >= gridSize;
  }

  void _tick() {
    if (!_running || winner != null) return;
    if (snake1Dead && snake2Dead) {
      _endGame();
      return;
    }

    _dir1 = _pending1;
    _dir2 = _pending2;

    Point<int>? newHead1 = snake1Dead ? null : _nextHead(snake1.first, _dir1);
    Point<int>? newHead2 = snake2Dead ? null : _nextHead(snake2.first, _dir2);

    bool die1 = snake1Dead;
    bool die2 = snake2Dead;

    // Wall collisions.
    if (newHead1 != null && _outOfBounds(newHead1)) die1 = true;
    if (newHead2 != null && _outOfBounds(newHead2)) die2 = true;

    // Head-to-head collision: both snakes move into the same cell.
    if (!die1 &&
        !die2 &&
        newHead1 != null &&
        newHead2 != null &&
        newHead1 == newHead2) {
      die1 = true;
      die2 = true;
    }

    final willGrow1 = newHead1 != null && foods.contains(newHead1);
    final willGrow2 = newHead2 != null && foods.contains(newHead2);

    // Self / body collisions, checked against pre-move bodies (tail cell
    // is safe to enter unless that snake is about to grow).
    if (!die1 && newHead1 != null) {
      final body1 = willGrow1 ? snake1 : snake1.sublist(0, snake1.length - 1);
      if (body1.contains(newHead1) || snake2.contains(newHead1)) die1 = true;
    }
    if (!die2 && newHead2 != null) {
      final body2 = willGrow2 ? snake2 : snake2.sublist(0, snake2.length - 1);
      if (body2.contains(newHead2) || snake1.contains(newHead2)) die2 = true;
    }

    // Apply snake 1.
    if (!die1 && newHead1 != null) {
      snake1 = [newHead1, ...snake1];
      if (willGrow1) {
        player1Score++;
        foods.remove(newHead1);
        _spawnFood();
      } else {
        snake1 = snake1.sublist(0, snake1.length - 1);
      }
    } else if (die1 && !snake1Dead) {
      snake1Dead = true;
    }

    // Apply snake 2.
    if (!die2 && newHead2 != null) {
      snake2 = [newHead2, ...snake2];
      if (willGrow2) {
        player2Score++;
        foods.remove(newHead2);
        _spawnFood();
      } else {
        snake2 = snake2.sublist(0, snake2.length - 1);
      }
    } else if (die2 && !snake2Dead) {
      snake2Dead = true;
    }

    if (willGrow1 || willGrow2) _speedUp();

    if (player1Score >= targetScore || player2Score >= targetScore) {
      _decideWinnerAndEnd();
      return;
    }
    if (snake1Dead && snake2Dead) {
      _decideWinnerAndEnd();
      return;
    }

    _safeNotify();
  }

  void _speedUp() {
    final newMillis = (_tickRate.inMilliseconds - 5)
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
    } while (snake1.contains(candidate) ||
        snake2.contains(candidate) ||
        foods.contains(candidate));
    foods.add(candidate);
  }

  void _decideWinnerAndEnd() {
    winner = player2Score > player1Score ? 2 : 1;
    _endGame();
  }

  void _endGame() {
    _running = false;
    _timer?.cancel();
    winner ??= player2Score > player1Score ? 2 : 1;
    _safeNotify();
  }
}

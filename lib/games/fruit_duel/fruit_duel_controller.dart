import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/game_object.dart';

/// What just happened to the last object, used to drive feedback
/// (flash colors, haptics, etc.) in the UI layer.
enum RoundResult {
  none,
  player1Fruit,
  player1Bomb,
  player2Fruit,
  player2Bomb,
  missedFruit,
  missedBomb,
}

/// Drives a single match of Fruit Duel: spawning objects on a timer,
/// resolving cuts, tracking score, and detecting a winner.
///
/// This is plain Dart (a [ChangeNotifier]) with no dependency on any
/// specific widget, so it's easy to unit test or reuse for a different
/// front end.
class FruitDuelController extends ChangeNotifier {
  static const int targetScore = 10;
  static const List<String> _fruitEmojis = [
    '🍎', '🍊', '🍌', '🍇', '🍉', '🍓', '🍍', '🥝'
  ];
  static const double _bombChance = 0.3;

  final Random _random = Random();

  int player1Score = 0;
  int player2Score = 0;
  GameObject? currentObject;
  int? winner; // 1, 2, or null while the match is in progress
  int? countdown;
  RoundResult lastResult = RoundResult.none;

  // Guards against both players scoring off the same object: the first
  // cut (or the expiry timer, if nobody cuts) sets this to true, and any
  // event after that for the same object is a no-op.
  bool _objectResolved = false;
  int _objectCounter = 0;
  Timer? _spawnTimer;
  Timer? _lifetimeTimer;
  bool _running = false;
  bool _disposed = false;

  Future<void> start() async {
    player1Score = 0;
    player2Score = 0;
    winner = null;
    currentObject = null;
    lastResult = RoundResult.none;
    countdown = 3;

    _running = true;
    _safeNotify();

    while (countdown! > 0) {
      await Future.delayed(const Duration(seconds: 1));
      countdown = countdown! - 1;
      _safeNotify();
    }

    // Show "GO!" for a short time
    countdown = 0;
    _safeNotify();

    await Future.delayed(const Duration(milliseconds: 600));

    countdown = null;
    _safeNotify();

    // Start spawning objects
    _scheduleNextSpawn(
      initialDelay: const Duration(milliseconds: 300),
    );
  }


  void stop() {
    _running = false;
    _spawnTimer?.cancel();
    _lifetimeTimer?.cancel();
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

  void _scheduleNextSpawn({Duration? initialDelay}) {
    _spawnTimer?.cancel();
    final delay = initialDelay ?? Duration(milliseconds: 500 + _random.nextInt(500));
    _spawnTimer = Timer(delay, _spawnObject);
  }

  void _spawnObject() {
    if (!_running || winner != null) return;

    _objectCounter++;
    final isBomb = _random.nextDouble() < _bombChance;
    final kind = isBomb ? ObjectKind.bomb : ObjectKind.fruit;
    final emoji = isBomb
        ? '💣'
        : _fruitEmojis[_random.nextInt(_fruitEmojis.length)];

    currentObject = GameObject(id: _objectCounter, kind: kind, emoji: emoji);
    _objectResolved = false;
    lastResult = RoundResult.none;
    _safeNotify();

    // How long the object stays on screen before it's considered "missed".
    final lifetime = Duration(milliseconds: 850 + _random.nextInt(550));
    _lifetimeTimer?.cancel();
    _lifetimeTimer = Timer(lifetime, () => _onObjectExpired(_objectCounter));
  }

  void _onObjectExpired(int objectId) {
    // Ignore if this expiry is for an object that's already gone (cut, or
    // a previous expiry already fired for it).
    if (currentObject?.id != objectId || _objectResolved) return;

    _objectResolved = true;
    lastResult = currentObject!.kind == ObjectKind.fruit
        ? RoundResult.missedFruit
        : RoundResult.missedBomb;
    currentObject = null;
    _safeNotify();
    _scheduleNextSpawn();
  }

  /// Called when [player] (1 or 2) taps their sword / CUT button.
  void cut(int player) {
    assert(player == 1 || player == 2);
    if (!_running || winner != null) return;

    final obj = currentObject;
    if (obj == null || _objectResolved) return; // nothing to cut right now

    // Lock the object immediately — this is what stops the other player's
    // simultaneous tap from also scoring off the same object.
    _objectResolved = true;
    _lifetimeTimer?.cancel();

    if (obj.kind == ObjectKind.fruit) {
      if (player == 1) {
        player1Score++;
        lastResult = RoundResult.player1Fruit;
      } else {
        player2Score++;
        lastResult = RoundResult.player2Fruit;
      }
    } else {
      if (player == 1) {
        player1Score--;
        lastResult = RoundResult.player1Bomb;
      } else {
        player2Score--;
        lastResult = RoundResult.player2Bomb;
      }
    }

    currentObject = null;

    if (player1Score >= targetScore) {
      winner = 1;
    } else if (player2Score >= targetScore) {
      winner = 2;
    }

    _safeNotify();

    if (winner == null) {
      _scheduleNextSpawn(initialDelay: const Duration(milliseconds: 450));
    } else {
      stop();
    }
  }
}

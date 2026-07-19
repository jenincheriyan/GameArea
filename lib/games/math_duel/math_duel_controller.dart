import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'math_equation.dart';

/// What just happened to the last equation, useful for UI feedback.
enum MathRoundResult {
  none,
  player1Correct,
  player1Wrong,
  player2Correct,
  player2Wrong,
  missedTrue,
  missedFalse,
}

/// Drives a match of Math Duel: the same equation is shown to both
/// players; whoever taps first when it's TRUE scores, and tapping a
/// FALSE equation costs a point — same fairness model as
/// [FruitDuelController] (first touch to an object "resolves" it, so
/// simultaneous taps can't both score).
class MathDuelController extends ChangeNotifier {
  static const int targetScore = 10;

  final Random _random = Random();

  int player1Score = 0;
  int player2Score = 0;
  MathEquation? currentEquation;
  int? winner;
  MathRoundResult lastResult = MathRoundResult.none;

  bool _resolved = false;
  int _counter = 0;
  Timer? _spawnTimer;
  Timer? _lifetimeTimer;
  bool _running = false;
  bool _disposed = false;

  void start() {
    player1Score = 0;
    player2Score = 0;
    winner = null;
    currentEquation = null;
    lastResult = MathRoundResult.none;
    _running = true;
    _scheduleNextSpawn(initialDelay: const Duration(milliseconds: 700));
    _safeNotify();
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
    final delay =
        initialDelay ?? Duration(milliseconds: 500 + _random.nextInt(500));
    _spawnTimer = Timer(delay, _spawnEquation);
  }

  void _spawnEquation() {
    if (!_running || winner != null) return;

    _counter++;
    final equation = _generateEquation(_counter);
    currentEquation = equation;
    _resolved = false;
    lastResult = MathRoundResult.none;
    _safeNotify();

    // Equations stay up a bit longer than Fruit Duel's objects since
    // reading + doing the math takes more time than spotting a fruit.
    final lifetime = Duration(milliseconds: 1400 + _random.nextInt(700));
    _lifetimeTimer?.cancel();
    _lifetimeTimer = Timer(lifetime, () => _onExpired(equation.id));
  }

  MathEquation _generateEquation(int id) {
    const ops = ['+', '-', '×'];
    final op = ops[_random.nextInt(ops.length)];
    int a, b, correct;

    switch (op) {
      case '+':
        a = 1 + _random.nextInt(20);
        b = 1 + _random.nextInt(20);
        correct = a + b;
        break;
      case '-':
        a = 5 + _random.nextInt(20);
        b = 1 + _random.nextInt(a); // keeps the result non-negative
        correct = a - b;
        break;
      default: // ×
        a = 1 + _random.nextInt(12);
        b = 1 + _random.nextInt(12);
        correct = a * b;
    }

    final showTrue = _random.nextBool();
    var shown = correct;
    if (!showTrue) {
      var delta = 0;
      while (delta == 0) {
        delta = 1 + _random.nextInt(6);
        if (_random.nextBool()) delta = -delta;
      }
      shown = correct + delta;
    }

    return MathEquation(
      id: id,
      expression: '$a $op $b = $shown',
      isTrue: shown == correct,
    );
  }

  void _onExpired(int equationId) {
    if (currentEquation?.id != equationId || _resolved) return;
    _resolved = true;
    lastResult = currentEquation!.isTrue
        ? MathRoundResult.missedTrue
        : MathRoundResult.missedFalse;
    currentEquation = null;
    _safeNotify();
    _scheduleNextSpawn();
  }

  /// Called when [player] (1 or 2) taps their button, claiming the shown
  /// equation is true.
  void answer(int player) {
    assert(player == 1 || player == 2);
    if (!_running || winner != null) return;

    final eq = currentEquation;
    if (eq == null || _resolved) return;

    // Locks the equation immediately so a simultaneous tap on the other
    // side can't also score off it.
    _resolved = true;
    _lifetimeTimer?.cancel();

    if (eq.isTrue) {
      if (player == 1) {
        player1Score++;
        lastResult = MathRoundResult.player1Correct;
      } else {
        player2Score++;
        lastResult = MathRoundResult.player2Correct;
      }
    } else {
      if (player == 1) {
        player1Score--;
        lastResult = MathRoundResult.player1Wrong;
      } else {
        player2Score--;
        lastResult = MathRoundResult.player2Wrong;
      }
    }

    currentEquation = null;

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

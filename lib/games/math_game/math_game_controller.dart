import 'dart:async'; // NEW: needed for the per-question countdown Timer
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'math_question.dart';

/// Drives the single-player Math Game: one True/False statement at a
/// time, an ever-climbing current score, and a high score persisted to
/// disk via [SharedPreferences].
///
/// Plain Dart (a [ChangeNotifier]) with no widget dependency, matching
/// the shape of every other controller in the project — a screen just
/// listens and rebuilds.
class MathGameController extends ChangeNotifier {
  static const String _highScoreKey = 'math_game_high_score';

  // NEW: life system + question timer configuration.
  static const int maxLives = 3;
  static const int questionSeconds = 2;

  final Random _random = Random();

  MathQuestion? currentQuestion;
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isReady = false; // becomes true once the saved high score has loaded

  // NEW: remaining lives and remaining seconds on the current question,
  // both surfaced to the UI.
  int lives = maxLives;
  int secondsRemaining = questionSeconds;

  int _questionCounter = 0;
  bool _disposed = false;

  // NEW: the single active countdown timer for the current question.
  Timer? _questionTimer;

  /// Loads the saved high score, then starts the first round. Call once
  /// when the screen mounts.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(_highScoreKey) ?? 0;
    isReady = true;
    _startRound(resetScore: true);
  }

  /// Resets only the current score/round state — the high score is left
  /// untouched, exactly as required for "play again".
  void restart() {
    _startRound(resetScore: true);
  }

  void _startRound({required bool resetScore}) {
    if (resetScore) {
      score = 0;
    }
    lives = maxLives; // NEW: refill lives at the start of a round
    isGameOver = false;
    _nextQuestion();
  }

  @override
  void dispose() {
    _disposed = true;
    _questionTimer?.cancel(); // NEW: avoid a leaked timer firing after dispose
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Difficulty tier derived from the current score: every 5 correct
  /// answers nudges the number ranges up and makes comparison-style
  /// questions (the hardest kind) more likely, up to a cap so things
  /// don't spiral into unreadable numbers.
  int get _tier => min(score ~/ 5, 6);

  void _nextQuestion() {
    _questionCounter++;
    currentQuestion = _generateQuestion(_questionCounter, _tier);
    _startQuestionTimer(); // NEW: (re)start the countdown for this question
    _safeNotify();
  }

  // NEW: Timer management -----------------------------------------------
  //
  // Ensures only one countdown is ever running: any existing timer is
  // cancelled before a new one is created, whenever a question loads.

  void _startQuestionTimer() {
    _questionTimer?.cancel(); // cancel any previous timer first
    secondsRemaining = questionSeconds;
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      secondsRemaining--;
      if (secondsRemaining <= 0) {
        timer.cancel();
        _handleTimeExpired();
      } else {
        _safeNotify();
      }
    });
  }

  /// Called when the countdown reaches zero before the player answers:
  /// counts as a miss (loses a life) and advances to the next question,
  /// exactly like a wrong answer.
  void _handleTimeExpired() {
    if (isGameOver || currentQuestion == null) return;
    _loseLife();
  }

  /// Shared "lose a life" path used by both a wrong answer and a timer
  /// expiry: ends the game if that was the last life, otherwise moves on.
  void _loseLife() {
    lives--;
    if (lives <= 0) {
      _endGame();
    } else {
      _nextQuestion();
    }
  }

  /// Stops the timer, marks the round over, and persists a new high
  /// score if this run beat it. Factored out so both the wrong-answer
  /// path and the timer-expiry path share identical game-over behavior.
  Future<void> _endGame() async {
    _questionTimer?.cancel(); // NEW: stop the timer once the game is over
    isGameOver = true;
    currentQuestion = null;
    if (score > highScore) {
      highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, highScore);
    }
    _safeNotify();
  }
  // ------------------------------------------------------------------

  MathQuestion _generateQuestion(int id, int tier) {
    // Comparison statements ("a op b > c op d") get more common as the
    // tier rises; simple single-equation statements ("a op b = c") are
    // the baseline, easier question.
    final comparisonChance = min(0.15 + tier * 0.08, 0.55);
    final isComparison = _random.nextDouble() < comparisonChance;

    if (isComparison) {
      final leftValue = _randomTerm(tier);
      final rightValue = _randomTerm(tier);
      // Shown comparator is picked at random; whether it happens to
      // match the actual relationship between the two sides is exactly
      // what the player has to work out.
      const comparators = ['>', '<', '='];
      final shownComparator = comparators[_random.nextInt(comparators.length)];

      final actual = leftValue.value.compareTo(rightValue.value);
      final isTrue = switch (shownComparator) {
        '>' => actual > 0,
        '<' => actual < 0,
        _ => actual == 0,
      };

      return MathQuestion(
        id: id,
        expression:
            '${leftValue.expression} $shownComparator ${rightValue.expression}',
        isTrue: isTrue,
      );
    }

    // Simple "a op b = shown" statement.
    final term = _randomTerm(tier);
    final showTrue = _random.nextBool();
    var shown = term.value;
    if (!showTrue) {
      var delta = 0;
      while (delta == 0) {
        delta = 1 + _random.nextInt(5 + tier * 2);
        if (_random.nextBool()) delta = -delta;
      }
      shown = term.value + delta;
    }

    return MathQuestion(
      id: id,
      expression: '${term.expression} = $shown',
      isTrue: shown == term.value,
    );
  }

  /// Generates one random "a op b" term (addition, subtraction, or
  /// multiplication) whose number range grows with [tier].
  _Term _randomTerm(int tier) {
    const ops = ['+', '-', '\u00d7'];
    final op = ops[_random.nextInt(ops.length)];
    final range = 10 + tier * 8;
    int a, b, value;

    switch (op) {
      case '+':
        a = 1 + _random.nextInt(range);
        b = 1 + _random.nextInt(range);
        value = a + b;
        break;
      case '-':
        a = 5 + _random.nextInt(range);
        b = 1 + _random.nextInt(a); // keeps the result non-negative
        value = a - b;
        break;
      default: // ×
        final factorMax = 4 + tier;
        a = 1 + _random.nextInt(factorMax);
        b = 1 + _random.nextInt(factorMax);
        value = a * b;
    }

    return _Term(expression: '$a $op $b', value: value);
  }

  /// Called when the player answers. [answeredTrue] is what they tapped;
  /// a correct answer advances the score and the round. A wrong answer
  /// costs a life (see [_loseLife]) — the game only ends, persisting a
  /// new high score if this run beat it, once lives reach 0.
  Future<void> answer(bool answeredTrue) async {
    if (isGameOver || currentQuestion == null) return;
    _questionTimer?.cancel(); // NEW: stop the timer now that an answer came in

    final correct = answeredTrue == currentQuestion!.isTrue;
    if (correct) {
      score++;
      _nextQuestion();
    } else {
      // CHANGED: a wrong answer now costs a life instead of ending the
      // game outright; _loseLife() ends the game only once lives hit 0.
      _loseLife();
    }
  }
}

class _Term {
  final String expression;
  final int value;
  const _Term({required this.expression, required this.value});
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'ludo_ai.dart';
import 'ludo_models.dart';

/// Drives one match of Ludo for [playerCount] players (2-4), optionally
/// with the last seat played by [LudoAi] (single-player "vs AI" mode).
///
/// Turn flow: roll the die, see which tokens can legally move, the
/// player (or the AI) picks one, it moves — capturing an opponent token
/// on a non-safe cell sends it back to the yard. Rolling a 6 or landing
/// a capture earns another roll for the same player; otherwise the turn
/// passes to the next seat. First player to get all 4 tokens home wins.
class LudoController extends ChangeNotifier {
  final int playerCount;
  final bool vsAI;

  late List<LudoColor> colors;
  late List<List<LudoToken>> tokensByPlayer;

  int currentPlayer = 0;
  int? diceValue;
  bool hasRolledThisTurn = false;
  List<int> movableTokenIndices = [];
  int? winnerPlayerIndex;
  bool isAiThinking = false;

  final Random _random = Random();
  final LudoAi _ai = LudoAi();
  bool _disposed = false;

  /// [playerCount] must be 2-4. In `vsAI` mode the last seat (index
  /// `playerCount - 1`) is always the computer.
  LudoController({required this.playerCount, this.vsAI = false})
      : assert(playerCount >= 2 && playerCount <= 4);

  int get aiPlayerIndex => playerCount - 1;
  bool get isAiTurn => vsAI && currentPlayer == aiPlayerIndex;

  void start() {
    // Standard 4-color seating order: Red, Green, Yellow, Blue — the
    // first [playerCount] of those play this match.
    colors = LudoColor.values.take(playerCount).toList();
    tokensByPlayer = List.generate(
      playerCount,
      (p) => List.generate(4, (i) => LudoToken(index: i)),
    );
    currentPlayer = 0;
    diceValue = null;
    hasRolledThisTurn = false;
    movableTokenIndices = [];
    winnerPlayerIndex = null;
    isAiThinking = false;
    _safeNotify();

    if (isAiTurn) _scheduleAiTurn();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  /// Rolls the die for the current player and figures out which of
  /// their tokens (if any) have a legal move.
  void rollDice() {
    if (winnerPlayerIndex != null || hasRolledThisTurn) return;
    if (vsAI && currentPlayer == aiPlayerIndex) return; // AI rolls itself

    diceValue = 1 + _random.nextInt(6);
    hasRolledThisTurn = true;
    movableTokenIndices = _computeMovableTokens(currentPlayer, diceValue!);
    _safeNotify();

    if (movableTokenIndices.isEmpty) {
      _passTurnSoon();
    }
  }

  List<int> _computeMovableTokens(int player, int roll) {
    final tokens = tokensByPlayer[player];
    final result = <int>[];
    for (var i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (t.isFinished) continue;
      if (t.isInYard) {
        if (roll == 6) result.add(i);
      } else {
        if (t.progress + roll <= LudoToken.finishProgress) result.add(i);
      }
    }
    return result;
  }

  /// Called when the player taps one of their movable tokens (index
  /// 0..3). Ignored for indices that aren't currently movable.
  void moveToken(int tokenIndex) {
    if (winnerPlayerIndex != null) return;
    if (!hasRolledThisTurn || diceValue == null) return;
    if (!movableTokenIndices.contains(tokenIndex)) return;

    final token = tokensByPlayer[currentPlayer][tokenIndex];
    final roll = diceValue!;
    final capturedSomeone = _applyMove(currentPlayer, token, roll);

    if (_hasWon(currentPlayer)) {
      winnerPlayerIndex = currentPlayer;
      _safeNotify();
      return;
    }

    final bonusTurn = roll == 6 || capturedSomeone;
    diceValue = null;
    hasRolledThisTurn = false;
    movableTokenIndices = [];

    if (!bonusTurn) {
      currentPlayer = (currentPlayer + 1) % playerCount;
    }
    _safeNotify();

    if (isAiTurn) _scheduleAiTurn();
  }

  bool _applyMove(int player, LudoToken token, int roll) {
    if (token.isInYard) {
      token.progress = 0;
    } else {
      token.progress += roll;
    }

    if (token.progress > 50) return false; // in home stretch, no captures

    final color = colors[player];
    final absCell = (color.entryIndex + token.progress) % LudoBoard.ringLength;
    if (LudoBoard.safeCells.contains(absCell)) return false;

    var captured = false;
    for (var p = 0; p < playerCount; p++) {
      if (p == player) continue;
      for (final other in tokensByPlayer[p]) {
        if (other.isInYard || other.progress > 50) continue;
        final otherAbsCell = (colors[p].entryIndex + other.progress) % LudoBoard.ringLength;
        if (otherAbsCell == absCell) {
          other.progress = -1;
          captured = true;
        }
      }
    }
    return captured;
  }

  bool _hasWon(int player) => tokensByPlayer[player].every((t) => t.isFinished);

  void _passTurnSoon() {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (_disposed || winnerPlayerIndex != null) return;
      diceValue = null;
      hasRolledThisTurn = false;
      movableTokenIndices = [];
      currentPlayer = (currentPlayer + 1) % playerCount;
      _safeNotify();
      if (isAiTurn) _scheduleAiTurn();
    });
  }

  void _scheduleAiTurn() {
    isAiThinking = true;
    _safeNotify();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (_disposed || winnerPlayerIndex != null) return;
      diceValue = 1 + _random.nextInt(6);
      hasRolledThisTurn = true;
      movableTokenIndices = _computeMovableTokens(currentPlayer, diceValue!);
      _safeNotify();

      if (movableTokenIndices.isEmpty) {
        isAiThinking = false;
        _passTurnSoon();
        return;
      }

      Future.delayed(const Duration(milliseconds: 700), () {
        if (_disposed || winnerPlayerIndex != null) return;
        isAiThinking = false;
        final choice = _ai.chooseMove(
          aiTokens: tokensByPlayer[currentPlayer],
          movableIndices: movableTokenIndices,
          roll: diceValue!,
          aiColor: colors[currentPlayer],
          allTokensByPlayer: tokensByPlayer,
          colorsInOrder: colors,
        );
        moveToken(choice);
      });
    });
  }

  /// Number of this player's tokens that have reached home — handy for
  /// a simple progress readout in the UI.
  int finishedCount(int player) =>
      tokensByPlayer[player].where((t) => t.isFinished).length;
}

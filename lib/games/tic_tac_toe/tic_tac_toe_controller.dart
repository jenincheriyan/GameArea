import 'dart:async';
import 'package:flutter/foundation.dart';
import 'tic_tac_toe_ai.dart';

/// Drives one match of Tic-Tac-Toe. The same controller backs both game
/// modes described in the spec:
///  * Single player — player is always 'X' (player 1), the AI is always
///    'O' (player 2) and moves via [TicTacToeAi] on [difficulty].
///  * Local two player — both cells are driven by taps, turns just
///    alternate between player 1 ('X') and player 2 ('O').
///
/// Plain Dart (a [ChangeNotifier]), same shape as every other controller
/// in the project.
class TicTacToeController extends ChangeNotifier {
  static const String humanSymbol = 'X'; // player 1
  static const String aiSymbol = 'O'; // player 2 in single-player mode

  late List<String?> board;
  int currentPlayer = 1; // 1 = 'X', 2 = 'O'
  bool vsAI = false;
  AiDifficulty difficulty = AiDifficulty.hard;

  int? winner; // 1 or 2, once the match is decided
  bool isDraw = false;
  bool aiThinking = false;

  TicTacToeAi? _ai;
  Timer? _aiTimer;
  bool _disposed = false;

  void start({required bool vsAI, AiDifficulty difficulty = AiDifficulty.hard}) {
    this.vsAI = vsAI;
    this.difficulty = difficulty;
    _ai = vsAI ? TicTacToeAi(aiSymbol: aiSymbol, humanSymbol: humanSymbol) : null;

    board = List<String?>.filled(9, null);
    currentPlayer = 1;
    winner = null;
    isDraw = false;
    aiThinking = false;
    _aiTimer?.cancel();
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    _aiTimer?.cancel();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  String _symbolFor(int player) => player == 1 ? humanSymbol : aiSymbol;

  /// Called when a board cell is tapped. Ignored if the match is over,
  /// the cell is occupied, or (in single-player mode) it isn't the
  /// human's turn.
  void tapCell(int index) {
    if (winner != null || isDraw) return;
    if (board[index] != null) return;
    if (vsAI && currentPlayer != 1) return; // AI's turn — ignore taps

    _placeMark(index);
  }

  void _placeMark(int index) {
    board[index] = _symbolFor(currentPlayer);
    _safeNotify();

    if (_checkForGameEnd()) return;

    currentPlayer = currentPlayer == 1 ? 2 : 1;
    _safeNotify();

    if (vsAI && currentPlayer == 2) {
      _scheduleAiMove();
    }
  }

  /// Returns true if the match just ended (win or draw), having already
  /// updated [winner]/[isDraw] and notified listeners.
  bool _checkForGameEnd() {
    final winningSymbol = ticTacToeWinnerSymbol(board);
    if (winningSymbol != null) {
      winner = winningSymbol == humanSymbol ? 1 : 2;
      _safeNotify();
      return true;
    }
    if (ticTacToeIsBoardFull(board)) {
      isDraw = true;
      _safeNotify();
      return true;
    }
    return false;
  }

  void _scheduleAiMove() {
    aiThinking = true;
    _safeNotify();

    _aiTimer?.cancel();
    _aiTimer = Timer(const Duration(milliseconds: 500), () {
      if (_disposed || winner != null || isDraw) return;
      final move = _ai!.chooseMove(board, difficulty);
      aiThinking = false;
      _placeMark(move);
    });
  }
}

import 'dart:math';

/// The two difficulty levels offered in single-player mode.
enum AiDifficulty { easy, hard }

/// All 8 winning lines on a 3x3 board, expressed as cell indices
/// (0..8, row-major: 0 1 2 / 3 4 5 / 6 7 8).
const List<List<int>> ticTacToeWinLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6], // diagonals
];

/// Returns the symbol ('X' or 'O') that has won on [board], or null if
/// there is no winner yet.
String? ticTacToeWinnerSymbol(List<String?> board) {
  for (final line in ticTacToeWinLines) {
    final a = board[line[0]];
    final b = board[line[1]];
    final c = board[line[2]];
    if (a != null && a == b && b == c) return a;
  }
  return null;
}

bool ticTacToeIsBoardFull(List<String?> board) =>
    board.every((cell) => cell != null);

/// Stateless Tic-Tac-Toe AI. [aiSymbol] is the mark the AI plays as,
/// [humanSymbol] is the opponent's mark.
class TicTacToeAi {
  final Random _random = Random();
  final String aiSymbol;
  final String humanSymbol;

  TicTacToeAi({required this.aiSymbol, required this.humanSymbol});

  /// Picks the AI's next move (a cell index) given the current [board].
  ///
  ///  * [AiDifficulty.hard] always plays the game-theoretically optimal
  ///    move via minimax, so it can never be beaten (at best, drawn).
  ///  * [AiDifficulty.easy] plays a random legal move most of the time,
  ///    only falling back to the optimal move part of the time — good
  ///    enough to be beatable while still occasionally punishing mistakes.
  int chooseMove(List<String?> board, AiDifficulty difficulty) {
    final emptyCells = [
      for (var i = 0; i < board.length; i++)
        if (board[i] == null) i,
    ];
    assert(emptyCells.isNotEmpty, 'chooseMove called on a full board');

    if (difficulty == AiDifficulty.easy && _random.nextDouble() < 0.65) {
      return emptyCells[_random.nextInt(emptyCells.length)];
    }

    return _bestMove(board);
  }

  int _bestMove(List<String?> board) {
    var bestScore = -1 << 30;
    var bestMove = -1;

    for (var i = 0; i < board.length; i++) {
      if (board[i] != null) continue;
      board[i] = aiSymbol;
      final score = _minimax(board, depth: 1, isMaximizing: false);
      board[i] = null;
      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
    return bestMove;
  }

  /// Standard minimax over the full (tiny, 9-cell) game tree. Scores are
  /// biased by [depth] so the AI prefers to win sooner and delay losing
  /// as long as possible.
  int _minimax(List<String?> board, {required int depth, required bool isMaximizing}) {
    final winner = ticTacToeWinnerSymbol(board);
    if (winner == aiSymbol) return 10 - depth;
    if (winner == humanSymbol) return depth - 10;
    if (ticTacToeIsBoardFull(board)) return 0;

    if (isMaximizing) {
      var best = -1 << 30;
      for (var i = 0; i < board.length; i++) {
        if (board[i] != null) continue;
        board[i] = aiSymbol;
        best = max(best, _minimax(board, depth: depth + 1, isMaximizing: false));
        board[i] = null;
      }
      return best;
    } else {
      var best = 1 << 30;
      for (var i = 0; i < board.length; i++) {
        if (board[i] != null) continue;
        board[i] = humanSymbol;
        best = min(best, _minimax(board, depth: depth + 1, isMaximizing: true));
        board[i] = null;
      }
      return best;
    }
  }
}

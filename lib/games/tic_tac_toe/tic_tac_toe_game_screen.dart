import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'tic_tac_toe_ai.dart';
import 'tic_tac_toe_controller.dart';
import 'widgets/board_grid.dart';
import 'widgets/difficulty_picker.dart';

/// [vsAI] selects single-player (with a difficulty picker shown first)
/// vs. local two-player (starts immediately, turns just alternate).
class TicTacToeGameScreen extends StatefulWidget {
  final bool vsAI;

  const TicTacToeGameScreen({super.key, required this.vsAI});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  late final TicTacToeController _controller;
  bool _navigatedToWinner = false;
  bool _started = false; // gates on the difficulty picker in single-player

  @override
  void initState() {
    super.initState();
    _controller = TicTacToeController()..addListener(_onGameStateChanged);
    if (!widget.vsAI) {
      _started = true;
      _controller.start(vsAI: false);
    }
  }

  void _startSinglePlayer(AiDifficulty difficulty) {
    setState(() => _started = true);
    _controller.start(vsAI: true, difficulty: difficulty);
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.winner != null && !_navigatedToWinner) {
      _navigatedToWinner = true;
      _goToWinnerScreen();
    }
  }

  void _goToWinnerScreen() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final winner = _controller.winner!;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WinnerScreen(
            winner: winner,
            // Tic-Tac-Toe doesn't have an accumulating score like the
            // duel games — a 1/0 split simply flags who took this match,
            // so WinnerScreen's score chips still read sensibly.
            player1Score: winner == 1 ? 1 : 0,
            player2Score: winner == 2 ? 1 : 0,
            playAgainBuilder: (_) => TicTacToeGameScreen(vsAI: widget.vsAI),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: !_started
              ? DifficultyPicker(onSelected: _startSinglePlayer)
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          _TurnIndicator(controller: _controller, vsAI: widget.vsAI),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              BoardGrid(
                                board: _controller.board,
                                onCellTap: _controller.tapCell,
                                enabled: _controller.winner == null &&
                                    !_controller.isDraw &&
                                    !_controller.aiThinking,
                              ),
                              if (_controller.isDraw) _DrawOverlay(controller: _controller),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _TurnIndicator extends StatelessWidget {
  final TicTacToeController controller;
  final bool vsAI;

  const _TurnIndicator({required this.controller, required this.vsAI});

  @override
  Widget build(BuildContext context) {
    if (controller.winner != null || controller.isDraw) {
      return const SizedBox(height: 24);
    }
    final label = controller.aiThinking
        ? 'AI IS THINKING…'
        : vsAI
            ? (controller.currentPlayer == 1 ? 'YOUR TURN (X)' : "AI'S TURN (O)")
            : (controller.currentPlayer == 1 ? 'PLAYER 1 (X)' : 'PLAYER 2 (O)');
    final color = controller.currentPlayer == 1
        ? const Color(0xFF4EA8DE)
        : const Color(0xFFFF5E5E);
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

/// Shown in place of a WinnerScreen navigation when the match ends in a
/// draw — there's no winner to hand to WinnerScreen, so this stays as a
/// simple in-board overlay, matching the game-over overlay style used by
/// Snake and the Math Game.
class _DrawOverlay extends StatelessWidget {
  final TicTacToeController controller;
  const _DrawOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.78),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "IT'S A DRAW",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.start(
                  vsAI: controller.vsAI,
                  difficulty: controller.difficulty,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EE7A0),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'BACK TO HOME',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

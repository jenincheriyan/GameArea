import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'ludo_controller.dart';
import 'ludo_models.dart';
import 'widgets/dice_view.dart';
import 'widgets/ludo_board.dart';

/// Human (Red) vs AI (Green) — always exactly 2 seats, so this reuses
/// WinnerScreen for the result the same way single-player Tic-Tac-Toe
/// does.
class LudoGameScreen extends StatefulWidget {
  const LudoGameScreen({super.key});

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen> {
  late final LudoController _controller;
  bool _navigatedToWinner = false;

  @override
  void initState() {
    super.initState();
    _controller = LudoController(playerCount: 2, vsAI: true)
      ..addListener(_onGameStateChanged);
    _controller.start();
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.winnerPlayerIndex != null && !_navigatedToWinner) {
      _navigatedToWinner = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        final winnerIndex = _controller.winnerPlayerIndex!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WinnerScreen(
              winner: winnerIndex == 0 ? 1 : 2,
              player1Score: _controller.finishedCount(0),
              player2Score: _controller.finishedCount(1),
              player1Label: 'You',
              player2Label: 'AI',
              playAgainBuilder: (_) => const LudoGameScreen(),
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final youColor = _controller.colors[0];
    final aiColor = _controller.colors[1];
    final isYourTurn = _controller.currentPlayer == 0;

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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    _controller.isAiThinking
                        ? 'AI IS THINKING…'
                        : isYourTurn
                            ? 'YOUR TURN'
                            : "AI'S TURN",
                    style: TextStyle(
                      color: isYourTurn ? youColor.color : aiColor.color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PlayerChip(label: 'You (${youColor.label})', color: youColor.color, finished: _controller.finishedCount(0)),
                    _PlayerChip(label: 'AI (${aiColor.label})', color: aiColor.color, finished: _controller.finishedCount(1)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LudoBoardView(
                    colors: _controller.colors,
                    tokensByPlayer: _controller.tokensByPlayer,
                    movableTokenIndices: isYourTurn ? _controller.movableTokenIndices : const [],
                    currentPlayer: _controller.currentPlayer,
                    onTapToken: _controller.moveToken,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: DiceView(
                  value: _controller.diceValue,
                  accentColor: youColor.color,
                  onTap: isYourTurn && !_controller.hasRolledThisTurn ? _controller.rollDice : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String label;
  final Color color;
  final int finished;

  const _PlayerChip({required this.label, required this.color, required this.finished});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text('$label · $finished/4', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

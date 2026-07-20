import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'snake_multiplayer_controller.dart';
import 'widgets/dual_snake_board.dart';
import 'widgets/player_dpad.dart';

class SnakeMultiplayerGameScreen extends StatefulWidget {
  const SnakeMultiplayerGameScreen({super.key});

  @override
  State<SnakeMultiplayerGameScreen> createState() =>
      _SnakeMultiplayerGameScreenState();
}

class _SnakeMultiplayerGameScreenState
    extends State<SnakeMultiplayerGameScreen> {
  late final SnakeMultiplayerController _controller;
  bool _navigatedToWinner = false;

  static const _p1Color = Color(0xFF4EA8DE);
  static const _p2Color = Color(0xFFFF5E5E);

  @override
  void initState() {
    super.initState();
    _controller = SnakeMultiplayerController()
      ..addListener(_onGameStateChanged);
    _controller.start();
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
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WinnerScreen(
            winner: _controller.winner!,
            player1Score: _controller.player1Score,
            player2Score: _controller.player2Score,
            playAgainBuilder: (_) => const SnakeMultiplayerGameScreen(),
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
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(Icons.close, color: Colors.white70, size: 20),
                    ),
                  ),
                  _ScorePill(
                    label: 'P1',
                    score: _controller.player1Score,
                    color: _p1Color,
                    dead: _controller.snake1Dead,
                  ),
                  Text(
                    'FIRST TO ${SnakeMultiplayerController.targetScore}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  _ScorePill(
                    label: 'P2',
                    score: _controller.player2Score,
                    color: _p2Color,
                    dead: _controller.snake2Dead,
                  ),
                  const SizedBox(width: 40), // balances the exit button
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Transform.rotate(
                  angle: math.pi,
                  child: PlayerDPad(
                    color: _p1Color,
                    onDirection: _controller.changeDirection1,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CustomPaint(
                            painter: DualSnakeBoardPainter(
                              snake1: _controller.snake1,
                              snake2: _controller.snake2,
                              snake1Dead: _controller.snake1Dead,
                              snake2Dead: _controller.snake2Dead,
                              foods: _controller.foods,
                              gridSize: SnakeMultiplayerController.gridSize,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: PlayerDPad(
                  color: _p2Color,
                  onDirection: _controller.changeDirection2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool dead;

  const _ScorePill({
    required this.label,
    required this.score,
    required this.color,
    required this.dead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: dead ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: TextStyle(
              color: dead ? color.withOpacity(0.35) : color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (dead) ...[
          const SizedBox(width: 4),
          const Icon(Icons.close, color: Colors.white38, size: 14),
        ],
      ],
    );
  }
}

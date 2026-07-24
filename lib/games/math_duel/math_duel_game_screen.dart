import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/winner_screen.dart';
import 'math_duel_controller.dart';
import 'widgets/player_half.dart';

class MathDuelGameScreen extends StatefulWidget {
  const MathDuelGameScreen({super.key});

  @override
  State<MathDuelGameScreen> createState() => _MathDuelGameScreenState();
}

class _MathDuelGameScreenState extends State<MathDuelGameScreen> {
  late final MathDuelController _controller;
  bool _navigatedToWinner = false;

  @override
  void initState() {
    super.initState();
    // Face-off layout: the phone lies flat on a table between the two
    // players, so this screen stays in portrait rather than landscape.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller = MathDuelController()..addListener(_onGameStateChanged);
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WinnerScreen(
            winner: _controller.winner!,
            player1Score: _controller.player1Score,
            player2Score: _controller.player2Score,
            playAgainBuilder: (_) => const MathDuelGameScreen(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA870AC), Color(0xFF7C4C82)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top player's half — rotated 180° so their copy of the
              // equation, and their avatar/score corner, both read
              // correctly from someone facing the phone from this end.
              Expanded(
                child: Transform.rotate(
                  angle: math.pi,
                  child: PlayerHalf(
                    score: _controller.player1Score,
                    color: const Color(0xFF4EA8DE),
                    equation: _controller.currentEquation,
                    onTap: () => _controller.answer(1),
                  ),
                ),
              ),
              _CenterDivider(onTapExit: () => Navigator.of(context).pop()),
              // Bottom player's half — normal orientation.
              Expanded(
                child: PlayerHalf(
                  score: _controller.player2Score,
                  color: const Color(0xFFFF5E5E),
                  equation: _controller.currentEquation,
                  onTap: () => _controller.answer(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The neutral strip between the two halves: two faint horizontal lines
/// with a small circular exit button in between, matching the reference
/// design's "no-man's-land" divider.
class _CenterDivider extends StatelessWidget {
  final VoidCallback onTapExit;
  const _CenterDivider({required this.onTapExit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            child: Container(
              width: 150,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: 150,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTapExit,
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
        ],
      ),
    );
  }
}

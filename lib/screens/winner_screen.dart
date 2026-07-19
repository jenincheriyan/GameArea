import 'package:flutter/material.dart';
import 'home_screen.dart';

class WinnerScreen extends StatelessWidget {
  final int winner;
  final int player1Score;
  final int player2Score;
  final WidgetBuilder playAgainBuilder;
  final String player1Label;
  final String player2Label;

  const WinnerScreen({
    super.key,
    required this.winner,
    required this.player1Score,
    required this.player2Score,
    required this.playAgainBuilder,
    this.player1Label = 'Player 1',
    this.player2Label = 'Player 2',
  });

  @override
  Widget build(BuildContext context) {
    final color =
        winner == 2 ? const Color(0xFFFF5E5E) : const Color(0xFF4EA8DE);
    final winnerLabel = winner == 2 ? player2Label : player1Label;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), const Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text(
                  '${winnerLabel.toUpperCase()} WINS!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ScoreChip(
                      label: player1Label,
                      score: player1Score,
                      highlighted: winner == 1,
                    ),
                    const SizedBox(width: 24),
                    _ScoreChip(
                      label: player2Label,
                      score: player2Score,
                      highlighted: winner == 2,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: playAgainBuilder),
                );
              },
              child: const Text('PLAY AGAIN',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'BACK TO HOME',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
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

class _ScoreChip extends StatelessWidget {
  final String label;
  final int score;
  final bool highlighted;

  const _ScoreChip({
    required this.label,
    required this.score,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(highlighted ? 0.25 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: highlighted ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

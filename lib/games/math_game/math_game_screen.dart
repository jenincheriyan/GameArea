import 'package:flutter/material.dart';
import 'math_game_controller.dart';
import 'widgets/question_card.dart';
import 'widgets/true_false_buttons.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  late final MathGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MathGameController()..addListener(_onGameStateChanged);
    _controller.init();
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() {});
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
            colors: [Color(0xFFA870AC), Color(0xFF7C4C82)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: !_controller.isReady
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white70),
                )
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
                          Row(
                            children: [
                              _StatChip(label: 'SCORE', value: _controller.score),
                              const SizedBox(width: 12),
                              _StatChip(
                                label: 'BEST',
                                value: _controller.highScore,
                                color: const Color(0xFFFFD166),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // NEW: lives indicator, shown as a row of heart icons
                      // between the top stat row and the question card.
                      if (!_controller.isGameOver) ...[
                        const SizedBox(height: 14),
                        _LivesIndicator(
                          lives: _controller.lives,
                          maxLives: MathGameController.maxLives,
                        ),
                      ],
                      Expanded(
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // NEW: question countdown timer, shown
                                  // just above the question card.
                                  if (!_controller.isGameOver) ...[
                                    _QuestionTimer(
                                      secondsRemaining: _controller.secondsRemaining,
                                      totalSeconds: MathGameController.questionSeconds,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  QuestionCard(question: _controller.currentQuestion),
                                  const SizedBox(height: 32),
                                  TrueFalseButtons(
                                    enabled: !_controller.isGameOver,
                                    onAnswer: _controller.answer,
                                  ),
                                ],
                              ),
                            ),
                            if (_controller.isGameOver)
                              _GameOverOverlay(
                                score: _controller.score,
                                highScore: _controller.highScore,
                                onRestart: _controller.restart,
                              ),
                          ],
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

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// NEW: Row of heart icons showing remaining lives out of the max.
class _LivesIndicator extends StatelessWidget {
  final int lives;
  final int maxLives;

  const _LivesIndicator({required this.lives, required this.maxLives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLives, (index) {
        final filled = index < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: filled ? const Color(0xFFFF5E5E) : Colors.white38,
            size: 22,
          ),
        );
      }),
    );
  }
}

// NEW: Countdown display for the current question, backed by
// MathGameController.secondsRemaining. Purely presentational — all
// timer start/cancel/reset logic lives in the controller.
class _QuestionTimer extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;

  const _QuestionTimer({
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0
        ? 0.0
        : (secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    final isLow = secondsRemaining <= 3;
    final color = isLow ? const Color(0xFFFF5E5E) : const Color(0xFF6EE7A0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SizedBox(
        //   width: 160,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.circular(8),
        //     child: LinearProgressIndicator(
        //       value: progress,
        //       minHeight: 8,
        //       backgroundColor: Colors.white.withOpacity(0.12),
        //       valueColor: AlwaysStoppedAnimation<Color>(color),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 6),
        Text(
          '$secondsRemaining ',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;

  const _GameOverOverlay({
    required this.score,
    required this.highScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score >= highScore && score > 0;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.78),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              if (isNewHighScore) ...[
                const SizedBox(height: 4),
                const Text(
                  'New high score! 🎉',
                  style: TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRestart,
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

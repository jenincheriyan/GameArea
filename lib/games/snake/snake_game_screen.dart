import 'package:flutter/material.dart';
import 'snake_controller.dart';
import 'widgets/snake_board.dart';
import 'widgets/lcd_digits.dart';
import 'widgets/dpad_controls.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  late final SnakeController _controller;

  static const Color screenColor = Color(0xFFA3C000);
  static const Color headerColor = Color(0xFF16171A);

  @override
  void initState() {
    super.initState();
    _controller = SnakeController()..addListener(_onGameStateChanged);
    _controller.loadHiScore().then((_) => _controller.start());
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header — fixed at the top, always visible while playing.
            _Header(
              score: _controller.score,
              hiScore: _controller.hiScore,
            ),
            // 2. Game area — fills the remaining space in the middle.
            Expanded(
              child: Container(
                width: double.infinity,
                color: screenColor,
                // padding: const EdgeInsets.all(2),
                // child: Center(
                //   child: AspectRatio(
                //     aspectRatio: 1,
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: SnakeBoardPainter(
                            snake: _controller.snake,
                            food: _controller.food,
                            gridSize: SnakeController.gridSize,
                          ),
                          child: const SizedBox.expand(),
                        ),
                        if (_controller.isPaused && !_controller.isGameOver)
                          const _PausedOverlay(),
                        if (_controller.isGameOver)
                          _GameOverOverlay(
                            score: _controller.score,
                            onRestart: () => _controller.start(),
                          ),
                      ],
                    ),
                  // ),
                // ),
              ),
            ),
            // 3. Footer — fixed D-pad control cluster at the bottom.
            DpadControls(
              isPaused: _controller.isPaused,
              onDirection: _controller.changeDirection,
              onTogglePause: _controller.togglePause,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int score;
  final int hiScore;

  const _Header({required this.score, required this.hiScore});

  static const Color inkColor = _SnakeGameScreenState.screenColor;

  static const TextStyle _labelStyle = TextStyle(
    color: inkColor,
    fontSize: 14,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    fontFamily: 'monospace',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _SnakeGameScreenState.headerColor,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ReadoutColumn(label: 'SCORE', value: score),
          ),
          Expanded(
            child: _ReadoutColumn(label: 'HI-SCORE', value: hiScore),
          ),
        ],
      ),
    );
  }
}

class _ReadoutColumn extends StatelessWidget {
  final String label;
  final int value;

  const _ReadoutColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _Header._labelStyle),
        const SizedBox(height: 4),
        LcdDigits(
          value: value,
          digitWidth: 18,
          digitHeight: 28,
          gap: 3,
          color: _Header.inkColor,
        ),
      ],
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: const Center(
          child: Text(
            'PAUSED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;

  const _GameOverOverlay({required this.score, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.78),
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
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA3C000),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

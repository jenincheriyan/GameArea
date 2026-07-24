import 'package:flutter/material.dart';
import 'flappy_bird_controller.dart';
import 'widgets/flappy_board_painter.dart';

class FlappyBirdGameScreen extends StatefulWidget {
  const FlappyBirdGameScreen({super.key});

  @override
  State<FlappyBirdGameScreen> createState() => _FlappyBirdGameScreenState();
}

class _FlappyBirdGameScreenState extends State<FlappyBirdGameScreen> {
  late final FlappyBirdController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlappyBirdController()..addListener(_onGameStateChanged);
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
            colors: [Color(0xFF000000), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: !_controller.isReady
              ? const Center(child: CircularProgressIndicator(color: Colors.white70))
              : Column(
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
                            const SizedBox(width: 10),
                            _StatChip(
                              label: 'BEST',
                              value: _controller.highScore,
                              color: const Color(0xFFFFD166),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _controller.isGameOver ? null : _controller.flap,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.15),
                                    child: CustomPaint(
                                      painter: FlappyBoardPainter(
                                        pipes: _controller.pipes,
                                        birdY: _controller.birdY,
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
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
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Text(
                        'TAP ANYWHERE TO FLAP',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
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

  const _StatChip({required this.label, required this.value, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text('$value',
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;

  const _GameOverOverlay({required this.score, required this.highScore, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = score >= highScore && score > 0;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('GAME OVER',
                  style: TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Score: $score', style: const TextStyle(color: Colors.white70, fontSize: 18)),
              if (isNewHighScore) ...[
                const SizedBox(height: 4),
                const Text('New high score! 🎉',
                    style: TextStyle(color: Color(0xFFFFD166), fontSize: 15, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EE7A0),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('BACK TO HOME', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

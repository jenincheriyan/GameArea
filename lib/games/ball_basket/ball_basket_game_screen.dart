import 'package:flutter/material.dart';
import 'ball_basket_controller.dart';
import 'widgets/aim_line_painter.dart';
import 'widgets/hoop_and_ball.dart';

class BallBasketGameScreen extends StatefulWidget {
  const BallBasketGameScreen({super.key});

  @override
  State<BallBasketGameScreen> createState() => _BallBasketGameScreenState();
}

class _BallBasketGameScreenState extends State<BallBasketGameScreen> {
  late final BallBasketController _controller;
  Offset? _dragCurrent;
  Offset? _dragStart;

  @override
  void initState() {
    super.initState();
    _controller = BallBasketController()..addListener(_onGameStateChanged);
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
            colors: [Color(0xFFEE9CA7), Color(0xFFFFDDE1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: !_controller.isReady
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          ),
                          Row(
                            children: List.generate(
                              BallBasketController.startingLives,
                              (i) => Icon(
                                i < _controller.lives ? Icons.favorite : Icons.favorite_border,
                                color: const Color(0xFFE94057),
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _StatChip(label: 'SCORE', value: _controller.score),
                              const SizedBox(width: 8),
                              _StatChip(label: 'STREAK x${_streakMultiplier()}', value: _controller.streak),
                              const SizedBox(width: 8),
                              _StatChip(label: 'BEST', value: _controller.highScore, color: const Color(0xFFE94057)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final scaleX = constraints.maxWidth / BallBasketController.boardWidth;
                                final scaleY = constraints.maxHeight / BallBasketController.boardHeight;
                                final ballScreen = Offset(
                                  _controller.ballX * scaleX,
                                  _controller.ballY * scaleY,
                                );

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: _controller.isFlying || _controller.isGameOver
                                      ? null
                                      : (details) {
                                          _dragStart = details.localPosition;
                                          _dragCurrent = details.localPosition;
                                          setState(() {});
                                        },
                                  onPanUpdate: (details) {
                                    if (_dragStart == null) return;
                                    setState(() => _dragCurrent = details.localPosition);
                                  },
                                  onPanEnd: (details) {
                                    if (_dragStart == null || _dragCurrent == null) return;
                                    final dragVector = _dragCurrent! - _dragStart!;
                                    _controller.launch(
                                      Offset(dragVector.dx / scaleX, dragVector.dy / scaleY),
                                    );
                                    setState(() {
                                      _dragStart = null;
                                      _dragCurrent = null;
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      BasketWidget(
                                        centerX: _controller.basketX * scaleX,
                                        centerY: BallBasketController.basketY * scaleY,
                                      ),
                                      BallWidget(
                                        centerX: _controller.ballX * scaleX,
                                        centerY: _controller.ballY * scaleY,
                                        radius: BallBasketController.ballRadius * scaleX,
                                      ),
                                      if (_dragStart != null && _dragCurrent != null)
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: AimLinePainter(
                                              from: ballScreen,
                                              to: _dragCurrent!,
                                              color: const Color(0xFFE94057),
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
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Drag away from the ball, then release to throw',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  int _streakMultiplier() {
    if (_controller.streak <= 0) return 1;
    return _controller.streak > 5 ? 5 : _controller.streak;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({required this.label, required this.value, this.color = Colors.black87});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text('$value', style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
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
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('GAME OVER',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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

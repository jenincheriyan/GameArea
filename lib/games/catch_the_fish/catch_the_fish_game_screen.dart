import 'package:flutter/material.dart';
import 'catch_the_fish_controller.dart';
import 'widgets/item_view.dart';

class CatchTheFishGameScreen extends StatefulWidget {
  const CatchTheFishGameScreen({super.key});

  @override
  State<CatchTheFishGameScreen> createState() => _CatchTheFishGameScreenState();
}

class _CatchTheFishGameScreenState extends State<CatchTheFishGameScreen> {
  late final CatchTheFishController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CatchTheFishController()..addListener(_onGameStateChanged);
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
            colors: [Color(0xFF03396C), Color(0xFF005B96), Color(0xFF6497B1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: !_controller.isReady
              ? const Center(child: CircularProgressIndicator(color: Colors.white70))
              : Padding(
                  padding: const EdgeInsets.all(16),
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
                            children: List.generate(
                              CatchTheFishController.startingLives,
                              (i) => Icon(
                                i < _controller.lives ? Icons.favorite : Icons.favorite_border,
                                color: const Color(0xFFFF5E5E),
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _StatChip(label: 'SCORE', value: _controller.score),
                              const SizedBox(width: 8),
                              _StatChip(
                                label: 'BEST',
                                value: _controller.highScore,
                                color: const Color(0xFFFFD166),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final scaleX =
                                    constraints.maxWidth / CatchTheFishController.boardWidth;
                                final scaleY =
                                    constraints.maxHeight / CatchTheFishController.boardHeight;
                                final item = _controller.currentItem;
                                return Stack(
                                  children: [
                                    if (item != null)
                                      ItemView(
                                        item: item,
                                        left: item.x * scaleX,
                                        top: item.y * scaleY,
                                        onTap: () => _controller.tapItem(item.id),
                                      ),
                                    if (_controller.isGameOver)
                                      _GameOverOverlay(
                                        score: _controller.score,
                                        highScore: _controller.highScore,
                                        onRestart: _controller.restart,
                                      ),
                                  ],
                                );
                              },
                            ),
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

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({required this.label, required this.value, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
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

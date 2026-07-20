import 'package:flutter/material.dart';
import 'car_race_controller.dart';
import 'widgets/road_view.dart';

class CarRaceGameScreen extends StatefulWidget {
  const CarRaceGameScreen({super.key});

  @override
  State<CarRaceGameScreen> createState() => _CarRaceGameScreenState();
}

class _CarRaceGameScreenState extends State<CarRaceGameScreen> {
  late final CarRaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarRaceController()..addListener(_onGameStateChanged);
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
            colors: [Color(0xFF232526), Color(0xFF414345)],
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
                            const SizedBox(width: 8),
                            _StatChip(label: 'COINS', value: _controller.coins, color: const Color(0xFFFFD166)),
                            const SizedBox(width: 8),
                            _StatChip(label: 'BEST', value: _controller.highScore, color: const Color(0xFF6EE7A0)),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final scaleX = constraints.maxWidth / CarRaceController.boardWidth;
                                final scaleY = constraints.maxHeight / CarRaceController.boardHeight;
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: RoadPainter(
                                          items: _controller.items,
                                          boardWidth: CarRaceController.boardWidth,
                                          boardHeight: CarRaceController.boardHeight,
                                          laneCount: CarRaceController.laneCount,
                                        ),
                                      ),
                                    ),
                                    PlayerCarWidget(
                                      carX: _controller.carX,
                                      carY: CarRaceController.carY,
                                      width: CarRaceController.carWidth,
                                      height: CarRaceController.carHeight,
                                      scaleX: scaleX,
                                      scaleY: scaleY,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _LaneButton(icon: Icons.arrow_back_ios, onTap: _controller.moveLeft),
                          _LaneButton(icon: Icons.arrow_forward_ios, onTap: _controller.moveRight),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LaneButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _LaneButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
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
              const Text('CRASHED!',
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

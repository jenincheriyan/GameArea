import 'package:flutter/material.dart';
import 'snake_controller.dart';
import 'widgets/snake_board.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  late final SnakeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SnakeController()..addListener(_onGameStateChanged);
    _controller.start();
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

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() < 60 && velocity.dy.abs() < 60) return; // too slow/small to count
    if (velocity.dx.abs() > velocity.dy.abs()) {
      _controller.changeDirection(
        velocity.dx > 0 ? Direction.right : Direction.left,
      );
    } else {
      _controller.changeDirection(
        velocity.dy > 0 ? Direction.down : Direction.up,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'HIGH SCORE: ${_controller.highScore}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'SCORE: ${_controller.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48), // balances the back button
                ],
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onPanEnd: _handleSwipe,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CustomPaint(
                                  painter: SnakeBoardPainter(
                                    snake: _controller.snake,
                                    food: _controller.food,
                                    gridSize: SnakeController.gridSize,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          ),
                          if (_controller.isGameOver)
                            _GameOverOverlay(
                              score: _controller.score,
                              onRestart: () => _controller.start(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _DPad(onDirection: _controller.changeDirection),
              const SizedBox(height: 20),
            ],
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EE7A0),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

/// On-screen directional pad, an alternative to swiping for precise
/// single-tap turns.
class _DPad extends StatelessWidget {
  final ValueChanged<Direction> onDirection;
  const _DPad({required this.onDirection});

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, Direction dir) {
      return _DPadButton(icon: icon, onTap: () => onDirection(dir));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.keyboard_arrow_up, Direction.up),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(Icons.keyboard_arrow_left, Direction.left),
            const SizedBox(width: 56),
            button(Icons.keyboard_arrow_right, Direction.right),
          ],
        ),
        const SizedBox(height: 8),
        button(Icons.keyboard_arrow_down, Direction.down),
      ],
    );
  }
}

class _DPadButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DPadButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

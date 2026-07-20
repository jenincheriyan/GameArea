import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'car_race_controller.dart' show RoadItem;
import 'car_race_duel_controller.dart';
import 'widgets/road_view.dart';

class CarRaceDuelScreen extends StatefulWidget {
  const CarRaceDuelScreen({super.key});

  @override
  State<CarRaceDuelScreen> createState() => _CarRaceDuelScreenState();
}

class _CarRaceDuelScreenState extends State<CarRaceDuelScreen> {
  late final CarRaceDuelController _controller;
  bool _navigatedToWinner = false;

  static const _p1Color = Color(0xFF4EA8DE);
  static const _p2Color = Color(0xFFFF5E5E);

  @override
  void initState() {
    super.initState();
    _controller = CarRaceDuelController()..addListener(_onGameStateChanged);
    _controller.start();
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.winner != null && !_navigatedToWinner) {
      _navigatedToWinner = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WinnerScreen(
              winner: _controller.winner!,
              player1Score: _controller.player1Score,
              player2Score: _controller.player2Score,
              playAgainBuilder: (_) => const CarRaceDuelScreen(),
            ),
          ),
        );
      });
    }
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    'FIRST TO ${CarRaceDuelController.finishDistance.toInt()}m',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: _LaneView(
                  color: _p2Color,
                  label: 'P2',
                  score: _controller.player2Score,
                  alive: _controller.player2Alive,
                  lane: _controller.player2Lane,
                  items: _controller.items,
                  onLeft: () => _controller.movePlayer2(-1),
                  onRight: () => _controller.movePlayer2(1),
                ),
              ),
              Container(height: 2, color: Colors.white24),
              Expanded(
                child: _LaneView(
                  color: _p1Color,
                  label: 'P1',
                  score: _controller.player1Score,
                  alive: _controller.player1Alive,
                  lane: _controller.player1Lane,
                  items: _controller.items,
                  onLeft: () => _controller.movePlayer1(-1),
                  onRight: () => _controller.movePlayer1(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaneView extends StatelessWidget {
  final Color color;
  final String label;
  final int score;
  final bool alive;
  final int lane;
  final List<RoadItem> items;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _LaneView({
    required this.color,
    required this.label,
    required this.score,
    required this.alive,
    required this.lane,
    required this.items,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(alive ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$label · ${score}m${alive ? '' : ' 💥'}',
                      style: TextStyle(
                          color: alive ? color : Colors.white38, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final scaleX = constraints.maxWidth / CarRaceDuelController.boardWidth;
                          final scaleY = constraints.maxHeight / CarRaceDuelController.boardHeight;
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: RoadPainter(
                                    items: items,
                                    boardWidth: CarRaceDuelController.boardWidth,
                                    boardHeight: CarRaceDuelController.boardHeight,
                                    laneCount: CarRaceDuelController.laneCount,
                                  ),
                                ),
                              ),
                              PlayerCarWidget(
                                carX: (lane + 0.5) * CarRaceDuelController.boardWidth / CarRaceDuelController.laneCount,
                                carY: CarRaceDuelController.carY,
                                width: 44,
                                height: CarRaceDuelController.carHeight,
                                scaleX: scaleX,
                                scaleY: scaleY,
                                color: alive ? color : Colors.white24,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SmallLaneButton(icon: Icons.arrow_back_ios, onTap: onLeft, color: color),
              const SizedBox(height: 8),
              _SmallLaneButton(icon: Icons.arrow_forward_ios, onTap: onRight, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallLaneButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _SmallLaneButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

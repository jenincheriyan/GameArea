import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'catch_the_fish_duel_controller.dart';

class CatchTheFishDuelScreen extends StatefulWidget {
  const CatchTheFishDuelScreen({super.key});

  @override
  State<CatchTheFishDuelScreen> createState() => _CatchTheFishDuelScreenState();
}

class _CatchTheFishDuelScreenState extends State<CatchTheFishDuelScreen> {
  late final CatchTheFishDuelController _controller;
  bool _navigatedToWinner = false;

  static const _p1Color = Color(0xFF4EA8DE);
  static const _p2Color = Color(0xFFFF5E5E);
  static const double _hitRadius = 42;

  @override
  void initState() {
    super.initState();
    _controller = CatchTheFishDuelController()..addListener(_onGameStateChanged);
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
              playAgainBuilder: (_) => const CatchTheFishDuelScreen(),
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

  void _handleZoneTap(Offset localPosition, double zoneLeftOffset, double scaleX,
      double scaleY, int player) {
    final item = _controller.currentItem;
    if (item == null) return;
    final boardX = (localPosition.dx + zoneLeftOffset) / scaleX;
    final boardY = localPosition.dy / scaleY;
    final dx = boardX - item.x;
    final dy = boardY - item.y;
    final distance = (dx * dx + dy * dy);
    if (distance <= _hitRadius * _hitRadius) {
      _controller.attemptTap(player, item.id);
    }
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
                    'FIRST TO ${CatchTheFishDuelController.targetScore}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ScorePill(label: 'P1', score: _controller.player1Score, color: _p1Color),
                    _ScorePill(label: 'P2', score: _controller.player2Score, color: _p2Color),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scaleX = constraints.maxWidth / CatchTheFishDuelController.boardWidth;
                      final scaleY = constraints.maxHeight / CatchTheFishDuelController.boardHeight;
                      final midX = constraints.maxWidth / 2;
                      final item = _controller.currentItem;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapUp: (details) => _handleZoneTap(
                                          details.localPosition, 0, scaleX, scaleY, 1),
                                      child: Container(color: _p1Color.withOpacity(0.08)),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapUp: (details) => _handleZoneTap(
                                          details.localPosition, midX, scaleX, scaleY, 2),
                                      child: Container(color: _p2Color.withOpacity(0.08)),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                left: midX - 1,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 2, color: Colors.white24),
                              ),
                              if (item != null)
                                IgnorePointer(
                                  child: Positioned(
                                    left: item.x * scaleX - 28,
                                    top: item.y * scaleY - 28,
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Center(
                                        child: Text(item.emoji, style: const TextStyle(fontSize: 34)),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Tap the fish on your side of the line — sharks and bombs cost a point!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScorePill({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text('$score',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

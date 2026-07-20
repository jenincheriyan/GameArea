import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'tug_of_war_controller.dart';
import 'widgets/rope_view.dart';

class TugOfWarGameScreen extends StatefulWidget {
  const TugOfWarGameScreen({super.key});

  @override
  State<TugOfWarGameScreen> createState() => _TugOfWarGameScreenState();
}

class _TugOfWarGameScreenState extends State<TugOfWarGameScreen> {
  late final TugOfWarController _controller;
  bool _navigatedToWinner = false;

  static const _p1Color = Color(0xFF4EA8DE);
  static const _p2Color = Color(0xFFFF5E5E);

  @override
  void initState() {
    super.initState();
    _controller = TugOfWarController()..addListener(_onGameStateChanged);
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
              player1Score: _controller.player1Taps,
              player2Score: _controller.player2Taps,
              playAgainBuilder: (_) => const TugOfWarGameScreen(),
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
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
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
                  const Text(
                    'TUG OF WAR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: RopeView(ropePosition: _controller.ropePosition),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TapZone(
                        color: _p1Color,
                        label: 'P1\nTAP!',
                        taps: _controller.player1Taps,
                        onTap: _controller.tapPlayer1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _TapZone(
                        color: _p2Color,
                        label: 'P2\nTAP!',
                        taps: _controller.player2Taps,
                        onTap: _controller.tapPlayer2,
                      ),
                    ),
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

class _TapZone extends StatelessWidget {
  final Color color;
  final String label;
  final int taps;
  final VoidCallback onTap;

  const _TapZone({
    required this.color,
    required this.label,
    required this.taps,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.6), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$taps',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

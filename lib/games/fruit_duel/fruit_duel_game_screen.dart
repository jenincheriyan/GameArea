import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/winner_screen.dart';
import 'fruit_duel_controller.dart';
import 'widgets/player_panel.dart';
import 'widgets/spawn_object_view.dart';

class FruitDuelGameScreen extends StatefulWidget {
  const FruitDuelGameScreen({super.key});

  @override
  State<FruitDuelGameScreen> createState() => _FruitDuelGameScreenState();
}

class _FruitDuelGameScreenState extends State<FruitDuelGameScreen> {
  late final FruitDuelController _controller;
  bool _navigatedToWinner = false;

  @override
  void initState() {
    super.initState();
    // Face-off layout: the phone lies flat on a table between the two
    // players, so this screen stays in portrait rather than landscape.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
    _controller = FruitDuelController()..addListener(_onGameStateChanged);
    _controller.start();
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.winner != null && !_navigatedToWinner) {
      _navigatedToWinner = true;
      _goToWinnerScreen();
    }
  }

  void _goToWinnerScreen() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WinnerScreen(
            winner: _controller.winner!,
            player1Score: _controller.player1Score,
            player2Score: _controller.player2Score,
            playAgainBuilder: (_) => const FruitDuelGameScreen(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top player's half — rotated 180° so their sword sits
                  // right-side up for someone facing the phone from that
                  // end, matching Math Duel's face-off layout.
                  Expanded(
                    child: Transform.rotate(
                      angle: math.pi,
                      child: PlayerPanel(
                        label: '',
                        score: _controller.player1Score,
                        colors: const [
                          Color(0xFF5080FF),
                          Color(0xFF3060FF),
                        ],
                        onCut: () => _controller.cut(1),
                      ),
                    ),
                  ),
                  _CenterStrip(
                    onTapExit: () => Navigator.of(context).pop(),
                    child: SpawnObjectView(object: _controller.currentObject),
                  ),
                  // Bottom player's half — normal orientation.
                  Expanded(
                    child: PlayerPanel(
                      label: '',
                      score: _controller.player2Score,
                      colors: const [Color(0xFFFF5E5E), Color(0xFFFF4444)],
                      onCut: () => _controller.cut(2),
                    ),
                  ),
                ],
              ),
              // Countdown overlay
              if (_controller.countdown != null)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      _controller.countdown == 0
                          ? 'GO!'
                          : '${_controller.countdown}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                      ),
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

/// The neutral strip between the two halves: two faint horizontal lines
/// with the spawn object centered between them and a small circular exit
/// button tucked to the side — matches Math Duel's "no-man's-land" divider.
class _CenterStrip extends StatelessWidget {
  final Widget child;
  final VoidCallback onTapExit;
  const _CenterStrip({required this.child, required this.onTapExit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            child: Container(
              width: 150,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: 150,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(child: child),
          Positioned(
            right: 20,
            child: GestureDetector(
              onTap: onTapExit,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(Icons.close, color: Colors.white70, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

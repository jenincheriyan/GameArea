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
    // This game is designed for landscape play only.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
    // Small pause so the final score change is visible before transitioning.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WinnerScreen(
            winner: _controller.winner!,
            player1Score: _controller.player1Score,
            player2Score: _controller.player2Score,
            onPlayAgain: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FruitDuelGameScreen()),
              );
            },
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
              Row(
                children: [
                  Expanded(
                    child: PlayerPanel(
                      label: 'PLAYER 1',
                      score: _controller.player1Score,
                      colors: const [
                        Color(0xFF5080FF),
                        Color(0xFF3060FF),
                      ],
                      onCut: () => _controller.cut(1),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: Center(
                      child: SpawnObjectView(
                        object: _controller.currentObject,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PlayerPanel(
                      label: 'PLAYER 2',
                      score: _controller.player2Score,
                      colors: const [Color(0xFFFF5E5E), Color(0xFFFF4444)],
                      onCut: () => _controller.cut(2),
                      flip: true,
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

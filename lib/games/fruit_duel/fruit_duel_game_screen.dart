import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/game_object.dart';
import '../../screens/winner_screen.dart';
import 'fruit_duel_controller.dart';
import 'services/audio_service.dart';
import 'widgets/player_panel.dart';
import 'widgets/spawn_object_view.dart';

class FruitDuelGameScreen extends StatefulWidget {
  const FruitDuelGameScreen({super.key});

  @override
  State<FruitDuelGameScreen> createState() => _FruitDuelGameScreenState();
}

class _FruitDuelGameScreenState extends State<FruitDuelGameScreen>
    with SingleTickerProviderStateMixin {
  late final FruitDuelController _controller;
  late final AnimationController _shakeController;
  final AudioService _audio = AudioService.instance;

  bool _navigatedToWinner = false;
  int _lastSeenResultTick = 0;

  @override
  void initState() {
    super.initState();
    // Face-off layout: the phone lies flat on a table between the two
    // players, so this screen stays in portrait rather than landscape.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _controller = FruitDuelController()..addListener(_onGameStateChanged);
    _lastSeenResultTick = _controller.resultTick;
    _controller.start();
  }

  void _onGameStateChanged() {
    if (!mounted) return;

    if (_controller.resultTick != _lastSeenResultTick) {
      _lastSeenResultTick = _controller.resultTick;
      final obj = _controller.lastResolvedObject;
      if (obj != null) {
        if (obj.kind == ObjectKind.bomb) {
          _audio.playExplosion();
          _shakeController.forward(from: 0);
        } else {
          _audio.playFruitSlice();
          _audio.playJuiceSplash();
        }
      }
    }

    setState(() {});

    if (_controller.winner != null && !_navigatedToWinner) {
      _navigatedToWinner = true;
      _audio.playVictoryFanfare();
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
    _shakeController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _cut(int player) {
    _audio.playButtonTap();
    _controller.cut(player);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Purple gradient background, per the reference art.
          gradient: LinearGradient(
            colors: [Color(0xFFA870AC), Color(0xFF7C4C82)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final t = _shakeController.value;
              final decay = (1 - t);
              final dx = math.sin(t * math.pi * 10) * 10 * decay;
              final dy = math.cos(t * math.pi * 8) * 6 * decay;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: child,
              );
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top player's half — rotated 180° so their score and
                    // CUT button sit right-side up for someone facing the
                    // phone from that end.
                    Expanded(
                      child: Transform.rotate(
                        angle: math.pi,
                        child: PlayerPanel(
                          score: _controller.player1Score,
                          color: const Color(0xFF17C4EE),
                          onCut: () => _cut(1),
                        ),
                      ),
                    ),
                    _CenterStrip(
                      onTapExit: () => Navigator.of(context).pop(),
                      child: ArenaObjectView(controller: _controller),
                    ),
                    // Bottom player's half — normal orientation.
                    Expanded(
                      child: PlayerPanel(
                        score: _controller.player2Score,
                        color: const Color(0xFFFF5F57),
                        onCut: () => _cut(2),
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
      ),
    );
  }
}

/// The neutral strip between the two halves: the live/cut object centered
/// between them, with a small circular exit button tucked to the side.
class _CenterStrip extends StatelessWidget {
  final Widget child;
  final VoidCallback onTapExit;
  const _CenterStrip({required this.child, required this.onTapExit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(child: child),
          Positioned(
            right: 20,
            child: GestureDetector(
              onTap: onTapExit,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black26, width: 1.5),
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

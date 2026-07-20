import 'package:flutter/material.dart';
import 'ludo_controller.dart';
import 'ludo_models.dart';
import 'widgets/dice_view.dart';
import 'widgets/ludo_board.dart';

/// Local pass-and-play Ludo for 2-4 players. WinnerScreen only models a
/// two-competitor result, so with a variable 2-4 player count this mode
/// shows its own lightweight win overlay instead — matching the
/// project's existing precedent of not forcing WinnerScreen where it
/// doesn't structurally fit (see: Tic-Tac-Toe's draw overlay).
class LudoDuelScreen extends StatefulWidget {
  const LudoDuelScreen({super.key});

  @override
  State<LudoDuelScreen> createState() => _LudoDuelScreenState();
}

class _LudoDuelScreenState extends State<LudoDuelScreen> {
  LudoController? _controller;
  int? _playerCount;

  void _startWith(int playerCount) {
    _controller?.dispose();
    _controller = LudoController(playerCount: playerCount)
      ..addListener(_onGameStateChanged);
    _controller!.start();
    setState(() => _playerCount = playerCount);
  }

  void _onGameStateChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onGameStateChanged);
    _controller?.dispose();
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
          child: _playerCount == null
              ? _PlayerCountPicker(onSelected: _startWith)
              : _BoardView(controller: _controller!),
        ),
      ),
    );
  }
}

class _PlayerCountPicker extends StatelessWidget {
  final ValueChanged<int> onSelected;
  const _PlayerCountPicker({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('HOW MANY PLAYERS?',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [2, 3, 4].map((n) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => onSelected(n),
                  child: Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BoardView extends StatelessWidget {
  final LudoController controller;
  const _BoardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final current = controller.colors[controller.currentPlayer];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Text(
              "${current.label.toUpperCase()}'S TURN",
              style: TextStyle(color: current.color, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            const SizedBox(width: 48),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: List.generate(controller.colors.length, (p) {
              final color = controller.colors[p];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.color.withOpacity(p == controller.currentPlayer ? 0.28 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.color.withOpacity(0.6)),
                ),
                child: Text('${color.label} · ${controller.finishedCount(p)}/4',
                    style: TextStyle(color: color.color, fontWeight: FontWeight.w700, fontSize: 12)),
              );
            }),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                LudoBoardView(
                  colors: controller.colors,
                  tokensByPlayer: controller.tokensByPlayer,
                  movableTokenIndices: controller.movableTokenIndices,
                  currentPlayer: controller.currentPlayer,
                  onTapToken: controller.moveToken,
                ),
                if (controller.winnerPlayerIndex != null)
                  _WinOverlay(controller: controller),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DiceView(
            value: controller.diceValue,
            accentColor: current.color,
            onTap: controller.winnerPlayerIndex == null && !controller.hasRolledThisTurn
                ? controller.rollDice
                : null,
          ),
        ),
      ],
    );
  }
}

class _WinOverlay extends StatelessWidget {
  final LudoController controller;
  const _WinOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    final winnerColor = controller.colors[controller.winnerPlayerIndex!];
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                '${winnerColor.label.toUpperCase()} WINS!',
                style: TextStyle(color: winnerColor.color, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.start(),
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

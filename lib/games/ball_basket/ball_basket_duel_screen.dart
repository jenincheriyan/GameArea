import 'package:flutter/material.dart';
import '../../screens/winner_screen.dart';
import 'ball_basket_duel_controller.dart';
import 'widgets/hoop_and_ball.dart';

class BallBasketDuelScreen extends StatefulWidget {
  const BallBasketDuelScreen({super.key});

  @override
  State<BallBasketDuelScreen> createState() => _BallBasketDuelScreenState();
}

class _BallBasketDuelScreenState extends State<BallBasketDuelScreen> {
  late final BallBasketDuelController _controller;
  bool _navigatedToWinner = false;

  Offset? _p1DragStart;
  Offset? _p1DragCurrent;
  Offset? _p2DragStart;
  Offset? _p2DragCurrent;

  static const _p1Color = Color(0xFF4EA8DE);
  static const _p2Color = Color(0xFFFF5E5E);

  @override
  void initState() {
    super.initState();
    _controller = BallBasketDuelController()..addListener(_onGameStateChanged);
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
              playAgainBuilder: (_) => const BallBasketDuelScreen(),
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
                    '${_controller.secondsRemaining}s',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: _RigView(
                  color: _p2Color,
                  label: 'P2',
                  score: _controller.player2Score,
                  ballX: _controller.ball2X,
                  ballY: _controller.ball2Y,
                  basketX: _controller.basket2X,
                  dragStart: _p2DragStart,
                  dragCurrent: _p2DragCurrent,
                  onPanStart: (p) => setState(() {
                    _p2DragStart = p;
                    _p2DragCurrent = p;
                  }),
                  onPanUpdate: (p) => setState(() => _p2DragCurrent = p),
                  onPanEnd: (scaleX, scaleY) {
                    if (_p2DragStart == null || _p2DragCurrent == null) return;
                    final v = _p2DragCurrent! - _p2DragStart!;
                    _controller.launchPlayer2(Offset(v.dx / scaleX, v.dy / scaleY));
                    setState(() {
                      _p2DragStart = null;
                      _p2DragCurrent = null;
                    });
                  },
                ),
              ),
              Container(height: 2, color: Colors.white24),
              Expanded(
                child: _RigView(
                  color: _p1Color,
                  label: 'P1',
                  score: _controller.player1Score,
                  ballX: _controller.ball1X,
                  ballY: _controller.ball1Y,
                  basketX: _controller.basket1X,
                  dragStart: _p1DragStart,
                  dragCurrent: _p1DragCurrent,
                  onPanStart: (p) => setState(() {
                    _p1DragStart = p;
                    _p1DragCurrent = p;
                  }),
                  onPanUpdate: (p) => setState(() => _p1DragCurrent = p),
                  onPanEnd: (scaleX, scaleY) {
                    if (_p1DragStart == null || _p1DragCurrent == null) return;
                    final v = _p1DragCurrent! - _p1DragStart!;
                    _controller.launchPlayer1(Offset(v.dx / scaleX, v.dy / scaleY));
                    setState(() {
                      _p1DragStart = null;
                      _p1DragCurrent = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RigView extends StatelessWidget {
  final Color color;
  final String label;
  final int score;
  final double ballX;
  final double ballY;
  final double basketX;
  final Offset? dragStart;
  final Offset? dragCurrent;
  final ValueChanged<Offset> onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final void Function(double scaleX, double scaleY) onPanEnd;

  const _RigView({
    required this.color,
    required this.label,
    required this.score,
    required this.ballX,
    required this.ballY,
    required this.basketX,
    required this.dragStart,
    required this.dragCurrent,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$label · $score',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scaleX = constraints.maxWidth / 400; // boardWidth
                final scaleY = constraints.maxHeight / 500; // boardHeight
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) => onPanStart(d.localPosition),
                  onPanUpdate: (d) => onPanUpdate(d.localPosition),
                  onPanEnd: (_) => onPanEnd(scaleX, scaleY),
                  child: Stack(
                    children: [
                      BasketWidget(centerX: basketX * scaleX, centerY: 100 * scaleY, width: 70),
                      BallWidget(centerX: ballX * scaleX, centerY: ballY * scaleY, radius: 14 * scaleX),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

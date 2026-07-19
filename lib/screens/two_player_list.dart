import 'package:flutter/material.dart';
import '../models/game_info.dart';
import '../games/fruit_duel/fruit_duel_game_screen.dart';
import '../games/math_duel/math_duel_game_screen.dart';
import '../games/snake_multiplayer/snake_multiplayer_game_screen.dart';
import '../games/snake_multiplayer/snake_multiplayer_controller.dart';
import '../games/tic_tac_toe/tic_tac_toe_game_screen.dart';

/// The single registry of games shown on the home screen. Add a new
/// [GameInfo] entry here to make a new game appear in the app — nothing
/// else needs to change.
final List<GameInfo> availableGames = [
  GameInfo(
    id: 'fruit_duel',
    title: 'Fruit Duel',
    imagePath: 'assets/images/logo1.png',
    tagline: 'Cut fast. Dodge bombs. First to 10 wins.',
    rules: const [
    ],
    primaryColor: const Color(0xFF4E4D4D),
    secondaryColor: const Color(0xFF000000),
    gameScreenBuilder: (context) => const FruitDuelGameScreen(),
  ),
  GameInfo(
    id: 'math_duel',
    title: 'MATH',
    imagePath: 'assets/images/math_duel.png',
    tagline: 'Same equation, two players. Tap fast if it checks out.',
    rules: const [
      'The screen splits into two sides — Player 1 (left) and Player 2 (right).',
      'The same equation appears in the middle for both players to see.',
      'If the equation is TRUE, tap your button — first correct tap earns +1.',
      'If the equation is FALSE, tapping costs you −1 point.',
      'If nobody taps before it disappears, no points change hands.',
      'First player to reach 10 points wins the duel!',
    ],
    primaryColor: const Color(0xFF000000),
    secondaryColor: const Color(0xFF424242),
    gameScreenBuilder: (context) => const MathDuelGameScreen(),
  ),
  GameInfo(
    id: 'snake_multiplayer',
    title: 'SNAKE',
    imagePath: 'assets/images/snake_multiplayer.png',
    tagline: 'Two snakes, two foods, one board. First to '
        '${SnakeMultiplayerController.targetScore} wins.',
    rules: const [
      'Both snakes move on the same board at the same time.',
      'Two food items are always on the board — either snake can eat either one.',
      'Player 1 uses the left D-pad, Player 2 uses the right D-pad.',
      'Hitting a wall, yourself, or the other snake ends that snake\'s run.',
      'The match ends when a player reaches the target score, or when both snakes are down.',
      'Whoever has the higher score when it ends wins!',
    ],
    primaryColor: const Color(0xFF302B63),
    secondaryColor: const Color(0xFF24243E),
    gameScreenBuilder: (context) => const SnakeMultiplayerGameScreen(),
  ),
  GameInfo(
    id: 'tic_tac_toe_2p',
    title: 'XOX',
    imagePath: 'assets/images/tic_tac_toe.png',
    tagline: 'Pass and play. X goes first — get three in a row!',
    rules: const [
      'Players alternate turns, X always goes first.',
      'First to line up three marks in a row, column, or diagonal wins.',
      'If the board fills up with no winner, it\'s a draw.',
    ],
    primaryColor: const Color(0xFF4E4D4D),
    secondaryColor: const Color(0xFF1A1A2E),
    gameScreenBuilder: (context) => const TicTacToeGameScreen(vsAI: false),
  ),
];


class TwoPlayerList extends StatelessWidget {
  const TwoPlayerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF000000), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                  'GAMES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: availableGames.length,
                    itemBuilder: (context, index) {
                      return _GameCard(game: availableGames[index]);
                    },
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

class _GameCard extends StatelessWidget {
  final GameInfo game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: game.gameScreenBuilder),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [game.primaryColor, game.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: game.primaryColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    game.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              game.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
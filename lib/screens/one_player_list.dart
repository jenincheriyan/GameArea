import 'package:flutter/material.dart';
import '../models/game_info.dart';
import '../games/snake/snake_game_screen.dart';
import '../games/math_game/math_game_screen.dart';
import '../games/tic_tac_toe/tic_tac_toe_game_screen.dart';


/// The single registry of games shown on the home screen. Add a new
/// [GameInfo] entry here to make a new game appear in the app — nothing
/// else needs to change.
final List<GameInfo> availableGames = [
  GameInfo(
    id: 'snake',
    title: 'SNAKE',
    imagePath: 'assets/images/snake.png',
    tagline: 'Snake',
    rules: const [
    ],
    primaryColor: const Color(0xFF000000),
    secondaryColor: const Color(0xFF252525),
    gameScreenBuilder: (context) => const SnakeGameScreen(),
  ),
  GameInfo(
    id: 'math_game',
    title: 'Math',
    imagePath: 'assets/images/math_game.png',
    tagline: 'True or false? Answer fast, climb your high score.',
    rules: const [
      'One statement is shown at a time — addition, subtraction, multiplication, or a comparison like "8 x 4 < 35".',
      'Tap TRUE or FALSE to judge whether it\'s correct.',
      'Each correct answer adds to your score and the questions get a bit harder.',
      'One wrong answer ends the run — your best score is saved.',
    ],
    primaryColor: const Color(0xFF302B63),
    secondaryColor: const Color(0xFF0F0C29),
    gameScreenBuilder: (context) => const MathGameScreen(),
  ),
  GameInfo(
    id: 'tic_tac_toe_1p',
    title: 'XOX',
    imagePath: 'assets/images/tic_tac_toe.png',
    tagline: 'Pick a difficulty and try to beat the computer.',
    rules: const [
      'You play X and always go first.',
      'Choose Easy for a beatable AI, or Hard for an unbeatable one.',
      'First to line up three marks in a row, column, or diagonal wins.',
      'If the board fills up with no winner, it\'s a draw.',
    ],
    primaryColor: const Color(0xFF4E4D4D),
    secondaryColor: const Color(0xFF1A1A2E),
    gameScreenBuilder: (context) => const TicTacToeGameScreen(vsAI: true),
  ),
];

class OnePlayerList extends StatelessWidget {
  const OnePlayerList({super.key});

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
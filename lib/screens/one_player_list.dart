import 'package:flutter/material.dart';
import '../models/game_info.dart';
import '../games/snake/snake_game_screen.dart';
import '../games/math_game/math_game_screen.dart';
import '../games/tic_tac_toe/tic_tac_toe_game_screen.dart';
import '../games/flappy_bird/flappy_bird_game_screen.dart';
import '../games/catch_the_fish/catch_the_fish_game_screen.dart';
import '../games/ball_basket/ball_basket_game_screen.dart';
import '../games/car_race/car_race_game_screen.dart';
import '../games/ludo/ludo_game_screen.dart';
import '../games/coming_soon/coming_soon_screen.dart';
import 'settings_sheet.dart';

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
    primaryColor: const Color(0xFFACB502),
    secondaryColor: const Color(0xFFACB502),
    gameScreenBuilder: (context) => const SnakeGameScreen(),
  ),
  GameInfo(
    id: 'math_game',
    title: 'MATH',
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
  GameInfo(
    id: 'flappy_bird',
    title: 'BOUNCE',
    imagePath: 'assets/images/flappy_bird.png',
    tagline: 'Tap to flap, dodge the pipes, beat your best.',
    rules: const [
    'Tap anywhere to make the bird flap upward.',
    'Gravity pulls it back down between taps.',
    'Fly through the gaps in the pipes — hitting one, the ground, or the ceiling ends the run.',
    'Speed picks up the further you get. Your best score is saved.',
    ],
    primaryColor: const Color(0xFF1E3C72),
    secondaryColor: const Color(0xFF2A5298),
    gameScreenBuilder: (context) => const FlappyBirdGameScreen(),
  ),
  // GameInfo(
  //   id: 'catch_the_fish',
  //   title: 'Catch the Fish',
  //   imagePath: 'assets/images/catch_the_fish.png',
  //   tagline: 'Tap fish to score. Sharks and bombs cost a life.',
  //   rules: const [
  //   'Fish, sharks, and bombs appear one at a time at random spots.',
  //   'Tap a fish to score a point.',
  //   'Tap a shark or a bomb and you lose one of your 3 lives.',
  //   'Items get faster as your score climbs. Your best score is saved.',
  //   ],
  //   primaryColor: const Color(0xFF1E3C72),
  //   secondaryColor: const Color(0xFF2A5298),
  //   gameScreenBuilder: (context) => const FlappyBirdGameScreen(),
  // ),
  // GameInfo(
  //   id: 'ball_basket',
  //   title: 'Ball in the Basket',
  //   imagePath: 'assets/images/ball_basket.png',
  //   tagline: 'Drag to aim, flick to throw, chain makes for bonus points.',
  //   rules: const [
  //     'Drag away from the ball like a slingshot, then release to throw it.',
  //     'Land it in the basket to score — the basket moves each round.',
  //     'Consecutive makes build a streak multiplier, up to x5.',
  //     'Three misses ends the run. Your best score is saved.',
  //   ],
  //   primaryColor: const Color(0xFFEE9CA7),
  //   secondaryColor: const Color(0xFFFFDDE1),
  //   gameScreenBuilder: (context) => const BallBasketGameScreen(),
  // ),
  GameInfo(
    id: 'car_race',
    title: 'RACE',
    imagePath: 'assets/images/car_race.png',
    tagline: 'Dodge traffic, grab coins, rack up distance.',
    rules: const [
      'Switch lanes with the left/right buttons to dodge oncoming traffic.',
      'Grab coins for bonus points.',
      'Hitting a car ends the run — speed increases the further you get.',
      'Your score is based on distance. Your best score is saved.',
    ],
    primaryColor: const Color(0xFF232526),
    secondaryColor: const Color(0xFF414345),
    gameScreenBuilder: (context) => const CarRaceGameScreen(),
  ),
  // GameInfo(
  //   id: 'ludo_vs_ai',
  //   title: 'Ludo (vs AI)',
  //   imagePath: 'assets/images/ludo.png',
  //   tagline: 'Classic Ludo — you against the computer.',
  //   rules: const [
  //     'Roll a 6 to bring a token out of your yard.',
  //     'Move a token by the number rolled; land on an opponent (off a safe cell) to send them home.',
  //     'Rolling a 6 or capturing an opponent earns another roll.',
  //     'Get all 4 tokens home first to win.',
  //   ],
  //   primaryColor: const Color(0xFF302B63),
  //   secondaryColor: const Color(0xFF24243E),
  //   gameScreenBuilder: (context) => const LudoGameScreen(),
  // ),
  GameInfo(
    id: 'snake_multiplayer',
    title: '',
    imagePath: 'assets/images/coming_soon.png',
    tagline: 'Two snakes, two foods, one board. First to ',
    rules: const [
      'Both snakes move on the same board at the same time.',
      'Two food items are always on the board — either snake can eat either one.',
      'Player 1 uses the left D-pad, Player 2 uses the right D-pad.',
      'Hitting a wall, yourself, or the other snake ends that snake\'s run.',
      'The match ends when a player reaches the target score, or when both snakes are down.',
      'Whoever has the higher score when it ends wins!',
    ],
    primaryColor: const Color(0xFFFBCB09),
    secondaryColor: const Color(0xFFFBCB09),
    gameScreenBuilder: (context) => const ComingSoonScreen(),
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

                Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),

                    // Title
                    const Expanded(
                      child: Center(
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
                    ),

                    // Settings button
                    IconButton(
                      onPressed: () => showSettingsSheet(context),
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white70,
                      ),
                    ),
                  ],
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
import 'package:flutter/material.dart';
import '../models/game_info.dart';
import '../games/fruit_duel/fruit_duel_game_screen.dart';
import '../games/math_duel/math_duel_game_screen.dart';
import '../games/snake_multiplayer/snake_multiplayer_game_screen.dart';
import '../games/snake_multiplayer/snake_multiplayer_controller.dart';
import '../games/tic_tac_toe/tic_tac_toe_game_screen.dart';
import '../games/tug_of_war/tug_of_war_game_screen.dart';
import '../games/catch_the_fish/catch_the_fish_duel_screen.dart';
import '../games/ball_basket/ball_basket_duel_screen.dart';
import '../games/car_race/car_race_duel_screen.dart';
import '../games/ludo/ludo_duel_screen.dart';
import '../games/coming_soon/coming_soon_screen.dart';
import 'settings_sheet.dart';


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
  GameInfo(
    id: 'snake_multiplayer',
    title: '',
    imagePath: 'assets/images/coming_soon.png',
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
    primaryColor: const Color(0xFFFBCB09),
    secondaryColor: const Color(0xFFFBCB09),
    gameScreenBuilder: (context) => const ComingSoonScreen(),
  ),
  // GameInfo(
  //   id: 'tug_of_war',
  //   title: 'Tug of War',
  //   imagePath: 'assets/images/tug_of_war.png',
  //   tagline: 'Tap as fast as you can to pull the rope your way.',
  //   rules: const [
  //     'The rope starts in the center.',
  //     'Each player has their own big TAP button.',
  //     'Every tap pulls the rope a little toward your side.',
  //     'First to pull the rope all the way to their side wins.',
  //   ],
  //   primaryColor: const Color(0xFF302B63),
  //   secondaryColor: const Color(0xFF24243E),
  //   gameScreenBuilder: (context) => const TugOfWarGameScreen(),
  // ),
  // GameInfo(
  //   id: 'catch_the_fish_2p',
  //   title: 'Catch the Fish (Duel)',
  //   imagePath: 'assets/images/catch_the_fish.png',
  //   tagline: 'Fish appear in the middle — first tap wins the point.',
  //   rules: const [
  //     'The board is split into a Player 1 side and a Player 2 side.',
  //     'Fish, sharks, and bombs always appear in the shared middle strip.',
  //     'First player to tap a fish scores a point.',
  //     'Tapping a shark or bomb costs a point. First to the target score wins.',
  //   ],
  //   primaryColor: const Color(0xFF03396C),
  //   secondaryColor: const Color(0xFF6497B1),
  //   gameScreenBuilder: (context) => const CatchTheFishDuelScreen(),
  // ),
  // GameInfo(
  //   id: 'ball_basket_2p',
  //   title: 'Ball in the Basket (Duel)',
  //   imagePath: 'assets/images/ball_basket.png',
  //   tagline: 'Two baskets, one clock — highest score wins.',
  //   rules: const [
  //     'Both players throw at the same time on their own half of the screen.',
  //     'Drag away from the ball, then release to throw it toward your basket.',
  //     'Whoever has the higher score when the clock runs out wins.',
  //   ],
  //   primaryColor: const Color(0xFFEE9CA7),
  //   secondaryColor: const Color(0xFFFFDDE1),
  //   gameScreenBuilder: (context) => const BallBasketDuelScreen(),
  // ),
  // GameInfo(
  //   id: 'car_race_2p',
  //   title: 'Car Race (Duel)',
  //   imagePath: 'assets/images/car_race.png',
  //   tagline: 'Same obstacles, side by side — first to the finish wins.',
  //   rules: const [
  //     'Both players race the exact same obstacle course, split top and bottom.',
  //     'Use your left/right buttons to dodge traffic and grab coins.',
  //     'First to reach 400m wins — or whoever\'s gone furthest if both crash.',
  //   ],
  //   primaryColor: const Color(0xFF232526),
  //   secondaryColor: const Color(0xFF414345),
  //   gameScreenBuilder: (context) => const CarRaceDuelScreen(),
  // ),
  // GameInfo(
  //   id: 'ludo_2p',
  //   title: 'Ludo',
  //   imagePath: 'assets/images/ludo.png',
  //   tagline: 'Classic Ludo, pass and play with 2-4 players.',
  //   rules: const [
  //     'Choose 2, 3, or 4 players, then pass the device between turns.',
  //     'Roll a 6 to bring a token out of your yard.',
  //     'Land on an opponent (off a safe cell) to send their token home.',
  //     'Rolling a 6 or capturing an opponent earns another roll.',
  //     'First to get all 4 tokens home wins.',
  //   ],
  //   primaryColor: const Color(0xFF302B63),
  //   secondaryColor: const Color(0xFF24243E),
  //   gameScreenBuilder: (context) => const LudoDuelScreen(),
  // ),
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
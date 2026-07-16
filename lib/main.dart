import 'package:flutter/material.dart';
import 'package:idam/screens/player_mode_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IdamApp());
}

/// Root widget for Idam — a small hub of local two-player, pass-and-play
/// games. New games are registered in [availableGames] (home_screen.dart)
/// and everything else (details screen, navigation, theming) just works.
class IdamApp extends StatelessWidget {
  const IdamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF000000),
        scaffoldBackgroundColor: const Color(0xFF000000),
        fontFamily: 'Roboto',
      ),
      home: const PlayerModeScreen(),
    );
  }
}

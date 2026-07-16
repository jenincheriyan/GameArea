import 'package:flutter/material.dart';
import 'package:idam/screens/home_screen.dart';
import 'screens/two_player_list.dart';

void main() {
  runApp(const IdamApp());
}

/// Root widget for Idam — a small hub of local two-player, pass-and-play
/// games. New games are registered in [availableGames] (two_player_list.dart)
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
      home: const HomeScreen(),
    );
  }
}

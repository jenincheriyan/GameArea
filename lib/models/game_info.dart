import 'package:flutter/material.dart';

/// Describes a game available in the Idam hub.
///
/// To add a new game to the app:
///   1. Build its screen(s) under lib/games/<your_game>/.
///   2. Create one [GameInfo] describing it.
///   3. Add that GameInfo to the `availableGames` list in home_screen.dart.
/// The home screen, details screen, and navigation all pick it up
/// automatically — no other file needs to change.
class GameInfo {
  final String id;
  final String title;
  final String imagePath;
  final String tagline;
  final List<String> rules;
  final Color primaryColor;
  final Color secondaryColor;
  final WidgetBuilder gameScreenBuilder;

  const GameInfo({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.tagline,
    required this.rules,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gameScreenBuilder,
  });
}

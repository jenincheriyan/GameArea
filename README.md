# Idam

A small hub of local, pass-and-play, two-player mobile games built in Flutter.
The first game is **Fruit Duel**.

## Running it

This zip contains only the `lib/` source and `pubspec.yaml` — you'll need the
standard Flutter platform scaffolding (`android/`, `ios/`, etc.) around it.

1. Create a fresh Flutter project and drop these files in:
   ```bash
   flutter create idam
   cd idam
   # copy lib/ and pubspec.yaml from this zip into the new project, overwriting the defaults
   flutter pub get
   flutter run
   ```
2. Or, if you already have a Flutter project, just copy `lib/` and merge
   `pubspec.yaml`'s `dependencies` section into yours.

No Firebase, no internet permissions, no backend — everything is local state.

## Project structure

```
lib/
  main.dart                     # MaterialApp root, points at HomeScreen
  models/
    game_info.dart              # Describes one game for the home/details screens
    game_object.dart            # A spawned fruit/bomb object
  screens/
    home_screen.dart            # Game picker grid (register new games here)
    game_details_screen.dart    # Rules + Start Game button
    winner_screen.dart          # Final score + Play Again / Back to Home
  games/
    fruit_duel/
      fruit_duel_controller.dart   # All game logic: spawning, timers, scoring
      fruit_duel_game_screen.dart  # Landscape game screen, wires controller to UI
      widgets/
        sword_button.dart          # Tappable sword with slash animation
        spawn_object_view.dart     # Animated center fruit/bomb
        player_panel.dart          # One side's score + sword + CUT button
```

## Adding a new game later

1. Build it under `lib/games/<your_game>/`, following the Fruit Duel folder
   as a template (a `ChangeNotifier` controller + a screen that listens to it
   tends to keep things simple).
2. Add one `GameInfo` entry to `availableGames` in `home_screen.dart` — title,
   emoji, tagline, rules list, colors, and a builder for its game screen.
3. That's it. The home screen grid and the details screen are generic and
   pick up any game described this way automatically.

## How Fruit Duel's fairness is enforced

Each spawned object gets a unique incrementing id. The controller keeps a
single `_objectResolved` flag per object: the *first* thing to touch it —
whichever player's `cut()` call runs first, or the expiry timer if nobody
cuts in time — flips that flag and every other event for that same object
is ignored. Since Dart callbacks run to completion on a single thread, there
is no race condition even if both players tap in the same frame; whichever
tap handler executes first wins the point, and the second is a no-op.

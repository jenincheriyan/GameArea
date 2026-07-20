GameArea is a Flutter-based mini games hub — a single app that bundles together a growing collection of single-player and two-player (same-device) games, all wrapped in one.

Think of it as an arcade cabinet: pick a mode (1 Player or 2 Player), pick a game, and play.


Project Structure

lib/
├── main.dart                 # App entry point, theme, lifecycle-aware audio pausing
├── models/
│   ├── game_info.dart         # GameInfo model — describes a game card in the registry
│   ├── game_object.dart
│   └── home_mode.dart          # HomeMode enum (onePlayer / twoPlayer)
├── services/
│   └── audio_manager.dart     # Singleton for background music + sound effects
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart       # Mode picker (1 Player / 2 Player)
│   ├── one_player_list.dart   # 🔑 registry of all 1-player GameInfo entries
│   ├── two_player_list.dart   # 🔑 registry of all 2-player GameInfo entries
│   ├── game_details_screen.dart # Rules/instructions screen before starting a game
│   ├── winner_screen.dart
│   └── settings_sheet.dart    # Mute toggle, etc.
└── games/
    ├── snake/
    ├── tic_tac_toe/
    ├── math_game/
    ├── math_duel/
    ├── flappy_bird/
    ├── ball_basket/
    ├── car_race/
    ├── fruit_duel/
    ├── snake_multiplayer/
    ├── catch_the_fish/
    ├── tug_of_war/
    └── ludo/
        ├── <game>_controller.dart   # Game logic / state
        ├── <game>_game_screen.dart  # UI + gameplay loop
        └── widgets/                 # Game-specific widgets (boards, buttons, painters)
```

Each game is self-contained under `lib/games/<game_name>/`, typically split into:
- a **controller** (game state, rules, timers, scoring)
- a **screen** (renders the controller's state, handles input)
- **widgets** (custom-painted boards, buttons, HUD elements)

---

Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel `stable` recommended)
- A configured emulator/simulator, or a physical Android/iOS device
- Dart SDK `>=3.0.0 <4.0.0` (bundled with Flutter)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/game_area.git
cd game_area

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```


Adding a New Game

The project is intentionally structured so a new game can be added without touching the home screen, navigation, or details screen. This is documented directly in `lib/models/game_info.dart`:

1. Build the new game's screen(s) and controller under `lib/games/<your_game>/`.
2. Create a `GameInfo` entry describing it (id, title, image, tagline, rules, colors, and the screen builder).
3. Add that `GameInfo` to the `availableGames` list in `one_player_list.dart` (for solo games) or `two_player_list.dart` (for duel games).

That's it — the home screen grid, the details/rules screen, and navigation all pick it up automatically.

---

## 🤝 Contributing

Contributions are very welcome, whether it's a bug fix, a new game, or finishing one of the scaffolded-but-disabled games (Ludo, Catch the Fish, Tug of War, and the duel variants of Ball Basket / Car Race).

1. **Fork** the repository
2. **Create a branch** for your change: `git checkout -b feature/my-new-game`
3. **Follow the existing structure**: keep game logic in a controller, keep the screen focused on rendering/input, and reuse the `GameInfo` pattern for registration
4. **Run the linter** before committing: `flutter analyze`
5. **Commit** your changes with a clear message
6. **Push** to your fork and **open a Pull Request** describing what you changed and why

### Ideas for contributions

- Create three player and four player
- Add a global leaderboard or achievements system
- Add haptic feedback
- improve UI, UX
- Improve accessibility (font scaling, color contrast, screen-reader labels)
- Add unit/widget tests (the project currently has minimal test coverage)

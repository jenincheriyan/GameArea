import 'package:flutter/services.dart';

/// Central place for every sound/haptic cue Fruit Duel plays.
///
/// This keeps audio completely decoupled from game logic and widgets —
/// the controller and UI just call `AudioService.instance.playX()` and
/// don't care how the sound is actually produced.
///
/// Out of the box this uses [SystemSound] + [HapticFeedback] so the game
/// has *some* feedback with zero bundled assets. To upgrade to real sound
/// effects:
///   1. Add the `audioplayers` package to pubspec.yaml.
///   2. Drop files into `assets/audio/` (e.g. `slash.mp3`, `slice.mp3`,
///      `juice.mp3`, `explosion.mp3`, `button.mp3`, `victory.mp3`) and
///      register them under `flutter: assets:`.
///   3. Replace each method body below with, e.g.:
///        await AudioPlayer().play(AssetSource('audio/slash.mp3'));
/// Every call site elsewhere in the game stays exactly the same.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  Future<void> playButtonTap() async {
    await HapticFeedback.selectionClick();
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCutSwipe() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> playFruitSlice() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> playJuiceSplash() async {
    // Reserved for a dedicated splash sound once real assets are wired up.
  }

  Future<void> playExplosion() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> playVictoryFanfare() async {
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
  }
}

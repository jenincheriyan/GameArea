import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  final AudioPlayer _player = AudioPlayer();

  bool musicEnabled = true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    musicEnabled = prefs.getBool('music_enabled') ?? true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.3); // Set default volume
    if (musicEnabled) {
      playMusic();
    }
  }

  Future<void> playMusic() async {
    if (!musicEnabled) return;
    await _player.play(
      AssetSource('audio/bgm.mp3'),
    );
  }

  Future<void> stopMusic() async {
    await _player.stop();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', enabled);

    if (enabled) {
      playMusic();
    } else {
      stopMusic();
    }
  }
}
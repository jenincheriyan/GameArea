import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

/// Opens the settings bottom sheet. Call this from any screen's
/// settings button — it's the single shared entry point so One Player
/// and Two Player (and anywhere else, later) all get the same sheet.
void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late bool _musicEnabled = AudioManager.instance.musicEnabled;

  void _toggleMusic(bool value) {
    setState(() => _musicEnabled = value);
    AudioManager.instance.setMusicEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _musicEnabled ? Icons.music_note : Icons.music_off,
                    color: const Color(0xFF6EE7A0),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Music',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: _musicEnabled,
                    activeColor: const Color(0xFF6EE7A0),
                    onChanged: _toggleMusic,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

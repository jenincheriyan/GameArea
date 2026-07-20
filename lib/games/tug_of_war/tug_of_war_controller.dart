import 'package:flutter/foundation.dart';

/// Drives a local two-player Tug of War match. [ropePosition] ranges
/// from -1.0 (fully pulled to player 2's side) to 1.0 (fully pulled to
/// player 1's side), starting at 0 (center). Every tap nudges the rope
/// toward the tapping player; first to push it to +-1.0 wins.
class TugOfWarController extends ChangeNotifier {
  static const double _tapPower = 0.045;
  static const double winThreshold = 1.0;

  double ropePosition = 0;
  int player1Taps = 0;
  int player2Taps = 0;
  int? winner;

  bool _disposed = false;

  void start() {
    ropePosition = 0;
    player1Taps = 0;
    player2Taps = 0;
    winner = null;
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void tapPlayer1() {
    if (winner != null) return;
    player1Taps++;
    ropePosition = (ropePosition + _tapPower).clamp(-winThreshold, winThreshold);
    _checkWinner();
    _safeNotify();
  }

  void tapPlayer2() {
    if (winner != null) return;
    player2Taps++;
    ropePosition = (ropePosition - _tapPower).clamp(-winThreshold, winThreshold);
    _checkWinner();
    _safeNotify();
  }

  void _checkWinner() {
    if (ropePosition >= winThreshold) {
      winner = 1;
    } else if (ropePosition <= -winThreshold) {
      winner = 2;
    }
  }
}

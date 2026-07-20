import 'ludo_models.dart';

/// Picks which of the AI's movable tokens to play, given the roll.
/// Priority: capture an opponent if possible, then get a token out of
/// the yard, then push the most advanced token further (closest to
/// finishing), else just take the first legal move.
class LudoAi {
  int chooseMove({
    required List<LudoToken> aiTokens,
    required List<int> movableIndices,
    required int roll,
    required LudoColor aiColor,
    required List<List<LudoToken>> allTokensByPlayer,
    required List<LudoColor> colorsInOrder,
  }) {
    assert(movableIndices.isNotEmpty);

    int? captureMove = _findCaptureMove(
      aiTokens: aiTokens,
      movableIndices: movableIndices,
      roll: roll,
      aiColor: aiColor,
      allTokensByPlayer: allTokensByPlayer,
      colorsInOrder: colorsInOrder,
    );
    if (captureMove != null) return captureMove;

    final exitMove = movableIndices.firstWhere(
      (i) => aiTokens[i].isInYard,
      orElse: () => -1,
    );
    if (exitMove != -1) return exitMove;

    // Otherwise advance whichever movable token is furthest along.
    movableIndices.sort(
      (a, b) => aiTokens[b].progress.compareTo(aiTokens[a].progress),
    );
    return movableIndices.first;
  }

  int? _findCaptureMove({
    required List<LudoToken> aiTokens,
    required List<int> movableIndices,
    required int roll,
    required LudoColor aiColor,
    required List<List<LudoToken>> allTokensByPlayer,
    required List<LudoColor> colorsInOrder,
  }) {
    for (final i in movableIndices) {
      final token = aiTokens[i];
      if (token.isInYard) continue;
      final newProgress = token.progress + roll;
      if (newProgress > 50) continue; // home stretch — no captures there
      final absCell = (aiColor.entryIndex + newProgress) % LudoBoard.ringLength;
      if (LudoBoard.safeCells.contains(absCell)) continue;

      for (var p = 0; p < colorsInOrder.length; p++) {
        if (colorsInOrder[p] == aiColor) continue;
        for (final opponentToken in allTokensByPlayer[p]) {
          if (opponentToken.isInYard || opponentToken.progress > 50) continue;
          final opponentAbsCell =
              (colorsInOrder[p].entryIndex + opponentToken.progress) % LudoBoard.ringLength;
          if (opponentAbsCell == absCell) return i;
        }
      }
    }
    return null;
  }
}

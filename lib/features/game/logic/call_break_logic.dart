import 'package:myapp/features/game/models/card.dart';
import 'package:myapp/features/game/models/game_state.dart';

/// Pure logic for Call Break game rules
class CallBreakLogic {
  /// Determine who wins the trick
  static String determineTrickWinner(Trick trick) {
    if (trick.cards.isEmpty) throw Exception('Trick cannot be empty');
    
    PlayedCard winningCard = trick.cards.first;
    
    for (var playedCard in trick.cards.skip(1)) {
      final comparison = playedCard.card.compareTo(
        winningCard.card,
        trumpSuit, // Spades are always trump in Call Break
        trick.ledSuit,
      );
      if (comparison > 0) {
        winningCard = playedCard;
      }
    }
    
    return winningCard.playerId;
  }

  /// Calculate scores for a round
  static Map<String, double> calculateRoundScores({
    required Map<String, int> bids,
    required Map<String, int> tricksWon,
    required double pointValue,
  }) {
    final roundScores = <String, double>{};
    
    bids.forEach((playerId, bidAmount) {
      final tricksActual = tricksWon[playerId] ?? 0;

      double score;
      if (tricksActual >= bidAmount) {
        // Made bid: get bid amount + bonus for extra tricks
        score = (bidAmount + (tricksActual - bidAmount) * 0.1) * pointValue;
      } else {
        // Failed bid: negative bid amount
        score = -(bidAmount * pointValue);
      }
      roundScores[playerId] = score;
    });
    
    return roundScores;
  }

  /// Get next player in rotation
  static String getNextPlayer(List<String> playerIds, String currentPlayerId) {
    final currentIndex = playerIds.indexOf(currentPlayerId);
    if (currentIndex == -1) throw Exception('Player not found in list');
    return playerIds[(currentIndex + 1) % playerIds.length];
  }
}

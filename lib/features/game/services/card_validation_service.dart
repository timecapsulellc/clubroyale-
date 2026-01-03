import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/models/game_state.dart';

/// Service for validating card plays according to Call Break rules
class CardValidationService {
  /// Check if a card can be played given the current trick and hand
  static bool canPlayCard(
    PlayingCard card,
    List<PlayingCard> hand,
    Trick? currentTrick,
  ) {
    // Must have the card in hand
    if (!hand.any((c) => c.id == card.id)) {
      return false;
    }

    // If leading (first card of trick), any card is valid
    if (currentTrick == null || currentTrick.cards.isEmpty) {
      return true;
    }

    final ledSuit = currentTrick.ledSuit;

    // Must follow suit if possible
    if (mustFollowSuit(hand, ledSuit)) {
      return card.suit == ledSuit;
    }

    // If can't follow suit, any card is valid
    return true;
  }

  /// Check if player must follow the led suit
  static bool mustFollowSuit(List<PlayingCard> hand, CardSuit ledSuit) {
    return hand.any((card) => card.suit == ledSuit);
  }

  /// Get all valid cards that can be played
  static List<PlayingCard> getValidCards(
    List<PlayingCard> hand,
    Trick? currentTrick,
  ) {
    // If leading, all cards are valid
    if (currentTrick == null || currentTrick.cards.isEmpty) {
      return List.from(hand);
    }

    final ledSuit = currentTrick.ledSuit;

    // If player has cards of led suit, must play one
    final ledSuitCards = hand.where((card) => card.suit == ledSuit).toList();
    if (ledSuitCards.isNotEmpty) {
      return ledSuitCards;
    }

    // If no cards of led suit, can play any card
    return List.from(hand);
  }

  /// Check if a bid is valid (1-13)
  static bool isValidBid(int amount) {
    return amount >= 1 && amount <= 13;
  }

  /// Get suggested bid based on hand strength
  static int suggestBid(List<PlayingCard> hand) {
    int strength = 0;

    // Count high cards
    final spades = hand.where((c) => c.suit == CardSuit.spades).toList();
    final highSpades = spades
        .where((c) => c.rank.value >= 11)
        .length; // J, Q, K, A
    strength += highSpades * 2; // Spades worth more (trump)

    // Count aces and kings in other suits
    final otherSuits = hand.where((c) => c.suit != CardSuit.spades).toList();
    final highCards = otherSuits
        .where((c) => c.rank.value >= 13)
        .length; // K, A
    strength += highCards;

    // Estimate bid (conservative)
    if (strength >= 10) return 7;
    if (strength >= 8) return 6;
    if (strength >= 6) return 5;
    if (strength >= 4) return 4;
    if (strength >= 3) return 3;
    if (strength >= 2) return 2;
    return 1;
  }
}

import 'package:clubroyale/core/models/playing_card.dart';

/// Deck of 52 playing cards
class Deck {
  /// Generate a complete deck of 52 cards
  static List<PlayingCard> generateDeck() {
    final cards = <PlayingCard>[];

    for (final suit in CardSuit.values) {
      for (final rank in CardRank.values) {
        cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }

    return cards;
  }

  /// Shuffle the deck
  static List<PlayingCard> shuffle(List<PlayingCard> cards) {
    final shuffled = List<PlayingCard>.from(cards);
    shuffled.shuffle();
    return shuffled;
  }

  /// Deal cards to 4 players (13 cards each)
  static Map<String, List<PlayingCard>> dealHands(
    List<String> playerIds,
  ) {
    if (playerIds.length != 4) {
      throw ArgumentError('Call Break requires exactly 4 players');
    }

    final deck = shuffle(generateDeck());
    final hands = <String, List<PlayingCard>>{};

    for (int i = 0; i < 4; i++) {
      final playerId = playerIds[i];
      final hand = deck.sublist(i * 13, (i + 1) * 13);
      // Sort hand by suit and rank for better UX
      hand.sort((a, b) {
        final suitCompare = a.suit.index.compareTo(b.suit.index);
        if (suitCompare != 0) return suitCompare;
        return b.rank.value.compareTo(a.rank.value); // Descending rank
      });
      hands[playerId] = hand;
    }

    return hands;
  }

  /// Serialize a card list to JSON
  static List<Map<String, dynamic>> serializeHand(List<PlayingCard> hand) {
    return hand.map((card) => card.toJson()).toList();
  }

  /// Deserialize a card list from JSON
  static List<PlayingCard> deserializeHand(List<dynamic> json) {
    return json
        .cast<Map<String, dynamic>>()
        .map((cardJson) => PlayingCard.fromJson(cardJson))
        .toList();
  }
}

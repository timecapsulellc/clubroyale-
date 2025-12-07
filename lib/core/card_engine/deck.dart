/// Deck - A pile of cards representing a game deck
/// 
/// Supports single deck (52 cards), double deck (104), triple deck (156)
/// Based on gin_rummy Deck pattern

import 'pile.dart';

/// Deck configuration
enum DeckConfig {
  single(1, false),    // 52 cards, no jokers
  double(2, false),    // 104 cards, no jokers
  triple(3, true),     // 156 cards + 6 jokers (for Marriage 2-5 players)
  quadruple(4, true);  // 208 cards + 8 jokers (for Marriage 6-8 players)
  
  final int deckCount;
  final bool includeJokers;
  
  const DeckConfig(this.deckCount, this.includeJokers);
}

/// A deck of playing cards
class Deck extends Pile {
  final DeckConfig config;
  
  Deck({this.config = DeckConfig.single}) {
    _initialize();
  }
  
  /// Create a standard 52-card deck
  factory Deck.standard() => Deck(config: DeckConfig.single);
  
  /// Create a double deck (104 cards) for games like Canasta
  factory Deck.double() => Deck(config: DeckConfig.double);
  
  /// Create a triple deck for Marriage (156 cards + jokers)
  /// Use [deckCount] parameter for 6-8 players (4 decks needed)
  factory Deck.forMarriage({int deckCount = 3}) {
    if (deckCount >= 4) {
      return Deck(config: DeckConfig.quadruple);
    }
    return Deck(config: DeckConfig.triple);
  }
  
  void _initialize() {
    clear();
    
    for (int deckIndex = 0; deckIndex < config.deckCount; deckIndex++) {
      // Add all standard cards
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          addCard(Card(rank: rank, suit: suit, deckIndex: deckIndex));
        }
      }
      
      // Add jokers if configured
      if (config.includeJokers) {
        addCard(Card.joker(deckIndex * 2));
        addCard(Card.joker(deckIndex * 2 + 1));
      }
    }
  }
  
  /// Reset and shuffle the deck
  void reset() {
    _initialize();
    shuffle();
  }
  
  /// Deal cards to multiple hands
  List<List<Card>> deal(int playerCount, int cardsPerPlayer) {
    final hands = List.generate(playerCount, (_) => <Card>[]);
    
    for (int c = 0; c < cardsPerPlayer; c++) {
      for (int p = 0; p < playerCount; p++) {
        final card = drawCard();
        if (card != null) {
          hands[p].add(card);
        }
      }
    }
    
    return hands;
  }
}

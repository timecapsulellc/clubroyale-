/// Pile - Base class for a collection of cards (from gin_rummy pattern)
/// 
/// This is the foundation for Deck, Hand, and DiscardPile
library;

import 'dart:math' as math;

/// Represents a playing card suit
enum Suit {
  spades('♠', false),
  hearts('♥', true),
  diamonds('♦', true),
  clubs('♣', false);
  
  final String symbol;
  final bool isRed;
  
  const Suit(this.symbol, this.isRed);
}

/// Represents a playing card rank
enum Rank {
  ace(1, 'A'),
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5'),
  six(6, '6'),
  seven(7, '7'),
  eight(8, '8'),
  nine(9, '9'),
  ten(10, '10'),
  jack(11, 'J'),
  queen(12, 'Q'),
  king(13, 'K');
  
  final int value;
  final String symbol;
  
  const Rank(this.value, this.symbol);
  
  /// Point value for Marriage scoring (face cards = 10)
  int get points => value >= 10 ? 10 : value;
}

/// A playing card with rank, suit, and deck index for multi-deck games
class Card {
  final Rank rank;
  final Suit suit;
  final int deckIndex; // 0, 1, or 2 for triple deck games
  final bool isJoker;
  
  const Card({
    required this.rank,
    required this.suit,
    this.deckIndex = 0,
    this.isJoker = false,
  });
  
  /// Private constructor for joker
  const Card._joker(this.deckIndex)
      : rank = Rank.ace,
        suit = Suit.spades,
        isJoker = true;
  
  /// Unique identifier for this specific card instance
  String get id => isJoker ? 'joker_$deckIndex' : '${rank.symbol}${suit.symbol}_$deckIndex';
  
  /// Display name (e.g., "A♠" or "Joker")
  String get displayName => isJoker ? '🃏' : '${rank.symbol}${suit.symbol}';
  
  /// Asset path for card image
  String get assetPath => isJoker 
      ? 'assets/cards/png/joker.png' 
      : 'assets/cards/png/${rank.symbol.toLowerCase()}_of_${suit.name}.png';
  
  /// Create a joker card
  factory Card.joker([int deckIndex = 0]) => Card._joker(deckIndex);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          rank == other.rank &&
          suit == other.suit &&
          deckIndex == other.deckIndex;
  
  @override
  int get hashCode => Object.hash(rank, suit, deckIndex);
  
  @override
  String toString() => displayName;
}

/// Base pile of cards - foundation for Deck, Hand, DiscardPile
class Pile {
  final List<Card> _cards = [];
  
  /// Current cards in the pile
  List<Card> get cards => List.unmodifiable(_cards);
  
  /// Number of cards in the pile
  int get length => _cards.length;
  
  /// Is the pile empty?
  bool get isEmpty => _cards.isEmpty;
  
  /// Is the pile not empty?
  bool get isNotEmpty => _cards.isNotEmpty;
  
  /// Add a card to the top of the pile
  void addCard(Card card) => _cards.add(card);
  
  /// Add multiple cards to the pile
  void addCards(List<Card> cards) => _cards.addAll(cards);
  
  /// Remove and return the top card
  Card? drawCard() => _cards.isNotEmpty ? _cards.removeLast() : null;
  
  /// Draw multiple cards from the top
  List<Card> drawCards(int count) {
    final drawn = <Card>[];
    for (int i = 0; i < count && _cards.isNotEmpty; i++) {
      drawn.add(_cards.removeLast());
    }
    return drawn;
  }
  
  /// Peek at the top card without removing it
  Card? get topCard => _cards.isNotEmpty ? _cards.last : null;
  
  /// Remove a specific card from the pile
  bool removeCard(Card card) => _cards.remove(card);
  
  /// Shuffle the pile
  void shuffle() {
    final random = math.Random();
    for (int i = _cards.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }
  }
  
  /// Clear all cards from the pile
  void clear() => _cards.clear();
}

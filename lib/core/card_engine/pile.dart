/// Pile - Base class for a collection of cards
/// 
/// This is the foundation for Deck, Hand, and DiscardPile
library;

import 'dart:math' as math;
import 'package:clubroyale/core/models/playing_card.dart';

// Export PlayingCard so consumers only need to import pile/deck/game
export 'package:clubroyale/core/models/playing_card.dart';

// Compatibility Layer
typedef Card = PlayingCard;
typedef Rank = CardRank;
typedef Suit = CardSuit;

/// Base pile of cards - foundation for Deck, Hand, DiscardPile
class Pile {
  final List<PlayingCard> _cards = [];
  
  /// Current cards in the pile
  List<PlayingCard> get cards => List.unmodifiable(_cards);
  
  /// Number of cards in the pile
  int get length => _cards.length;
  
  /// Is the pile empty?
  bool get isEmpty => _cards.isEmpty;
  
  /// Is the pile not empty?
  bool get isNotEmpty => _cards.isNotEmpty;
  
  /// Add a card to the top of the pile
  void addCard(PlayingCard card) => _cards.add(card);
  
  /// Add multiple cards to the pile
  void addCards(List<PlayingCard> cards) => _cards.addAll(cards);
  
  /// Remove and return the top card
  PlayingCard? drawCard() => _cards.isNotEmpty ? _cards.removeLast() : null;
  
  /// Draw multiple cards from the top
  List<PlayingCard> drawCards(int count) {
    final drawn = <PlayingCard>[];
    for (int i = 0; i < count && _cards.isNotEmpty; i++) {
      drawn.add(_cards.removeLast());
    }
    return drawn;
  }
  
  /// Peek at the top card without removing it
  PlayingCard? get topCard => _cards.isNotEmpty ? _cards.last : null;
  
  /// Remove a specific card from the pile
  bool removeCard(PlayingCard card) => _cards.remove(card);
  
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

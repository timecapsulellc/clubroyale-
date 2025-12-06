/// PlayerStrategy - Abstract interface for bot AI
/// 
/// Based on gin_rummy PlayerStrategy pattern
/// Allows different difficulty levels and play styles

import 'pile.dart';

/// A player's hand of cards
class Hand extends Pile {
  /// Sort the hand by suit, then by rank
  void sortBySuit() {
    final sorted = List<Card>.from(cards)
      ..sort((a, b) {
        final suitCompare = a.suit.index.compareTo(b.suit.index);
        if (suitCompare != 0) return suitCompare;
        return a.rank.value.compareTo(b.rank.value);
      });
    clear();
    addCards(sorted);
  }
  
  /// Sort the hand by rank, then by suit
  void sortByRank() {
    final sorted = List<Card>.from(cards)
      ..sort((a, b) {
        final rankCompare = a.rank.value.compareTo(b.rank.value);
        if (rankCompare != 0) return rankCompare;
        return a.suit.index.compareTo(b.suit.index);
      });
    clear();
    addCards(sorted);
  }
}

/// Abstract interface for bot strategies
abstract class PlayerStrategy {
  /// Name of this strategy for display
  String get name;
  
  /// Difficulty level (1-5)
  int get difficulty;
  
  /// Select which card to discard from hand
  Card selectCardToDiscard(Hand hand, List<Card> discardPile, {Card? tiplu});
  
  /// Should we draw from the discard pile instead of deck?
  bool shouldDrawFromDiscard(Card topDiscard, Hand hand, {Card? tiplu});
  
  /// Should we declare/show our hand? (Marriage/Rummy)
  bool shouldDeclare(Hand hand, {Card? tiplu});
}

/// Random strategy - plays randomly (difficulty 1)
class RandomStrategy implements PlayerStrategy {
  @override
  String get name => 'Random Bot';
  
  @override
  int get difficulty => 1;
  
  @override
  Card selectCardToDiscard(Hand hand, List<Card> discardPile, {Card? tiplu}) {
    // Just pick a random card
    if (hand.isEmpty) throw StateError('Cannot discard from empty hand');
    final randomIndex = DateTime.now().millisecondsSinceEpoch % hand.length;
    return hand.cards[randomIndex];
  }
  
  @override
  bool shouldDrawFromDiscard(Card topDiscard, Hand hand, {Card? tiplu}) {
    // 30% chance to draw from discard
    return DateTime.now().millisecondsSinceEpoch % 10 < 3;
  }
  
  @override
  bool shouldDeclare(Hand hand, {Card? tiplu}) {
    // Never declares (too random to win)
    return false;
  }
}

/// Conservative strategy - minimizes points, plays safe (difficulty 3)
class ConservativeStrategy implements PlayerStrategy {
  @override
  String get name => 'Conservative Bot';
  
  @override
  int get difficulty => 3;
  
  @override
  Card selectCardToDiscard(Hand hand, List<Card> discardPile, {Card? tiplu}) {
    // Discard highest point card not in a potential meld
    final sorted = List<Card>.from(hand.cards)
      ..sort((a, b) => b.rank.points.compareTo(a.rank.points));
    return sorted.first;
  }
  
  @override
  bool shouldDrawFromDiscard(Card topDiscard, Hand hand, {Card? tiplu}) {
    // Only draw if it completes a meld potential
    // Simple heuristic: draw if we have another card of same rank
    return hand.cards.any((c) => c.rank == topDiscard.rank);
  }
  
  @override
  bool shouldDeclare(Hand hand, {Card? tiplu}) {
    // Declare if total points < 5
    final points = hand.cards.fold<int>(0, (sum, c) => sum + c.rank.points);
    return points < 5;
  }
}

/// Aggressive strategy - tries to complete melds quickly (difficulty 4)
class AggressiveStrategy implements PlayerStrategy {
  @override
  String get name => 'Aggressive Bot';
  
  @override
  int get difficulty => 4;
  
  @override
  Card selectCardToDiscard(Hand hand, List<Card> discardPile, {Card? tiplu}) {
    // Discard cards that don't fit any potential meld
    final cards = List<Card>.from(hand.cards);
    
    // Group by rank and suit
    final rankCounts = <Rank, int>{};
    final suitCounts = <Suit, int>{};
    
    for (final card in cards) {
      rankCounts[card.rank] = (rankCounts[card.rank] ?? 0) + 1;
      suitCounts[card.suit] = (suitCounts[card.suit] ?? 0) + 1;
    }
    
    // Find the most "isolated" card
    cards.sort((a, b) {
      final aScore = (rankCounts[a.rank] ?? 0) + (suitCounts[a.suit] ?? 0) / 2;
      final bScore = (rankCounts[b.rank] ?? 0) + (suitCounts[b.suit] ?? 0) / 2;
      return aScore.compareTo(bScore);
    });
    
    return cards.first;
  }
  
  @override
  bool shouldDrawFromDiscard(Card topDiscard, Hand hand, {Card? tiplu}) {
    // Draw if it helps form a meld
    final sameRank = hand.cards.where((c) => c.rank == topDiscard.rank).length;
    final sameSuit = hand.cards.where((c) => c.suit == topDiscard.suit).length;
    
    return sameRank >= 2 || sameSuit >= 3;
  }
  
  @override
  bool shouldDeclare(Hand hand, {Card? tiplu}) {
    // Declare more aggressively
    final points = hand.cards.fold<int>(0, (sum, c) => sum + c.rank.points);
    return points < 10;
  }
}

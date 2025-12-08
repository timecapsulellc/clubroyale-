// Enhanced Heuristic Engine
//
// Fast local AI for routine card game decisions.
// Chief Architect: Use for 90% of moves to save on GenKit costs.

import 'package:taasclub/core/card_engine/card.dart';

/// Bot move result
class BotMove {
  final String action; // 'playCard', 'bid', 'draw', 'discard', 'declare'
  final String? cardId;
  final List<String>? cardIds;
  final int? bidValue;
  final String reasoning;
  final bool usedGenKit;
  
  BotMove({
    required this.action,
    this.cardId,
    this.cardIds,
    this.bidValue,
    required this.reasoning,
    this.usedGenKit = false,
  });

  Map<String, dynamic> toJson() => {
    'action': action,
    'cardId': cardId,
    'cardIds': cardIds,
    'bidValue': bidValue,
    'reasoning': reasoning,
    'usedGenKit': usedGenKit,
  };
}

/// Local heuristic engine for fast AI decisions
class HeuristicEngine {
  
  /// Calculate move for Call Break
  BotMove callBreakMove({
    required List<Card> hand,
    required List<Card>? currentTrick,
    required String? leadSuit,
    required int myBid,
    required int myTricks,
    required String difficulty,
  }) {
    final validCards = _getValidCards(hand, leadSuit);
    
    if (validCards.isEmpty) {
      return BotMove(
        action: 'playCard',
        cardId: hand.first.id,
        reasoning: 'No valid cards, playing first',
      );
    }
    
    // Leading the trick
    if (currentTrick == null || currentTrick.isEmpty) {
      if (myTricks >= myBid) {
        // Already made bid, play lowest
        final lowest = _getLowestCard(validCards);
        return BotMove(
          action: 'playCard',
          cardId: lowest.id,
          reasoning: 'Made bid, playing low to avoid overbid penalty',
        );
      } else {
        // Need tricks, lead with high non-trump
        final nonTrump = validCards.where((c) => c.suit != Suit.spades).toList();
        if (nonTrump.isNotEmpty) {
          final highest = _getHighestCard(nonTrump);
          return BotMove(
            action: 'playCard',
            cardId: highest.id,
            reasoning: 'Need tricks, leading high non-trump',
          );
        }
        // Only trumps, lead lowest
        final lowest = _getLowestCard(validCards);
        return BotMove(
          action: 'playCard',
          cardId: lowest.id,
          reasoning: 'Only trumps, leading lowest',
        );
      }
    }
    
    // Following a trick
    final currentWinner = _getCurrentTrickWinner(currentTrick, leadSuit!);
    final canWin = validCards.any((c) => _beats(c, currentWinner, leadSuit));
    
    if (myTricks < myBid && canWin) {
      // Need tricks and can win
      final winningCards = validCards.where((c) => _beats(c, currentWinner, leadSuit)).toList();
      final lowestWinner = _getLowestCard(winningCards);
      return BotMove(
        action: 'playCard',
        cardId: lowestWinner.id,
        reasoning: 'Need tricks, playing to win',
      );
    } else {
      // Don't need tricks or can't win
      final lowest = _getLowestCard(validCards);
      return BotMove(
        action: 'playCard',
        cardId: lowest.id,
        reasoning: 'Playing lowest valid card',
      );
    }
  }
  
  /// Calculate move for Marriage game
  BotMove marriageMove({
    required List<Card> hand,
    required Card? topDiscard,
    required Card? tiplu,
    required String phase, // 'drawing', 'discarding'
  }) {
    if (phase == 'drawing') {
      // Check if discard would complete a meld
      if (topDiscard != null && _completesAnyMeld(topDiscard, hand)) {
        return BotMove(
          action: 'drawDiscard',
          reasoning: 'Discard completes a meld',
        );
      }
      return BotMove(
        action: 'drawDeck',
        reasoning: 'Drawing from deck (unknown cards better)',
      );
    }
    
    // Discarding phase
    final deadwood = _getDeadwoodCards(hand, tiplu);
    
    if (deadwood.isNotEmpty) {
      // Discard highest point deadwood
      final highest = _getHighestPointCard(deadwood);
      return BotMove(
        action: 'discard',
        cardId: highest.id,
        reasoning: 'Discarding highest deadwood (${highest.rank.points} points)',
      );
    }
    
    // No deadwood, discard least useful card
    final leastUseful = _getLeastUsefulCard(hand, tiplu);
    return BotMove(
      action: 'discard',
      cardId: leastUseful.id,
      reasoning: 'Discarding least useful card',
    );
  }
  
  /// Calculate bid for Call Break
  BotMove calculateBid({
    required List<Card> hand,
    required String difficulty,
  }) {
    int bid = 0;
    
    // Count high cards
    final highCards = hand.where((c) => c.rank.value >= 11).length;
    bid += (highCards * 0.7).floor();
    
    // Count trump cards (spades)
    final trumps = hand.where((c) => c.suit == Suit.spades).length;
    bid += (trumps * 0.8).floor();
    
    // Minimum bid is 1
    bid = bid.clamp(1, 8);
    
    // Adjust by difficulty
    if (difficulty == 'easy') {
      bid = (bid * 0.8).floor().clamp(1, 8);
    } else if (difficulty == 'hard' || difficulty == 'expert') {
      // More accurate bidding
      bid = _calculateAccurateBid(hand);
    }
    
    return BotMove(
      action: 'bid',
      bidValue: bid,
      reasoning: 'Calculated bid based on hand strength',
    );
  }
  
  int _calculateAccurateBid(List<Card> hand) {
    int expectedTricks = 0;
    
    // Group by suit
    final suits = <Suit, List<Card>>{};
    for (final card in hand) {
      suits.putIfAbsent(card.suit, () => []).add(card);
    }
    
    // Count sure tricks in trumps
    final trumps = suits[Suit.spades] ?? [];
    trumps.sort((a, b) => b.rank.value.compareTo(a.rank.value));
    
    // High trumps are sure tricks
    for (int i = 0; i < trumps.length && i < 3; i++) {
      if (trumps[i].rank.value >= 12) { // Q, K, A
        expectedTricks++;
      }
    }
    
    // Count sure tricks in other suits
    for (final entry in suits.entries) {
      if (entry.key == Suit.spades) continue;
      final suitCards = entry.value;
      suitCards.sort((a, b) => b.rank.value.compareTo(a.rank.value));
      
      // Aces are likely tricks
      if (suitCards.isNotEmpty && suitCards.first.rank == Rank.ace) {
        expectedTricks++;
      }
    }
    
    // Add for short suits (can trump)
    final shortSuits = suits.entries.where((e) => 
      e.key != Suit.spades && e.value.length <= 2
    ).length;
    expectedTricks += (shortSuits * 0.5 * trumps.length).floor();
    
    return expectedTricks.clamp(1, 8);
  }
  
  // ============ Helper Methods ============
  
  List<Card> _getValidCards(List<Card> hand, String? leadSuit) {
    if (leadSuit == null) return hand;
    
    final suit = Suit.values.firstWhere(
      (s) => s.name == leadSuit.toLowerCase(),
      orElse: () => Suit.hearts,
    );
    
    final suitCards = hand.where((c) => c.suit == suit).toList();
    return suitCards.isNotEmpty ? suitCards : hand;
  }
  
  Card _getLowestCard(List<Card> cards) {
    return cards.reduce((a, b) => a.rank.value < b.rank.value ? a : b);
  }
  
  Card _getHighestCard(List<Card> cards) {
    return cards.reduce((a, b) => a.rank.value > b.rank.value ? a : b);
  }
  
  Card _getCurrentTrickWinner(List<Card> trick, String leadSuit) {
    final suit = Suit.values.firstWhere(
      (s) => s.name == leadSuit.toLowerCase(),
      orElse: () => Suit.hearts,
    );
    
    Card winner = trick.first;
    for (final card in trick.skip(1)) {
      if (_beats(card, winner, leadSuit)) {
        winner = card;
      }
    }
    return winner;
  }
  
  bool _beats(Card card, Card other, String leadSuit) {
    // Trump beats non-trump
    if (card.suit == Suit.spades && other.suit != Suit.spades) return true;
    if (card.suit != Suit.spades && other.suit == Suit.spades) return false;
    
    // Same suit: higher rank wins
    if (card.suit == other.suit) {
      return card.rank.value > other.rank.value;
    }
    
    // Different non-trump suits: lead suit wins
    final lead = Suit.values.firstWhere(
      (s) => s.name == leadSuit.toLowerCase(),
      orElse: () => Suit.hearts,
    );
    if (card.suit == lead) return true;
    return false;
  }
  
  bool _completesAnyMeld(Card card, List<Card> hand) {
    // Check if card would complete a set (3+ same rank)
    final sameRank = hand.where((c) => c.rank == card.rank).length;
    if (sameRank >= 2) return true;
    
    // Check if card would complete a run (3+ consecutive same suit)
    final sameSuit = hand.where((c) => c.suit == card.suit).toList();
    sameSuit.add(card);
    sameSuit.sort((a, b) => a.rank.value.compareTo(b.rank.value));
    
    int consecutive = 1;
    for (int i = 1; i < sameSuit.length; i++) {
      if (sameSuit[i].rank.value == sameSuit[i-1].rank.value + 1) {
        consecutive++;
        if (consecutive >= 3) return true;
      } else if (sameSuit[i].rank.value != sameSuit[i-1].rank.value) {
        consecutive = 1;
      }
    }
    
    return false;
  }
  
  List<Card> _getDeadwoodCards(List<Card> hand, Card? tiplu) {
    return hand.where((card) {
      // Tiplu (wild card) is never deadwood
      if (tiplu != null && card.rank == tiplu.rank) return false;
      
      // Check if part of a set
      final sameRank = hand.where((c) => c.rank == card.rank).length;
      if (sameRank >= 3) return false;
      
      // Check if part of a run
      final sameSuit = hand.where((c) => c.suit == card.suit).toList();
      sameSuit.sort((a, b) => a.rank.value.compareTo(b.rank.value));
      
      final cardIndex = sameSuit.indexWhere((c) => c.id == card.id);
      if (cardIndex > 0 && cardIndex < sameSuit.length - 1) {
        final prev = sameSuit[cardIndex - 1];
        final next = sameSuit[cardIndex + 1];
        if (card.rank.value == prev.rank.value + 1 && 
            next.rank.value == card.rank.value + 1) {
          return false; // Part of a run
        }
      }
      
      return true; // Deadwood
    }).toList();
  }
  
  Card _getHighestPointCard(List<Card> cards) {
    return cards.reduce((a, b) => a.rank.points > b.rank.points ? a : b);
  }
  
  Card _getLeastUsefulCard(List<Card> hand, Card? tiplu) {
    // Score each card by potential usefulness
    final scored = hand.map((card) {
      double score = 0;
      
      // Tiplu is very valuable
      if (tiplu != null && card.rank == tiplu.rank) {
        score += 100;
      }
      
      // Cards close to forming sets
      final sameRank = hand.where((c) => c.rank == card.rank).length;
      score += sameRank * 15;
      
      // Cards close to forming runs
      final sameSuit = hand.where((c) => c.suit == card.suit).toList();
      final neighbors = sameSuit.where((c) => 
        (c.rank.value - card.rank.value).abs() == 1
      ).length;
      score += neighbors * 20;
      
      // Lower point cards are less risky to keep
      score -= card.rank.points * 0.5;
      
      return MapEntry(card, score);
    }).toList();
    
    scored.sort((a, b) => a.value.compareTo(b.value));
    return scored.first.key;
  }
}

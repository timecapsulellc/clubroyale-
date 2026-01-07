/// ExpertStrategy - Advanced AI for competitive play
///
/// Uses Tree of Thoughts reasoning for optimal decision making.
/// Tracks opponent tendencies and Maal card probabilities.
library;

import 'dart:math' as math;
import 'pile.dart';
import 'meld.dart';
import 'player_strategy.dart';

/// Expert strategy - uses Tree of Thoughts reasoning (difficulty 5)
class ExpertStrategy implements PlayerStrategy {
  // Track cards that have been discarded (opponent modeling)
  final Set<String> _discardedCards = {};
  
  // Track cards seen in play (probability calculation)
  final Set<String> _seenCards = {};

  @override
  String get name => 'Expert Bot';

  @override
  int get difficulty => 5;

  /// Reset tracking for new game
  void resetTracking() {
    _discardedCards.clear();
    _seenCards.clear();
  }

  /// Record a card being discarded (for opponent modeling)
  void recordDiscard(PlayingCard card) {
    _discardedCards.add(card.id);
    _seenCards.add(card.id);
  }
  
  @override
  PlayingCard selectCardToDiscard(
    Hand hand,
    List<PlayingCard> discardPile, {
    PlayingCard? tiplu,
  }) {
    if (hand.isEmpty) throw StateError('Cannot discard from empty hand');
    
    // Tree of Thoughts: Evaluate multiple discard strategies
    final candidates = <_DiscardCandidate>[];
    
    for (final card in hand.cards) {
      final score = _evaluateDiscardCandidate(card, hand, tiplu);
      candidates.add(_DiscardCandidate(card, score));
    }
    
    // Sort by score (lower = better to discard)
    candidates.sort((a, b) => a.score.compareTo(b.score));
    
    // Return the best card to discard (lowest score = least valuable)
    return candidates.first.card;
  }

  /// Evaluate how valuable a card is to keep
  /// Lower score = less valuable = should discard
  double _evaluateDiscardCandidate(PlayingCard card, Hand hand, PlayingCard? tiplu) {
    double score = 0.0;
    
    // 1. Maal value check (DON'T discard Maal cards)
    if (tiplu != null) {
      if (card.rank == tiplu.rank && card.suit == tiplu.suit) {
        score += 100; // Tiplu - never discard
      } else if (card.suit == tiplu.suit) {
        final rankDiff = (card.rank.value - tiplu.rank.value).abs();
        if (rankDiff == 1) score += 50; // Poplu/Jhiplu
      } else if (card.rank == tiplu.rank && card.suit.isRed == tiplu.suit.isRed) {
        score += 80; // Alter
      }
    }
    
    // 2. Meld potential (count cards that work with this one)
    final sameRank = hand.cards.where((c) => c.rank == card.rank && c.id != card.id).length;
    final sameSuit = hand.cards.where((c) => c.suit == card.suit && c.id != card.id).length;
    
    // Set potential (3+ same rank)
    score += sameRank * 15;
    
    // Run potential (consecutive same suit)
    final adjacentCount = _countAdjacentCards(card, hand);
    score += adjacentCount * 20;
    
    // Tunnel potential (3 identical)
    final identical = hand.cards.where(
      (c) => c.rank == card.rank && c.suit == card.suit && c.id != card.id
    ).length;
    score += identical * 30;
    
    // 3. High card penalty (face cards harder to meld)
    if (card.rank.value >= 11) {
      score -= 5; // Slightly prefer discarding high cards if no potential
    }
    
    // 4. Already seen in discard (less likely to complete meld)
    if (_discardedCards.contains(card.id)) {
      score -= 10;
    }
    
    return score;
  }
  
  int _countAdjacentCards(PlayingCard card, Hand hand) {
    int count = 0;
    for (final other in hand.cards) {
      if (other.suit == card.suit && other.id != card.id) {
        final diff = (other.rank.value - card.rank.value).abs();
        if (diff == 1 || diff == 2) count++;
      }
    }
    return count;
  }

  @override
  bool shouldDrawFromDiscard(
    PlayingCard topDiscard,
    Hand hand, {
    PlayingCard? tiplu,
  }) {
    // Tree of Thoughts: Evaluate draw options
    
    // 1. If it's a Maal card, ALWAYS draw
    if (tiplu != null) {
      if (topDiscard.rank == tiplu.rank && topDiscard.suit == tiplu.suit) {
        return true; // Tiplu!
      }
      if (topDiscard.suit == tiplu.suit) {
        final rankDiff = (topDiscard.rank.value - tiplu.rank.value).abs();
        if (rankDiff == 1) return true; // Poplu/Jhiplu
      }
    }
    
    // 2. If it completes a meld, draw it
    final sameRank = hand.cards.where((c) => c.rank == topDiscard.rank).length;
    if (sameRank >= 2) return true; // Would complete a Set
    
    // 3. If it extends a run significantly
    final sameSuit = hand.cards.where((c) => c.suit == topDiscard.suit).toList();
    if (sameSuit.length >= 2) {
      // Check if this card fits in a sequence
      final allCards = [...sameSuit, topDiscard];
      final runMeld = RunMeld(allCards);
      if (runMeld.isValid) return true;
    }
    
    // 4. If it creates tunnel potential
    final identical = hand.cards.where(
      (c) => c.rank == topDiscard.rank && c.suit == topDiscard.suit
    ).length;
    if (identical >= 1) return true; // Tunnel potential
    
    // 5. Default: don't draw (deck is safer - no information leak)
    return false;
  }

  @override
  bool shouldDeclare(Hand hand, {PlayingCard? tiplu}) {
    // Analyze if we can form valid melds with all cards
    final melds = MeldDetector.findAllMelds(hand.cards, tiplu: tiplu);
    
    // Count cards in valid melds
    final meldedCards = <String>{};
    for (final meld in melds) {
      for (final card in meld.cards) {
        meldedCards.add(card.id);
      }
    }
    
    // Check for pure melds (required for Phase 1)
    final pureRuns = melds.where((m) => m is RunMeld).length;
    final tunnnels = melds.where((m) => m is TunnelMeld).length;
    final pureSets = melds.where((m) => m is SetMeld).length;
    
    // Marriage rules: Need 3 pure sets to "visit"
    final pureMeldCount = pureRuns + tunnnels;
    
    // If we have 3+ pure melds AND low deadwood, declare
    if (pureMeldCount >= 3) {
      final deadwood = hand.cards.where((c) => !meldedCards.contains(c.id)).length;
      if (deadwood <= 3) return true;
    }
    
    // Aggressive: If we have most cards melded
    final meldPercentage = meldedCards.length / hand.length;
    if (meldPercentage >= 0.85) return true;
    
    return false;
  }
}

/// Internal class for discard evaluation
class _DiscardCandidate {
  final PlayingCard card;
  final double score;
  
  _DiscardCandidate(this.card, this.score);
}

/// Extension to add expert analysis to MeldDetector
extension ExpertMeldAnalysis on MeldDetector {
  /// Get a score for the hand quality (higher = better)
  static double analyzeHandQuality(List<PlayingCard> hand, {PlayingCard? tiplu}) {
    double score = 0.0;
    
    final melds = MeldDetector.findAllMelds(hand, tiplu: tiplu);
    
    // Points for each meld
    for (final meld in melds) {
      if (meld is TunnelMeld) {
        score += 30; // Tunnel is very valuable
      } else if (meld is RunMeld) {
        score += 20 + (meld.cards.length - 3) * 5; // Longer runs = more points
      } else if (meld is SetMeld) {
        score += 15;
      } else if (meld is ImpureRunMeld || meld is ImpureSetMeld) {
        score += 10; // Impure melds less valuable
      }
    }
    
    // Penalty for high deadwood cards
    final meldedCardIds = melds.expand((m) => m.cards.map((c) => c.id)).toSet();
    for (final card in hand) {
      if (!meldedCardIds.contains(card.id)) {
        score -= card.rank.points * 0.5;
      }
    }
    
    return score;
  }
}

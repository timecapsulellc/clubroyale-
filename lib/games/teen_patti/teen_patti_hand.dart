/// Teen Patti Hand Rankings
/// 
/// Based on Indian card game Teen Patti (Three Patti)
/// Port from JavaScript/Python open source patterns
library;

import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/models/playing_card.dart';

/// Teen Patti hand types (highest to lowest)
enum TeenPattiHandType {
  trail,         // Three of a kind (AAA highest)
  pureSequence,  // Straight flush (same suit consecutive)
  sequence,      // Straight (different suits consecutive)
  color,         // Flush (same suit)
  pair,          // Two of a kind
  highCard,      // Nothing (highest card wins)
}

/// A Teen Patti hand (3 cards)
class TeenPattiHand {
  final List<PlayingCard> cards;
  late TeenPattiHandType type;
  late int rank;  // Numeric rank for comparison
  
  TeenPattiHand(this.cards) {
    if (cards.length != 3) {
      throw ArgumentError('Teen Patti hand must have exactly 3 cards');
    }
    _evaluateHand();
  }
  
  void _evaluateHand() {
    // Sort cards by rank (descending)
    final sorted = List<PlayingCard>.from(cards)
      ..sort((a, b) => b.rank.points.compareTo(a.rank.points));
    
    final r1 = sorted[0].rank;
    final r2 = sorted[1].rank;
    final r3 = sorted[2].rank;
    
    final s1 = sorted[0].suit;
    final s2 = sorted[1].suit;
    final s3 = sorted[2].suit;
    
    final sameSuit = s1 == s2 && s2 == s3;
    final isSequence = _isSequence(r1, r2, r3);
    final isThreeOfAKind = r1 == r2 && r2 == r3;
    final isPair = r1 == r2 || r2 == r3;
    
    // Determine hand type
    if (isThreeOfAKind) {
      type = TeenPattiHandType.trail;
      // Trail rank: 0-12 (2=0, A=12), AAA is highest
      rank = r1.points - 1;
    } else if (sameSuit && isSequence) {
      type = TeenPattiHandType.pureSequence;
      // Pure sequence rank: A-2-3 is highest (not A-K-Q), then A-K-Q, then K-Q-J...
      rank = _sequenceRank(r1, r2, r3);
    } else if (isSequence) {
      type = TeenPattiHandType.sequence;
      rank = _sequenceRank(r1, r2, r3);
    } else if (sameSuit) {
      type = TeenPattiHandType.color;
      // Color rank: compare highest, then second, then third
      rank = r1.points * 10000 + r2.points * 100 + r3.points;
    } else if (isPair) {
      type = TeenPattiHandType.pair;
      // Pair rank: pair rank * 100 + kicker
      if (r1 == r2) {
        rank = r1.points * 100 + r3.points;
      } else {
        rank = r2.points * 100 + r1.points;
      }
    } else {
      type = TeenPattiHandType.highCard;
      rank = r1.points * 10000 + r2.points * 100 + r3.points;
    }
  }
  
  bool _isSequence(CardRank r1, CardRank r2, CardRank r3) {
    final ranks = [_rankValue(r1), _rankValue(r2), _rankValue(r3)]..sort();
    
    // Check normal sequence
    if (ranks[1] == ranks[0] + 1 && ranks[2] == ranks[1] + 1) {
      return true;
    }
    
    // Check A-2-3 (A low)
    if (ranks.contains(14) && ranks.contains(2) && ranks.contains(3)) {
      return true;
    }
    
    return false;
  }
  
  int _rankValue(CardRank r) {
    // A=14, K=13, Q=12, J=11, 10-2 = 10-2
    switch (r) {
      case CardRank.ace: return 14;
      case CardRank.king: return 13;
      case CardRank.queen: return 12;
      case CardRank.jack: return 11;
      default: return r.points;
    }
  }
  
  int _sequenceRank(CardRank r1, CardRank r2, CardRank r3) {
    // A-2-3 is highest (return 15), then A-K-Q (14), K-Q-J (13), etc.
    final ranks = [_rankValue(r1), _rankValue(r2), _rankValue(r3)]..sort();
    
    // A-2-3 special case
    if (ranks.contains(14) && ranks.contains(2) && ranks.contains(3)) {
      return 15;  // Highest sequence
    }
    
    return ranks[2];  // Highest card in sequence
  }
  
  /// Compare two hands: >0 if this wins, <0 if other wins, 0 if tie
  int compareTo(TeenPattiHand other) {
    // First compare hand type (lower index = stronger)
    final typeDiff = type.index - other.type.index;
    if (typeDiff != 0) {
      return -typeDiff;  // Negative because lower index is better
    }
    
    // Same type: compare rank
    return rank - other.rank;
  }
  
  /// Get display name for hand type
  String get displayName {
    switch (type) {
      case TeenPattiHandType.trail:
        return 'Trail';
      case TeenPattiHandType.pureSequence:
        return 'Pure Sequence';
      case TeenPattiHandType.sequence:
        return 'Sequence';
      case TeenPattiHandType.color:
        return 'Color';
      case TeenPattiHandType.pair:
        return 'Pair';
      case TeenPattiHandType.highCard:
        return 'High Card';
    }
  }
  
  @override
  String toString() {
    final cardStr = cards.map((c) => c.displayString).join(', ');
    return '$displayName: $cardStr';
  }
}

/// Helper for evaluating Teen Patti hands
class TeenPattiHandEvaluator {
  /// Compare multiple hands and return the winner indices
  static List<int> findWinners(List<TeenPattiHand> hands) {
    if (hands.isEmpty) return [];
    if (hands.length == 1) return [0];
    
    var bestHand = hands[0];
    var bestIndices = [0];
    
    for (int i = 1; i < hands.length; i++) {
      final comparison = hands[i].compareTo(bestHand);
      if (comparison > 0) {
        // New winner
        bestHand = hands[i];
        bestIndices = [i];
      } else if (comparison == 0) {
        // Tie
        bestIndices.add(i);
      }
    }
    
    return bestIndices;
  }
}

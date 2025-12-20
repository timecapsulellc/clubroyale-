/// Marriage Game Scoring
/// 
/// Based on rummy-scorekeeper scoring algorithms
/// Enhanced with pure sequence, dublee, and config integration
library;

import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Score calculation for Marriage game
class MarriageScorer {
  final Card? tiplu;
  final MarriageGameConfig config;
  
  MarriageScorer({
    this.tiplu,
    this.config = const MarriageGameConfig(),
  });
  
  /// Calculate deadwood points in hand (unmelded cards)
  int calculateDeadwood(List<Card> hand) {
    int points = 0;
    
    for (final card in hand) {
      if (_isWild(card)) {
        points += 0; // Wild cards = 0 points
      } else {
        points += card.rank.points;
      }
    }
    
    return points;
  }
  
  /// Check if a card is wild (joker or tiplu/jhiplu/poplu)
  bool _isWild(Card card) {
    if (card.isJoker) return true;
    if (tiplu == null) return false;
    
    // Tiplu: exact match
    if (card.rank == tiplu!.rank && card.suit == tiplu!.suit) return true;
    
    // Jhiplu: same rank, opposite color
    if (card.rank == tiplu!.rank && card.suit.isRed != tiplu!.suit.isRed) {
      return true;
    }
    
    // Poplu: next rank up, same suit
    if (card.suit == tiplu!.suit) {
      final popluValue = tiplu!.rank.value == 13 ? 1 : tiplu!.rank.value + 1;
      if (card.rank.value == popluValue) return true;
    }
    
    return false;
  }
  
  /// Check if a run meld is a pure sequence (no wild cards)
  bool isPureSequence(Meld meld) {
    if (meld.type != MeldType.run) return false;
    
    // Check if any card in the meld is wild
    for (final card in meld.cards) {
      if (_isWild(card)) return false;
    }
    return true;
  }
  
  /// Check if hand has at least one pure sequence
  bool hasPureSequence(List<Meld> melds) {
    return melds.any((m) => isPureSequence(m));
  }
  
  /// Check for Dublee: two runs of same suit
  bool hasDublee(List<Meld> melds) {
    final runsBySuit = <Suit, int>{};
    
    for (final meld in melds) {
      if (meld.type == MeldType.run && meld.cards.isNotEmpty) {
        final suit = meld.cards.first.suit;
        runsBySuit[suit] = (runsBySuit[suit] ?? 0) + 1;
      }
    }
    
    // Dublee = at least 2 runs of same suit
    return runsBySuit.values.any((count) => count >= 2);
  }
  
  /// Count Marriage melds (K+Q pairs in melds)
  int countMarriages(List<Meld> melds) {
    int count = 0;
    for (final meld in melds) {
      if (meld.type == MeldType.marriage) {
        count++;
      } else if (meld.type == MeldType.set) {
        // Check for K+Q in same set
        final hasKing = meld.cards.any((c) => c.rank == Rank.king);
        final hasQueen = meld.cards.any((c) => c.rank == Rank.queen);
        if (hasKing && hasQueen) count++;
      }
    }
    return count;
  }
  
  /// Calculate bonus for special melds
  int calculateMeldBonus(List<Meld> melds) {
    int bonus = 0;
    
    for (final meld in melds) {
      switch (meld.type) {
        case MeldType.tunnel:
          if (config.tunnelBonus) bonus += MarriagePoints.tunnelBonus;
        case MeldType.marriage:
          if (config.marriageBonus) bonus += MarriagePoints.marriageBonus;
        case MeldType.set:
        case MeldType.run:
          // Check for K+Q marriage within melds
          if (config.marriageBonus && meld.type == MeldType.set) {
            final hasKing = meld.cards.any((c) => c.rank == Rank.king);
            final hasQueen = meld.cards.any((c) => c.rank == Rank.queen);
            if (hasKing && hasQueen) bonus += MarriagePoints.marriageBonus;
          }
      }
    }
    
    // Dublee bonus
    if (config.dubleeBonus && hasDublee(melds)) {
      bonus += MarriagePoints.dubleeBonus;
    }
    
    return bonus;
  }
  
  /// Validate if a hand can be declared
  /// Returns (isValid, errorReason)
  (bool, String?) validateDeclaration(List<Card> hand, List<Meld> melds) {
    // Check if all cards are in valid melds (MeldDetector.validateHand handles this)
    final isComplete = MeldDetector.validateHand(hand, tiplu: tiplu);
    if (!isComplete) {
      return (false, 'Not all cards form valid melds');
    }
    
    // Check for pure sequence if required
    if (config.requirePureSequence && !hasPureSequence(melds)) {
      return (false, 'Must have at least one pure sequence (no wilds)');
    }
    
    // Check for marriage if required
    if (config.requireMarriageToWin && countMarriages(melds) == 0) {
      return (false, 'Must have at least one Marriage (K+Q) meld');
    }
    
    return (true, null);
  }
  
  /// Calculate final score for a player
  /// Lower is better (like golf)
  int calculateRoundScore({
    required List<Card> hand,
    required List<Meld> melds,
    required bool isDeclarer,
    required bool isValidDeclaration,
  }) {
    if (isDeclarer) {
      if (isValidDeclaration) {
        // Winner gets bonus points subtracted
        final bonus = calculateMeldBonus(melds);
        return -bonus; // Negative = good
      } else {
        // Invalid declaration = penalty
        return config.wrongDeclarationPenalty;
      }
    } else {
      // Losers get deadwood added
      final deadwood = calculateDeadwood(hand);
      
      // Check for no life penalty
      if (config.requirePureSequence && !hasPureSequence(melds)) {
        return config.noLifePenalty;
      }
      
      // Cap at full count
      return deadwood > config.fullCountPenalty ? config.fullCountPenalty : deadwood;
    }
  }
}

/// Score result for a player
class PlayerScoreResult {
  final String playerId;
  final int score;
  final bool isDeclarer;
  final List<int> bonuses;
  final List<String> bonusReasons;
  
  PlayerScoreResult({
    required this.playerId,
    required this.score,
    required this.isDeclarer,
    this.bonuses = const [],
    this.bonusReasons = const [],
  });
  
  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'score': score,
    'isDeclarer': isDeclarer,
    'bonuses': bonuses,
    'bonusReasons': bonusReasons,
  };
}

/// Marriage point values
class MarriagePoints {
  // Card point values
  static const int ace = 1;
  static const int two = 2;
  static const int three = 3;
  static const int four = 4;
  static const int five = 5;
  static const int six = 6;
  static const int seven = 7;
  static const int eight = 8;
  static const int nine = 9;
  static const int ten = 10;
  static const int jack = 10;
  static const int queen = 10;
  static const int king = 10;
  
  // Bonus points
  static const int tunnelBonus = 50;
  static const int marriageBonus = 100;
  static const int dubleeBonus = 25; // Two sequences of same suit
  
  // Penalty points
  static const int noLifePenalty = 100; // No pure sequence
  static const int fullCountPenalty = 120; // Maximum penalty
}

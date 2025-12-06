/// Marriage Game Scoring
/// 
/// Based on rummy-scorekeeper scoring algorithms

import 'package:taasclub/core/card_engine/pile.dart';
import 'package:taasclub/core/card_engine/meld.dart';

/// Score calculation for Marriage game
class MarriageScorer {
  final Card? tiplu;
  
  MarriageScorer({this.tiplu});
  
  /// Calculate deadwood points in hand
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
  
  /// Check if a card is wild (joker or tiplu)
  bool _isWild(Card card) {
    if (card.isJoker) return true;
    if (tiplu == null) return false;
    return card.rank == tiplu!.rank && card.suit == tiplu!.suit;
  }
  
  /// Calculate bonus for special melds
  int calculateMeldBonus(List<Meld> melds) {
    int bonus = 0;
    
    for (final meld in melds) {
      switch (meld.type) {
        case MeldType.tunnel:
          bonus += 50; // Tunnel bonus
        case MeldType.marriage:
          bonus += 100; // Marriage bonus
        case MeldType.set:
        case MeldType.run:
          bonus += 0; // Regular melds no bonus
      }
    }
    
    return bonus;
  }
  
  /// Calculate final score for a round
  /// Lower is better (like golf)
  int calculateRoundScore({
    required List<Card> hand,
    required List<Meld> melds,
    required bool isDeclarer,
  }) {
    if (isDeclarer) {
      // Winner gets bonus points subtracted
      final bonus = calculateMeldBonus(melds);
      return -bonus; // Negative = good
    } else {
      // Losers get deadwood added
      return calculateDeadwood(hand);
    }
  }
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

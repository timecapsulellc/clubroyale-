/// Teen Patti Bot Strategy
/// 
/// AI-powered bot decision making for Teen Patti game
/// Includes betting, folding, sideshow, and showdown logic

import 'dart:math';
import 'package:taasclub/games/teen_patti/teen_patti_game.dart';
import 'package:taasclub/games/teen_patti/teen_patti_hand.dart';
import 'package:taasclub/core/card_engine/pile.dart';

/// Bot difficulty level
enum BotDifficulty {
  easy,    // Random decisions, plays blind often
  medium,  // Basic hand evaluation
  hard,    // Strategic play, bluffing
}

/// Teen Patti Bot Strategy
class TeenPattiBotStrategy {
  final Random _random = Random();
  final BotDifficulty difficulty;
  
  TeenPattiBotStrategy({this.difficulty = BotDifficulty.medium});
  
  // --- Decision Making ---
  
  /// Decide whether bot should see their cards (switch from blind to seen)
  bool shouldSeeCards({
    required TeenPattiPlayer player,
    required int roundNumber,
    required int potSize,
  }) {
    if (player.status != PlayerStatus.blind) return false;
    
    switch (difficulty) {
      case BotDifficulty.easy:
        // Easy bots stay blind longer, randomly see cards
        return roundNumber >= 4 || _random.nextDouble() < 0.2;
        
      case BotDifficulty.medium:
        // Medium bots see after 2-3 rounds
        return roundNumber >= 3 || _random.nextDouble() < 0.3;
        
      case BotDifficulty.hard:
        // Hard bots strategically stay blind if pot is small
        if (potSize < 50) return roundNumber >= 4;
        return roundNumber >= 2 || _random.nextDouble() < 0.4;
    }
  }
  
  /// Decide betting action: returns bet amount or -1 to fold
  int decideBetAction({
    required TeenPattiPlayer player,
    required List<Card> hand,
    required int currentBet,
    required int potSize,
    required int playersRemaining,
    required int minBet,
    required int maxBet,
  }) {
    // If player is blind, they haven't seen cards - bet based on gut feeling
    if (player.status == PlayerStatus.blind) {
      return _decideBlindBet(
        currentBet: currentBet,
        minBet: minBet,
        maxBet: maxBet,
      );
    }
    
    // Player has seen cards - evaluate hand strength
    final handStrength = evaluateHand(hand);
    
    return _decideSeenBet(
      handStrength: handStrength,
      currentBet: currentBet,
      potSize: potSize,
      playersRemaining: playersRemaining,
      minBet: minBet,
      maxBet: maxBet,
    );
  }
  
  /// Decide blind bet (haven't seen cards)
  int _decideBlindBet({
    required int currentBet,
    required int minBet,
    required int maxBet,
  }) {
    switch (difficulty) {
      case BotDifficulty.easy:
        // Easy: always min bet when blind
        return minBet;
        
      case BotDifficulty.medium:
        // Medium: sometimes raise to intimidate
        return _random.nextDouble() < 0.2 
            ? (minBet * 1.5).round().clamp(minBet, maxBet)
            : minBet;
            
      case BotDifficulty.hard:
        // Hard: strategically vary bets to confuse
        final variation = _random.nextDouble();
        if (variation < 0.6) return minBet;
        if (variation < 0.85) return (minBet * 1.5).round().clamp(minBet, maxBet);
        return (minBet * 2).clamp(minBet, maxBet);
    }
  }
  
  /// Decide seen bet (has seen cards)
  int _decideSeenBet({
    required double handStrength,
    required int currentBet,
    required int potSize,
    required int playersRemaining,
    required int minBet,
    required int maxBet,
  }) {
    // Fold thresholds
    double foldThreshold;
    switch (difficulty) {
      case BotDifficulty.easy:
        foldThreshold = 0.1; // Easy folds rarely
      case BotDifficulty.medium:
        foldThreshold = 0.25; // Medium has reasonable threshold
      case BotDifficulty.hard:
        foldThreshold = 0.35; // Hard is more conservative
    }
    
    // Decide to fold if hand is weak
    if (handStrength < foldThreshold && currentBet > minBet) {
      // Bluff chance for hard bots
      if (difficulty == BotDifficulty.hard && _random.nextDouble() < 0.15) {
        // Bluff! Bet high with weak hand
        return maxBet;
      }
      return -1; // Fold
    }
    
    // Strong hand - bet aggressively
    if (handStrength >= 0.7) {
      switch (difficulty) {
        case BotDifficulty.easy:
          return (minBet * 1.5).round().clamp(minBet, maxBet);
        case BotDifficulty.medium:
          return (minBet * 2).clamp(minBet, maxBet);
        case BotDifficulty.hard:
          // Mix up betting to avoid predictability
          if (_random.nextDouble() < 0.3) return minBet; // Slow play
          return (minBet * 2.5).round().clamp(minBet, maxBet);
      }
    }
    
    // Medium hand - standard bet
    if (handStrength >= 0.4) {
      return (minBet * 1.2).round().clamp(minBet, maxBet);
    }
    
    // Weak-ish hand - min bet or fold
    if (_random.nextDouble() < 0.3) {
      return -1; // Fold sometimes with weak hand
    }
    return minBet;
  }
  
  /// Decide whether to request sideshow
  bool shouldRequestSideshow({
    required TeenPattiPlayer player,
    required List<Card> hand,
    required TeenPattiPlayer? previousPlayer,
    required int potSize,
  }) {
    // Can only sideshow if seen and previous player is also seen
    if (player.status != PlayerStatus.seen) return false;
    if (previousPlayer == null || previousPlayer.status != PlayerStatus.seen) return false;
    
    final handStrength = evaluateHand(hand);
    
    switch (difficulty) {
      case BotDifficulty.easy:
        // Easy bots rarely request sideshow
        return handStrength >= 0.6 && _random.nextDouble() < 0.2;
        
      case BotDifficulty.medium:
        // Medium requests if hand is decent and pot is big
        return handStrength >= 0.5 && potSize > 100 && _random.nextDouble() < 0.4;
        
      case BotDifficulty.hard:
        // Hard strategically uses sideshow to eliminate players
        if (handStrength >= 0.4 && potSize > 80) {
          return _random.nextDouble() < 0.5;
        }
        return false;
    }
  }
  
  /// Decide whether to accept sideshow challenge
  bool shouldAcceptSideshow({
    required List<Card> hand,
    required int potSize,
  }) {
    final handStrength = evaluateHand(hand);
    
    switch (difficulty) {
      case BotDifficulty.easy:
        // Easy accepts most sideshows
        return _random.nextDouble() < 0.7;
        
      case BotDifficulty.medium:
        // Medium accepts if hand is decent
        return handStrength >= 0.4;
        
      case BotDifficulty.hard:
        // Hard considers pot odds
        if (handStrength >= 0.5) return true;
        if (handStrength >= 0.3 && potSize < 100) return true;
        return _random.nextDouble() < 0.3; // Sometimes bluff accept
    }
  }
  
  /// Decide whether to request showdown (only when 2 players left)
  bool shouldRequestShowdown({
    required List<Card> hand,
    required int potSize,
    required int chips,
  }) {
    final handStrength = evaluateHand(hand);
    
    // Always showdown with very strong hand
    if (handStrength >= 0.7) return true;
    
    // Consider pot size vs chips
    if (potSize > chips * 0.5 && handStrength >= 0.5) {
      return true; // Don't bleed chips
    }
    
    return _random.nextDouble() < 0.3; // Sometimes force showdown
  }
  
  // --- Hand Evaluation ---
  
  /// Evaluate hand strength (0.0 = worst, 1.0 = best)
  double evaluateHand(List<Card> cards) {
    if (cards.length != 3) return 0.0;
    
    final hand = TeenPattiHand(cards);
    
    // Map hand type to strength range
    switch (hand.type) {
      case TeenPattiHandType.trail:
        // Trail (three of a kind): 0.90 - 1.00
        return 0.90 + (hand.rank / 12) * 0.10;
        
      case TeenPattiHandType.pureSequence:
        // Pure sequence: 0.80 - 0.89
        return 0.80 + (hand.rank / 15) * 0.09;
        
      case TeenPattiHandType.sequence:
        // Sequence: 0.65 - 0.79
        return 0.65 + (hand.rank / 15) * 0.14;
        
      case TeenPattiHandType.color:
        // Color (flush): 0.50 - 0.64
        final colorRank = (hand.rank / 141412) * 0.14; // Max rank ~141412
        return 0.50 + colorRank.clamp(0.0, 0.14);
        
      case TeenPattiHandType.pair:
        // Pair: 0.25 - 0.49
        final pairRank = (hand.rank / 1414) * 0.24; // Max pair rank ~1414
        return 0.25 + pairRank.clamp(0.0, 0.24);
        
      case TeenPattiHandType.highCard:
        // High card: 0.00 - 0.24
        final highRank = (hand.rank / 141412) * 0.24;
        return highRank.clamp(0.0, 0.24);
    }
  }
  
  /// Get hand type description for display
  String getHandDescription(List<Card> cards) {
    if (cards.length != 3) return 'Invalid hand';
    final hand = TeenPattiHand(cards);
    return hand.displayName;
  }
}

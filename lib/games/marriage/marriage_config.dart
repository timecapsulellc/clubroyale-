/// Marriage Game Configuration
/// 
/// Configurable rules for Nepali Marriage (Royal Meld) game.
/// Supports multiple regional variants with toggle options.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'marriage_config.freezed.dart';
part 'marriage_config.g.dart';

/// Configuration for Marriage game rules
@freezed
abstract class MarriageGameConfig with _$MarriageGameConfig {
  const MarriageGameConfig._();
  
  const factory MarriageGameConfig({
    // === Core Rules ===
    
    /// Joker Block Rule: When a Joker is discarded, next player 
    /// CANNOT pick from discard pile, must draw from deck.
    @Default(true) bool jokerBlocksDiscard,
    
    /// Wild Card Pickup: If false, players cannot pick Tiplu/Jhiplu/Poplu
    /// from discard pile.
    @Default(false) bool canPickupWildFromDiscard,
    
    /// Pure Sequence Required: Must have at least one pure sequence
    /// (no wilds) to declare. "No Life" penalty applies otherwise.
    @Default(true) bool requirePureSequence,
    
    /// Marriage Required: Must have at least one K+Q Marriage meld to declare.
    @Default(false) bool requireMarriageToWin,
    
    // === Bonus Rules ===
    
    /// Dublee Bonus: Award 25 points for two sequences of same suit.
    @Default(true) bool dubleeBonus,
    
    /// Tunnel Bonus: Award 50 points for 3 cards of same rank AND suit.
    @Default(true) bool tunnelBonus,
    
    /// Marriage Bonus: Award 100 points for K+Q pair in melds.
    @Default(true) bool marriageBonus,
    
    // === Limits ===
    
    /// Minimum cards required for a valid sequence.
    @Default(3) int minSequenceLength,
    
    /// Maximum wild cards allowed in a single meld.
    @Default(2) int maxWildsInMeld,
    
    /// Cards dealt per player.
    @Default(21) int cardsPerPlayer,
    
    // === Turn Rules ===
    
    /// First turn must draw from deck, cannot pick initial discard.
    @Default(true) bool firstDrawFromDeck,
    
    /// Turn timeout in seconds (0 = no timeout).
    @Default(30) int turnTimeoutSeconds,
    
    // === Scoring ===
    
    /// Penalty for declaring without a pure sequence.
    @Default(100) int noLifePenalty,
    
    /// Maximum penalty (full count - no melds at all).
    @Default(120) int fullCountPenalty,
    
    /// Penalty for wrong/invalid declaration.
    @Default(50) int wrongDeclarationPenalty,
    
    // === Display Options ===
    
    /// Automatically sort hand by suit and rank.
    @Default(true) bool autoSortHand,
    
    /// Show meld suggestions to help player.
    @Default(true) bool showMeldSuggestions,
    
    /// Total rounds to play.
    @Default(5) int totalRounds,
    
    /// Point value per unit (for settlements).
    @Default(1.0) double pointValue,
  }) = _MarriageGameConfig;

  factory MarriageGameConfig.fromJson(Map<String, dynamic> json) =>
      _$MarriageGameConfigFromJson(json);
  
  /// Nepali Standard preset
  static const MarriageGameConfig nepaliStandard = MarriageGameConfig(
    jokerBlocksDiscard: true,
    canPickupWildFromDiscard: false,
    requirePureSequence: true,
    requireMarriageToWin: false,
    dubleeBonus: true,
    tunnelBonus: true,
    marriageBonus: true,
    minSequenceLength: 3,
    maxWildsInMeld: 2,
    cardsPerPlayer: 21,
    firstDrawFromDeck: true,
    turnTimeoutSeconds: 30,
    noLifePenalty: 100,
    fullCountPenalty: 120,
    wrongDeclarationPenalty: 50,
  );
  
  /// Indian Rummy variant (more relaxed rules)
  static const MarriageGameConfig indianRummy = MarriageGameConfig(
    jokerBlocksDiscard: false,
    canPickupWildFromDiscard: true,
    requirePureSequence: true,
    requireMarriageToWin: false,
    dubleeBonus: false,
    tunnelBonus: false,
    marriageBonus: false,
    minSequenceLength: 3,
    maxWildsInMeld: 3,
    cardsPerPlayer: 13, // Standard Indian Rummy uses 13 cards
  );
  
  /// Casual/Beginner preset (relaxed rules)
  static const MarriageGameConfig casual = MarriageGameConfig(
    jokerBlocksDiscard: false,
    canPickupWildFromDiscard: true,
    requirePureSequence: false,
    requireMarriageToWin: false,
    turnTimeoutSeconds: 60, // More time
    showMeldSuggestions: true,
  );
}

/// Helper extension for config validation
extension MarriageGameConfigX on MarriageGameConfig {
  /// Validate configuration values
  bool get isValid {
    return minSequenceLength >= 3 &&
           maxWildsInMeld >= 1 &&
           cardsPerPlayer >= 7 &&
           turnTimeoutSeconds >= 0 &&
           totalRounds >= 1;
  }
  
  /// Get config description for display
  String get presetName {
    if (jokerBlocksDiscard && !canPickupWildFromDiscard && requirePureSequence) {
      return 'Nepali Standard';
    } else if (!jokerBlocksDiscard && canPickupWildFromDiscard && cardsPerPlayer == 13) {
      return 'Indian Rummy';
    } else if (!requirePureSequence && turnTimeoutSeconds >= 60) {
      return 'Casual';
    }
    return 'Custom';
  }
}

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

    /// Marriage Required: Must have Jhiplu+Tiplu+Poplu combo to declare.
    @Default(false) bool requireMarriageToWin,

    // === Bonus Rules ===

    /// Dublee Bonus: Award 25 points for two sequences of same suit.
    @Default(true) bool dubleeBonus,

    /// Tunnel Bonus: Award points for 3 cards of same rank AND suit.
    /// If shown before first draw, award 5 pts (authentic Nepali rule).
    @Default(true) bool tunnelBonus,

    /// Tunnel display bonus value (shown before first draw).
    @Default(5) int tunnelDisplayBonusValue,

    /// Marriage Bonus: Award 10 points for Jhiplu+Tiplu+Poplu combo of same suit.
    @Default(true) bool marriageBonus,

    /// Marriage combo value (Jhiplu+Tiplu+Poplu).
    @Default(10) int marriageBonusValue,

    /// 8-Dublee Win: Player can win by holding 8 pairs of same rank+suit.
    @Default(true) bool eightDubleeWinEnabled,

    /// Bonus points for winning with 8 Dublees.
    @Default(5) int eightDubleeWinBonus,

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

    // === Visiting Rules (Gatekeeper Logic) ===

    /// Number of pure sequences required to "Visit" (unlock Maal).
    @Default(3) int sequencesRequiredToVisit,

    /// Allow Dublee Visit: Player can visit with 7 pairs instead of sequences.
    @Default(true) bool allowDubleeVisit,

    /// Number of pairs required for Dublee visit.
    @Default(7) int dubleeCountRequired,

    /// Tunnel counts as a sequence for visiting purposes.
    @Default(true) bool tunnelAsSequence,

    /// Must visit before picking from discard pile (strict visiting).
    @Default(false) bool mustVisitToPickDiscard,

    // === Maal (Value Card) System ===

    /// Tiplu value (exact match of drawn wild card).
    @Default(3) int tipluValue,

    /// Poplu value (rank +1, same suit as Tiplu).
    @Default(2) int popluValue,

    /// Jhiplu value (rank -1, same suit as Tiplu).
    @Default(2) int jhipluValue,

    /// Alter value (same rank+color, different suit as Tiplu).
    @Default(5) int alterValue,

    /// Man (printed Joker) value.
    @Default(2) int manValue,

    /// Enable Man (printed Joker) as Maal.
    @Default(true) bool isManEnabled,

    /// Tunnel Pachaunu: Tunnel points (5/15/25) are VOIDED if player
    /// fails to make at least 1 pure sequence (Phase 1).
    @Default(false) bool tunnelPachaunu,

    // === Kidnap/Murder Rules ===

    /// Kidnap: If winner and opponent not visited, opponent's Maal goes to winner.
    @Default(true) bool enableKidnap,

    /// Murder: If not visited, Maal points are set to 0 (stricter than Kidnap).
    @Default(false) bool enableMurder,

    /// Penalty for losing while not visited.
    @Default(10) int unvisitedPenalty,

    /// Penalty for losing while visited.
    @Default(3) int visitedPenalty,
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
    // Visiting rules
    sequencesRequiredToVisit: 3,
    allowDubleeVisit: true,
    dubleeCountRequired: 7,
    tunnelAsSequence: true,
    mustVisitToPickDiscard: false,
    // Maal values
    tipluValue: 3,
    popluValue: 2,
    jhipluValue: 2,
    alterValue: 5,
    manValue: 2,
    isManEnabled: true,
    // Kidnap/Murder
    enableKidnap: true,
    enableMurder: false,
    unvisitedPenalty: 10,
    visitedPenalty: 3,
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
    if (jokerBlocksDiscard &&
        !canPickupWildFromDiscard &&
        requirePureSequence) {
      return 'Nepali Standard';
    } else if (!jokerBlocksDiscard &&
        canPickupWildFromDiscard &&
        cardsPerPlayer == 13) {
      return 'Indian Rummy';
    } else if (!requirePureSequence && turnTimeoutSeconds >= 60) {
      return 'Casual';
    }
    return 'Custom';
  }
}

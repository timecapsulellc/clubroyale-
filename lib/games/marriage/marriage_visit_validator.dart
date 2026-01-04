/// Marriage Visit Validator
///
/// Validates if a player can "Visit" (unlock Maal access).
/// Players must show 3 pure sequences OR 7 pairs (Dublee) to visit.
library;

import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Result of a visit validation check
class VisitValidationResult {
  final bool canVisit;
  final List<Meld> validMelds;
  final String? reason;
  final VisitType visitType;

  VisitValidationResult({
    required this.canVisit,
    this.validMelds = const [],
    this.reason,
    this.visitType = VisitType.none,
  });

  static VisitValidationResult fail(String reason) =>
      VisitValidationResult(canVisit: false, reason: reason);

  static VisitValidationResult success({
    required List<Meld> melds,
    required VisitType type,
  }) =>
      VisitValidationResult(canVisit: true, validMelds: melds, visitType: type);
}

/// Type of visit achieved
enum VisitType {
  /// Standard visit with 3 pure sequences
  sequence,

  /// Dublee visit with 7 pairs
  dublee,

  /// Tunnel visit (3 tunnels = instant win)
  tunnel,

  /// Not visited
  none,
}

/// Validates visiting requirements for Nepali Marriage
class MarriageVisitValidator {
  final MarriageGameConfig config;
  final Card? tiplu;

  MarriageVisitValidator({
    this.config = const MarriageGameConfig(),
    this.tiplu,
  });

  /// Check if player can visit with standard sequences
  VisitValidationResult canVisitSequence(List<Card> hand) {
    // Find all pure sequences (no wild cards)
    final pureSequences = _findPureSequences(hand);

    // Add tunnels if they count as sequences
    final tunnels = <Meld>[];
    if (config.tunnelAsSequence) {
      tunnels.addAll(MeldDetector.findTunnels(hand));
    }

    final totalSequences = pureSequences.length + tunnels.length;

    if (totalSequences >= config.sequencesRequiredToVisit) {
      return VisitValidationResult.success(
        melds: [...pureSequences, ...tunnels],
        type: VisitType.sequence,
      );
    }

    return VisitValidationResult.fail(
      'Need ${config.sequencesRequiredToVisit} pure sequences, have $totalSequences',
    );
  }

  /// Check if player can visit with Dublee (7 pairs)
  VisitValidationResult canVisitDublee(List<Card> hand) {
    if (!config.allowDubleeVisit) {
      return VisitValidationResult.fail('Dublee visit not enabled');
    }

    // Find ACTUAL Dublee melds (Pairs)
    final dublees = MeldDetector.findDublees(hand);

    if (dublees.length >= config.dubleeCountRequired) {
      return VisitValidationResult.success(
        melds: dublees,
        type: VisitType.dublee,
      );
    }

    return VisitValidationResult.fail(
      'Need ${config.dubleeCountRequired} pairs, have ${dublees.length}',
    );
  }

  /// Check if player has 3 tunnels (instant win)
  VisitValidationResult checkTunnelWin(List<Card> hand) {
    final tunnels = MeldDetector.findTunnels(hand);

    if (tunnels.length >= 3) {
      return VisitValidationResult.success(
        melds: tunnels,
        type: VisitType.tunnel,
      );
    }

    return VisitValidationResult.fail(
      'Need 3 tunnels for instant win, have ${tunnels.length}',
    );
  }

  /// Attempt to visit - try all valid methods
  VisitValidationResult attemptVisit(List<Card> hand) {
    // Check for tunnel win first (instant game over)
    final tunnelResult = checkTunnelWin(hand);
    if (tunnelResult.canVisit) return tunnelResult;

    // Check standard sequence visit
    final sequenceResult = canVisitSequence(hand);
    if (sequenceResult.canVisit) return sequenceResult;

    // Check dublee visit
    final dubleeResult = canVisitDublee(hand);
    if (dubleeResult.canVisit) return dubleeResult;

    // Cannot visit
    return VisitValidationResult.fail(
      'Cannot visit: need ${config.sequencesRequiredToVisit} sequences or ${config.dubleeCountRequired} pairs',
    );
  }

  /// Find all PURE sequences (no wild cards)
  List<Meld> _findPureSequences(List<Card> hand) {
    final allRuns = MeldDetector.findRuns(hand);
    final pureRuns = <Meld>[];

    for (final run in allRuns) {
      bool isPure = true;
      for (final card in run.cards) {
        if (_isWildCard(card)) {
          isPure = false;
          break;
        }
      }
      if (isPure) {
        pureRuns.add(run);
      }
    }

    return pureRuns;
  }

  /// Find all pairs in hand (Deprecated internal - use MeldDetector)
  // Logic moved to MeldDetector.findDublees
  // Keeping fallback or removing entirely? Removing to avoid confusion.

  /// Check if card is a wild card (Joker or Tiplu)
  bool _isWildCard(Card card) {
    if (card.isJoker) return true;
    if (tiplu == null) return false;

    // Tiplu: exact match
    if (card.rank == tiplu!.rank && card.suit == tiplu!.suit) return true;

    // Jhiplu: same rank, opposite color
    if (card.rank == tiplu!.rank && card.suit.isRed != tiplu!.suit.isRed) {
      return true;
    }

    // Poplu: next rank, same suit
    final popluValue = tiplu!.rank.value == 13 ? 1 : tiplu!.rank.value + 1;
    if (card.suit == tiplu!.suit && card.rank.value == popluValue) return true;

    return false;
  }
}

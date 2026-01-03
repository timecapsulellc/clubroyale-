/// Marriage Maal Calculator
///
/// Calculates Maal (value card) points based on Tiplu.
/// Maal cards have dynamic values determined by the center card.
library;

import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Types of Maal (value cards) in Nepali Marriage
enum MaalType {
  /// Tiplu: Exact match of center card (rank + suit)
  tiplu,

  /// Poplu: Rank +1, same suit as Tiplu
  poplu,

  /// Jhiplu: Rank -1, same suit as Tiplu
  jhiplu,

  /// Alter: Same rank + color, different suit as Tiplu
  alter,

  /// Man: Printed Joker card
  man,

  /// None: Regular card (no Maal value)
  none,
}

/// Calculates Maal values based on Tiplu (center wild card)
class MarriageMaalCalculator {
  final Card tiplu;
  final MarriageGameConfig config;

  MarriageMaalCalculator({
    required this.tiplu,
    this.config = const MarriageGameConfig(),
  });

  /// Get the Maal type of a card
  MaalType getMaalType(Card card) {
    // Man: Printed Joker
    if (card.isJoker && config.isManEnabled) {
      return MaalType.man;
    }

    // Skip Jokers for other checks
    if (card.isJoker) return MaalType.none;

    // Tiplu: Exact match (same rank AND suit)
    if (card.rank == tiplu.rank && card.suit == tiplu.suit) {
      return MaalType.tiplu;
    }

    final tVal = tiplu.rank.value;

    // Poplu: Rank +1, same suit
    // If K(13) -> A(14)
    // If A(14) -> 2(2) (Round the corner)
    int popluValue;
    if (tVal == 13) {
      popluValue = 14; // K -> A
    } else if (tVal == 14) {
      popluValue = 2; // A -> 2
    } else {
      popluValue = tVal + 1;
    }

    if (card.suit == tiplu.suit && card.rank.value == popluValue) {
      return MaalType.poplu;
    }

    // Jhiplu: Rank -1, same suit
    // If A(14) -> K(13)
    // If 2(2) -> A(14) (Round the corner)
    int jhipluValue;
    if (tVal == 14) {
      jhipluValue = 13; // A -> K
    } else if (tVal == 2) {
      jhipluValue = 14; // 2 -> A
    } else {
      jhipluValue = tVal - 1;
    }

    if (card.suit == tiplu.suit && card.rank.value == jhipluValue) {
      return MaalType.jhiplu;
    }

    // Alter: Same rank AND color, different suit
    if (card.rank == tiplu.rank &&
        card.suit.isRed == tiplu.suit.isRed &&
        card.suit != tiplu.suit) {
      return MaalType.alter;
    }

    return MaalType.none;
  }

  /// Get the point value for a Maal type
  int getMaalValue(MaalType type) {
    switch (type) {
      case MaalType.tiplu:
        return config.tipluValue;
      case MaalType.poplu:
        return config.popluValue;
      case MaalType.jhiplu:
        return config.jhipluValue;
      case MaalType.alter:
        return config.alterValue;
      case MaalType.man:
        return config.manValue;
      case MaalType.none:
        return 0;
    }
  }

  /// Get human-readable name for Maal type
  static String getMaalName(MaalType type) {
    switch (type) {
      case MaalType.tiplu:
        return 'Tiplu';
      case MaalType.poplu:
        return 'Poplu';
      case MaalType.jhiplu:
        return 'Jhiplu';
      case MaalType.alter:
        return 'Alter';
      case MaalType.man:
        return 'Man';
      case MaalType.none:
        return 'None';
    }
  }

  /// Calculate total Maal points in a hand
  int calculateMaalPoints(List<Card> hand) {
    int total = 0;
    for (final card in hand) {
      final type = getMaalType(card);
      total += getMaalValue(type);
    }
    return total;
  }

  /// Get detailed breakdown of Maal cards in hand
  List<MaalCardInfo> getMaalBreakdown(List<Card> hand) {
    final maalCards = <MaalCardInfo>[];

    for (final card in hand) {
      final type = getMaalType(card);
      if (type != MaalType.none) {
        maalCards.add(
          MaalCardInfo(card: card, type: type, value: getMaalValue(type)),
        );
      }
    }

    return maalCards;
  }

  /// Count Maal cards by type
  Map<MaalType, int> countMaalByType(List<Card> hand) {
    final counts = <MaalType, int>{};

    for (final card in hand) {
      final type = getMaalType(card);
      if (type != MaalType.none) {
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }

    return counts;
  }
}

/// Information about a Maal card
class MaalCardInfo {
  final Card card;
  final MaalType type;
  final int value;

  MaalCardInfo({required this.card, required this.type, required this.value});

  @override
  String toString() =>
      '${MarriageMaalCalculator.getMaalName(type)}: ${card.displayString} ($value pts)';
}

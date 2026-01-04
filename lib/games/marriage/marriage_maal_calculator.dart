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

  /// Check if hand contains a Marriage Combo (Jhiplu + Tiplu + Poplu of same suit)
  /// Returns the bonus value if present, 0 otherwise.
  int getMarriageComboBonus(List<Card> hand) {
    if (!config.marriageBonus) return 0;

    bool hasJhiplu = false;
    bool hasTiplu = false;
    bool hasPoplu = false;

    for (final card in hand) {
      final type = getMaalType(card);
      if (type == MaalType.jhiplu) hasJhiplu = true;
      if (type == MaalType.tiplu) hasTiplu = true;
      if (type == MaalType.poplu) hasPoplu = true;
    }

    // Marriage: All three Maal cards of same suit (Tiplu's suit)
    if (hasJhiplu && hasTiplu && hasPoplu) {
      return config.marriageBonusValue;
    }
    return 0;
  }

  /// Count Tunnels (3 identical cards: same rank AND suit) in hand.
  /// Used for display bonus calculation.
  int countTunnels(List<Card> hand) {
    // Group cards by rank+suit key
    final Map<String, int> cardCounts = {};
    for (final card in hand) {
      if (card.isJoker) continue;
      final key = '${card.rank.value}_${card.suit.index}';
      cardCounts[key] = (cardCounts[key] ?? 0) + 1;
    }

    // Count how many groups have 3+ cards (tunnel)
    int tunnels = 0;
    for (final count in cardCounts.values) {
      if (count >= 3) tunnels++;
    }
    return tunnels;
  }

  /// Calculate Tunnel Display Bonus (shown before first draw).
  /// 1 Tunnel = 5 pts, 2 Tunnels = 15 pts, 3 Tunnels = 25 pts.
  int getTunnelDisplayBonus(List<Card> hand) {
    if (!config.tunnelBonus) return 0;

    final tunnelCount = countTunnels(hand);
    if (tunnelCount == 0) return 0;
    if (tunnelCount == 1) return config.tunnelDisplayBonusValue;
    if (tunnelCount == 2) return config.tunnelDisplayBonusValue * 3; // 15
    return config.tunnelDisplayBonusValue * 5; // 25 for 3+
  }

  /// Check if hand can win with 8 Dublees (8 pairs of same rank+suit).
  bool canWinWith8Dublee(List<Card> hand) {
    if (!config.eightDubleeWinEnabled) return false;
    if (hand.length < 16) return false; // Need at least 16 cards for 8 pairs

    // Group cards by rank+suit key
    final Map<String, int> cardCounts = {};
    for (final card in hand) {
      if (card.isJoker) continue;
      final key = '${card.rank.value}_${card.suit.index}';
      cardCounts[key] = (cardCounts[key] ?? 0) + 1;
    }

    // Count pairs (2 or more of same card)
    int pairCount = 0;
    for (final count in cardCounts.values) {
      pairCount += count ~/ 2; // Integer division gives number of pairs
    }

    return pairCount >= 8;
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

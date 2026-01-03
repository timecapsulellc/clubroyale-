/// Marriage Meld Analyzer
///
/// Advanced meld analysis for AI/bot decision-making in Marriage game.
/// Provides detailed hand evaluation, sequence potential, and strategic insights.
library;

import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';

/// Hand analysis result with detailed breakdown
class MeldAnalysisResult {
  /// Total melds found
  final List<Meld> melds;

  /// Pure sequences (runs without wildcards)
  final List<Meld> pureSequences;

  /// Tunnels (3+ cards of same rank)
  final List<Meld> tunnels;

  /// Near-complete melds (2 cards toward a run/set)
  final List<NearMeld> nearMelds;

  /// Cards not part of any meld
  final List<Card> deadwood;

  /// Estimated Maal points
  final int maalPoints;

  /// Progress toward visit (0.0 - 1.0)
  final double visitProgress;

  /// Can declare (fully melded)
  final bool canDeclare;

  /// Suggested best discard
  final Card? suggestedDiscard;

  const MeldAnalysisResult({
    required this.melds,
    required this.pureSequences,
    required this.tunnels,
    required this.nearMelds,
    required this.deadwood,
    required this.maalPoints,
    required this.visitProgress,
    required this.canDeclare,
    this.suggestedDiscard,
  });

  /// Number of cards in valid melds
  int get meldedCardCount =>
      melds.fold<int>(0, (sum, m) => sum + m.cards.length);

  /// Ready to visit (3+ pure sequences)
  bool get canVisit => pureSequences.length >= 3;

  /// Has tunnel bonus potential
  bool get hasTunnelPotential => tunnels.isNotEmpty;

  /// Hand strength score (0.0 - 1.0)
  double get handStrength {
    if (canDeclare) return 1.0;

    double score = 0;
    // Pure sequences are most valuable
    score += pureSequences.length * 0.15;
    // Other melds help
    score += (melds.length - pureSequences.length) * 0.08;
    // Near melds show potential
    score += nearMelds.length * 0.05;
    // Maal is valuable
    score += maalPoints * 0.02;
    // Less deadwood = better
    score += (1 - deadwood.length / 13.0) * 0.2;

    return score.clamp(0.0, 1.0);
  }

  @override
  String toString() =>
      'MeldAnalysis(melds: ${melds.length}, pure: ${pureSequences.length}, tunnels: ${tunnels.length}, near: ${nearMelds.length}, deadwood: ${deadwood.length})';
}

/// A near-complete meld (nearly a run or set)
class NearMeld {
  final List<Card> cards;
  final MeldType targetType;
  final List<CardRequirement> neededCards;

  const NearMeld({
    required this.cards,
    required this.targetType,
    required this.neededCards,
  });

  /// How close to completion (0.0 - 1.0)
  double get completion => cards.length / (cards.length + neededCards.length);
}

/// Card needed to complete a meld
class CardRequirement {
  final CardRank rank;
  final CardSuit? suit;
  final bool isWildAcceptable;

  const CardRequirement({
    required this.rank,
    this.suit,
    this.isWildAcceptable = true,
  });

  /// Check if a card satisfies this requirement
  bool matches(Card card, {Card? tiplu}) {
    // Wildcards always match if acceptable
    if (isWildAcceptable) {
      if (card.isJoker) return true;
      if (tiplu != null && card.rank == tiplu.rank) return true;
    }

    if (card.rank != rank) return false;
    if (suit != null && card.suit != suit) return false;
    return true;
  }
}

/// Marriage Meld Analyzer - AI decision support
class MarriageMeldAnalyzer {
  final Card? tiplu;

  MarriageMeldAnalyzer({this.tiplu});

  /// Perform full analysis of a hand
  MeldAnalysisResult analyze(List<Card> hand) {
    // Find all melds
    final allMelds = MeldDetector.findAllMelds(hand, tiplu: tiplu);

    // Categorize melds
    final pureSequences = <Meld>[];
    final tunnels = <Meld>[];

    for (final meld in allMelds) {
      if (_isPureSequence(meld)) {
        pureSequences.add(meld);
      }
      if (meld.type == MeldType.tunnel || meld is TunnelMeld) {
        tunnels.add(meld);
      }
    }

    // Find cards in melds
    final meldedCards = <Card>{};
    for (final meld in allMelds) {
      meldedCards.addAll(meld.cards);
    }

    // Find deadwood
    final deadwood = hand.where((c) => !meldedCards.contains(c)).toList();

    // Find near-complete melds
    final nearMelds = _findNearMelds(hand, meldedCards);

    // Calculate Maal
    final maalPoints = _calculateMaal(hand);

    // Visit progress (need 3 pure sequences)
    final visitProgress = (pureSequences.length / 3.0).clamp(0.0, 1.0);

    // Can declare if all cards melded
    final canDeclare = deadwood.isEmpty && pureSequences.length >= 3;

    // Suggest best discard
    final suggestedDiscard = _suggestDiscard(hand, deadwood, meldedCards);

    return MeldAnalysisResult(
      melds: allMelds,
      pureSequences: pureSequences,
      tunnels: tunnels,
      nearMelds: nearMelds,
      deadwood: deadwood,
      maalPoints: maalPoints,
      visitProgress: visitProgress,
      canDeclare: canDeclare,
      suggestedDiscard: suggestedDiscard,
    );
  }

  /// Evaluate if picking a card would improve the hand
  double evaluatePickup(List<Card> hand, Card card) {
    final currentAnalysis = analyze(hand);
    final withCard = [...hand, card];
    final newAnalysis = analyze(withCard);

    // Score improvement
    double improvement = 0;

    // More pure sequences = big improvement
    improvement +=
        (newAnalysis.pureSequences.length -
            currentAnalysis.pureSequences.length) *
        0.3;

    // More melds = good
    improvement +=
        (newAnalysis.melds.length - currentAnalysis.melds.length) * 0.15;

    // Less deadwood = good
    improvement +=
        (currentAnalysis.deadwood.length - newAnalysis.deadwood.length) * 0.1;

    // More near-melds = some improvement
    improvement +=
        (newAnalysis.nearMelds.length - currentAnalysis.nearMelds.length) *
        0.05;

    // Maal points gained
    improvement += (newAnalysis.maalPoints - currentAnalysis.maalPoints) * 0.02;

    return improvement.clamp(-1.0, 1.0);
  }

  /// Find cards that would help complete near-melds
  List<CardRequirement> getNeededCards(List<Card> hand) {
    final requirements = <CardRequirement>[];

    // Group by suit for runs
    final bySuit = <CardSuit, List<Card>>{};
    for (final card in hand) {
      if (card.isJoker) continue;
      bySuit.putIfAbsent(card.suit, () => []).add(card);
    }

    for (final entry in bySuit.entries) {
      final suit = entry.key;
      final cards = entry.value
        ..sort((a, b) => a.rank.value.compareTo(b.rank.value));

      // Find gaps that would complete runs
      for (int i = 0; i < cards.length - 1; i++) {
        final diff = cards[i + 1].rank.value - cards[i].rank.value;
        if (diff == 2) {
          // Gap of 1 - need middle card
          final neededRank = CardRank.values.firstWhere(
            (r) => r.value == cards[i].rank.value + 1,
            orElse: () => CardRank.ace,
          );
          requirements.add(CardRequirement(rank: neededRank, suit: suit));
        }
      }

      // Check for extensions (card before first or after last)
      if (cards.isNotEmpty) {
        final first = cards.first;
        final last = cards.last;

        if (first.rank.value > 1) {
          final below = CardRank.values.firstWhere(
            (r) => r.value == first.rank.value - 1,
            orElse: () => CardRank.ace,
          );
          requirements.add(CardRequirement(rank: below, suit: suit));
        }

        if (last.rank.value < 13) {
          final above = CardRank.values.firstWhere(
            (r) => r.value == last.rank.value + 1,
            orElse: () => CardRank.king,
          );
          requirements.add(CardRequirement(rank: above, suit: suit));
        }
      }
    }

    // Group by rank for tunnels
    final byRank = <CardRank, int>{};
    for (final card in hand) {
      if (card.isJoker) continue;
      byRank[card.rank] = (byRank[card.rank] ?? 0) + 1;
    }

    // If 2 of a rank, need 1 more for tunnel
    for (final entry in byRank.entries) {
      if (entry.value == 2) {
        requirements.add(CardRequirement(rank: entry.key, suit: null));
      }
    }

    return requirements;
  }

  /// Check if a meld is a pure sequence
  bool _isPureSequence(Meld meld) {
    if (meld.type != MeldType.run) return false;

    // Check for wildcards
    for (final card in meld.cards) {
      if (card.isJoker) return false;
      if (tiplu != null && card.rank == tiplu!.rank) return false;
    }

    return true;
  }

  /// Find near-complete melds
  List<NearMeld> _findNearMelds(List<Card> hand, Set<Card> alreadyMelded) {
    final nearMelds = <NearMeld>[];
    final available = hand.where((c) => !alreadyMelded.contains(c)).toList();

    // Group by suit for near-runs
    final bySuit = <CardSuit, List<Card>>{};
    for (final card in available) {
      if (card.isJoker) continue;
      bySuit.putIfAbsent(card.suit, () => []).add(card);
    }

    for (final entry in bySuit.entries) {
      final cards = entry.value
        ..sort((a, b) => a.rank.value.compareTo(b.rank.value));

      // Look for 2 consecutive cards (near-run)
      for (int i = 0; i < cards.length - 1; i++) {
        final diff = cards[i + 1].rank.value - cards[i].rank.value;
        if (diff == 1) {
          nearMelds.add(
            NearMeld(
              cards: [cards[i], cards[i + 1]],
              targetType: MeldType.run,
              neededCards: [
                CardRequirement(
                  rank: CardRank.values.firstWhere(
                    (r) => r.value == cards[i].rank.value - 1,
                    orElse: () => CardRank.ace,
                  ),
                  suit: cards[i].suit,
                ),
                CardRequirement(
                  rank: CardRank.values.firstWhere(
                    (r) => r.value == cards[i + 1].rank.value + 1,
                    orElse: () => CardRank.king,
                  ),
                  suit: cards[i].suit,
                ),
              ],
            ),
          );
        }
      }
    }

    // Group by rank for near-tunnels
    final byRank = <CardRank, List<Card>>{};
    for (final card in available) {
      if (card.isJoker) continue;
      byRank.putIfAbsent(card.rank, () => []).add(card);
    }

    for (final entry in byRank.entries) {
      if (entry.value.length == 2) {
        nearMelds.add(
          NearMeld(
            cards: entry.value,
            targetType: MeldType.tunnel,
            neededCards: [CardRequirement(rank: entry.key)],
          ),
        );
      }
    }

    return nearMelds;
  }

  /// Calculate Maal points
  int _calculateMaal(List<Card> hand) {
    if (tiplu == null) return 0;

    int maal = 0;
    for (final card in hand) {
      if (card.isJoker) {
        maal += 3;
        continue;
      }

      // Tiplu
      if (card.rank == tiplu!.rank && card.suit == tiplu!.suit) {
        maal += 4;
      }
      // Same rank, different suit
      else if (card.rank == tiplu!.rank) {
        maal += 2;
      }
      // Ace or King of tiplu suit
      if (card.suit == tiplu!.suit &&
          (card.rank == CardRank.ace || card.rank == CardRank.king)) {
        maal += 2;
      }
    }

    return maal;
  }

  /// Suggest best card to discard
  Card? _suggestDiscard(
    List<Card> hand,
    List<Card> deadwood,
    Set<Card> meldedCards,
  ) {
    if (deadwood.isEmpty) return null;

    // Never discard wildcards
    final nonWild = deadwood.where((c) => !_isWild(c)).toList();
    if (nonWild.isEmpty) return deadwood.first;

    // Score each card (lower = better to discard)
    Card? worst;
    int worstScore = 999;

    for (final card in nonWild) {
      int score = 0;

      // Connectivity to other cards
      for (final other in hand) {
        if (other == card) continue;
        if (other.suit == card.suit) {
          final diff = (other.rank.value - card.rank.value).abs();
          if (diff <= 2) score += 10;
        }
        if (other.rank == card.rank) score += 15;
      }

      // High cards are less valuable to keep
      score -= card.rank.points ~/ 2;

      if (score < worstScore) {
        worstScore = score;
        worst = card;
      }
    }

    return worst ?? nonWild.first;
  }

  /// Check if card is wild
  bool _isWild(Card card) {
    if (card.isJoker) return true;
    if (tiplu != null && card.rank == tiplu!.rank) return true;
    return false;
  }
}

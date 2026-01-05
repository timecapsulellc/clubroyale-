/// Marriage Bot Strategy
///
/// AI-powered bot decision making for Marriage (Royal Meld) game
/// Includes meld detection, draw selection, discard optimization, and visit logic
library;

import 'dart:math';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/features/agents/models/bot_personality.dart';

/// Bot difficulty level
enum MarriageBotDifficulty {
  easy, // Random decisions, basic play
  medium, // Basic meld detection, reasonable discards
  hard, // Strategic play, optimal meld building
}

/// Marriage Bot Strategy
class MarriageBotStrategy {
  final Random _random = Random();
  final MarriageBotDifficulty difficulty;
  final BotPersonality? personality;

  MarriageBotStrategy({
    this.difficulty = MarriageBotDifficulty.medium,
    this.personality,
  });

  /// Get risk tolerance from personality or default by difficulty
  double get _riskTolerance {
    if (personality != null) return personality!.riskTolerance;
    switch (difficulty) {
      case MarriageBotDifficulty.easy:
        return 0.7;
      case MarriageBotDifficulty.medium:
        return 0.5;
      case MarriageBotDifficulty.hard:
        return 0.3;
    }
  }

  /// Get aggression from personality or default by difficulty
  double get _aggression {
    if (personality != null) return personality!.aggression;
    switch (difficulty) {
      case MarriageBotDifficulty.easy:
        return 0.3;
      case MarriageBotDifficulty.medium:
        return 0.5;
      case MarriageBotDifficulty.hard:
        return 0.7;
    }
  }

  /// Decide whether to draw from deck or discard pile
  /// Returns true for deck, false for discard
  bool shouldDrawFromDeck({
    required List<Card> hand,
    required Card? topDiscard,
    required Card? tiplu,
    required bool hasVisited,
    required bool
    canPickFromDiscard, // False if blocked by Joker or visiting rule
  }) {
    // If can't pick from discard, must use deck
    if (!canPickFromDiscard || topDiscard == null) return true;

    switch (difficulty) {
      case MarriageBotDifficulty.easy:
        // Easy: Random choice, slight preference for deck
        return _random.nextDouble() < 0.6;

      case MarriageBotDifficulty.medium:
        // Medium: Pick discard if it obviously helps a meld
        if (_wouldHelpMeld(hand, topDiscard, tiplu)) {
          return false; // Pick from discard
        }
        return true; // Otherwise deck

      case MarriageBotDifficulty.hard:
        // Hard: Evaluate meld potential before and after picking
        final currentMeldCount = _countMeldCards(hand, tiplu);
        final potentialMeldCount = _countMeldCards([
          ...hand,
          topDiscard,
        ], tiplu);

        // If discard significantly improves our melds, take it
        if (potentialMeldCount > currentMeldCount + 1) {
          return false; // Pick from discard
        }

        // Also consider: don't reveal interest in that card to opponents
        // Random factor to be less predictable
        if (potentialMeldCount > currentMeldCount &&
            _random.nextDouble() < 0.7) {
          return false;
        }

        return true;
    }
  }

  /// Choose which card to discard
  Card chooseDiscard({
    required List<Card> hand,
    required Card? tiplu,
    required Card?
    lastDrawnCard, // Can't discard what we just drew (house rule)
  }) {
    if (hand.isEmpty) {
      throw StateError('Cannot discard from empty hand');
    }

    // Filter out last drawn card if applicable
    final candidates = lastDrawnCard != null
        ? hand.where((c) => c != lastDrawnCard).toList()
        : List<Card>.from(hand);

    if (candidates.isEmpty) {
      // Must discard the drawn card if it's all we have
      return hand.first;
    }

    switch (difficulty) {
      case MarriageBotDifficulty.easy:
        // Easy: Random discard
        return candidates[_random.nextInt(candidates.length)];

      case MarriageBotDifficulty.medium:
        // Medium: Discard highest value card not in a meld
        return _findBestDiscard(candidates, tiplu, preferHighValue: true);

      case MarriageBotDifficulty.hard:
        // Hard: Strategic discard, considering meld potential
        return _findBestDiscard(candidates, tiplu, preferHighValue: false);
    }
  }

  /// Check if bot should attempt to visit (show pure sequences)
  bool shouldAttemptVisit({
    required List<Card> hand,
    required Card? tiplu,
    required int requiredSequences,
  }) {
    // Find all melds
    final melds = MeldDetector.findAllMelds(hand, tiplu: tiplu);

    // Count pure sequences and tunnels
    int pureCount = 0;
    for (final meld in melds) {
      if (meld.type == MeldType.run || meld.type == MeldType.tunnel) {
        if (_isPureMeld(meld, tiplu)) {
          pureCount++;
        }
      }
    }

    switch (difficulty) {
      case MarriageBotDifficulty.easy:
        // Easy: Only visit if way over threshold
        return pureCount >= requiredSequences + 1;

      case MarriageBotDifficulty.medium:
        // Medium: Visit as soon as eligible
        return pureCount >= requiredSequences;

      case MarriageBotDifficulty.hard:
        // Hard: Consider timing - visit early to unlock powers
        if (pureCount >= requiredSequences) {
          // Visit if we also have good Maal potential
          final maalPoints = _estimateMaalPoints(hand, tiplu);
          if (maalPoints > 0 || _random.nextDouble() < 0.8) {
            return true;
          }
        }
        return false;
    }
  }

  /// Check if bot should declare (end the round)
  bool shouldDeclare({
    required List<Card> hand,
    required Card? tiplu,
    required bool hasVisited,
  }) {
    // Validate if hand can be fully melded
    final isValid = MeldDetector.validateHand(
      hand,
      tiplu: hasVisited ? tiplu : null,
    );

    if (!isValid) return false;

    switch (difficulty) {
      case MarriageBotDifficulty.easy:
        // Easy: Declare immediately when valid
        return true;

      case MarriageBotDifficulty.medium:
        // Medium: Declare when valid
        return true;

      case MarriageBotDifficulty.hard:
        // Hard: Consider if we have good Maal before declaring
        // Sometimes wait to build more Maal
        final maalPoints = _estimateMaalPoints(hand, tiplu);
        if (maalPoints >= 3 || _random.nextDouble() < 0.7) {
          return true;
        }
        // Wait a bit if we could get more Maal
        return false;
    }
  }

  /// Check if taking a card would help form a meld
  bool _wouldHelpMeld(List<Card> hand, Card card, Card? tiplu) {
    // Check if card connects to existing cards
    for (final existing in hand) {
      // Same suit, adjacent rank -> potential run
      if (existing.suit == card.suit) {
        final diff = (existing.rank.value - card.rank.value).abs();
        if (diff == 1 || diff == 2) return true;
      }

      // Same rank -> potential tunnel
      if (existing.rank == card.rank) return true;
    }

    // Check if it's a wild card (always helpful)
    if (tiplu != null && card.rank == tiplu.rank) return true;
    if (card.isJoker) return true;

    return false;
  }

  /// Count cards that are part of melds
  int _countMeldCards(List<Card> hand, Card? tiplu) {
    final melds = MeldDetector.findAllMelds(hand, tiplu: tiplu);
    final meldCards = <Card>{};
    for (final meld in melds) {
      meldCards.addAll(meld.cards);
    }
    return meldCards.length;
  }

  /// Find the best card to discard
  Card _findBestDiscard(
    List<Card> candidates,
    Card? tiplu, {
    required bool preferHighValue,
  }) {
    // 1. Never discard wildcards
    final nonWild = candidates.where((c) => !_isWildCard(c, tiplu)).toList();
    var pool = nonWild.isNotEmpty ? nonWild : candidates;

    // 2. Personality Overrides
    if (personality?.type == BotPersonalityType.tunnelHunter) {
      // Tunnel Hunter: Avoid discarding cards that have a pair in hand/melds
      // (Simplified: just avoid breaking pairs in hand)
      // Actually, we should filter out cards that are part of a PAIR
      final pairRanks = <Rank>{};
      for (final c in candidates) {
        if (candidates.where((o) => o != c && o.rank == c.rank).isNotEmpty) {
           pairRanks.add(c.rank);
        }
      }
      // If we have non-pair cards, restrict pool to them
      final nonPair = pool.where((c) => !pairRanks.contains(c.rank)).toList();
      if (nonPair.isNotEmpty) {
        pool = nonPair;
      }
    } else if (personality?.type == BotPersonalityType.maalCollector) {
      // Maal Collector: Avoid discarding cards that COULD be Maal
      // (e.g., same suit as Tiplu, or close rank)
      if (tiplu != null) {
        final nonPotentialMaal = pool.where((c) {
          // Keep same suit (Alter/Man potential)
          if (c.suit == tiplu.suit) return false;
          // Keep same rank (Jhiplu potential)
          if (c.rank == tiplu.rank) return false;
          return true;
        }).toList();
        
        if (nonPotentialMaal.isNotEmpty) {
          pool = nonPotentialMaal;
        }
      }
    }

    // Find cards not in any meld
    final allCards = List<Card>.from(pool);
    final melds = MeldDetector.findAllMelds(allCards, tiplu: tiplu);
    final meldCards = <Card>{};
    for (final meld in melds) {
      meldCards.addAll(meld.cards);
    }

    final loose = pool.where((c) => !meldCards.contains(c)).toList();

    if (loose.isNotEmpty) {
      if (preferHighValue) {
        // Discard highest value loose card
        loose.sort((a, b) => _cardValue(b).compareTo(_cardValue(a)));
      } else {
        // Discard least connected loose card
        loose.sort(
          (a, b) => _connectivity(a, pool).compareTo(_connectivity(b, pool)),
        );
      }
      return loose.first;
    }

    // All cards are in melds - find the least valuable meld card
    pool.sort((a, b) => _cardValue(a).compareTo(_cardValue(b)));
    return pool.first;
  }

  /// Check if a card is a wild card (Tiplu, Jhiplu, or Joker)
  bool _isWildCard(Card card, Card? tiplu) {
    if (card.isJoker) return true;
    if (tiplu == null) return false;

    // Tiplu itself
    if (card.rank == tiplu.rank && card.suit == tiplu.suit) return true;

    // Jhiplu: Same rank, alternate color
    if (card.rank == tiplu.rank) {
      final tipluIsRed =
          tiplu.suit == Suit.hearts || tiplu.suit == Suit.diamonds;
      final cardIsRed = card.suit == Suit.hearts || card.suit == Suit.diamonds;
      if (tipluIsRed != cardIsRed) return true;
    }

    return false;
  }

  /// Check if a meld is pure (no wildcards)
  bool _isPureMeld(Meld meld, Card? tiplu) {
    for (final card in meld.cards) {
      if (_isWildCard(card, tiplu)) return false;
    }
    return true;
  }

  /// Estimate Maal points in hand
  int _estimateMaalPoints(List<Card> hand, Card? tiplu) {
    if (tiplu == null) return 0;

    int maal = 0;
    for (final card in hand) {
      // Tiplu: 4 points
      if (card.rank == tiplu.rank && card.suit == tiplu.suit) {
        maal += 4;
      }
      // Jhiplu: 3 points (same rank, opposite color)
      else if (card.rank == tiplu.rank) {
        final tipluIsRed =
            tiplu.suit == Suit.hearts || tiplu.suit == Suit.diamonds;
        final cardIsRed =
            card.suit == Suit.hearts || card.suit == Suit.diamonds;
        if (tipluIsRed != cardIsRed) {
          maal += 3;
        } else {
          maal += 2; // Poplu (same rank, same color, different suit)
        }
      }
      // Alter/Man (Ace of tiplu suit, King of tiplu suit) - 2 points each
      if (card.suit == tiplu.suit) {
        if (card.rank == Rank.ace || card.rank == Rank.king) maal += 2;
      }
      // Jokers
      if (card.isJoker) maal += 3;
    }
    return maal;
  }

  /// Get card point value for comparison
  int _cardValue(Card card) {
    if (card.isJoker) return 15; // High value, don't discard
    switch (card.rank) {
      case Rank.ace:
        return 14;
      case Rank.king:
        return 13;
      case Rank.queen:
        return 12;
      case Rank.jack:
        return 11;
      default:
        return card.rank.value;
    }
  }

  /// Calculate how connected a card is to other cards (for discard decision)
  int _connectivity(Card card, List<Card> hand) {
    int connections = 0;
    for (final other in hand) {
      if (other == card) continue;

      // Same suit and adjacent
      if (other.suit == card.suit) {
        final diff = (other.rank.value - card.rank.value).abs();
        if (diff <= 2) connections++;
      }

      // Same rank
      if (other.rank == card.rank) connections++;
    }
    return connections;
  }
}

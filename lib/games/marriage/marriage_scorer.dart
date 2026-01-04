import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';

/// Score calculation for Marriage game (Nepali Style)
class MarriageScorer {
  final PlayingCard? tiplu;
  final MarriageGameConfig config;
  MarriageMaalCalculator? _maalCalculator;

  MarriageScorer({this.tiplu, this.config = const MarriageGameConfig()}) {
    // Initialize calculator with tiplu (if null, Maal = 0)
    if (tiplu != null) {
      _maalCalculator = MarriageMaalCalculator(tiplu: tiplu!, config: config);
    }
  }

  /// Calculate total points (Maal Exchange + Game Points) for all players
  Map<String, int> calculateFinalSettlement({
    required Map<String, List<PlayingCard>> hands, // PlayerId -> Hand
    required Map<String, List<Meld>>
    melds, // PlayerId -> Melds (for Tunella/Validation)
    required String? winnerId,
  }) {
    if (tiplu == null || _maalCalculator == null) {
      return {for (var k in hands.keys) k: 0};
    }

    final playerIds = hands.keys.toList();
    final netScores = {for (var pid in playerIds) pid: 0};
    final maalPoints = <String, int>{};
    final gamePoints = <String, int>{};

    // 1. Calculate Maal Points & Game Points for everyone
    for (final pid in playerIds) {
      // Maal - use null-safe access
      int mp = _maalCalculator!.calculateMaalPoints(hands[pid]!);

      // Add Tunnel points (not in hand Maal calc usually, strictly Meld bonus)
      // Tunnels are worth 5 points
      if (melds[pid] != null) {
        for (final m in melds[pid]!) {
          if (m.type == MeldType.tunnel) {
            mp += 5; // Standard tunnel value
          }
        }
      }

      maalPoints[pid] = mp;

      // Game Points (Deadwood)
      if (pid == winnerId) {
        gamePoints[pid] = 0;
      } else {
        // Calculate Deadwood
        // Note: In Marriage, if you haven't "Seen" (Opened), penalty applies.
        // For simplicity v1.2, we calculate pure deadwood of unmelded cards.
        // Assuming 'melds' passed are valid.
        // If not opened/seen, typically 100 penalty.
        // We use calculateDeadwood method below.
        int deadwood = calculateDeadwood(hands[pid]!);

        // Cap penalty (e.g. 100 points max)
        if (deadwood > config.fullCountPenalty) {
          deadwood = config.fullCountPenalty;
        }
        gamePoints[pid] = deadwood;
      }
    }

    // 2. Perform Payments
    // Pre-calculation: Handle Kidnap/Murder
    if (winnerId != null && (config.enableKidnap || config.enableMurder)) {
      final winnerMaal = maalPoints[winnerId]!;

      for (final pid in playerIds) {
        if (pid == winnerId) continue;

        // Check if player is "Visited" / Unlocked
        // Logic: Must have `config.sequencesRequiredToVisit` pure sequences
        // OR appropriate Dublee count if Dublee visit allowed.
        // For simplicity, we check strictly against Sequence count for standard play.
        int pureCount = 0;
        final pMelds = melds[pid] ?? [];
        for (final m in pMelds) {
          if (isPureSequence(m)) pureCount++;
        }

        bool isVisited = pureCount >= config.sequencesRequiredToVisit;
        // Note: This ignores Dublee visit logic for Kidnap check.
        // Ideally should pass `isVisited` state from GameEngine.
        // But for now, this strictly enforces the 3-sequence rule which is safer/standard.

        if (!isVisited) {
          // Player is "Locked" / Not Visited -> Kidnap/Murder applies
          final victimMaal = maalPoints[pid]!;

          if (config.enableKidnap) {
            // Kidnap: Transfer victim's Maal to Winner
            maalPoints[winnerId] = maalPoints[winnerId]! + victimMaal;
            maalPoints[pid] = 0;
          } else if (config.enableMurder) {
            // Murder: Destroy victim's Maal
            maalPoints[pid] = 0;
            // Winner gets nothing extra, points just vanish
          }
        }
      }
    }

    // 3. Perform Payments (Standard Matrix)
    for (int i = 0; i < playerIds.length; i++) {
      final p1 = playerIds[i];

      for (int j = i + 1; j < playerIds.length; j++) {
        final p2 = playerIds[j];

        // A. Maal Exchange (Between everyone)
        // P1 receives from P2: (P1.Maal - P2.Maal)
        final diff = maalPoints[p1]! - maalPoints[p2]!;
        netScores[p1] = netScores[p1]! + diff;
        netScores[p2] = netScores[p2]! - diff;
      }

      // B. Game Points (Loser pays Winner)
      if (winnerId != null) {
        if (p1 != winnerId) {
          // p1 is Loser, pays gamePoints to Winner
          final points = gamePoints[p1]!;
          netScores[p1] = netScores[p1]! - points;
          netScores[winnerId] = netScores[winnerId]! + points;
        }
      }
    }

    return netScores;
  }

  /// Calculate deadwood points in hand (unmelded cards)
  int calculateDeadwood(List<PlayingCard> hand) {
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
  bool _isWild(PlayingCard card) {
    if (card.isJoker) return true;
    if (tiplu == null) return false;

    // Tiplu: exact match
    if (card.rank == tiplu!.rank && card.suit == tiplu!.suit) return true;

    // Jhiplu: same rank, opposite color (Standard Nepal: Rank-1)
    final tVal = tiplu!.rank.value;
    final cVal = card.rank.value;

    // Poplu: Rank + 1 (same suit)
    int popluVal = tVal == 13 ? 1 : tVal + 1;
    if (card.suit == tiplu!.suit && cVal == popluVal) return true;

    // Jhiplu: Rank - 1 (same suit)
    int jhipluVal = tVal == 1 ? 13 : tVal - 1;
    if (card.suit == tiplu!.suit && cVal == jhipluVal) return true;

    return false;
  }

  /// Check if a meld is a pure sequence (no wildcards used as substitutes)
  bool isPureSequence(Meld meld) {
    // Impure melds are explicitly not pure (they use wildcards)
    if (meld.type == MeldType.impureRun || meld.type == MeldType.impureSet) {
      return false;
    }

    // Pure sequences are RunMeld type (strict consecutiveness, no wildcards)
    if (meld.type == MeldType.run && meld is RunMeld && meld.isValid) {
      return true;
    }

    // Tunnels are also considered "pure" for visit purposes
    if (meld.type == MeldType.tunnel && meld is TunnelMeld && meld.isValid) {
      return true;
    }

    // Sets are valid melds but not "pure sequences" for visit requirement
    return false;
  }

  bool hasPureSequence(List<Meld> melds) {
    return melds.any((m) => isPureSequence(m));
  }

  /// Validate if a player can declare (win)
  (bool, String?) validateDeclaration(
    List<PlayingCard> hand,
    List<Meld> melds,
  ) {
    if (hand.isNotEmpty) {
      return (false, 'Hand must be empty (all cards melded)');
    }

    // Must have at least one pure sequence/tunnel?
    // Standard rule: 3 pure sequences to visit, then anything to end.
    // But if you haven't visited, you need everything pure?
    // For now, if melds cover all cards, it's valid.
    return (true, null);
  }
}

/// Score result for a player
class PlayerScoreResult {
  final String playerId;
  final int score;
  final int maalPoints;
  final int gamePoints;
  final bool isDeclarer;
  final List<int> bonuses;
  final List<String> bonusReasons;

  PlayerScoreResult({
    required this.playerId,
    required this.score,
    required this.maalPoints,
    required this.gamePoints,
    this.isDeclarer = false,
    this.bonuses = const [],
    this.bonusReasons = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'score': score,
      'maalPoints': maalPoints,
      'gamePoints': gamePoints,
      'isDeclarer': isDeclarer,
      'bonuses': bonuses,
      'bonusReasons': bonusReasons,
    };
  }
}

/// Marriage point values
class MarriagePoints {
  static const int fullCountPenalty = 100; // Standard Max
}

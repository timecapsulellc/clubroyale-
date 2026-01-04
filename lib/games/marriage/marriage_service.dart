/// Royal Meld (Marriage) Service - Firebase sync for multiplayer game
///
/// Handles real-time game state synchronization via Firestore
/// Supports both ClubRoyale (Global) and Marriage (South Asian) terminology
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/marriage/marriage_scorer.dart';
import 'package:clubroyale/games/marriage/marriage_visit_validator.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';

/// Provider for Royal Meld (Marriage) Service
final marriageServiceProvider = Provider((ref) => MarriageService());

/// Royal Meld (Marriage) game state stored in Firestore
class MarriageGameState {
  final String tipluCardId; // The wild card for this round
  final Map<String, List<String>> playerHands; // playerId -> card IDs
  final List<String> deckCards; // Remaining deck cards
  final List<String> discardPile; // Discard pile cards
  final String currentPlayerId;
  final int currentRound;
  final String phase; // 'dealing', 'playing', 'scoring'
  final String turnPhase; // 'drawing' or 'discarding' - P0 FIX
  final String? lastDrawnCardId; // Track what was drawn this turn
  final String? lastDiscardedCardId; // Track last discard for Joker block
  final DateTime? turnStartTime; // For turn timer
  final MarriageGameConfig config; // Game configuration

  // === Visiting Collections System ===
  final Map<String, bool> playerVisited; // playerId -> has visited
  final Map<String, String?>
  playerVisitType; // playerId -> 'sequence' or 'dublee'
  final Map<String, int> playerMaalPoints; // playerId -> current Maal points
  final Map<String, List<Map<String, dynamic>>>
  playerDeclaredMelds; // playerId -> list of serialized melds

  MarriageGameState({
    required this.tipluCardId,
    required this.playerHands,
    required this.deckCards,
    required this.discardPile,
    required this.currentPlayerId,
    required this.currentRound,
    required this.phase,
    this.turnPhase = 'drawing',
    this.lastDrawnCardId,
    this.lastDiscardedCardId,
    this.turnStartTime,
    this.config = const MarriageGameConfig(),
    this.playerVisited = const {},
    this.playerVisitType = const {},
    this.playerMaalPoints = const {},
    this.playerDeclaredMelds = const {},
  });

  factory MarriageGameState.fromJson(Map<String, dynamic> json) {
    return MarriageGameState(
      tipluCardId: json['tipluCardId'] ?? '',
      playerHands:
          (json['playerHands'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v as List)),
          ) ??
          {},
      deckCards: List<String>.from(json['deckCards'] ?? []),
      discardPile: List<String>.from(json['discardPile'] ?? []),
      currentPlayerId: json['currentPlayerId'] ?? '',
      currentRound: json['currentRound'] ?? 1,
      phase: json['phase'] ?? 'waiting',
      turnPhase: json['turnPhase'] ?? 'drawing',
      lastDrawnCardId: json['lastDrawnCardId'],
      lastDiscardedCardId: json['lastDiscardedCardId'],
      turnStartTime: json['turnStartTime'] != null
          ? DateTime.tryParse(json['turnStartTime'])
          : null,
      config: json['config'] != null
          ? MarriageGameConfig.fromJson(json['config'] as Map<String, dynamic>)
          : const MarriageGameConfig(),
      // Visiting fields
      playerVisited:
          (json['playerVisited'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool),
          ) ??
          {},
      playerVisitType:
          (json['playerVisitType'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String?),
          ) ??
          {},
      playerMaalPoints:
          (json['playerMaalPoints'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      playerDeclaredMelds:
          (json['playerDeclaredMelds'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v as List)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
    'tipluCardId': tipluCardId,
    'playerHands': playerHands,
    'deckCards': deckCards,
    'discardPile': discardPile,
    'currentPlayerId': currentPlayerId,
    'currentRound': currentRound,
    'phase': phase,
    'turnPhase': turnPhase,
    'lastDrawnCardId': lastDrawnCardId,
    'lastDiscardedCardId': lastDiscardedCardId,
    'turnStartTime': turnStartTime?.toIso8601String(),
    'config': config.toJson(),
    'playerVisited': playerVisited,
    'playerVisitType': playerVisitType,
    'playerMaalPoints': playerMaalPoints,
    'playerDeclaredMelds': playerDeclaredMelds,
  };

  /// Check if player has drawn this turn
  bool get hasDrawnThisTurn => turnPhase == 'discarding';

  /// Check if in drawing phase
  bool get isDrawingPhase => turnPhase == 'drawing';

  /// Check if in discarding phase
  bool get isDiscardingPhase => turnPhase == 'discarding';

  /// Check if a specific player has visited
  bool hasVisited(String playerId) => playerVisited[playerId] ?? false;

  /// Get a player's visit type
  String? getVisitType(String playerId) => playerVisitType[playerId];

  /// Get a player's current Maal points
  int getMaalPoints(String playerId) => playerMaalPoints[playerId] ?? 0;

  /// Get remaining turn time in seconds (for timeout warning)
  int? get turnTimeRemaining {
    if (turnStartTime == null) return null;
    final elapsed = DateTime.now().difference(turnStartTime!).inSeconds;
    final remaining = config.turnTimeoutSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }
}

class MarriageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Start a new Marriage game with configurable rules
  Future<void> startGame(
    String roomId,
    List<String> playerIds, {
    MarriageGameConfig config = const MarriageGameConfig(),
  }) async {
    // Use 4 decks for 6-8 players, 3 decks for 2-5 players
    final requiredDecks = playerIds.length > 5 ? 4 : 3;
    final deck = Deck.forMarriage(deckCount: requiredDecks);
    deck.shuffle();

    // Deal cards to each player (configurable cards per player)
    final playerHands = <String, List<String>>{};
    for (final playerId in playerIds) {
      final hand = <String>[];
      for (int i = 0; i < config.cardsPerPlayer; i++) {
        final card = deck.drawCard();
        if (card != null) {
          hand.add(card.id);
        }
      }
      playerHands[playerId] = hand;
    }

    // Draw tiplu (wild card)
    final tiplu = deck.drawCard();

    // Put first card on discard pile
    final firstDiscard = deck.drawCard();

    // Remaining deck
    final deckCards = deck.cards.map((c) => c.id).toList();

    // Check for Start-of-Game Tunnela Bonus
    // Authentic Rule: Tunnela at start gives immediate bonus points
    final initialMaalPoints = <String, int>{};
    if (config.tunnelBonus) {
      for (final playerId in playerIds) {
        final handIds = playerHands[playerId] ?? [];
        final hand = handIds
            .map((id) => _getCard(id))
            .whereType<PlayingCard>()
            .toList();

        final tunnels = MeldDetector.findTunnels(hand);
        if (tunnels.isNotEmpty) {
          final points = tunnels.length * config.tunnelDisplayBonusValue;
          initialMaalPoints[playerId] = points;
        }
      }
    }

    // Create game state with config and turnPhase initialized to 'drawing'
    final gameState = MarriageGameState(
      tipluCardId: tiplu?.id ?? '',
      playerHands: playerHands,
      deckCards: deckCards,
      discardPile: firstDiscard != null ? [firstDiscard.id] : [],
      currentPlayerId: playerIds.first,
      currentRound: 1,
      phase: 'playing',
      turnPhase: 'drawing', // P0 FIX: Start in drawing phase
      turnStartTime: DateTime.now(), // P1: Turn timer start
      config: config, // Store the host's rule configuration
      playerMaalPoints: initialMaalPoints,
    );

    // Save to Firestore
    await _firestore.collection('games').doc(roomId).update({
      'status': 'playing',
      'marriageState': gameState.toJson(),
    });
  }

  /// Watch Marriage game state
  Stream<MarriageGameState?> watchGameState(String roomId) {
    return _firestore.collection('games').doc(roomId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null || data['marriageState'] == null) return null;
      return MarriageGameState.fromJson(
        data['marriageState'] as Map<String, dynamic>,
      );
    });
  }

  /// Draw card from deck
  Future<String?> drawFromDeck(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return null;

    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );

    if (state.currentPlayerId != playerId) return null;
    if (state.deckCards.isEmpty) return null;
    // P0 FIX: Validate player is in drawing phase
    if (state.turnPhase != 'drawing') return null;

    // Draw top card
    final drawnCardId = state.deckCards.last;
    final newDeck = List<String>.from(state.deckCards)..removeLast();

    // Add to player's hand
    final newHands = Map<String, List<String>>.from(state.playerHands);
    newHands[playerId] = [...(newHands[playerId] ?? []), drawnCardId];

    // Update Firestore - P0 FIX: Set turnPhase to 'discarding'
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.deckCards': newDeck,
      'marriageState.playerHands.$playerId': newHands[playerId],
      'marriageState.turnPhase': 'discarding',
      'marriageState.lastDrawnCardId': drawnCardId,
    });

    return drawnCardId;
  }

  /// Draw card from discard pile
  Future<String?> drawFromDiscard(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return null;

    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );

    if (state.currentPlayerId != playerId) return null;
    if (state.discardPile.isEmpty) return null;
    // P0 FIX: Validate player is in drawing phase
    if (state.turnPhase != 'drawing') return null;

    // ===== VISITING RESTRICTION =====
    // If mustVisitToPickDiscard is enabled, player cannot pick from discard until visited
    if (state.config.mustVisitToPickDiscard && !state.hasVisited(playerId)) {
      return null; // Must visit before picking from discard
    }

    // ===== JOKER BLOCK RULE =====
    // If the last discarded card was a Joker or Wild, player MUST draw from deck
    if (state.discardPile.isNotEmpty && state.config.jokerBlocksDiscard) {
      final topCardId = state.discardPile.last;
      if (_isBlockedCard(topCardId, state.tipluCardId, state.config)) {
        return null; // Cannot pick from discard, must use deck
      }
    }

    // ===== WILD CARD PICKUP RESTRICTION =====
    // If canPickupWildFromDiscard is false, block Tiplu/Jhiplu/Poplu pickup
    if (!state.config.canPickupWildFromDiscard &&
        state.discardPile.isNotEmpty) {
      final topCardId = state.discardPile.last;
      if (_isWildCard(topCardId, state.tipluCardId)) {
        return null; // Cannot pick wild cards from discard
      }
    }

    // Draw top card from discard
    final drawnCardId = state.discardPile.last;
    final newDiscard = List<String>.from(state.discardPile)..removeLast();

    // Add to player's hand
    final newHands = Map<String, List<String>>.from(state.playerHands);
    newHands[playerId] = [...(newHands[playerId] ?? []), drawnCardId];

    // Update Firestore - P0 FIX: Set turnPhase to 'discarding'
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.discardPile': newDiscard,
      'marriageState.playerHands.$playerId': newHands[playerId],
      'marriageState.turnPhase': 'discarding',
      'marriageState.lastDrawnCardId': drawnCardId,
    });

    return drawnCardId;
  }

  /// Discard a card
  Future<void> discardCard(
    String roomId,
    String playerId,
    String cardId,
  ) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return;

    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );

    if (state.currentPlayerId != playerId) return;
    // P0 FIX: Validate player is in discarding phase
    if (state.turnPhase != 'discarding') return;

    // Remove from player's hand
    final newHands = Map<String, List<String>>.from(state.playerHands);
    newHands[playerId] = (newHands[playerId] ?? [])..remove(cardId);

    // Add to discard pile
    final newDiscard = [...state.discardPile, cardId];

    // Move to next player
    final playerIds = state.playerHands.keys.toList();
    final currentIndex = playerIds.indexOf(playerId);
    final nextIndex = (currentIndex + 1) % playerIds.length;
    final nextPlayerId = playerIds[nextIndex];

    // Update Firestore - P0 FIX: Reset turnPhase to 'drawing' for next player
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.discardPile': newDiscard,
      'marriageState.playerHands.$playerId': newHands[playerId],
      'marriageState.currentPlayerId': nextPlayerId,
      'marriageState.turnPhase': 'drawing', // Reset for next player
      'marriageState.lastDrawnCardId': null, // Clear drawn card
      'marriageState.lastDiscardedCardId': cardId, // Track for Joker block
      'marriageState.turnStartTime': DateTime.now()
          .toIso8601String(), // P1: Reset timer
    });
  }

  /// Attempt to "Visit" - show 3 pure sequences to unlock Maal access
  /// Returns (success, visitType, reason)
  Future<(bool, String?, String?)> attemptVisit(
    String roomId,
    String playerId,
  ) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) {
      return (false, null, 'Game not found');
    }

    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );

    // Already visited?
    if (state.hasVisited(playerId)) {
      return (false, state.getVisitType(playerId), 'Already visited');
    }

    // Get player's hand as Card objects
    final handIds = state.playerHands[playerId] ?? [];
    final hand = handIds.map((id) => _getCard(id)).whereType<Card>().toList();

    // Get tiplu card
    final tiplu = _getCard(state.tipluCardId);

    // Validate visiting
    final validator = MarriageVisitValidator(
      config: state.config,
      tiplu: tiplu,
    );

    final result = validator.attemptVisit(hand);

    if (!result.canVisit) {
      return (false, null, result.reason);
    }

    // Calculate Maal points for this player
    // Calculate Maal points for this player
    int maalPoints = 0;
    if (tiplu != null) {
      final maalCalculator = MarriageMaalCalculator(
        tiplu: tiplu,
        config: state.config,
      );
      maalPoints = maalCalculator.calculateMaalPoints(hand);
    }

    // Persist melds and update hand
    final serializedMelds = result.validMelds.map((m) => m.toJson()).toList();
    final meldCardIds = result.validMelds
        .expand((m) => m.cards.map((c) => c.id))
        .toSet();
    final currentHand = state.playerHands[playerId] ?? [];
    final newHand = currentHand
        .where((id) => !meldCardIds.contains(id))
        .toList();

    // Update Firestore with visited status
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.playerVisited.$playerId': true,
      'marriageState.playerVisitType.$playerId': result.visitType.name,
      'marriageState.playerMaalPoints.$playerId': maalPoints,
      'marriageState.playerDeclaredMelds.$playerId': serializedMelds,
      'marriageState.playerHands.$playerId': newHand,
    });

    return (true, result.visitType.name, null);
  }

  /// Declare/show hand (attempt to win)
  Future<bool> declare(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return false;

    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );

    if (state.currentPlayerId != playerId) return false;

    // Get player's hand as Card objects
    final handIds = List<String>.from(state.playerHands[playerId] ?? []);

    // Add declared meld cards (recombine for validation)
    final declaredMelds = state.playerDeclaredMelds[playerId] ?? [];
    for (final meld in declaredMelds) {
      handIds.addAll(List<String>.from(meld['cardIds'] ?? []));
    }
    final hand = handIds.map((id) => _getCard(id)).whereType<Card>().toList();

    // Get tiplu card
    final tiplu = _getCard(state.tipluCardId);

    // Initialize scorer with config
    final scorer = MarriageScorer(tiplu: tiplu, config: state.config);

    // Find all melds in the player's hand
    final melds = MeldDetector.findAllMelds(hand, tiplu: tiplu);

    // Validate the declaration
    final (isValid, errorReason) = scorer.validateDeclaration(hand, melds);

    if (!isValid) {
      // Invalid declaration - player cannot declare
      // Return false so UI can show error to player
      return false;
    }

    // Calculate scores for all players
    // Calculate final scores using the full Nepali algorithm
    final scores = _calculateFinalScores(
      state: state,
      declarerId: playerId,
      tiplu: tiplu,
      config: state.config,
    );

    // Convert to simple map for Firestore
    final simpleScores = <String, int>{};
    final scoreDetails = <String, Map<String, dynamic>>{};

    for (final result in scores) {
      simpleScores[result.playerId] = result.score;
      scoreDetails[result.playerId] = result.toJson();
    }

    // Update game state to scoring phase with results
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.phase': 'scoring',
      'marriageState.roundScores': simpleScores,
      'marriageState.scoreDetails': scoreDetails,
      'marriageState.declarerId': playerId,
      'status': 'finished',
    });

    return true;
  }

  // Calculate final scores using base points + Maal exchange + Kidnap/Murder
  List<PlayerScoreResult> _calculateFinalScores({
    required MarriageGameState state,
    required String declarerId,
    required Card? tiplu,
    required MarriageGameConfig config,
  }) {
    final playerIds = state.playerHands.keys.toList();
    final results = <PlayerScoreResult>[];

    // 1. Calculate Maal Points for everyone
    final maalPointsMap = <String, int>{};
    final maalCalculator = tiplu != null
        ? MarriageMaalCalculator(tiplu: tiplu, config: config)
        : null;

    for (final pid in playerIds) {
      final handIds = state.playerHands[pid] ?? [];
      final hand = handIds.map((id) => _getCard(id)).whereType<Card>().toList();
      maalPointsMap[pid] = maalCalculator?.calculateMaalPoints(hand) ?? 0;
    }

    // 2. Determine base game points and apply Kidnap/Murder rules
    for (final pid in playerIds) {
      int totalScore = 0;
      final bonuses = <int>[];
      final bonusReasons = <String>[];

      final isDeclarer = pid == declarerId;
      final isVisited = state.hasVisited(pid);

      // --- A. Base Game Points ---
      if (isDeclarer) {
        // Winner gets points from everyone else
        for (final otherPid in playerIds) {
          if (otherPid == pid) continue;

          final otherVisited = state.hasVisited(otherPid);
          if (otherVisited) {
            // Visited loser pays 3 points (or configured amount)
            totalScore += config.visitedPenalty;
          } else {
            // Unvisited loser pays 10 points (or configured amount)
            totalScore += config.unvisitedPenalty;
          }
        }
        bonuses.add(totalScore);
        bonusReasons.add('Game Win');
      } else {
        // Loser pays winner
        final penalty = isVisited
            ? config.visitedPenalty
            : config.unvisitedPenalty;
        totalScore -= penalty;
        bonuses.add(-penalty);
        bonusReasons.add(isVisited ? 'Lost (Visited)' : 'Lost (Unvisited)');
      }

      // --- B. Maal Exchange & Kidnap/Murder ---
      for (final otherPid in playerIds) {
        if (otherPid == pid) continue;

        final myMaal = maalPointsMap[pid] ?? 0;
        final otherMaal = maalPointsMap[otherPid] ?? 0;
        final otherVisited = state.hasVisited(otherPid);

        int myEffectiveMaal = myMaal;
        int otherEffectiveMaal = otherMaal;

        // KIDNAP / MURDER LOGIC
        // If config requires visit for maal, unvisited players have 0 effective maal
        if (!isVisited) {
          myEffectiveMaal = 0;
        }
        if (!otherVisited) {
          otherEffectiveMaal = 0;
        }

        // Specific Kidnap Rule: If I am winner and opponent not visited, I get their maal points
        // (But usually in standard Maal exchange, unvisited just counts as 0, so net is MyMaal - 0 = +MyMaal)
        // (Kidnap usually means: Winner gets Opponent's ACTUAL points added to theirs? Or just treat opponent as 0?)
        // Standard "Kidnap" implementation:
        // If Opponent Not Visited -> They contribute 0 to the exchange calculation
        // But if "enableKidnap" is true, the Winner explicitly "steals" points?
        // Let's follow the standard "Net = MyMaal - OpponentMaal" logic where unvisited = 0.

        // Calculate net exchange
        final exchange = myEffectiveMaal - otherEffectiveMaal;
        totalScore += exchange;

        // Add reason if significant
        if (exchange != 0) {
          // bonuses.add(exchange);
          // bonusReasons.add('Maal vs $otherPid');
        }
      }

      results.add(
        PlayerScoreResult(
          playerId: pid,
          score: totalScore,
          maalPoints: maalPointsMap[pid] ?? 0, // Fix scope issue
          gamePoints: 0,
          isDeclarer: isDeclarer,
          bonuses: bonuses,
          bonusReasons: bonusReasons,
        ),
      );
    }

    return results;
  }

  /// Static card lookup cache
  static final Map<String, Card> _cardCache = {};

  /// Build card cache from deck
  static void _buildCardCache() {
    if (_cardCache.isNotEmpty) return;

    // Build full deck for lookups
    for (int deckIdx = 0; deckIdx < 4; deckIdx++) {
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          final card = Card(rank: rank, suit: suit, deckIndex: deckIdx);
          _cardCache[card.id] = card;
        }
      }
      // Add jokers
      final joker = Card.joker(deckIdx);
      _cardCache[joker.id] = joker;
    }
  }

  /// Get card from ID
  static Card? _getCard(String cardId) {
    _buildCardCache();
    return _cardCache[cardId];
  }

  /// Check if a card is a Joker (printed joker)
  static bool _isJoker(String cardId) {
    return cardId.startsWith('joker');
  }

  /// Check if a card is a Wild card (Tiplu, Jhiplu, or Poplu)
  static bool _isWildCard(String cardId, String tipluCardId) {
    if (_isJoker(cardId)) return true;
    if (tipluCardId.isEmpty) return false;

    final card = _getCard(cardId);
    final tiplu = _getCard(tipluCardId);
    if (card == null || tiplu == null) return false;

    // Exact Tiplu match (same rank and suit)
    if (card.rank == tiplu.rank && card.suit == tiplu.suit) return true;

    // Jhiplu: Same rank, alternating color suits
    if (card.rank == tiplu.rank) {
      final tipluIsRed = tiplu.suit.isRed;
      final cardIsRed = card.suit.isRed;
      if (tipluIsRed != cardIsRed) return true; // Opposite color = Jhiplu
    }

    // Poplu: Next rank above Tiplu, same suit
    if (card.suit == tiplu.suit) {
      final tipluValue = tiplu.rank.value;
      final cardValue = card.rank.value;
      // Handle wrap-around: K (13) -> A (1), otherwise value + 1
      final popluValue = tipluValue == 13 ? 1 : tipluValue + 1;
      if (cardValue == popluValue) return true;
    }

    return false;
  }

  /// Check if a card blocks picking from discard (Joker or Wild based on config)
  static bool _isBlockedCard(
    String cardId,
    String tipluCardId,
    MarriageGameConfig config,
  ) {
    // Printed Jokers always block if jokerBlocksDiscard is enabled
    if (_isJoker(cardId)) return true;

    // Wild cards (Tiplu/Jhiplu/Poplu) only block if canPickupWildFromDiscard is false
    if (!config.canPickupWildFromDiscard && _isWildCard(cardId, tipluCardId)) {
      return true;
    }

    return false;
  }

  // ========== TURN TIMER METHODS ==========

  /// Check if current player's turn has timed out
  bool hasTurnTimedOut(MarriageGameState state) {
    if (state.config.turnTimeoutSeconds == 0) return false; // No timeout
    if (state.turnStartTime == null) return false;

    final elapsed = DateTime.now().difference(state.turnStartTime!);
    return elapsed.inSeconds >= state.config.turnTimeoutSeconds;
  }

  /// Get remaining seconds for current turn
  int getRemainingTurnTime(MarriageGameState state) {
    if (state.config.turnTimeoutSeconds == 0) return -1; // No timeout
    if (state.turnStartTime == null) return state.config.turnTimeoutSeconds;

    final elapsed = DateTime.now().difference(state.turnStartTime!);
    final remaining = state.config.turnTimeoutSeconds - elapsed.inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  /// Auto-play for a timed-out player
  /// This should be called by a server-side function or a client that detects timeout
  Future<void> autoPlayTimeout(String roomId, String playerId) async {
    final doc = await _firestore.collection('games').doc(roomId).get();
    final data = doc.data();
    if (data == null || data['marriageState'] == null) return;

    final state = MarriageGameState.fromJson(
      data['marriageState'] as Map<String, dynamic>,
    );

    // Only auto-play for current player
    if (state.currentPlayerId != playerId) return;

    // Check if turn actually timed out
    if (!hasTurnTimedOut(state)) return;

    if (state.turnPhase == 'drawing') {
      // Auto-draw from deck
      await drawFromDeck(roomId, playerId);

      // If draw succeeded, also auto-discard to complete the turn
      final updatedDoc = await _firestore.collection('games').doc(roomId).get();
      final updatedData = updatedDoc.data();
      if (updatedData != null && updatedData['marriageState'] != null) {
        final updatedState = MarriageGameState.fromJson(
          updatedData['marriageState'] as Map<String, dynamic>,
        );

        if (updatedState.turnPhase == 'discarding') {
          // Discard the last drawn card (if available) or first card in hand
          final hand = updatedState.playerHands[playerId] ?? [];
          String? cardToDiscard = updatedState.lastDrawnCardId;

          if (cardToDiscard == null || !hand.contains(cardToDiscard)) {
            cardToDiscard = hand.isNotEmpty ? hand.first : null;
          }

          if (cardToDiscard != null) {
            await discardCard(roomId, playerId, cardToDiscard);
          }
        }
      }
    } else if (state.turnPhase == 'discarding') {
      // Auto-discard the first card in hand (or last drawn if available)
      final hand = state.playerHands[playerId] ?? [];
      String? cardToDiscard = state.lastDrawnCardId;

      if (cardToDiscard == null || !hand.contains(cardToDiscard)) {
        cardToDiscard = hand.isNotEmpty ? hand.first : null;
      }

      if (cardToDiscard != null) {
        await discardCard(roomId, playerId, cardToDiscard);
      }
    }
  }
}

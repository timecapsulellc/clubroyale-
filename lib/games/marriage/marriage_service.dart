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

/// Provider for Royal Meld (Marriage) Service
final marriageServiceProvider = Provider((ref) => MarriageService());

/// Royal Meld (Marriage) game state stored in Firestore
class MarriageGameState {

  final String tipluCardId;  // The wild card for this round
  final Map<String, List<String>> playerHands;  // playerId -> card IDs
  final List<String> deckCards;  // Remaining deck cards
  final List<String> discardPile;  // Discard pile cards
  final String currentPlayerId;
  final int currentRound;
  final String phase;  // 'dealing', 'playing', 'scoring'
  final String turnPhase;  // 'drawing' or 'discarding' - P0 FIX
  final String? lastDrawnCardId;  // Track what was drawn this turn
  final String? lastDiscardedCardId;  // Track last discard for Joker block
  final DateTime? turnStartTime;  // For turn timer
  final MarriageGameConfig config;  // Game configuration
  
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
  });
  
  factory MarriageGameState.fromJson(Map<String, dynamic> json) {
    return MarriageGameState(
      tipluCardId: json['tipluCardId'] ?? '',
      playerHands: (json['playerHands'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, List<String>.from(v as List)),
      ) ?? {},
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
  };
  
  /// Check if player has drawn this turn
  bool get hasDrawnThisTurn => turnPhase == 'discarding';
  
  /// Check if in drawing phase
  bool get isDrawingPhase => turnPhase == 'drawing';
  
  /// Check if in discarding phase
  bool get isDiscardingPhase => turnPhase == 'discarding';
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
    
    // Create game state with config and turnPhase initialized to 'drawing'
    final gameState = MarriageGameState(
      tipluCardId: tiplu?.id ?? '',
      playerHands: playerHands,
      deckCards: deckCards,
      discardPile: firstDiscard != null ? [firstDiscard.id] : [],
      currentPlayerId: playerIds.first,
      currentRound: 1,
      phase: 'playing',
      turnPhase: 'drawing',  // P0 FIX: Start in drawing phase
      turnStartTime: DateTime.now(),  // P1: Turn timer start
      config: config,  // Store the host's rule configuration
    );
    
    // Save to Firestore
    await _firestore.collection('games').doc(roomId).update({
      'status': 'playing',
      'marriageState': gameState.toJson(),
    });
  }
  
  /// Watch Marriage game state
  Stream<MarriageGameState?> watchGameState(String roomId) {
    return _firestore
        .collection('games')
        .doc(roomId)
        .snapshots()
        .map((snap) {
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
    if (!state.config.canPickupWildFromDiscard && state.discardPile.isNotEmpty) {
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
  Future<void> discardCard(String roomId, String playerId, String cardId) async {
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
      'marriageState.turnPhase': 'drawing',  // Reset for next player
      'marriageState.lastDrawnCardId': null,  // Clear drawn card
      'marriageState.lastDiscardedCardId': cardId,  // Track for Joker block
      'marriageState.turnStartTime': DateTime.now().toIso8601String(),  // P1: Reset timer
    });
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
    final handIds = state.playerHands[playerId] ?? [];
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
    final scores = <String, int>{};
    final scoreResults = <String, Map<String, dynamic>>{};
    
    for (final pid in state.playerHands.keys) {
      final playerHandIds = state.playerHands[pid] ?? [];
      final playerHand = playerHandIds.map((id) => _getCard(id)).whereType<Card>().toList();
      final playerMelds = MeldDetector.findAllMelds(playerHand, tiplu: tiplu);
      
      final score = scorer.calculateRoundScore(
        hand: playerHand,
        melds: playerMelds,
        isDeclarer: pid == playerId,
        isValidDeclaration: true, // Declaration was validated above
      );
      
      scores[pid] = score;
      scoreResults[pid] = {
        'score': score,
        'isDeclarer': pid == playerId,
        'meldCount': playerMelds.length,
        'hasPureSequence': scorer.hasPureSequence(playerMelds),
        'hasDublee': scorer.hasDublee(playerMelds),
        'marriageCount': scorer.countMarriages(playerMelds),
      };
    }
    
    // Update game state to scoring phase with results
    await _firestore.collection('games').doc(roomId).update({
      'marriageState.phase': 'scoring',
      'marriageState.roundScores': scores,
      'marriageState.scoreDetails': scoreResults,
      'marriageState.declarerId': playerId,
      'status': 'finished',
    });
    
    return true;
  }
  
  // ========== HELPER METHODS FOR RULE ENFORCEMENT ==========
  
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
  static bool _isBlockedCard(String cardId, String tipluCardId, MarriageGameConfig config) {
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

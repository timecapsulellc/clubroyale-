/// Marriage Bot Controller
/// 
/// Manages bot turns and integrates MarriageBotStrategy with game state
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:clubroyale/games/marriage/marriage_bot.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Controller for Marriage bot automation
class MarriageBotController {
  final MarriageService _service;
  final String roomId;
  StreamSubscription? _gameSubscription;
  bool _isProcessing = false;
  MarriageGameState? _lastState;
  
  // Bot strategies for each difficulty
  final Map<String, MarriageBotStrategy> _botStrategies = {};
  
  MarriageBotController({
    required MarriageService service,
    required this.roomId,
  }) : _service = service;
  
  /// Start monitoring for bot turns
  void startMonitoring() {
    debugPrint('MarriageBotController: Starting monitoring for room $roomId');
    
    // Subscribe to game state changes
    _gameSubscription = _service.watchGameState(roomId).listen((state) {
      _lastState = state;
      _checkBotTurn();
    });
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _gameSubscription?.cancel();
    _gameSubscription = null;
    debugPrint('MarriageBotController: Stopped monitoring');
  }
  
  /// Check if current turn belongs to a bot and process it
  Future<void> _checkBotTurn() async {
    if (_isProcessing) return;
    
    final state = _lastState;
    if (state == null) return;
    if (state.phase == 'finished' || state.phase == 'scoring') return;
    
    final currentPlayerId = state.currentPlayerId;
    if (currentPlayerId.isEmpty) return;
    
    // Check if current player is a bot (starts with 'bot_')
    if (!currentPlayerId.startsWith('bot_')) return;
    
    _isProcessing = true;
    
    try {
      // Add delay for natural feel
      await Future.delayed(const Duration(milliseconds: 1500));
      await _processBotTurn(state, currentPlayerId);
    } catch (e) {
      debugPrint('MarriageBotController Error: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Process a bot's turn
  Future<void> _processBotTurn(MarriageGameState state, String botId) async {
    debugPrint('MarriageBotController: Processing turn for $botId');
    
    // Get or create bot strategy
    final strategy = _getStrategy(botId);
    
    // Get bot's hand as Card objects
    final handIds = state.playerHands[botId] ?? [];
    final hand = handIds.map((id) => _parseCard(id)).whereType<Card>().toList();
    
    if (hand.isEmpty) return;
    
    // Get tiplu card
    final tiplu = _parseCard(state.tipluCardId);
    
    // Check if bot has visited
    final hasVisited = state.hasVisited(botId);
    
    // Check if bot should try to visit first
    if (!hasVisited) {
      final shouldVisit = strategy.shouldAttemptVisit(
        hand: hand,
        tiplu: tiplu,
        requiredSequences: state.config.sequencesRequiredToVisit,
      );
      
      if (shouldVisit) {
        debugPrint('MarriageBotController: $botId attempting to visit');
        final result = await _service.attemptVisit(roomId, botId);
        if (result.$1) {
          debugPrint('MarriageBotController: $botId visited successfully!');
        }
      }
    }
    
    // Check if bot can declare (win)
    final updatedHasVisited = state.hasVisited(botId) || 
        (await _getUpdatedVisitStatus(botId));
    
    if (strategy.shouldDeclare(hand: hand, tiplu: tiplu, hasVisited: updatedHasVisited)) {
      debugPrint('MarriageBotController: $botId attempting to declare');
      final declared = await _service.declare(roomId, botId);
      if (declared) {
        debugPrint('MarriageBotController: $botId declared and won!');
        return;
      }
    }
    
    // Normal turn: Draw and Discard
    if (state.turnPhase == 'drawing') {
      await _performDraw(state, botId, hand, tiplu, strategy);
    } else if (state.turnPhase == 'discarding') {
      await _performDiscard(state, botId, tiplu, strategy);
    }
  }
  
  /// Perform the draw action
  Future<void> _performDraw(
    MarriageGameState state,
    String botId,
    List<Card> hand,
    Card? tiplu,
    MarriageBotStrategy strategy,
  ) async {
    // Check discard pile
    final topDiscardId = state.discardPile.isNotEmpty ? state.discardPile.last : null;
    final topDiscard = topDiscardId != null ? _parseCard(topDiscardId) : null;
    
    // Can bot pick from discard?
    bool canPickFromDiscard = topDiscard != null;
    
    // Check visiting requirement
    if (state.config.mustVisitToPickDiscard && !state.hasVisited(botId)) {
      canPickFromDiscard = false;
    }
    
    // Check Joker block
    if (topDiscardId != null && state.config.jokerBlocksDiscard) {
      if (_isBlockedCard(topDiscardId, state.tipluCardId, state.config)) {
        canPickFromDiscard = false;
      }
    }
    
    // Decide draw source
    final drawFromDeck = strategy.shouldDrawFromDeck(
      hand: hand,
      topDiscard: topDiscard,
      tiplu: tiplu,
      hasVisited: state.hasVisited(botId),
      canPickFromDiscard: canPickFromDiscard,
    );
    
    if (drawFromDeck) {
      debugPrint('MarriageBotController: $botId drawing from deck');
      await _service.drawFromDeck(roomId, botId);
    } else {
      debugPrint('MarriageBotController: $botId drawing from discard');
      await _service.drawFromDiscard(roomId, botId);
    }
    
    // Small delay before discarding
    await Future.delayed(const Duration(milliseconds: 800));
  }
  
  /// Perform the discard action
  Future<void> _performDiscard(
    MarriageGameState state,
    String botId,
    Card? tiplu,
    MarriageBotStrategy strategy,
  ) async {
    // Get fresh hand (includes newly drawn card)
    final handIds = state.playerHands[botId] ?? [];
    final hand = handIds.map((id) => _parseCard(id)).whereType<Card>().toList();
    
    if (hand.isEmpty) return;
    
    // Check last drawn card
    final lastDrawnCard = state.lastDrawnCardId != null 
        ? _parseCard(state.lastDrawnCardId!)
        : null;
    
    // Choose card to discard
    final cardToDiscard = strategy.chooseDiscard(
      hand: hand,
      tiplu: tiplu,
      lastDrawnCard: lastDrawnCard,
    );
    
    debugPrint('MarriageBotController: $botId discarding ${cardToDiscard.id}');
    await _service.discardCard(roomId, botId, cardToDiscard.id);
  }
  
  /// Get updated visit status (in case we just visited)
  Future<bool> _getUpdatedVisitStatus(String botId) async {
    // Re-check state
    final state = _lastState;
    return state?.hasVisited(botId) ?? false;
  }
  
  /// Get strategy for a bot (create if needed)
  MarriageBotStrategy _getStrategy(String botId) {
    if (!_botStrategies.containsKey(botId)) {
      // Assign difficulty based on bot number
      final difficulty = _getDifficultyForBot(botId);
      _botStrategies[botId] = MarriageBotStrategy(difficulty: difficulty);
    }
    return _botStrategies[botId]!;
  }
  
  /// Assign difficulty based on bot ID
  MarriageBotDifficulty _getDifficultyForBot(String botId) {
    if (botId.contains('1')) return MarriageBotDifficulty.easy;
    if (botId.contains('2')) return MarriageBotDifficulty.medium;
    return MarriageBotDifficulty.hard;
  }
  
  /// Parse card ID to Card object
  Card? _parseCard(String? cardId) {
    if (cardId == null || cardId.isEmpty) return null;
    
    try {
      // Handle jokers
      if (cardId.startsWith('joker')) {
        final parts = cardId.split('_');
        final deckIndex = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        return Card.joker(deckIndex);
      }
      
      // Format: rank_suit or rank_suit_deckIndex
      final parts = cardId.split('_');
      if (parts.length < 2) return null;
      
      final rankName = parts[0];
      final suitName = parts[1];
      final deckIndex = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
      
      final rank = Rank.values.firstWhere(
        (r) => r.name.toLowerCase() == rankName.toLowerCase(),
        orElse: () => Rank.ace,
      );
      
      final suit = Suit.values.firstWhere(
        (s) => s.name.toLowerCase() == suitName.toLowerCase(),
        orElse: () => Suit.spades,
      );
      
      return Card(rank: rank, suit: suit, deckIndex: deckIndex);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a card blocks picking from discard
  bool _isBlockedCard(String cardId, String tipluCardId, dynamic config) {
    // Jokers always block
    if (cardId.startsWith('joker')) return true;
    
    // Wild cards might block based on config
    if (tipluCardId.isEmpty) return false;
    
    final card = _parseCard(cardId);
    final tiplu = _parseCard(tipluCardId);
    if (card == null || tiplu == null) return false;
    
    // Tiplu itself blocks
    if (card.rank == tiplu.rank && card.suit == tiplu.suit) return true;
    
    return false;
  }
  
  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _botStrategies.clear();
  }
}

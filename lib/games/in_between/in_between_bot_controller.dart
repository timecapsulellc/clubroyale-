/// In Between Bot Controller
///
/// Manages bot turns and integrates InBetweenBotStrategy with game state
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:clubroyale/games/in_between/in_between_bot.dart';
import 'package:clubroyale/games/in_between/in_between_service.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Controller for In Between bot automation
class InBetweenBotController {
  final InBetweenService _service;
  final String roomId;
  Timer? _botTimer;
  StreamSubscription? _gameSubscription;
  bool _isProcessing = false;
  InBetweenGameState? _lastState;

  // Bot strategies for each difficulty
  final Map<String, InBetweenBotStrategy> _botStrategies = {};

  InBetweenBotController({
    required InBetweenService service,
    required this.roomId,
  }) : _service = service;

  /// Start monitoring for bot turns
  void startMonitoring() {
    debugPrint('InBetweenBotController: Starting monitoring for room $roomId');

    // Subscribe to game state changes
    _gameSubscription = _service.watchGameState(roomId).listen((state) {
      _lastState = state;
      _checkBotTurn();
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _botTimer?.cancel();
    _gameSubscription?.cancel();
    _botTimer = null;
    _gameSubscription = null;
    debugPrint('InBetweenBotController: Stopped monitoring');
  }

  /// Check if current turn belongs to a bot and process it
  Future<void> _checkBotTurn() async {
    if (_isProcessing) return;

    final state = _lastState;
    if (state == null) return;

    final currentPlayerId = state.currentPlayerId;
    if (currentPlayerId.isEmpty) return;

    // Check if current player is a bot (starts with 'bot_')
    if (!currentPlayerId.startsWith('bot_')) return;

    // Only process betting phase
    if (state.phase != 'betting') return;

    _isProcessing = true;

    try {
      // Small delay for natural feel
      await Future.delayed(const Duration(milliseconds: 1200));
      await _processBotTurn(state, currentPlayerId);
    } catch (e) {
      debugPrint('InBetweenBotController Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Process a bot's turn
  Future<void> _processBotTurn(InBetweenGameState state, String botId) async {
    debugPrint('InBetweenBotController: Processing turn for $botId');

    // Get or create bot strategy
    final strategy = _getStrategy(botId);

    // Parse current cards
    final lowCard = _parseCard(state.lowCardId);
    final highCard = _parseCard(state.highCardId);

    if (lowCard == null || highCard == null) {
      debugPrint('InBetweenBotController: Cannot parse cards');
      return;
    }

    // Get bot's chips
    final botChips = state.playerChips[botId] ?? 100;
    final cardsRemaining = state.deckCards.length;

    // Decide bet amount
    final betAmount = strategy.decideBetAmount(
      lowCard: lowCard,
      highCard: highCard,
      pot: state.pot,
      chips: botChips,
      cardsRemaining: cardsRemaining,
    );

    // Execute action
    if (betAmount <= 0) {
      // Pass
      debugPrint('InBetweenBotController: $botId passes');
      await _service.pass(roomId);
    } else {
      // Place bet
      debugPrint('InBetweenBotController: $botId bets $betAmount');
      await _service.placeBet(roomId, botId, betAmount);

      // Auto-reveal after betting
      await Future.delayed(const Duration(milliseconds: 800));
      await _service.reveal(roomId, botId);

      // Auto-next turn after result
      await Future.delayed(const Duration(milliseconds: 1200));
      await _service.nextTurn(roomId);
    }
  }

  /// Get strategy for a bot (create if needed)
  InBetweenBotStrategy _getStrategy(String botId) {
    if (!_botStrategies.containsKey(botId)) {
      // Assign difficulty based on bot number
      final difficulty = _getDifficultyForBot(botId);
      _botStrategies[botId] = InBetweenBotStrategy(difficulty: difficulty);
    }
    return _botStrategies[botId]!;
  }

  /// Assign difficulty based on bot ID
  InBetweenBotDifficulty _getDifficultyForBot(String botId) {
    if (botId.contains('1')) return InBetweenBotDifficulty.easy;
    if (botId.contains('2')) return InBetweenBotDifficulty.medium;
    return InBetweenBotDifficulty.hard;
  }

  /// Parse card ID to Card object
  Card? _parseCard(String? cardId) {
    if (cardId == null || cardId.isEmpty) return null;

    try {
      final parts = cardId.split('_');
      if (parts.length < 2) return null;

      final rankName = parts[0];
      final suitName = parts[1];

      final rank = Rank.values.firstWhere(
        (r) => r.name.toLowerCase() == rankName.toLowerCase(),
        orElse: () => Rank.ace,
      );

      final suit = Suit.values.firstWhere(
        (s) => s.name.toLowerCase() == suitName.toLowerCase(),
        orElse: () => Suit.spades,
      );

      return Card(rank: rank, suit: suit);
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _botStrategies.clear();
  }
}

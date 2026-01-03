/// Teen Patti Bot Controller
///
/// Manages bot turns and integrates TeenPattiBotStrategy with game state
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_bot.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_service.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_game.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Controller for Teen Patti bot automation
class TeenPattiBotController {
  final TeenPattiService _service;
  final String roomId;
  StreamSubscription? _gameSubscription;
  bool _isProcessing = false;
  TeenPattiGameState? _lastState;
  int _roundCounter = 0; // Track rounds for see cards timing

  // Bot strategies for each difficulty
  final Map<String, TeenPattiBotStrategy> _botStrategies = {};

  TeenPattiBotController({
    required TeenPattiService service,
    required this.roomId,
  }) : _service = service;

  /// Start monitoring for bot turns
  void startMonitoring() {
    debugPrint('TeenPattiBotController: Starting monitoring for room $roomId');

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
    debugPrint('TeenPattiBotController: Stopped monitoring');
  }

  /// Check if current turn belongs to a bot and process it
  Future<void> _checkBotTurn() async {
    if (_isProcessing) return;

    final state = _lastState;
    if (state == null) return;
    if (state.phase == 'finished') return;

    final currentPlayerId = state.currentPlayerId;
    if (currentPlayerId.isEmpty) return;

    // Check if current player is a bot (starts with 'bot_')
    if (!currentPlayerId.startsWith('bot_')) return;

    // Check if bot is folded
    if (state.playerStatus[currentPlayerId] == 'folded') return;

    _isProcessing = true;

    try {
      // Add delay for natural feel
      await Future.delayed(const Duration(milliseconds: 1200));
      await _processBotTurn(state, currentPlayerId);
    } catch (e) {
      debugPrint('TeenPattiBotController Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Process a bot's turn
  Future<void> _processBotTurn(TeenPattiGameState state, String botId) async {
    debugPrint('TeenPattiBotController: Processing turn for $botId');

    // Get or create bot strategy
    final strategy = _getStrategy(botId);

    // Get bot status
    final botStatus = state.playerStatus[botId] ?? 'blind';
    if (botStatus == 'folded') return;

    // Create mock player for strategy
    final player = TeenPattiPlayer(id: botId, name: 'Bot');
    player.status = _parseStatus(botStatus);

    // Get bot's cards
    final List<Card> hand = [];
    final cardIds = state.playerHands[botId] ?? [];
    for (final cardId in cardIds) {
      final card = _parseCard(cardId);
      if (card != null) hand.add(card);
    }

    // Track rounds
    _roundCounter++;

    // Check if bot should see cards first
    if (player.status == PlayerStatus.blind) {
      final shouldSee = strategy.shouldSeeCards(
        player: player,
        roundNumber: _roundCounter,
        potSize: state.pot,
      );

      if (shouldSee) {
        debugPrint('TeenPattiBotController: $botId sees cards');
        await _service.seeCards(roomId, botId);
        // After seeing, will bet on next callback
        return;
      }
    }

    // Check for showdown if only 2 active players
    final activeCount = _getActivePlayerCount(state);
    if (activeCount == 2 &&
        player.status == PlayerStatus.seen &&
        hand.length == 3) {
      final shouldShowdown = strategy.shouldRequestShowdown(
        hand: hand,
        potSize: state.pot,
        chips: 100, // Default chips
      );

      if (shouldShowdown) {
        debugPrint('TeenPattiBotController: $botId requests showdown');
        await _service.showdown(roomId, botId);
        return;
      }
    }

    // Calculate min/max bet
    final isSeen = botStatus == 'seen';
    final minBet = isSeen ? state.currentStake * 2 : state.currentStake;
    final maxBet = minBet * 2;

    // Decide betting action
    final betAmount = strategy.decideBetAction(
      player: player,
      hand: hand,
      currentBet: state.currentStake,
      potSize: state.pot,
      playersRemaining: activeCount,
      minBet: minBet,
      maxBet: maxBet,
    );

    // Execute action
    if (betAmount < 0) {
      debugPrint('TeenPattiBotController: $botId folds');
      await _service.fold(roomId, botId);
    } else {
      debugPrint('TeenPattiBotController: $botId bets $betAmount');
      await _service.bet(roomId, botId, betAmount.clamp(minBet, maxBet));
    }
  }

  /// Get strategy for a bot (create if needed)
  TeenPattiBotStrategy _getStrategy(String botId) {
    if (!_botStrategies.containsKey(botId)) {
      // Assign difficulty based on bot number
      final difficulty = _getDifficultyForBot(botId);
      _botStrategies[botId] = TeenPattiBotStrategy(difficulty: difficulty);
    }
    return _botStrategies[botId]!;
  }

  /// Assign difficulty based on bot ID
  BotDifficulty _getDifficultyForBot(String botId) {
    if (botId.contains('1')) return BotDifficulty.easy;
    if (botId.contains('2')) return BotDifficulty.medium;
    return BotDifficulty.hard;
  }

  /// Parse status string to enum
  PlayerStatus _parseStatus(String status) {
    switch (status) {
      case 'blind':
        return PlayerStatus.blind;
      case 'seen':
        return PlayerStatus.seen;
      case 'folded':
        return PlayerStatus.folded;
      default:
        return PlayerStatus.blind;
    }
  }

  /// Get count of active (non-folded) players
  int _getActivePlayerCount(TeenPattiGameState state) {
    int count = 0;
    for (final status in state.playerStatus.values) {
      if (status != 'folded') count++;
    }
    return count;
  }

  /// Parse card ID to Card object
  Card? _parseCard(String cardId) {
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

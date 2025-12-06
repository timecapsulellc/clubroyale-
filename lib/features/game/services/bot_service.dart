import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/game/game_room.dart';
import 'package:taasclub/features/game/game_service.dart';
import 'package:taasclub/features/game/call_break_service.dart';
import 'package:taasclub/features/game/models/game_state.dart';
import 'package:taasclub/features/game/services/card_validation_service.dart';

final botServiceProvider = Provider((ref) => BotService(ref));

class BotService {
  final Ref _ref;
  StreamSubscription? _subscription;
  Timer? _actionTimer;

  BotService(this._ref);

  void startMonitoring(String gameId) {
    stopMonitoring();
    debugPrint('BotService: Started monitoring game $gameId');

    final gameService = _ref.read(gameServiceProvider);
    _subscription = gameService.getGameStream(gameId).listen((game) {
      if (game == null) return;
      _checkForBotTurn(game);
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _actionTimer?.cancel();
    _subscription = null;
    _actionTimer = null;
    debugPrint('BotService: Stopped monitoring');
  }

  void _checkForBotTurn(GameRoom game) {
    // Only proceed if no action is pending
    if (_actionTimer != null && _actionTimer!.isActive) return;

    final currentTurnId = game.currentTurn;
    if (currentTurnId == null) return;

    // Check if current turn belongs to a bot
    // We identify bots by a specific prefix or flag. 
    // For simplicity, let's assume any player ID starting with 'bot_' is a bot.
    if (!currentTurnId.startsWith('bot_')) return;

    debugPrint('BotService: It is bot $currentTurnId turn');

    // Add delay to simulate thinking
    _actionTimer = Timer(const Duration(seconds: 1), () async {
      try {
        if (game.gamePhase == GamePhase.bidding) {
          await _handleBotBid(game, currentTurnId);
        } else if (game.gamePhase == GamePhase.playing) {
          await _handleBotPlay(game, currentTurnId);
        }
      } catch (e) {
        debugPrint('BotService Error: $e');
      } finally {
        _actionTimer = null;
      }
    });
  }

  Future<void> _handleBotBid(GameRoom game, String botId) async {
    final hand = game.playerHands[botId];
    if (hand == null || hand.isEmpty) return;

    final suggestedBid = CardValidationService.suggestBid(hand);
    // Add some randomness? No, stick to logic for now.
    
    debugPrint('BotService: $botId bidding $suggestedBid');
    await _ref.read(callBreakServiceProvider).placeBid(game.id!, botId, suggestedBid);
  }

  Future<void> _handleBotPlay(GameRoom game, String botId) async {
    final hand = game.playerHands[botId];
    if (hand == null || hand.isEmpty) return;

    final validCards = CardValidationService.getValidCards(hand, game.currentTrick);
    if (validCards.isEmpty) return;

    // Simple strategy: 
    // 1. If leading, play random (or highest?)
    // 2. If following, try to win if possible, else play low.
    
    // For testing, just pick the first valid card (random-ish)
    // Or pick a random one from valid cards to vary gameplay
    final cardToPlay = validCards[Random().nextInt(validCards.length)];

    debugPrint('BotService: $botId playing $cardToPlay');
    await _ref.read(callBreakServiceProvider).playCard(game.id!, botId, cardToPlay);
  }
}

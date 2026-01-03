import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:clubroyale/games/call_break/call_break_service.dart';
import 'package:clubroyale/features/agents/models/bot_personality.dart';

/// Controller for Bot behavior in Call Break Multiplayer
class CallBreakBotController {
  final CallBreakService _service;
  final String roomId;
  final String botId;
  final String botName;
  final BotPersonality? personality;

  StreamSubscription<CallBreakGameState?>? _subscription;
  bool _isDisposed = false;

  // Simulation delays
  final int _thinkingTimeMs = 1500;
  final int _varianceMs = 1000;

  /// Callback for bot reactions (e.g., to display in chat)
  void Function(String reaction)? onReaction;

  CallBreakBotController({
    required CallBreakService service,
    required this.roomId,
    required this.botId,
    required this.botName,
    this.personality,
    this.onReaction,
  }) : _service = service {
    _init();
  }

  void _init() {
    debugPrint('Initializing Bot Controller for $botId ($botName)');
    _subscription = _service.watchGameState(roomId).listen(_handleGameState);
  }

  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
  }

  void _handleGameState(CallBreakGameState? state) async {
    if (_isDisposed || state == null) return;

    // Only act if it's my turn
    if (state.currentPlayerId != botId) return;

    // Check phase
    if (state.phase == 'bidding') {
      await _makeBid(state);
    } else if (state.phase == 'playing') {
      await _playCard(state);
    }
  }

  Future<void> _makeBid(CallBreakGameState state) async {
    // Add realistic delay
    final delay = _thinkingTimeMs + Random().nextInt(_varianceMs);
    await Future.delayed(Duration(milliseconds: delay));
    if (_isDisposed) return;

    // Analyze hand to calculate bid
    final handIds = state.hands[botId] ?? [];
    if (handIds.isEmpty) return; // Should not happen

    // Simple logic: Count spades (trump) and high cards (A/K/Q)
    int spades = 0;
    int highCards = 0;

    for (final cardId in handIds) {
      if (cardId.contains('spades')) spades++;
      if (cardId.contains('ace') || cardId.contains('king')) highCards++;
    }

    // Base bid formula
    int bid = max(1, (spades / 2).floor() + (highCards / 2).floor());

    // Apply personality modifiers
    if (personality != null) {
      // Aggressive bots bid higher
      if (personality!.aggression > 0.6) {
        bid += 1;
      }
      // Cautious bots bid lower
      if (personality!.aggression < 0.3 && bid > 1) {
        bid -= 1;
      }
      // High risk tolerance = more aggressive bidding
      if (personality!.riskTolerance > 0.7) {
        bid = min(bid + 1, 8);
      }
    }

    bid = bid.clamp(1, 8); // Keep within valid range

    debugPrint(
      'Bot $botId bidding $bid (personality: ${personality?.name ?? "none"})',
    );
    await _service.submitBid(roomId, botId, bid);
  }

  Future<void> _playCard(CallBreakGameState state) async {
    // Add realistic delay
    final delay = _thinkingTimeMs + Random().nextInt(_varianceMs);
    await Future.delayed(Duration(milliseconds: delay));
    if (_isDisposed) return;

    final hand = state.hands[botId] ?? [];
    if (hand.isEmpty) return;

    // Valid moves logic needed? Service validates, but bot should try valid moves.
    // We need to know what cards we have.
    // Since we don't have the Card objects easily here without parsing logic...
    // Let's implement basic parsing to filter valid moves.

    List<String> validMoves = [];

    if (state.currentTrickCards.isEmpty) {
      // Leading: Can play anything
      validMoves = List.from(hand);
    } else {
      // Following
      final ledSuit = state.ledSuit;
      if (ledSuit != null) {
        // Must follow suit
        final suitCards = hand
            .where((c) => c.contains(ledSuit.toLowerCase()))
            .toList(); // Fragile parsing?

        // Let's rely on a smarter selection if parsing is hard.
        // Actually, Deck.standard() IDs are `suit_rank`. e.g. `spades_ace`.
        // So checking `contains(suit)` is safe.

        if (suitCards.isNotEmpty) {
          validMoves = suitCards;
        } else {
          // Can play anything (trump/throw-off)
          validMoves = List.from(hand);
        }
      }
    }

    // Pick a card
    // 1. Try to win (Play high spade or high suit)
    // 2. Else throw low

    // For MVP Bot: Play random valid card
    final cardToPlay = validMoves[Random().nextInt(validMoves.length)];

    debugPrint('Bot $botId playing $cardToPlay');
    await _service.playCard(roomId, botId, cardToPlay);
  }
}

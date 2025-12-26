
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/games/call_break/call_break_service.dart';

/// Controller for Bot behavior in Call Break Multiplayer
class CallBreakBotController {
  final CallBreakService _service;
  final String roomId;
  final String botId;
  final String botName;
  
  StreamSubscription<CallBreakGameState?>? _subscription;
  bool _isDisposed = false;
  
  // Simulation delays
  final int _thinkingTimeMs = 1500;
  final int _varianceMs = 1000;
  
  CallBreakBotController({
    required CallBreakService service, 
    required this.roomId, 
    required this.botId,
    required this.botName,
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
    
    // We don't have direct access to Card objects in state (only IDs), 
    // but the ID format is usually suit_rank or strict.
    // Ideally we'd use the service's cache or logic, but let's estimate.
    // Actually CallBreakService has _getCard/public cache? No, private.
    // But card IDs are typically descriptive or we can infer.
    // Wait, the Service uses random IDs or standard IDs?
    // Deck.standard() usually produces IDs like 'spades_ace', 'hearts_10'.
    
    for (final cardId in handIds) {
      if (cardId.contains('spades')) spades++;
      if (cardId.contains('ace') || cardId.contains('king')) highCards++;
    }
    
    // Conservative bid formula
    int bid = max(1, (spades / 2).floor() + (highCards / 2).floor());
    bid = min(bid, 8); // Cap at 8 to be safe
    
    debugPrint('Bot $botId bidding $bid');
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
        final suitCards = hand.where((c) => c.contains(ledSuit.toLowerCase())).toList(); // Fragile parsing?
        
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

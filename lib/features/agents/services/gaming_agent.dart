import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:taasclub/features/agents/models/agent.dart';

/// Gaming Agent provider
final gamingAgentProvider = Provider<GamingAgent>((ref) {
  return GamingAgent();
});

/// Gaming Agent - Handles game AI, bots, and strategic tips
class GamingAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final Random _random = Random();

  // ==================== BOT AI ====================

  /// Get bot move for a card game
  Future<Map<String, dynamic>> getBotMove({
    required String gameType,
    required List<String> hand,
    required Map<String, dynamic> gameState,
    String difficulty = 'medium',
  }) async {
    try {
      // Try cloud function first
      final callable = _functions.httpsCallable('getBotMove');
      final result = await callable.call<Map<String, dynamic>>({
        'gameType': gameType,
        'hand': hand,
        'gameState': gameState,
        'difficulty': difficulty,
      });
      return result.data;
    } catch (e) {
      // Fallback to local bot logic
      return _localBotMove(gameType, hand, gameState, difficulty);
    }
  }

  /// Local bot move logic (fallback)
  Map<String, dynamic> _localBotMove(
    String gameType,
    List<String> hand,
    Map<String, dynamic> gameState,
    String difficulty,
  ) {
    switch (gameType) {
      case 'callbreak':
        return _callBreakBotMove(hand, gameState, difficulty);
      case 'marriage':
        return _marriageBotMove(hand, gameState, difficulty);
      case 'teenpatti':
        return _teenPattiBotMove(hand, gameState, difficulty);
      default:
        // Generic: play random card
        return {
          'action': 'play',
          'card': hand[_random.nextInt(hand.length)],
          'confidence': 0.5,
        };
    }
  }

  /// Call Break bot logic
  Map<String, dynamic> _callBreakBotMove(
    List<String> hand,
    Map<String, dynamic> gameState,
    String difficulty,
  ) {
    final leadSuit = gameState['leadSuit'] as String?;
    final cardsPlayed = gameState['cardsPlayed'] as List? ?? [];

    // Filter playable cards
    List<String> playable = hand;
    if (leadSuit != null) {
      final suitCards = hand.where((c) => c.startsWith(leadSuit)).toList();
      if (suitCards.isNotEmpty) playable = suitCards;
    }

    // Strategy based on difficulty
    String selectedCard;
    double confidence;

    switch (difficulty) {
      case 'easy':
        // Random selection
        selectedCard = playable[_random.nextInt(playable.length)];
        confidence = 0.3;
        break;
      case 'hard':
        // Play highest if leading, lowest to dump
        if (leadSuit == null || cardsPlayed.isEmpty) {
          // Leading: play high
          selectedCard = _getHighestCard(playable);
        } else {
          // Following: win if possible, else dump low
          selectedCard = _getLowestCard(playable);
        }
        confidence = 0.85;
        break;
      default: // medium
        // 50% chance of optimal play
        if (_random.nextBool()) {
          selectedCard = _getHighestCard(playable);
        } else {
          selectedCard = playable[_random.nextInt(playable.length)];
        }
        confidence = 0.6;
    }

    return {
      'action': 'play',
      'card': selectedCard,
      'confidence': confidence,
    };
  }

  /// Marriage bot logic
  Map<String, dynamic> _marriageBotMove(
    List<String> hand,
    Map<String, dynamic> gameState,
    String difficulty,
  ) {
    final phase = gameState['phase'] as String? ?? 'play';

    if (phase == 'discard') {
      // Discard lowest value card
      final lowestCard = _getLowestCard(hand);
      return {
        'action': 'discard',
        'card': lowestCard,
        'confidence': 0.7,
      };
    }

    // Play phase
    return {
      'action': 'play',
      'card': _getLowestCard(hand),
      'confidence': 0.6,
    };
  }

  /// Teen Patti bot logic
  Map<String, dynamic> _teenPattiBotMove(
    List<String> hand,
    Map<String, dynamic> gameState,
    String difficulty,
  ) {
    final currentBet = gameState['currentBet'] as int? ?? 0;
    final pot = gameState['pot'] as int? ?? 0;
    final handStrength = _evaluateTeenPattiHand(hand);

    // Decision based on hand strength
    if (handStrength > 0.7) {
      return {
        'action': 'raise',
        'amount': (currentBet * 2).clamp(1, 1000),
        'confidence': handStrength,
      };
    } else if (handStrength > 0.3) {
      return {
        'action': 'call',
        'amount': currentBet,
        'confidence': handStrength,
      };
    } else {
      // Low hand: sometimes bluff
      if (_random.nextDouble() < 0.2 && difficulty == 'hard') {
        return {
          'action': 'raise',
          'amount': currentBet * 2,
          'confidence': 0.3,
          'bluff': true,
        };
      }
      return {
        'action': 'fold',
        'confidence': 1.0 - handStrength,
      };
    }
  }

  double _evaluateTeenPattiHand(List<String> hand) {
    // Simple hand strength evaluation (0.0 - 1.0)
    // In production, this would be more sophisticated
    if (hand.length != 3) return 0.5;

    // Check for pairs, sequences, etc.
    final ranks = hand.map((c) => c.substring(1)).toList();
    final uniqueRanks = ranks.toSet();

    if (uniqueRanks.length == 1) return 1.0; // Trail (three of a kind)
    if (uniqueRanks.length == 2) return 0.7; // Pair
    return 0.4; // High card
  }

  // ==================== TIPS & STRATEGY ====================

  /// Get contextual game tip
  Future<String> getGameTip({
    required String gameType,
    required Map<String, dynamic> gameState,
    String? userId,
  }) async {
    try {
      final callable = _functions.httpsCallable('getGameTip');
      final result = await callable.call<Map<String, dynamic>>({
        'gameType': gameType,
        'gameState': gameState,
        'userId': userId,
      });
      return result.data['tip'] as String? ?? _getLocalTip(gameType, gameState);
    } catch (e) {
      return _getLocalTip(gameType, gameState);
    }
  }

  /// Local tip generation
  String _getLocalTip(String gameType, Map<String, dynamic> gameState) {
    final tips = {
      'callbreak': [
        'Count trumps (spades) that have been played to know how many are left.',
        'Lead with your longest suit to establish control.',
        'Save high cards for later rounds when opponents run out of suits.',
        'If you have many trumps, bid aggressively.',
        'Watch what suit your opponents are short in.',
      ],
      'marriage': [
        'Try to form melds with your highest value cards.',
        'Keep track of which trump cards have been played.',
        'Discard cards from your shortest suit.',
        'Marriage (K+Q) is worth 40 points - protect these pairs!',
        'If you have the trump marriage, declare it early.',
      ],
      'teenpatti': [
        'Position matters - late position gives more information.',
        'Dont always fold weak hands - occasional bluffs keep opponents guessing.',
        'Watch betting patterns to read hand strength.',
        'Pack (fold) early with weak hands to save chips.',
        'Pure sequence beats sequence - know your hand rankings.',
      ],
    };

    final gameTips = tips[gameType] ?? ['Play smart and have fun!'];
    return gameTips[_random.nextInt(gameTips.length)];
  }

  /// Get bid suggestion for Call Break
  Future<int> getBidSuggestion({
    required List<String> hand,
    required int position,
  }) async {
    try {
      final callable = _functions.httpsCallable('getBidSuggestion');
      final result = await callable.call<Map<String, dynamic>>({
        'hand': hand,
        'position': position,
      });
      return result.data['bid'] as int? ?? _localBidSuggestion(hand);
    } catch (e) {
      return _localBidSuggestion(hand);
    }
  }

  /// Local bid calculation
  int _localBidSuggestion(List<String> hand) {
    int bid = 1; // Minimum bid

    // Count high cards (A, K, Q)
    for (final card in hand) {
      final rank = card.substring(1);
      if (rank == 'A' || rank == 'K') bid++;
      if (rank == 'Q' && card.startsWith('S')) bid++; // Queen of spades
    }

    // Count spades (trumps)
    final spades = hand.where((c) => c.startsWith('S')).length;
    bid += (spades / 2).floor();

    return bid.clamp(1, 8);
  }

  // ==================== HELPERS ====================

  String _getHighestCard(List<String> cards) {
    const rankOrder = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];
    cards.sort((a, b) {
      final aRank = rankOrder.indexOf(a.substring(1));
      final bRank = rankOrder.indexOf(b.substring(1));
      return bRank.compareTo(aRank);
    });
    return cards.first;
  }

  String _getLowestCard(List<String> cards) {
    const rankOrder = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];
    cards.sort((a, b) {
      final aRank = rankOrder.indexOf(a.substring(1));
      final bRank = rankOrder.indexOf(b.substring(1));
      return aRank.compareTo(bRank);
    });
    return cards.first;
  }
}

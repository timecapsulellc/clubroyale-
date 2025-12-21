import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/ai/hybrid_ai_service.dart';

/// AI Service for interacting with Genkit-powered Cloud Functions
class AiService {
  final FirebaseFunctions _functions;

  AiService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Get AI-powered game tip for optimal card play
  Future<GameTipResult> getGameTip({
    required List<String> hand,
    required List<String> trickCards,
    required int tricksNeeded,
    required int tricksWon,
    required int bid,
    String? ledSuit,
  }) async {
    final callable = _functions.httpsCallable('getGameTip');
    final result = await callable.call<Map<String, dynamic>>({
      'hand': hand,
      'trickCards': trickCards,
      'tricksNeeded': tricksNeeded,
      'tricksWon': tricksWon,
      'bid': bid,
      'trumpSuit': 'spades',
      'ledSuit': ledSuit,
    });

    final data = result.data;
    return GameTipResult(
      suggestedCard: data['suggestedCard'] as String,
      reasoning: data['reasoning'] as String,
      confidence: data['confidence'] as String,
      alternativeCard: data['alternativeCard'] as String?,
    );
  }

  /// Get AI bot's card selection for automated play
  Future<BotPlayResult> getBotPlay({
    required List<String> hand,
    required List<Map<String, String>> trickCards,
    required int currentRound,
    required int bid,
    required int tricksWon,
    required Map<String, int> allBids,
    required Map<String, int> allTricksWon,
    String difficulty = 'medium',
  }) async {
    final callable = _functions.httpsCallable('getBotPlay');
    final result = await callable.call<Map<String, dynamic>>({
      'hand': hand,
      'trickCards': trickCards,
      'currentRound': currentRound,
      'bid': bid,
      'tricksWon': tricksWon,
      'allBids': allBids,
      'allTricksWon': allTricksWon,
      'difficulty': difficulty,
    });

    final data = result.data;
    return BotPlayResult(
      selectedCard: data['selectedCard'] as String,
      strategy: data['strategy'] as String,
    );
  }

  /// Moderate a chat message before sending
  Future<ModerationResult> moderateChat({
    required String message,
    required String senderName,
    required String roomId,
    List<String>? recentMessages,
  }) async {
    final callable = _functions.httpsCallable('moderateChat');
    final result = await callable.call<Map<String, dynamic>>({
      'message': message,
      'senderName': senderName,
      'roomId': roomId,
      'recentMessages': recentMessages,
    });

    final data = result.data;
    return ModerationResult(
      isAllowed: data['isAllowed'] as bool,
      reason: data['reason'] as String?,
      category: data['category'] as String,
      action: data['action'] as String,
      editedMessage: data['editedMessage'] as String?,
    );
  }

  /// Get AI-powered bid suggestion
  Future<BidSuggestionResult> getBidSuggestion({
    required List<String> hand,
    required int position,
    List<int>? previousBids,
  }) async {
    final callable = _functions.httpsCallable('getBidSuggestion');
    final result = await callable.call<Map<String, dynamic>>({
      'hand': hand,
      'position': position,
      'previousBids': previousBids,
    });

    final data = result.data;
    return BidSuggestionResult(
      suggestedBid: data['suggestedBid'] as int,
      confidence: data['confidence'] as String,
      reasoning: data['reasoning'] as String,
      handStrength: data['handStrength'] as String,
      riskLevel: data['riskLevel'] as String,
    );
  }

  /// Get Marriage AI bot's play
  Future<MarriageBotPlayResult> getMarriageBotPlay({
    required String difficulty,
    required List<String> hand,
    required Map<String, dynamic> gameState,
  }) async {
    // FALLBACK: Use local Hybrid AI service to avoid CORS/Cloud issues during development
    try {
      final request = AIDecisionRequest(
        gameType: 'marriage',
        phase: gameState['phase'] ?? 'playing', 
        hand: hand,
        gameState: gameState,
        difficulty: difficulty,
      );
      
      final data = await HybridAIService.getMove(request);

      return MarriageBotPlayResult(
        action: data['action'] as String,
        card: data['card'] as String?,
        reasoning: data['reasoning'] as String?,
      );
    } catch (e) {
      // If local AI fails, try cloud (or just return fallback)
      print('Local AI failed, falling back to cloud (which might fail with CORS): $e');
      
      final callable = _functions.httpsCallable('marriageBotPlay');
      final result = await callable.call<Map<String, dynamic>>({
        'difficulty': difficulty,
        'hand': hand,
        'gameState': gameState,
      });

      final data = result.data;
      return MarriageBotPlayResult(
        action: data['action'] as String,
        card: data['card'] as String?,
        reasoning: data['reasoning'] as String?,
      );
    }
  }
}

// =====================================================
// RESULT MODELS
// =====================================================

class GameTipResult {
  final String suggestedCard;
  final String reasoning;
  final String confidence;
  final String? alternativeCard;

  GameTipResult({
    required this.suggestedCard,
    required this.reasoning,
    required this.confidence,
    this.alternativeCard,
  });
}

class BotPlayResult {
  final String selectedCard;
  final String strategy;

  BotPlayResult({
    required this.selectedCard,
    required this.strategy,
  });
}

class ModerationResult {
  final bool isAllowed;
  final String? reason;
  final String category;
  final String action;
  final String? editedMessage;

  ModerationResult({
    required this.isAllowed,
    this.reason,
    required this.category,
    required this.action,
    this.editedMessage,
  });
}

class BidSuggestionResult {
  final int suggestedBid;
  final String confidence;
  final String reasoning;
  final String handStrength;
  final String riskLevel;

  BidSuggestionResult({
    required this.suggestedBid,
    required this.confidence,
    required this.reasoning,
    required this.handStrength,
    required this.riskLevel,
  });
}

class MarriageBotPlayResult {
  final String action;
  final String? card;
  final String? reasoning;

  MarriageBotPlayResult({
    required this.action,
    this.card,
    this.reasoning,
  });
}

// =====================================================
// RIVERPOD PROVIDERS
// =====================================================

/// Provider for AI service instance
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

/// Provider for game tip (async)
final gameTipProvider = FutureProvider.family<GameTipResult, GameTipParams>(
  (ref, params) async {
    final aiService = ref.read(aiServiceProvider);
    return aiService.getGameTip(
      hand: params.hand,
      trickCards: params.trickCards,
      tricksNeeded: params.tricksNeeded,
      tricksWon: params.tricksWon,
      bid: params.bid,
      ledSuit: params.ledSuit,
    );
  },
);

/// Provider for bid suggestion
final bidSuggestionProvider = FutureProvider.family<BidSuggestionResult, BidSuggestionParams>(
  (ref, params) async {
    final aiService = ref.read(aiServiceProvider);
    return aiService.getBidSuggestion(
      hand: params.hand,
      position: params.position,
      previousBids: params.previousBids,
    );
  },
);

// =====================================================
// PARAMETER CLASSES
// =====================================================

class GameTipParams {
  final List<String> hand;
  final List<String> trickCards;
  final int tricksNeeded;
  final int tricksWon;
  final int bid;
  final String? ledSuit;

  GameTipParams({
    required this.hand,
    required this.trickCards,
    required this.tricksNeeded,
    required this.tricksWon,
    required this.bid,
    this.ledSuit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameTipParams &&
          runtimeType == other.runtimeType &&
          hand.toString() == other.hand.toString() &&
          trickCards.toString() == other.trickCards.toString();

  @override
  int get hashCode => hand.hashCode ^ trickCards.hashCode;
}

class BidSuggestionParams {
  final List<String> hand;
  final int position;
  final List<int>? previousBids;

  BidSuggestionParams({
    required this.hand,
    required this.position,
    this.previousBids,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidSuggestionParams &&
          runtimeType == other.runtimeType &&
          hand.toString() == other.hand.toString() &&
          position == other.position;

  @override
  int get hashCode => hand.hashCode ^ position.hashCode;
}

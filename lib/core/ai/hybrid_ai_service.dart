// Hybrid AI Service
//
// Combines fast local heuristics with GenKit LLM for optimal cost/performance.
// Chief Architect Audit: Prevents LLM call explosion (50K calls/hour issue).
//
// Strategy:
// - 90% of moves: Local heuristic algorithms (instant, free)
// - 10% critical decisions: GenKit LLM (bid strategy, trump selection)
// - Post-game: GenKit coaching analysis

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// When to use GenKit vs Local AI
enum AIDecisionType {
  /// Use local heuristics (fast, free)
  local,

  /// Use GenKit LLM (smart, costs money)
  genkit,
}

/// AI decision request
class AIDecisionRequest {
  final String gameType;
  final String phase;
  final List<String> hand;
  final Map<String, dynamic> gameState;
  final String difficulty;

  AIDecisionRequest({
    required this.gameType,
    required this.phase,
    required this.hand,
    required this.gameState,
    required this.difficulty,
  });

  /// Determine if this decision needs GenKit or can use local heuristics
  AIDecisionType get decisionType {
    // Critical decisions that need LLM
    if (phase == 'bidding') return AIDecisionType.genkit;
    if (phase == 'trumpSelection') return AIDecisionType.genkit;
    if (phase == 'declaring' && gameType == 'marriage') {
      return AIDecisionType.genkit;
    }

    // First card of a trick (strategic lead)
    if (gameState['currentTrick']?.isEmpty ?? true) {
      // Only use GenKit for hard/expert difficulty leads
      if (difficulty == 'hard' || difficulty == 'expert') {
        return AIDecisionType.genkit;
      }
    }

    // All other moves: local heuristics
    return AIDecisionType.local;
  }
}

/// Hybrid AI Service
class HybridAIService {
  /// Get AI move using hybrid approach
  static Future<Map<String, dynamic>> getMove(AIDecisionRequest request) async {
    if (request.decisionType == AIDecisionType.local) {
      return _getLocalMove(request);
    } else {
      return _getGenkitMove(request);
    }
  }

  /// Local heuristic move (instant, free)
  static Future<Map<String, dynamic>> _getLocalMove(
    AIDecisionRequest request,
  ) async {
    final hand = request.hand;
    final gameState = request.gameState;

    switch (request.gameType) {
      case 'call_break':
        return _callBreakLocalMove(hand, gameState, request.difficulty);
      case 'marriage':
        return _marriageLocalMove(hand, gameState, request.difficulty);
      default:
        // Fallback: play first valid card
        return {'action': 'playCard', 'card': hand.first, 'source': 'local'};
    }
  }

  /// GenKit LLM move (for critical decisions)
  static Future<Map<String, dynamic>> _getGenkitMove(
    AIDecisionRequest request,
  ) async {
    // This would call the Cloud Function
    // For now, return local move as fallback
    // In production: await functions.httpsCallable('getBotPlay').call(...)

    return {
      'action': 'genkit_pending',
      'source': 'genkit',
      'request': {
        'gameType': request.gameType,
        'phase': request.phase,
        'hand': request.hand,
        'difficulty': request.difficulty,
      },
    };
  }

  // ============================================================
  // CALL BREAK LOCAL HEURISTICS
  // ============================================================

  static Map<String, dynamic> _callBreakLocalMove(
    List<String> hand,
    Map<String, dynamic> gameState,
    String difficulty,
  ) {
    final currentTrick = gameState['currentTrick'] as List? ?? [];
    final leadSuit = gameState['leadSuit'] as String?;

    // Must follow suit if possible
    final suitCards = leadSuit != null
        ? hand.where((c) => _getSuit(c) == leadSuit).toList()
        : <String>[];

    String selectedCard;
    String reasoning;

    if (currentTrick.isEmpty) {
      // Leading: play highest non-trump card
      final nonTrumps = hand.where((c) => _getSuit(c) != 'S').toList();
      if (nonTrumps.isNotEmpty) {
        selectedCard = _getHighestCard(nonTrumps);
        reasoning = 'Leading with highest non-trump';
      } else {
        selectedCard = _getLowestCard(hand);
        reasoning = 'Leading with lowest trump';
      }
    } else if (suitCards.isNotEmpty) {
      // Must follow suit
      if (difficulty == 'easy') {
        selectedCard = suitCards.first;
        reasoning = 'Following suit (easy)';
      } else {
        // Try to win if possible, otherwise play lowest
        final currentWinner = _getCurrentWinner(currentTrick, leadSuit!);
        final canWin = suitCards.any(
          (c) => _cardValue(c) > _cardValue(currentWinner),
        );

        if (canWin) {
          selectedCard = _getLowestWinner(suitCards, currentWinner);
          reasoning = 'Following suit with winner';
        } else {
          selectedCard = _getLowestCard(suitCards);
          reasoning = 'Following suit, cannot win';
        }
      }
    } else {
      // Cannot follow suit: trump or discard
      final trumps = hand.where((c) => _getSuit(c) == 'S').toList();

      if (trumps.isNotEmpty && difficulty != 'easy') {
        selectedCard = _getLowestCard(trumps);
        reasoning = 'Trumping with lowest trump';
      } else {
        selectedCard = _getLowestCard(hand);
        reasoning = 'Discarding lowest card';
      }
    }

    return {
      'action': 'playCard',
      'card': selectedCard,
      'reasoning': reasoning,
      'source': 'local',
    };
  }

  // ============================================================
  // MARRIAGE LOCAL HEURISTICS
  // ============================================================

  static Map<String, dynamic> _marriageLocalMove(
    List<String> hand,
    Map<String, dynamic> gameState,
    String difficulty,
  ) {
    final phase = gameState['phase'] as String?;
    final topDiscard = gameState['topDiscard'] as String?;

    if (phase == 'drawing') {
      // Drawing phase: deck or discard
      if (topDiscard != null && _isUsefulCard(topDiscard, hand)) {
        return {
          'action': 'drawDiscard',
          'reasoning': 'Discard helps meld',
          'source': 'local',
        };
      }
      return {
        'action': 'drawDeck',
        'reasoning': 'Drawing from deck',
        'source': 'local',
      };
    } else {
      // Discarding phase: discard least useful card
      final leastUseful = _getLeastUsefulCard(hand, gameState);
      return {
        'action': 'discard',
        'card': leastUseful,
        'reasoning': 'Discarding least useful',
        'source': 'local',
      };
    }
  }

  // ============================================================
  // HELPER FUNCTIONS
  // ============================================================

  static String _getSuit(String card) {
    return card.isNotEmpty ? card[card.length - 1].toUpperCase() : '';
  }

  static int _cardValue(String card) {
    if (card.isEmpty) return 0;
    final rank = card.substring(0, card.length - 1);
    const values = {'A': 14, 'K': 13, 'Q': 12, 'J': 11};
    return values[rank] ?? int.tryParse(rank) ?? 0;
  }

  static String _getHighestCard(List<String> cards) {
    if (cards.isEmpty) return '';
    return cards.reduce((a, b) => _cardValue(a) > _cardValue(b) ? a : b);
  }

  static String _getLowestCard(List<String> cards) {
    if (cards.isEmpty) return '';
    return cards.reduce((a, b) => _cardValue(a) < _cardValue(b) ? a : b);
  }

  static String _getCurrentWinner(List<dynamic> trick, String leadSuit) {
    if (trick.isEmpty) return '';
    String winner = trick.first['card'] as String;
    for (final play in trick) {
      final card = play['card'] as String;
      if (_getSuit(card) == leadSuit && _cardValue(card) > _cardValue(winner)) {
        winner = card;
      } else if (_getSuit(card) == 'S' && _getSuit(winner) != 'S') {
        winner = card;
      }
    }
    return winner;
  }

  static String _getLowestWinner(List<String> cards, String toBeat) {
    final winners = cards
        .where((c) => _cardValue(c) > _cardValue(toBeat))
        .toList();
    return winners.isEmpty ? cards.first : _getLowestCard(winners);
  }

  static bool _isUsefulCard(String card, List<String> hand) {
    // Check if card helps form a meld
    final rank = card.substring(0, card.length - 1);
    final sameRank = hand.where((c) => c.startsWith(rank)).length;
    return sameRank >= 2; // Already have 2 of this rank
  }

  static String _getLeastUsefulCard(
    List<String> hand,
    Map<String, dynamic> gameState,
  ) {
    // Simple heuristic: discard highest single card
    final rankCounts = <String, int>{};
    for (final card in hand) {
      final rank = card.substring(0, card.length - 1);
      rankCounts[rank] = (rankCounts[rank] ?? 0) + 1;
    }

    // Find cards that are alone (not part of potential melds)
    final singles = hand.where((c) {
      final rank = c.substring(0, c.length - 1);
      return rankCounts[rank] == 1;
    }).toList();

    if (singles.isNotEmpty) {
      return _getHighestCard(singles);
    }

    return _getHighestCard(hand);
  }
}

/// Provider for Hybrid AI service
final hybridAIProvider = Provider<HybridAIService>((ref) {
  return HybridAIService();
});

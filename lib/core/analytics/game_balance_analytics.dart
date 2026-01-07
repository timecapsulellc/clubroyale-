import 'package:firebase_analytics/firebase_analytics.dart';

/// PhD Audit Finding #2: Wildcard Distribution Analytics
/// Monitor and track game balance metrics

class GameBalanceAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  /// Log wildcard distribution for balance monitoring
  static Future<void> logWildcardDistribution({
    required String gameId,
    required String playerId,
    required int wildcardCount,
    required int totalCards,
  }) async {
    await _analytics.logEvent(
      name: 'wildcard_distribution',
      parameters: {
        'game_id': gameId,
        'player_id': playerId,
        'wildcard_count': wildcardCount,
        'total_cards': totalCards,
        'wildcard_percentage': (wildcardCount / totalCards * 100).round(),
      },
    );
    
    // Flag if abnormally high (6+ wildcards)
    if (wildcardCount >= 6) {
      await _analytics.logEvent(
        name: 'high_wildcard_alert',
        parameters: {
          'game_id': gameId,
          'player_id': playerId,
          'count': wildcardCount,
        },
      );
    }
  }
  
  /// Log scoring breakdown for balance analysis
  static Future<void> logScoringBreakdown({
    required String gameId,
    required String playerId,
    required int alterPoints,
    required int tunnellaPoints,
    required int marriagePoints,
    required int totalMaalPoints,
  }) async {
    await _analytics.logEvent(
      name: 'scoring_breakdown',
      parameters: {
        'game_id': gameId,
        'player_id': playerId,
        'alter_pts': alterPoints,
        'tunnella_pts': tunnellaPoints,
        'marriage_pts': marriagePoints,
        'total_maal': totalMaalPoints,
        'alter_percentage': totalMaalPoints > 0 
            ? (alterPoints / totalMaalPoints * 100).round() 
            : 0,
      },
    );
  }
  
  /// Log game completion metrics
  static Future<void> logGameCompletion({
    required String gameId,
    required int playerCount,
    required int roundsPlayed,
    required Duration gameDuration,
    required String winnerType, // 'human' or 'bot'
    required String winCondition, // 'finish', 'dublee', 'points'
  }) async {
    await _analytics.logEvent(
      name: 'game_completion',
      parameters: {
        'game_id': gameId,
        'player_count': playerCount,
        'rounds_played': roundsPlayed,
        'duration_seconds': gameDuration.inSeconds,
        'winner_type': winnerType,
        'win_condition': winCondition,
      },
    );
  }
  
  /// Log turn timing for bot latency analysis
  static Future<void> logTurnTiming({
    required String gameId,
    required String playerId,
    required bool isBot,
    required Duration thinkingTime,
    required String action,
  }) async {
    await _analytics.logEvent(
      name: 'turn_timing',
      parameters: {
        'game_id': gameId,
        'player_id': playerId,
        'is_bot': isBot,
        'thinking_ms': thinkingTime.inMilliseconds,
        'action': action,
      },
    );
    
    // Flag slow bot turns for optimization
    if (isBot && thinkingTime.inMilliseconds > 2000) {
      await _analytics.logEvent(
        name: 'slow_bot_turn',
        parameters: {
          'game_id': gameId,
          'thinking_ms': thinkingTime.inMilliseconds,
        },
      );
    }
  }
  
  /// Log tutorial completion for onboarding analysis
  static Future<void> logTutorialProgress({
    required String userId,
    required int stepCompleted,
    required int totalSteps,
    required bool skipped,
  }) async {
    await _analytics.logEvent(
      name: 'tutorial_progress',
      parameters: {
        'user_id': userId,
        'step': stepCompleted,
        'total_steps': totalSteps,
        'skipped': skipped,
        'completion_rate': (stepCompleted / totalSteps * 100).round(),
      },
    );
  }
  
  /// Log regional variant usage
  static Future<void> logVariantUsage({
    required String gameId,
    required String variant, // 'standard', 'dashain', 'murder', 'kidnap'
    required int playerCount,
  }) async {
    await _analytics.logEvent(
      name: 'variant_usage',
      parameters: {
        'game_id': gameId,
        'variant': variant,
        'player_count': playerCount,
      },
    );
  }
  
  /// Log error prevention dialog usage
  static Future<void> logErrorPreventionUsage({
    required String eventType, // 'maal_discard_confirm', 'undo_action', 'invalid_set'
    required String outcome, // 'confirmed', 'cancelled', 'undone'
  }) async {
    await _analytics.logEvent(
      name: 'error_prevention',
      parameters: {
        'event_type': eventType,
        'outcome': outcome,
      },
    );
  }
}

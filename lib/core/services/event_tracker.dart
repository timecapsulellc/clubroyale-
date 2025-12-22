import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics Event Tracking Service
///
/// Centralized service for tracking all app events.
/// Integrates with Firebase Analytics for comprehensive insights.
class EventTracker {
  static final EventTracker _instance = EventTracker._internal();
  factory EventTracker() => _instance;
  EventTracker._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ==================== Game Events ====================

  /// Track when a game starts
  Future<void> trackGameStarted({
    required String gameType,
    required String roomId,
    required int playerCount,
    required bool hasBots,
    int? betAmount,
  }) async {
    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'game_type': gameType,
        'room_id': roomId,
        'player_count': playerCount,
        'has_bots': hasBots,
        if (betAmount != null) 'bet_amount': betAmount,
      },
    );
  }

  /// Track when a game ends
  Future<void> trackGameCompleted({
    required String gameType,
    required String roomId,
    required int durationSeconds,
    required String result, // 'win', 'loss', 'draw'
    int? scoreChange,
    int? diamondsWon,
  }) async {
    await _analytics.logEvent(
      name: 'game_completed',
      parameters: {
        'game_type': gameType,
        'room_id': roomId,
        'duration_seconds': durationSeconds,
        'result': result,
        if (scoreChange != null) 'score_change': scoreChange,
        if (diamondsWon != null) 'diamonds_won': diamondsWon,
      },
    );
  }

  /// Track instant play (bot room) usage
  Future<void> trackInstantPlay({
    required String gameType,
    required int waitTimeMs,
  }) async {
    await _analytics.logEvent(
      name: 'instant_play_used',
      parameters: {
        'game_type': gameType,
        'wait_time_ms': waitTimeMs,
      },
    );
  }

  // ==================== Diamond Economy Events ====================

  /// Track diamond spending
  Future<void> trackDiamondsSpent({
    required int amount,
    required String category, // 'game_entry', 'tip', 'gift', 'unlock'
    String? itemId,
  }) async {
    await _analytics.logEvent(
      name: 'diamonds_spent',
      parameters: {
        'amount': amount,
        'category': category,
        if (itemId != null) 'item_id': itemId,
      },
    );
    
    // Also log as Firebase ecommerce event
    await _analytics.logSpendVirtualCurrency(
      itemName: category,
      virtualCurrencyName: 'diamonds',
      value: amount.toDouble(),
    );
  }

  /// Track diamond earning
  Future<void> trackDiamondsEarned({
    required int amount,
    required String source, // 'game_win', 'daily_bonus', 'achievement', 'referral'
  }) async {
    await _analytics.logEvent(
      name: 'diamonds_earned',
      parameters: {
        'amount': amount,
        'source': source,
      },
    );
    
    await _analytics.logEarnVirtualCurrency(
      virtualCurrencyName: 'diamonds',
      value: amount.toDouble(),
    );
  }

  /// Track diamond purchase
  Future<void> trackDiamondPurchase({
    required String productId,
    required int diamondAmount,
    required double price,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: 'Diamond Pack',
          quantity: diamondAmount,
          price: price,
        ),
      ],
    );
  }

  // ==================== Social Events ====================

  /// Track friend added
  Future<void> trackFriendAdded({
    required String source, // 'search', 'game', 'invite', 'contact_sync'
  }) async {
    await _analytics.logEvent(
      name: 'friend_added',
      parameters: {'source': source},
    );
  }

  /// Track message sent
  Future<void> trackMessageSent({
    required String chatType, // 'dm', 'game', 'club'
    bool hasMedia = false,
  }) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'chat_type': chatType,
        'has_media': hasMedia,
      },
    );
  }

  /// Track story posted
  Future<void> trackStoryPosted({
    required String storyType, // 'photo', 'text', 'game_result'
  }) async {
    await _analytics.logEvent(
      name: 'story_posted',
      parameters: {'story_type': storyType},
    );
  }

  /// Track club joined
  Future<void> trackClubJoined({
    required String clubId,
    required int memberCount,
  }) async {
    await _analytics.logEvent(
      name: 'club_joined',
      parameters: {
        'club_id': clubId,
        'member_count': memberCount,
      },
    );
  }

  // ==================== Engagement Events ====================

  /// Track session start with context
  Future<void> trackSessionStart({
    required bool isReturningUser,
    int? daysSinceLastVisit,
  }) async {
    await _analytics.logEvent(
      name: 'session_start_detailed',
      parameters: {
        'is_returning_user': isReturningUser,
        if (daysSinceLastVisit != null) 'days_since_last_visit': daysSinceLastVisit,
      },
    );
  }

  /// Track feature discovery
  Future<void> trackFeatureDiscovered({
    required String featureName,
    required String context,
  }) async {
    await _analytics.logEvent(
      name: 'feature_discovered',
      parameters: {
        'feature_name': featureName,
        'context': context,
      },
    );
  }

  /// Track tutorial completion
  Future<void> trackTutorialCompleted({
    required String tutorialName,
    required int durationSeconds,
    bool skipped = false,
  }) async {
    await _analytics.logTutorialComplete();
    await _analytics.logEvent(
      name: 'tutorial_completed_detailed',
      parameters: {
        'tutorial_name': tutorialName,
        'duration_seconds': durationSeconds,
        'skipped': skipped,
      },
    );
  }

  // ==================== Error Events ====================

  /// Track errors for debugging
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? screen,
    String? action,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
        if (screen != null) 'screen': screen,
        if (action != null) 'action': action,
      },
    );
  }

  // ==================== User Properties ====================

  /// Set user properties for segmentation
  Future<void> setUserProperties({
    String? tier, // 'free', 'premium', 'vip'
    int? totalGamesPlayed,
    int? diamondBalance,
    String? preferredGameType,
    int? friendCount,
  }) async {
    if (tier != null) {
      await _analytics.setUserProperty(name: 'user_tier', value: tier);
    }
    if (totalGamesPlayed != null) {
      final bracket = _getPlayCountBracket(totalGamesPlayed);
      await _analytics.setUserProperty(name: 'play_count_bracket', value: bracket);
    }
    if (friendCount != null) {
      final socialLevel = friendCount > 20 ? 'high' : friendCount > 5 ? 'medium' : 'low';
      await _analytics.setUserProperty(name: 'social_level', value: socialLevel);
    }
    if (preferredGameType != null) {
      await _analytics.setUserProperty(name: 'preferred_game', value: preferredGameType);
    }
  }

  String _getPlayCountBracket(int count) {
    if (count == 0) return 'new';
    if (count < 10) return 'casual';
    if (count < 50) return 'regular';
    if (count < 200) return 'engaged';
    return 'power_user';
  }
}

/// Global instance
final eventTracker = EventTracker();

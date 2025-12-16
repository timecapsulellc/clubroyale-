// Analytics Service
//
// Firebase Analytics wrapper for tracking user behavior.
// All analytics are opt-out compliant.

import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics event names
class AnalyticsEvents {
  // Auth
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String logout = 'logout';
  
  // Game
  static const String gameCreate = 'game_create';
  static const String gameJoin = 'game_join';
  static const String gameStart = 'game_start';
  static const String gameEnd = 'game_end';
  static const String gameLeave = 'game_leave';
  
  // Monetization
  static const String storeOpen = 'store_open';
  static const String purchaseStart = 'purchase_start';
  static const String purchaseComplete = 'purchase_complete';
  static const String purchaseFail = 'purchase_fail';
  
  // Social
  static const String inviteSend = 'invite_send';
  static const String inviteAccept = 'invite_accept';
  static const String settlementShare = 'settlement_share';
  
  // Engagement
  static const String botMatch = 'bot_match';
  static const String tutorialStart = 'tutorial_start';
  static const String tutorialComplete = 'tutorial_complete';
}

/// Analytics service singleton
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get analytics observer for navigation
  FirebaseAnalyticsObserver get observer => 
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ AUTH EVENTS ============

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: AnalyticsEvents.logout);
  }

  // ============ GAME EVENTS ============

  Future<void> logGameCreate({
    required String gameType,
    required int maxPlayers,
    required bool hasBots,
  }) async {
    await _analytics.logEvent(
      name: AnalyticsEvents.gameCreate,
      parameters: {
        'game_type': gameType,
        'max_players': maxPlayers,
        'has_bots': hasBots,
      },
    );
  }

  Future<void> logGameJoin({
    required String gameType,
    required String joinMethod, // 'code', 'invite', 'matchmaking'
  }) async {
    await _analytics.logEvent(
      name: AnalyticsEvents.gameJoin,
      parameters: {
        'game_type': gameType,
        'join_method': joinMethod,
      },
    );
  }

  Future<void> logGameStart({
    required String gameType,
    required int playerCount,
    required int botCount,
  }) async {
    await _analytics.logEvent(
      name: AnalyticsEvents.gameStart,
      parameters: {
        'game_type': gameType,
        'player_count': playerCount,
        'bot_count': botCount,
      },
    );
  }

  Future<void> logGameEnd({
    required String gameType,
    required int durationMinutes,
    required int totalRounds,
    required bool completed, // vs abandoned
  }) async {
    await _analytics.logEvent(
      name: AnalyticsEvents.gameEnd,
      parameters: {
        'game_type': gameType,
        'duration_minutes': durationMinutes,
        'total_rounds': totalRounds,
        'completed': completed,
      },
    );
  }

  // Backwards Compatibility / Legacy Methods
  Future<void> logGameStarted(String gameId, {int playerCount = 4}) async {
    await logGameStart(
      gameType: 'unknown', 
      playerCount: playerCount, 
      botCount: 0
    );
  }

  Future<void> logGameCompleted(String gameId, {required int durationSeconds, required int totalRounds}) async {
    await logGameEnd(
      gameType: 'unknown',
      durationMinutes: durationSeconds ~/ 60,
      totalRounds: totalRounds,
      completed: true,
    );
  }

  Future<void> logRoomJoined(String roomId) async {
    await _analytics.logEvent(
      name: 'room_joined',
      parameters: {'room_id': roomId},
    );
  }

  Future<void> logCardPlayed(String gameId, String cardName) async {
    await _analytics.logEvent(
      name: 'card_played',
      parameters: {'game_id': gameId, 'card': cardName},
    );
  }

  Future<void> logBidPlaced(String gameId, int bidAmount) async {
    await _analytics.logEvent(
      name: 'bid_placed',
      parameters: {'game_id': gameId, 'bid_amount': bidAmount},
    );
  }

  // ============ MONETIZATION EVENTS ============

  Future<void> logStoreOpen() async {
    await _analytics.logEvent(name: AnalyticsEvents.storeOpen);
  }

  Future<void> logPurchaseStart({
    required String productId,
    required double price,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: AnalyticsEvents.purchaseStart,
      parameters: {
        'product_id': productId,
        'price': price,
        'currency': currency,
      },
    );
  }

  Future<void> logPurchaseComplete({
    required String productId,
    required double price,
    required String currency,
    required int diamondsGranted,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: 'Diamonds',
          quantity: diamondsGranted,
          price: price,
        ),
      ],
    );
  }

  Future<void> logPurchaseFail({
    required String productId,
    required String errorCode,
  }) async {
    await _analytics.logEvent(
      name: AnalyticsEvents.purchaseFail,
      parameters: {
        'product_id': productId,
        'error_code': errorCode,
      },
    );
  }
  
  // Legacy alias
  Future<void> logPurchaseCompleted(String productId, double amount, String currency) async {
    await logPurchaseComplete(
      productId: productId, 
      price: amount, 
      currency: currency, 
      diamondsGranted: 0
    );
  }
  
  Future<void> logPurchaseAttempt(String productId, double amount) async {
    await logPurchaseStart(
      productId: productId, 
      price: amount, 
      currency: 'USD'
    );
  }

  // ============ SOCIAL EVENTS ============

  Future<void> logInviteSend({required String gameType}) async {
    await _analytics.logShare(
      contentType: 'invite',
      itemId: gameType,
      method: 'share_sheet',
    );
  }

  Future<void> logSettlementShare({required String gameType}) async {
    await _analytics.logShare(
      contentType: 'settlement',
      itemId: gameType,
      method: 'share_sheet',
    );
  }
  
  Future<void> logRoomCreated(String roomId, {bool isPublic = true}) async {
    await _analytics.logEvent(
      name: 'room_created',
      parameters: {'room_id': roomId, 'is_public': isPublic},
    );
  }

  Future<void> logCustomEvent(String eventName, {Map<String, Object>? parameters}) async {
     await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }

  // ============ USER PROPERTIES ============

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setGamesPlayed(int count) async {
    await setUserProperty('games_played', count.toString());
  }

  Future<void> setPreferredGame(String gameType) async {
    await setUserProperty('preferred_game', gameType);
  }

  Future<void> setDiamondBalance(int balance) async {
    await setUserProperty('diamond_balance_tier', _getDiamondTier(balance));
  }

  String _getDiamondTier(int balance) {
    if (balance >= 1000) return 'whale';
    if (balance >= 500) return 'dolphin';
    if (balance >= 100) return 'minnow';
    if (balance > 0) return 'active';
    return 'free';
  }

  // ============ SCREEN TRACKING ============

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
  
  // Alias
  Future<void> setCurrentScreen(String screenName) => logScreenView(screenName);
  
  Future<void> logProfileUpdate() async {
    await _analytics.logEvent(name: 'profile_updated');
  }
}

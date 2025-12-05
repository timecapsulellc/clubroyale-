import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking analytics events throughout the app
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
      );

  // Game Events

  Future<void> logGameStarted(String gameId, {int playerCount = 4}) async {
    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'game_id': gameId,
        'player_count': playerCount,
      },
    );
  }

  Future<void> logGameCompleted(
    String gameId, {
    required int durationSeconds,
    required int totalRounds,
  }) async {
    await _analytics.logEvent(
      name: 'game_completed',
      parameters: {
        'game_id': gameId,
        'duration_seconds': durationSeconds,
        'total_rounds': totalRounds,
      },
    );
  }

  Future<void> logBidPlaced(String gameId, int bidAmount) async {
    await _analytics.logEvent(
      name: 'bid_placed',
      parameters: {
        'game_id': gameId,
        'bid_amount': bidAmount,
      },
    );
  }

  Future<void> logCardPlayed(String gameId, String cardName) async {
    await _analytics.logEvent(
      name: 'card_played',
      parameters: {
        'game_id': gameId,
        'card': cardName,
      },
    );
  }

  // User Events

  Future<void> logSignIn(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logProfileUpdate() async {
    await _analytics.logEvent(name: 'profile_updated');
  }

  // Room Events

  Future<void> logRoomCreated(String roomId, {bool isPublic = true}) async {
    await _analytics.logEvent(
      name: 'room_created',
      parameters: {
        'room_id': roomId,
        'is_public': isPublic,
      },
    );
  }

  Future<void> logRoomJoined(String roomId) async {
    await _analytics.logEvent(
      name: 'room_joined',
      parameters: {'room_id': roomId},
    );
  }

  // Purchase Events

  Future<void> logPurchaseAttempt(String productId, double amount) async {
    await _analytics.logEvent(
      name: 'purchase_attempt',
      parameters: {
        'product_id': productId,
        'amount': amount,
      },
    );
  }

  Future<void> logPurchaseCompleted(
    String productId,
    double amount,
    String currency,
  ) async {
    await _analytics.logPurchase(
      value: amount,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
        ),
      ],
    );
  }

  // Error Events

  Future<void> logError(String errorType, String errorMessage) async {
    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }

  // Screen Views

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Custom Events

  Future<void> logCustomEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}

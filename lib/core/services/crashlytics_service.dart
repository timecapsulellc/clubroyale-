/// Crashlytics Service - Enhanced error reporting
///
/// Features:
/// - User context in crash reports
/// - Game state tracking
/// - Custom keys for debugging
/// - Non-fatal error logging
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for crashlytics service
final crashlyticsServiceProvider = Provider((ref) => CrashlyticsService());

/// Crashlytics service for enhanced error reporting
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // ========== USER CONTEXT ==========

  /// Set user identifier for crash reports
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    debugPrint('🔥 Crashlytics: User ID set to $userId');
  }

  /// Clear user identifier on logout
  Future<void> clearUserId() async {
    await _crashlytics.setUserIdentifier('');
  }

  // ========== CUSTOM KEYS ==========

  /// Set a custom key for debugging
  Future<void> setKey(String key, dynamic value) async {
    if (value is String) {
      await _crashlytics.setCustomKey(key, value);
    } else if (value is bool) {
      await _crashlytics.setCustomKey(key, value);
    } else if (value is int) {
      await _crashlytics.setCustomKey(key, value);
    } else if (value is double) {
      await _crashlytics.setCustomKey(key, value);
    } else {
      await _crashlytics.setCustomKey(key, value.toString());
    }
  }

  /// Set current screen for crash context
  Future<void> setCurrentScreen(String screenName) async {
    await setKey('current_screen', screenName);
  }

  /// Set game context for crashes during gameplay
  Future<void> setGameContext({
    String? gameId,
    String? gameType,
    int? roundNumber,
    String? gamePhase,
  }) async {
    if (gameId != null) await setKey('game_id', gameId);
    if (gameType != null) await setKey('game_type', gameType);
    if (roundNumber != null) await setKey('game_round', roundNumber);
    if (gamePhase != null) await setKey('game_phase', gamePhase);
  }

  /// Clear game context when leaving game
  Future<void> clearGameContext() async {
    await setKey('game_id', '');
    await setKey('game_type', '');
    await setKey('game_round', 0);
    await setKey('game_phase', '');
  }

  /// Set user profile context
  Future<void> setUserContext({
    String? displayName,
    int? diamondBalance,
    int? gamesPlayed,
    String? accountType,
  }) async {
    if (displayName != null) await setKey('user_name', displayName);
    if (diamondBalance != null) await setKey('diamond_balance', diamondBalance);
    if (gamesPlayed != null) await setKey('games_played', gamesPlayed);
    if (accountType != null) await setKey('account_type', accountType);
  }

  // ========== ERROR LOGGING ==========

  /// Log a breadcrumb message (for debugging crash context)
  void log(String message) {
    _crashlytics.log(message);
    debugPrint('📝 Crashlytics log: $message');
  }

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
    debugPrint(
      '🔥 Crashlytics: Recorded ${fatal ? 'FATAL' : 'non-fatal'} error: $error',
    );
  }

  /// Record a Flutter error
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await _crashlytics.recordFlutterError(details);
    debugPrint('🔥 Crashlytics: Recorded Flutter error: ${details.exception}');
  }

  // ========== CONVENIENCE METHODS ==========

  /// Log network error with context
  Future<void> recordNetworkError({
    required String endpoint,
    required int statusCode,
    String? message,
  }) async {
    log('Network error: $endpoint returned $statusCode');
    await setKey('last_network_endpoint', endpoint);
    await setKey('last_network_status', statusCode);

    if (statusCode >= 500) {
      await recordError(
        Exception('Server error: $endpoint returned $statusCode'),
        null,
        reason: message ?? 'Network error',
      );
    }
  }

  /// Log game error with context
  Future<void> recordGameError({
    required String gameId,
    required String error,
    String? gamePhase,
  }) async {
    log('Game error in $gameId during $gamePhase: $error');
    await setKey('last_game_error', error);

    await recordError(
      Exception('Game error: $error'),
      null,
      reason: 'Game error in $gamePhase',
    );
  }

  /// Log payment error
  Future<void> recordPaymentError({
    required String productId,
    required String error,
  }) async {
    log('Payment error for $productId: $error');
    await setKey('last_payment_error', error);
    await setKey('last_payment_product', productId);

    await recordError(
      Exception('Payment error: $error'),
      null,
      reason: 'Payment failed for $productId',
    );
  }

  // ========== INITIALIZATION ==========

  /// Initialize Crashlytics with proper Flutter error handling
  static Future<void> initialize() async {
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Pass all uncaught async errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('🔥 Crashlytics initialized');
  }

  /// Force a test crash (for testing purposes only)
  void testCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/analytics_service.dart';

/// Analytics Service Tests
///
/// Tests for analytics event tracking.
void main() {
  late AnalyticsService analyticsService;

  setUpAll(() {
    AnalyticsService.isTestMode = true;
  });

  setUp(() {
    analyticsService = AnalyticsService();
  });

  group('Analytics Service', () {
    test('singleton instance exists', () {
      expect(analyticsService, isNotNull);
      expect(AnalyticsService(), same(analyticsService));
    });

    test('isTestMode is set correctly', () {
      expect(AnalyticsService.isTestMode, isTrue);
    });
  });

  group('Event Logging (Test Mode)', () {
    // In test mode, methods shouldn't actually call Firebase
    // These tests verify the API exists

    test('logCustomEvent exists', () {
      expect(analyticsService.logCustomEvent, isA<Function>());
    });

    test('logError exists', () {
      expect(analyticsService.logError, isA<Function>());
    });

    test('logGameStart exists', () {
      expect(analyticsService.logGameStart, isA<Function>());
    });

    test('logGameEnd exists', () {
      expect(analyticsService.logGameEnd, isA<Function>());
    });
  });

  group('User Properties', () {
    test('setUserId exists', () {
      expect(analyticsService.setUserId, isA<Function>());
    });

    test('setUserProperty exists', () {
      expect(analyticsService.setUserProperty, isA<Function>());
    });

    test('setGamesPlayed exists', () {
      expect(analyticsService.setGamesPlayed, isA<Function>());
    });
  });
}

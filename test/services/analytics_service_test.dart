import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/analytics_service.dart';

/// Analytics Service Tests
///
/// Tests for analytics event tracking and screen observation.
void main() {
  late AnalyticsService analyticsService;

  setUp(() {
    analyticsService = AnalyticsService();
  });

  group('Screen Tracking', () {
    test('creates FirebaseAnalyticsObserver', () {
      expect(analyticsService.observer, isNotNull);
    });

    test('observer is correct type', () {
      expect(
        analyticsService.observer.runtimeType.toString(),
        contains('Analytics'),
      );
    });
  });

  group('Event Logging', () {
    test('logEvent does not throw for valid event', () async {
      expect(
        () => analyticsService.logEvent('test_event', {'param': 'value'}),
        returnsNormally,
      );
    });

    test('logEvent handles null parameters', () async {
      expect(
        () => analyticsService.logEvent('test_event', null),
        returnsNormally,
      );
    });

    test('logEvent handles empty parameters', () async {
      expect(
        () => analyticsService.logEvent('test_event', {}),
        returnsNormally,
      );
    });
  });

  group('User Properties', () {
    test('setUserId does not throw', () async {
      expect(
        () => analyticsService.setUserId('test-user-123'),
        returnsNormally,
      );
    });

    test('setUserProperty does not throw', () async {
      expect(
        () => analyticsService.setUserProperty('tier', 'premium'),
        returnsNormally,
      );
    });
  });
}

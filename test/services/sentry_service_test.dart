import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/sentry_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry Service Tests
void main() {
  group('SentryService', () {
    test('isEnabled returns false when DSN not configured', () {
      // By default, DSN is empty in tests
      expect(SentryService.isEnabled, isFalse);
    });

    test('captureException does not throw when disabled', () async {
      await expectLater(
        SentryService.captureException(
          Exception('Test error'),
          message: 'Test message',
        ),
        completes,
      );
    });

    test('captureMessage does not throw when disabled', () async {
      await expectLater(
        SentryService.captureMessage('Test message', level: SentryLevel.info),
        completes,
      );
    });

    test('setUser does not throw when disabled', () async {
      await expectLater(SentryService.setUser(null), completes);
    });

    test('addBreadcrumb does not throw when disabled', () {
      expect(
        () => SentryService.addBreadcrumb(
          message: 'Test breadcrumb',
          category: 'test',
        ),
        returnsNormally,
      );
    });

    test('startTransaction returns null when disabled', () {
      final span = SentryService.startTransaction('test', 'operation');
      expect(span, isNull);
    });
  });

  group('SentryService with extras', () {
    test('captureException with extras does not throw', () async {
      await expectLater(
        SentryService.captureException(
          Exception('Test'),
          extras: {'key': 'value', 'count': 42},
        ),
        completes,
      );
    });

    test('captureMessage with extras does not throw', () async {
      await expectLater(
        SentryService.captureMessage(
          'Test message',
          extras: {'screen': 'lobby', 'action': 'tap'},
        ),
        completes,
      );
    });
  });
}

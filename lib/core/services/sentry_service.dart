import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sentry Error Tracking Service
///
/// Provides comprehensive error tracking across all platforms
/// including web (which Crashlytics doesn't support).
class SentryService {
  /// Sentry DSN - set via build: flutter build --dart-define=SENTRY_DSN=your_dsn
  static const String _dsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static bool get isEnabled => _dsn.isNotEmpty;

  /// Initialize Sentry with Flutter integration
  static Future<void> init() async {
    if (!isEnabled) {
      debugPrint('⚠️ Sentry DSN not configured - skipping initialization');
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = _dsn;
      options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.sendDefaultPii = false; // GDPR compliance
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;

      // Filter out sensitive data
      options.beforeSend = (event, hint) {
        // Remove any PII from breadcrumbs
        final breadcrumbs = event.breadcrumbs?.map((b) {
          if (b.data != null) {
            final filtered = Map<String, dynamic>.from(b.data!);
            filtered.remove('email');
            filtered.remove('phone');
            filtered.remove('password');
            return b.copyWith(data: filtered);
          }
          return b;
        }).toList();

        return event.copyWith(breadcrumbs: breadcrumbs);
      };
    });

    debugPrint('✅ Sentry initialized successfully');
  }

  /// Set user context for error tracking
  static Future<void> setUser(User? user) async {
    if (!isEnabled) return;

    if (user != null) {
      Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: user.uid,
            // Don't include email for privacy
          ),
        );
      });
    } else {
      Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    }
  }

  /// Capture an exception with optional context
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? message,
    Map<String, dynamic>? extras,
  }) async {
    if (!isEnabled) {
      debugPrint('Sentry: $exception');
      return;
    }

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (message != null) {
          scope.setTag('message', message);
        }
        if (extras != null) {
          extras.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
      },
    );
  }

  /// Capture a message for logging
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extras,
  }) async {
    if (!isEnabled) {
      debugPrint('Sentry [$level]: $message');
      return;
    }

    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        if (extras != null) {
          extras.forEach((key, value) {
            scope.setExtra(key, value);
          });
        }
      },
    );
  }

  /// Add breadcrumb for debugging context
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    if (!isEnabled) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        level: level,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Start a performance transaction
  static ISentrySpan? startTransaction(String name, String operation) {
    if (!isEnabled) return null;
    return Sentry.startTransaction(name, operation);
  }
}

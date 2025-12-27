/// Firebase and third-party service configuration
/// 
/// For production:
/// - VAPID Key: Get from Firebase Console -> Project Settings -> Cloud Messaging
/// - Sentry DSN: Set via --dart-define=SENTRY_DSN=your_dsn during build
class FirebaseConfig {
  /// Web Push VAPID key for Firebase Cloud Messaging
  static const String vapidKey = 'bRd7Z2Y1iTxyfB2OFic0yCNuJYeG2XYzL1c_PHYyAz4';
  
  /// Sentry DSN is read from environment (set during build with --dart-define)
  /// Note: firebase_config.dart:6 listed as placeholder was actually in sentry_service.dart
  /// Keeping this here as fallback documentation
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
}

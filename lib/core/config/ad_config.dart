import 'dart:io';

/// AdMob Configuration
///
/// Production IDs can be set via dart-define at build time:
/// flutter build apk --dart-define=ADMOB_ANDROID_APP_ID=ca-app-pub-XXX~XXX
/// flutter build apk --dart-define=ADMOB_ANDROID_REWARDED_ID=ca-app-pub-XXX/XXX
///
/// If not set, Test IDs are used (safe for development).
class AdConfig {
  // Environment variables (set via --dart-define)
  static const String _androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713', // Test ID
  );
  static const String _iosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511', // Test ID
  );
  static const String _androidRewardedId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917', // Test ID
  );
  static const String _iosRewardedId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313', // Test ID
  );

  static String get appId {
    if (Platform.isAndroid) {
      return _androidAppId;
    } else if (Platform.isIOS) {
      return _iosAppId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _androidRewardedId;
    } else if (Platform.isIOS) {
      return _iosRewardedId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Check if using test IDs (for logging/debugging)
  static bool get isUsingTestIds {
    return _androidAppId.contains('3940256099942544') ||
        _iosAppId.contains('3940256099942544');
  }

  static const int maxAdsPerDay = 6;
  static const int rewardAmount = 20;
}

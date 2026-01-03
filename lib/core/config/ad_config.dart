import 'dart:io';

class AdConfig {
  static String get appId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544~3347511713'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544~1458002511'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static const int maxAdsPerDay = 6;
  static const int rewardAmount = 20;
}

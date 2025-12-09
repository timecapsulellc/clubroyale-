import 'package:flutter/foundation.dart';

/// Web implementation of AdService (no ads on web)
class AdServiceWeb implements _AdServiceInterface {
  @override
  Future<void> initialize() async {
    debugPrint('AdService (Web): Ads not supported on web platform');
  }

  @override
  Future<bool> showRewardedAd() async {
    debugPrint('AdService (Web): Simulating ad reward');
    await Future.delayed(const Duration(seconds: 2));
    return true; // Always succeed on web for testing
  }
}

/// Platform interface
abstract class _AdServiceInterface {
  Future<void> initialize();
  Future<bool> showRewardedAd();
}

/// Factory function for web
AdServiceWeb getAdService() => AdServiceWeb();

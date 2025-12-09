// import 'dart:io'; // Remove dart:io
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:taasclub/core/config/diamond_config.dart';

part 'ad_service.g.dart';

@Riverpod(keepAlive: true)
AdService adService(AdServiceRef ref) {
  return AdService();
}

class AdService {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  Future<void> initialize() async {
    // MobileAds isn't supported on web, wrap in try-catch or check platform
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
      _loadRewardedAd();
    }
  }

  /// Load a rewarded video ad
  void _loadRewardedAd() {
    if (kIsWeb) return; // No ads on web
    if (_isAdLoading) return;
    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoading = false;
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadRewardedAd);
        },
      ),
    );
  }

  /// Show a rewarded video ad and return whether the user earned the reward
  Future<bool> showRewardedAd() async {
    // In web or dev mode, skipping ad might be desirable for testing
    if (kIsWeb) {
       debugPrint('Web Mode: Simulating ad success');
       // Simulate delay
       await Future.delayed(const Duration(seconds: 2));
       return true;
    }

    if (_rewardedAd == null) {
      debugPrint('Warning: Ad attempted to show before loading.');
      _loadRewardedAd(); // Try loading for next time
      
      if (kDebugMode) {
         debugPrint('Dev Mode: Simulating ad success');
         return true;
      }
      return false;
    }

    bool rewardEarned = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        rewardEarned = true;
      },
    );
    
    // Dispose and reload
    _rewardedAd = null;
    _loadRewardedAd();

    return rewardEarned;
  }

  /// Get platform specific ad unit ID
  String get _rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return DiamondConfig.androidAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return DiamondConfig.iosAdUnitId;
    } else {
      // Fallback or error
      return DiamondConfig.androidAdUnitId; 
    }
  }
}

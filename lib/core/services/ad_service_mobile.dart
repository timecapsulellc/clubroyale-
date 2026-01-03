import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clubroyale/core/config/diamond_config.dart';

/// Mobile (iOS/Android) implementation of AdService
class AdServiceMobile implements _AdServiceInterface {
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    if (_isAdLoading) return;
    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('\$ad loaded.');
          _rewardedAd = ad;
          _isAdLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: \$error');
          _rewardedAd = null;
          _isAdLoading = false;
          Future.delayed(const Duration(minutes: 1), _loadRewardedAd);
        },
      ),
    );
  }

  @override
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      debugPrint('Warning: Ad attempted to show before loading.');
      _loadRewardedAd();

      if (kDebugMode) {
        debugPrint('Dev Mode: Simulating ad success');
        return true;
      }
      return false;
    }

    bool rewardEarned = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: \${reward.amount} \${reward.type}');
        rewardEarned = true;
      },
    );

    _rewardedAd = null;
    _loadRewardedAd();

    return rewardEarned;
  }

  String get _rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return DiamondConfig.androidAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return DiamondConfig.iosAdUnitId;
    } else {
      return DiamondConfig.androidAdUnitId;
    }
  }
}

/// Platform interface
abstract class _AdServiceInterface {
  Future<void> initialize();
  Future<bool> showRewardedAd();
}

/// Factory function for mobile
AdServiceMobile getAdService() => AdServiceMobile();

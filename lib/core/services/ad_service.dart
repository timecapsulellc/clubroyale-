import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clubroyale/core/config/ad_config.dart';

class AdService {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _createRewardedAd();
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      _createRewardedAd(); // Try loading again
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd(); // Load the next one
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    _rewardedAd = null;
  }
}

final adService = AdService();

/// Stub implementation - should never be used
class AdServiceStub {
  Future<void> initialize() async {}
  Future<bool> showRewardedAd() async => false;
}

abstract class _AdServiceInterface {
  Future<void> initialize();
  Future<bool> showRewardedAd();
}

AdServiceStub getAdService() => AdServiceStub();

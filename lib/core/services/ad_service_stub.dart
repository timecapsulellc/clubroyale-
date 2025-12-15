/// Stub implementation - should never be used
class AdServiceStub {
  Future<void> initialize() async {}
  Future<bool> showRewardedAd() async => false;
}

AdServiceStub getAdService() => AdServiceStub();

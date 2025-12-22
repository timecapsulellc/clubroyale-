import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/feature_flags.dart';

/// Feature Flags Service Tests
void main() {
  group('FeatureFlags', () {
    test('singleton instance is same', () {
      expect(featureFlags, same(featureFlags));
    });

    test('socialEnabled has boolean value', () {
      expect(featureFlags.socialEnabled, isA<bool>());
    });

    test('storiesEnabled has boolean value', () {
      expect(featureFlags.storiesEnabled, isA<bool>());
    });

    test('voiceRoomsEnabled has boolean value', () {
      expect(featureFlags.voiceRoomsEnabled, isA<bool>());
    });

    test('liveVideoEnabled has boolean value', () {
      expect(featureFlags.liveVideoEnabled, isA<bool>());
    });
  });

  group('FeatureFlags.isEnabled', () {
    test('returns false for unknown feature', () {
      expect(featureFlags.isEnabled('unknown_feature'), isFalse);
    });

    test('returns boolean for known features', () {
      expect(featureFlags.isEnabled('social'), isA<bool>());
    });
  });

  group('FeatureFlags initialization', () {
    test('init completes without error', () async {
      await expectLater(featureFlags.init(), completes);
    });

    test('multiple init calls are safe', () async {
      await featureFlags.init();
      await expectLater(featureFlags.init(), completes);
    });
  });
}

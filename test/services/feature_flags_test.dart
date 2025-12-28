import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/feature_flags.dart';

/// Feature Flags Service Tests
void main() {
  late FeatureFlags flags;

  setUp(() {
    flags = FeatureFlags();
  });

  group('FeatureFlags', () {
    test('singleton instance is same', () {
      expect(flags, same(FeatureFlags()));
    });

    test('socialEnabled has boolean value', () {
      expect(flags.socialEnabled, isA<bool>());
    });

    test('storiesEnabled has boolean value', () {
      expect(flags.storiesEnabled, isA<bool>());
    });

    test('liveMediaEnabled has boolean value', () {
      expect(flags.liveMediaEnabled, isA<bool>());
    });

    test('spectatorEnabled has boolean value', () {
      expect(flags.spectatorEnabled, isA<bool>());
    });
  });

  group('FeatureFlags.isEnabled', () {
    test('returns false for social features by default (Gaming-First)', () {
      expect(flags.isEnabled(Feature.stories), isFalse);
      expect(flags.isEnabled(Feature.socialFeed), isFalse);
      expect(flags.isEnabled(Feature.contentCreation), isFalse);
    });

    test('returns true for gaming features by default', () {
      expect(flags.isEnabled(Feature.liveAudioVideo), isTrue);
      expect(flags.isEnabled(Feature.spectatorMode), isTrue);
      expect(flags.isEnabled(Feature.inGameChat), isTrue);
      expect(flags.isEnabled(Feature.gameRooms), isTrue);
    });
  });

  group('Feature Enum', () {
    test('has expected values', () {
      expect(Feature.values, contains(Feature.stories));
      expect(Feature.values, contains(Feature.liveAudioVideo));
      expect(Feature.values, contains(Feature.tournaments));
    });

    test('has correct count', () {
      expect(Feature.values.length, 11);
    });
  });
}

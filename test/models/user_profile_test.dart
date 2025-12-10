
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/profile/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('should create UserProfile from JSON', () {
      final json = {
        'id': 'user1',
        'displayName': 'John Doe',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user1');
      expect(profile.displayName, 'John Doe');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should create UserProfile with null avatarUrl', () {
      final json = {
        'id': 'user1',
        'displayName': 'John Doe',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user1');
      expect(profile.displayName, 'John Doe');
      expect(profile.avatarUrl, null);
    });

    test('should convert UserProfile to JSON', () {
      const profile = UserProfile(
        id: 'user1',
        displayName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final json = profile.toJson();

      expect(json['id'], 'user1');
      expect(json['displayName'], 'John Doe');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
    });

    test('should convert UserProfile without avatar to JSON', () {
      const profile = UserProfile(
        id: 'user1',
        displayName: 'John Doe',
      );

      final json = profile.toJson();

      expect(json['id'], 'user1');
      expect(json['displayName'], 'John Doe');
      expect(json['avatarUrl'], null);
    });

    test('should create copy with modified fields', () {
      const original = UserProfile(
        id: 'user1',
        displayName: 'Original Name',
      );

      final modified = original.copyWith(
        displayName: 'New Name',
        avatarUrl: 'https://newavatar.com/pic.jpg',
      );

      expect(modified.id, 'user1');
      expect(modified.displayName, 'New Name');
      expect(modified.avatarUrl, 'https://newavatar.com/pic.jpg');
      // Original should be unchanged
      expect(original.displayName, 'Original Name');
      expect(original.avatarUrl, null);
    });

    test('should handle equality for same data', () {
      const profile1 = UserProfile(
        id: 'user1',
        displayName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      const profile2 = UserProfile(
        id: 'user1',
        displayName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      // With Freezed, these should be equal
      expect(profile1, profile2);
    });

    test('should handle inequality for different data', () {
      const profile1 = UserProfile(
        id: 'user1',
        displayName: 'John Doe',
      );

      const profile2 = UserProfile(
        id: 'user2',
        displayName: 'Jane Doe',
      );

      expect(profile1, isNot(equals(profile2)));
    });
  });
}

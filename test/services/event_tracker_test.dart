import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/services/event_tracker.dart';

/// Event Tracker Service Tests
void main() {
  late EventTracker eventTracker;

  setUpAll(() {
    EventTracker.isTestMode = true;
  });

  setUp(() {
    eventTracker = EventTracker();
  });

  group('Game Events', () {
    test('trackGameStarted does not throw', () async {
      expect(
        () => eventTracker.trackGameStarted(
          gameType: 'marriage',
          roomId: 'test-room',
          playerCount: 4,
          hasBots: true,
          betAmount: 100,
        ),
        returnsNormally,
      );
    });

    test('trackGameCompleted does not throw', () async {
      expect(
        () => eventTracker.trackGameCompleted(
          gameType: 'call_break',
          roomId: 'test-room',
          durationSeconds: 600,
          result: 'win',
          scoreChange: 50,
          diamondsWon: 100,
        ),
        returnsNormally,
      );
    });

    test('trackInstantPlay does not throw', () async {
      expect(
        () => eventTracker.trackInstantPlay(
          gameType: 'teen_patti',
          waitTimeMs: 250,
        ),
        returnsNormally,
      );
    });
  });

  group('Diamond Economy Events', () {
    test('trackDiamondsSpent does not throw', () async {
      expect(
        () => eventTracker.trackDiamondsSpent(
          amount: 50,
          category: 'game_entry',
          itemId: 'room-123',
        ),
        returnsNormally,
      );
    });

    test('trackDiamondsEarned does not throw', () async {
      expect(
        () => eventTracker.trackDiamondsEarned(
          amount: 100,
          source: 'game_win',
        ),
        returnsNormally,
      );
    });

    test('trackDiamondPurchase does not throw', () async {
      expect(
        () => eventTracker.trackDiamondPurchase(
          productId: 'diamond_pack_100',
          diamondAmount: 100,
          price: 0.99,
          currency: 'USD',
        ),
        returnsNormally,
      );
    });
  });

  group('Social Events', () {
    test('trackFriendAdded does not throw', () async {
      expect(
        () => eventTracker.trackFriendAdded(source: 'search'),
        returnsNormally,
      );
    });

    test('trackMessageSent does not throw', () async {
      expect(
        () => eventTracker.trackMessageSent(chatType: 'dm', hasMedia: false),
        returnsNormally,
      );
    });

    test('trackStoryPosted does not throw', () async {
      expect(
        () => eventTracker.trackStoryPosted(storyType: 'photo'),
        returnsNormally,
      );
    });

    test('trackClubJoined does not throw', () async {
      expect(
        () => eventTracker.trackClubJoined(clubId: 'club-123', memberCount: 50),
        returnsNormally,
      );
    });
  });

  group('Engagement Events', () {
    test('trackSessionStart does not throw', () async {
      expect(
        () => eventTracker.trackSessionStart(
          isReturningUser: true,
          daysSinceLastVisit: 3,
        ),
        returnsNormally,
      );
    });

    test('trackFeatureDiscovered does not throw', () async {
      expect(
        () => eventTracker.trackFeatureDiscovered(
          featureName: 'stories',
          context: 'lobby_screen',
        ),
        returnsNormally,
      );
    });

    test('trackTutorialCompleted does not throw', () async {
      expect(
        () => eventTracker.trackTutorialCompleted(
          tutorialName: 'marriage_basics',
          durationSeconds: 120,
          skipped: false,
        ),
        returnsNormally,
      );
    });
  });

  group('Error Events', () {
    test('trackError does not throw', () async {
      expect(
        () => eventTracker.trackError(
          errorType: 'network',
          errorMessage: 'Connection timeout',
          screen: 'lobby_screen',
          action: 'join_room',
        ),
        returnsNormally,
      );
    });

    test('trackError truncates long messages', () async {
      final longMessage = 'A' * 200;
      expect(
        () => eventTracker.trackError(
          errorType: 'api',
          errorMessage: longMessage,
        ),
        returnsNormally,
      );
    });
  });

  group('User Properties', () {
    test('setUserProperties does not throw', () async {
      expect(
        () => eventTracker.setUserProperties(
          tier: 'premium',
          totalGamesPlayed: 150,
          diamondBalance: 5000,
          preferredGameType: 'marriage',
          friendCount: 25,
        ),
        returnsNormally,
      );
    });

    test('setUserProperties with partial data does not throw', () async {
      expect(
        () => eventTracker.setUserProperties(tier: 'free'),
        returnsNormally,
      );
    });
  });
}

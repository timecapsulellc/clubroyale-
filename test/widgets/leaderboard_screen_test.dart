
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/leaderboard/leaderboard_screen.dart';

void main() {
  group('LeaderboardScreen Widget Tests', () {
    // Helper to create widget under test
    Widget createWidgetUnderTest() {
      return const ProviderScope(
        child: MaterialApp(
          home: LeaderboardScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('should display back button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Without proper mocking of Firebase, we expect loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LeaderboardEntry Calculations', () {
    test('win rate should be 0 when no games played', () {
      final entry = LeaderboardEntry(
        odayerId: 'test',
        playerName: 'Test Player',
        totalScore: 0,
        gamesPlayed: 0,
        gamesWon: 0,
      );

      expect(entry.winRate, 0.0);
    });

    test('average score should be 0 when no games played', () {
      final entry = LeaderboardEntry(
        odayerId: 'test',
        playerName: 'Test Player',
        totalScore: 0,
        gamesPlayed: 0,
        gamesWon: 0,
      );

      expect(entry.averageScore, 0.0);
    });

    test('win rate should calculate correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'test',
        playerName: 'Test Player',
        totalScore: 100,
        gamesPlayed: 8,
        gamesWon: 2,
      );

      expect(entry.winRate, 0.25);
    });

    test('average score should calculate correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'test',
        playerName: 'Test Player',
        totalScore: 120,
        gamesPlayed: 4,
        gamesWon: 2,
      );

      expect(entry.averageScore, 30.0);
    });
  });
}

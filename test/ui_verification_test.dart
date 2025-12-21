
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';
import 'package:clubroyale/features/onboarding/onboarding_screen.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';
import 'package:clubroyale/features/tournament/widgets/bracket_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI Verification Tests', () {
    testWidgets('SkeletonGameScreen renders correctly', (tester) async {
      // Pump the SkeletonGameScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: SkeletonGameScreen(),
        ),
      );

      // Verify the AppBar title
      expect(find.text('Game Room'), findsOneWidget);

      // Verify presence of SkeletonBoxes (building blocks of the skeleton)
      // We expect multiple boxes for headers, stats, etc.
      expect(find.byType(SkeletonBox), findsWidgets);

      // Verify SkeletonPlayerTiles are rendered in the list
      // ListView only builds visible items, so we might not see all 6 immediately
      expect(find.byType(SkeletonPlayerTile), findsAtLeastNWidgets(1));
    });

    testWidgets('BracketView renders matches with correct data', (tester) async {
      // Mock Data
      final brackets = <TournamentBracket>[
        TournamentBracket(
          id: '1',
          round: 1,
          matchNumber: 1,
          player1Id: 'p1',
          player1Name: 'Alice',
          player1Score: 10,
          player2Id: 'p2',
          player2Name: 'Bob',
          player2Score: 8,
          winnerId: 'p1',
          status: BracketStatus.completed,
        ),
        TournamentBracket(
          id: '2',
          round: 1,
          matchNumber: 2,
          player1Id: 'p3',
          player1Name: 'Charlie',
          player1Score: 0,
          player2Id: 'p4',
          player2Name: 'Dave',
          player2Score: 0,
          status: BracketStatus.inProgress, // LIVE match
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: CasinoColors.darkTheme,
          home: Scaffold(
            body: BracketView(brackets: brackets),
          ),
        ),
      );

      // Allow animations to advance a fixed amount
      await tester.pump(const Duration(seconds: 1));

      // Verify Player Names
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Dave'), findsOneWidget);

      // Verify Scores
      expect(find.text('10'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);

      // Verify Status Badges
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Winner checkmark
      expect(find.byIcon(Icons.emoji_events), findsNWidgets(1)); // Trophy
    });

    testWidgets('OnboardingScreen renders properly', (tester) async {
      // OnboardingScreen relies on SharedPreferences, so we might need to mock or just test the page building
      // However, creating the widget usually triggers initState which loads prefs.
      // Assuming straightforward UI rendering:

      await tester.pumpWidget(
        const ProviderScope(
            child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Pump to start animations
      await tester.pump(const Duration(milliseconds: 500));

      // Verify initial page texts
      expect(find.text('Welcome to ClubRoyale'), findsOneWidget);
      expect(find.text('Play & Connect'), findsOneWidget);

      // Verify the Icon exists (this is the one we animated)
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      
      // We can't easily verify the "float" animation without complex ticking, 
      // but successfully pumping means no crash in the animation setup.
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}

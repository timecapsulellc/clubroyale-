import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/auth/auth_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    // Helper to build the widget with proper settling for animations
    Future<void> buildAuthScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );
      // Allow animations to complete (flutter_animate uses timers)
      // Pump multiple frames to let animations settle
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 200));
    }

    testWidgets('should display app title', (WidgetTester tester) async {
      await buildAuthScreen(tester);
      expect(find.text('ClubRoyale'), findsOneWidget);
    });

    testWidgets('should display subtitle', (WidgetTester tester) async {
      await buildAuthScreen(tester);
      // Current subtitle in auth_screen.dart
      expect(find.textContaining('Ultimate Card Game'), findsOneWidget);
    });

    testWidgets('should display Enter the Club button', (WidgetTester tester) async {
      await buildAuthScreen(tester);
      expect(find.textContaining('Enter the Club'), findsOneWidget);
    });

    testWidgets('should display feature cards', (WidgetTester tester) async {
      await buildAuthScreen(tester);
      
      // Feature cards from _buildFeaturesGrid (lines 434-493)
      expect(find.text('4 Players'), findsOneWidget);
      expect(find.text('Real-time'), findsOneWidget);
      expect(find.text('Bot Players'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('should display chip logo with CR text', (WidgetTester tester) async {
      await buildAuthScreen(tester);
      // Current chip logo has 'CR' text in center
      expect(find.text('CR'), findsOneWidget);
    });

    testWidgets('should have test mode button', (WidgetTester tester) async {
      await buildAuthScreen(tester);
      
      // Quick Test Mode button from _buildTestModeButton (line 417)
      expect(find.text('Quick Test Mode'), findsOneWidget);
    });
  });
}

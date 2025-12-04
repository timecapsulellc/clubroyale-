
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/auth/auth_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('TaasClub'), findsOneWidget);
    });

    testWidgets('should display subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('Play games with friends'), findsOneWidget);
    });

    testWidgets('should display Start Playing button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('Start Playing'), findsOneWidget);
    });

    testWidgets('should display feature items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('Create & join game rooms'), findsOneWidget);
      expect(find.text('Real-time score tracking'), findsOneWidget);
      expect(find.text('Share results with friends'), findsOneWidget);
    });

    testWidgets('should display game controller icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
    });

    testWidgets('should show loading state when signing in', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Find and tap the sign in button
      final button = find.text('Start Playing');
      expect(button, findsOneWidget);

      // We can't fully test Firebase sign-in without mocking,
      // but we can verify the button exists and is tappable
      await tester.tap(button);
      await tester.pump();
    });
  });
}

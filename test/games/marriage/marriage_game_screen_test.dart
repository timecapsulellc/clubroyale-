import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/widgets/visit_button_widget.dart';
import 'package:clubroyale/games/marriage/widgets/maal_indicator.dart';
import 'package:clubroyale/games/marriage/widgets/game_timer_widget.dart';
import 'package:clubroyale/features/ai/ai_service.dart';
import 'package:mockito/mockito.dart';

// Mock AI Service
class MockAiService extends Mock implements AiService {}

void main() {
  group('Marriage Game New Widgets Tests', () {
    testWidgets('VisitButtonWidget renders correctly in locked state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisitButtonWidget(
              state: VisitButtonState.locked,
              label: 'VISIT',
              pureSequenceCount: 1,
              dubleeCount: 2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VISIT'), findsOneWidget);
      // Widget shows progress, not subLabel in locked state
      expect(find.text('1/3 SEQ'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('VisitButtonWidget renders correctly in ready state', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisitButtonWidget(
              state: VisitButtonState.ready,
              label: 'VISIT',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('VISIT'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);

      // Test interaction - tap the button widget area
      await tester.tap(find.byType(VisitButtonWidget));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('VisitButtonWidget renders correctly in visited state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisitButtonWidget(state: VisitButtonState.visited),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VISITED'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('MaalIndicator renders points correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MaalIndicator(points: 15, hasMarriage: true)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('15'), findsOneWidget);
      expect(find.text('Maal'), findsOneWidget);
      expect(
        find.byIcon(Icons.volunteer_activism),
        findsOneWidget,
      ); // Bonus icon
    });

    testWidgets('GameTimerWidget renders countdown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameTimerWidget(totalSeconds: 30, remainingSeconds: 10),
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

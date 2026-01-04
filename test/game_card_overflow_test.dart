import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/widgets/game_card_graphic.dart';

void main() {
  testWidgets('GameCardGraphic renders without overflow at small sizes', (
    WidgetTester tester,
  ) async {
    // Test Marriage card at dashboard size (approx 40)
    // This previously caused a 2.8px overflow in the face cards
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GameCardGraphic(
              gameType: 'marriage',
              size: 40.0,
              animate: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(GameCardGraphic), findsOneWidget);

    // Test Teen Patti card
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GameCardGraphic(
              gameType: 'teen_patti',
              size: 40.0,
              animate: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GameCardGraphic), findsOneWidget);
  });
}

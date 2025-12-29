
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:clubroyale/main.dart' as app;
import 'package:clubroyale/features/game/engine/widgets/card_hand_widget.dart';
import 'package:clubroyale/games/marriage/marriage_game_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Nepali Marriage Gameplay Verification', (WidgetTester tester) async {
    // 1. Start App
    app.main();
    await tester.pumpAndSettle();
    
    // 2. Navigate to Marriage Game (Assume Debug/Dev shortcut or Navigation)
    // For integration test, we might push the screen directly if possible, 
    // or navigate via UI. Assuming UI navigation:
    // Tap "Marriage" card in lobby
    final marriageFinder = find.text('Marriage');
    if (marriageFinder.evaluate().isNotEmpty) {
      await tester.tap(marriageFinder);
      await tester.pumpAndSettle();
    } else {
       // Fallback: Skip if not found (or log error)
       print('Marriage game entry not found in lobby');
    }
    
    // 3. Verify Game Screen Loaded
    expect(find.byType(MarriageGameScreen), findsOneWidget);
    
    // 4. Verify Hand Widget is present
    expect(find.byType(CardHandWidget), findsOneWidget);
    
    // 5. Verify Wildcard Indicator (Tiplu)
    expect(find.text('Tiplu'), findsOneWidget);
    
    // Note: Full gameplay simulation (picking cards, forming dublees) 
    // requires complex state mocking or very specific tap sequences.
    // For this verification, we confirm the UI loads and Wildcard info is displayed.
  });
}

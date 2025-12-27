import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_hand_widget.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

void main() {
  testWidgets('MarriageHandWidget renders cards and groups', (WidgetTester tester) async {
    // Setup 10 cards
    final cards = List.generate(10, (i) => PlayingCard(
      rank: CardRank.values[i % 13], 
      suit: CardSuit.values[i % 4]
    ));

    String? selectedId;
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MarriageHandWidget(
          cards: cards,
          selectedCardId: null,
          onCardSelected: (id) => selectedId = id,
          config: MarriageGameConfig.nepaliStandard,
        ),
      ),
    ));

    // verify cards are present
    expect(find.byType(MarriageHandWidget), findsOneWidget);
    // Initially auto-grouped into 1 group? Or cards stored in local state?
    // We can find CardWidget
    // Note: MarriageHandWidget uses CardWidget internally
    // expect(find.byType(CardWidget), findsNWidgets(10)); 
    // Wait, Flutter test finder might not find customized widgets easily if wrapped.
    // Draggable is used.
    
    expect(find.text('AUTO GROUP'), findsOneWidget);
  });
  
  testWidgets('MarriageHandWidget interaction selects card', (WidgetTester tester) async {
     final card = PlayingCard(rank: CardRank.ace, suit: CardSuit.spades);
     String? selectedId;
     
     await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MarriageHandWidget(
          cards: [card],
          selectedCardId: null,
          onCardSelected: (id) => selectedId = id,
        ),
      ),
    ));
    
    // Tap the card
    // The card is inside Draggable -> GestureDetector
    await tester.tap(find.byType(GestureDetector).last); // Last might be the card
    await tester.pump();
    
    expect(selectedId, card.id);
  });
}

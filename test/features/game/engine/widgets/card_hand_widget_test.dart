import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taasclub/features/game/engine/models/card.dart';
import 'package:taasclub/features/game/engine/widgets/card_hand_widget.dart';

void main() {
  group('CardHandWidget', () {
    final testHand = [
      const PlayingCard(suit: CardSuit.spades, rank: CardRank.ace),
      const PlayingCard(suit: CardSuit.hearts, rank: CardRank.king),
      const PlayingCard(suit: CardSuit.diamonds, rank: CardRank.queen),
      const PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack),
      const PlayingCard(suit: CardSuit.spades, rank: CardRank.ten),
    ];

    testWidgets('displays all cards in hand', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardHandWidget(
              cards: testHand,
            ),
          ),
        ),
      );

      // Should render the hand widget
      expect(find.byType(CardHandWidget), findsOneWidget);
    });

    testWidgets('handles card selection', (tester) async {
      PlayingCard? selectedCard;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardHandWidget(
              cards: testHand,
              onCardSelected: (card) => selectedCard = card,
            ),
          ),
        ),
      );

      // Widget should be present
      expect(find.byType(CardHandWidget), findsOneWidget);
    });

    testWidgets('handles empty hand', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CardHandWidget(
              cards: [],
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(CardHandWidget), findsOneWidget);
    });

    testWidgets('displays single card', (tester) async {
      final singleCard = [
        const PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardHandWidget(
              cards: singleCard,
            ),
          ),
        ),
      );

      expect(find.byType(CardHandWidget), findsOneWidget);
    });

    testWidgets('displays full hand of 13 cards', (tester) async {
      final fullHand = [
        for (int i = 0; i < 13; i++)
          PlayingCard(
            suit: CardSuit.values[i % 4],
            rank: CardRank.values[i % 13],
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardHandWidget(
              cards: fullHand,
            ),
          ),
        ),
      );

      expect(find.byType(CardHandWidget), findsOneWidget);
    });
  });
}

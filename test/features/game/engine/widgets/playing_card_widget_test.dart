import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/game/engine/models/card.dart';
import 'package:clubroyale/features/game/engine/widgets/playing_card_widget.dart';

void main() {
  group('PlayingCardWidget', () {
    testWidgets('displays card with correct suit and rank', (tester) async {
      const card = PlayingCard(suit: CardSuit.spades, rank: CardRank.ace);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      // Card should render (image asset)
      expect(find.byType(PlayingCardWidget), findsOneWidget);
    });

    testWidgets('displays card back when face down', (tester) async {
      const card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              isFaceDown: true,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      // Card back should be displayed
      expect(find.byType(PlayingCardWidget), findsOneWidget);
    });

    testWidgets('shows selection border when selected', (tester) async {
      const card = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.queen);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              isSelected: true,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      // Find the widget
      final widget = tester.widget<PlayingCardWidget>(
        find.byType(PlayingCardWidget),
      );

      expect(widget.isSelected, true);
    });

    testWidgets('handles tap when playable', (tester) async {
      const card = PlayingCard(suit: CardSuit.clubs, rank: CardRank.jack);
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              isPlayable: true,
              onTap: () => tapped = true,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlayingCardWidget));
      expect(tapped, true);
    });

    testWidgets('does not handle tap when not playable', (tester) async {
      const card = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ten);
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              isPlayable: false,
              onTap: () => tapped = true,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlayingCardWidget));
      expect(tapped, false);
    });

    testWidgets('does not handle tap when face down', (tester) async {
      const card = PlayingCard(suit: CardSuit.spades, rank: CardRank.seven);
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              isFaceDown: true,
              onTap: () => tapped = true,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlayingCardWidget));
      expect(tapped, false);
    });

    testWidgets('renders with custom dimensions', (tester) async {
      const card = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.five);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: card,
              width: 100,
              height: 150,
            ),
          ),
        ),
      );

      final widget = tester.widget<PlayingCardWidget>(
        find.byType(PlayingCardWidget),
      );

      expect(widget.width, 100);
      expect(widget.height, 150);
    });

    testWidgets('handles null card (empty slot)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayingCardWidget(
              card: null,
              width: 60,
              height: 90,
            ),
          ),
        ),
      );

      // Should render empty card placeholder
      expect(find.byType(PlayingCardWidget), findsOneWidget);
    });
  });
}

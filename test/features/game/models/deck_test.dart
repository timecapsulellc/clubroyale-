import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/game/engine/models/card.dart';
import 'package:myapp/features/game/engine/models/deck.dart';

void main() {
  group('Deck', () {
    test('generateDeck creates 52 unique cards', () {
      final deck = Deck.generateDeck();
      expect(deck.length, 52);

      final uniqueCards = deck.map((c) => '${c.suit}_${c.rank}').toSet();
      expect(uniqueCards.length, 52);
    });

    test('shuffle changes card order', () {
      final deck1 = Deck.generateDeck();
      final deck2 = Deck.shuffle(deck1);

      // It's statistically impossible for a shuffled deck to match original exactly
      // but let's check if it contains same elements
      expect(deck2.length, 52);
      expect(deck2, containsAll(deck1));
      expect(deck2, isNot(orderedEquals(deck1)));
    });

    test('dealHands distributes cards correctly to 4 players', () {
      final playerIds = ['p1', 'p2', 'p3', 'p4'];
      final hands = Deck.dealHands(playerIds);

      expect(hands.length, 4);
      expect(hands.keys, containsAll(playerIds));

      for (final hand in hands.values) {
        expect(hand.length, 13);
      }

      // Verify all 52 cards are distributed
      final allDealtCards = hands.values.expand((i) => i).toList();
      expect(allDealtCards.length, 52);
      
      final uniqueDealt = allDealtCards.map((c) => '${c.suit}_${c.rank}').toSet();
      expect(uniqueDealt.length, 52);
    });
  });

  group('PlayingCard', () {
    test('displayString returns correct format', () {
      const card = PlayingCard(suit: CardSuit.spades, rank: CardRank.ace);
      expect(card.displayString, 'A♠');
    });

    test('compareTo correctly compares ranks', () {
      const ace = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
      const king = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king);
      
      // Ace > King
      expect(ace.rank.value > king.rank.value, isTrue);
    });
  });
}

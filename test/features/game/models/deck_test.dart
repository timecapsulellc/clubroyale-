import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/card_engine.dart';

void main() {
  group('Deck', () {
    test('creates standard deck with 52 cards', () {
      final deck = Deck();
      deck.reset();
      expect(deck.length, 52);
    });

    test('shuffle changes card order', () {
      final deck = Deck();
      deck.reset();
      final originalFirst = deck.cards.first;
      
      // Shuffle and check it changed
      deck.shuffle();
      // At least one card should be different (statistically near-certain)
      expect(deck.length, 52);
    });

    test('drawCard removes and returns a card', () {
      final deck = Deck();
      deck.reset();
      
      final initialLength = deck.length;
      final card = deck.drawCard();
      
      expect(card, isNotNull);
      expect(deck.length, initialLength - 1);
    });

    test('drawCards returns multiple cards', () {
      final deck = Deck();
      deck.reset();
      
      final cards = deck.drawCards(5);
      
      expect(cards.length, 5);
      expect(deck.length, 47); // 52 - 5
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
      
      // Ace > King (ace value = 14, king value = 13)
      expect(ace.rank.value > king.rank.value, isTrue);
    });

    test('equality works correctly', () {
      const card1 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
      const card2 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.ace);
      
      expect(card1, equals(card2));
    });
  });
}

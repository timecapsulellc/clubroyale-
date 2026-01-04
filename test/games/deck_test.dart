import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Tests for Deck configuration with Marriage game
void main() {
  group('Deck Configuration Tests', () {
    test('Test 1.1: Triple Deck (3 decks) - Default', () {
      // Arrange & Act
      final deck = Deck.forMarriage();

      // Assert
      expect(deck.config, DeckConfig.triple);
      expect(deck.cards.length, 162); // 52 * 3 + 6 jokers
      expect(deck.config.deckCount, 3);
      expect(deck.config.includeJokers, true);

      // Verify jokers are included
      final jokers = deck.cards.where((c) => c.isJoker).toList();
      expect(jokers.length, 6);
    });

    test('Test 1.2: Triple Deck (3 decks) - Explicit', () {
      // Arrange & Act
      final deck = Deck.forMarriage(deckCount: 3);

      // Assert
      expect(deck.config, DeckConfig.triple);
      expect(deck.cards.length, 162);
      expect(deck.config.deckCount, 3);
    });

    test('Test 1.3: Quadruple Deck (4 decks)', () {
      // Arrange & Act
      final deck = Deck.forMarriage(deckCount: 4);

      // Assert
      expect(deck.config, DeckConfig.quadruple);
      expect(deck.cards.length, 216); // 52 * 4 + 8 jokers
      expect(deck.config.deckCount, 4);
      expect(deck.config.includeJokers, true);

      // Verify jokers are included
      final jokers = deck.cards.where((c) => c.isJoker).toList();
      expect(jokers.length, 8);
    });

    test('Test 1.4: Card Distribution - All Ranks Present', () {
      // Arrange & Act
      final deck = Deck.forMarriage(deckCount: 3);

      // Assert - each rank should appear 12 times (3 decks * 4 suits)
      // Exclude jokers from this count
      final nonJokerCards = deck.cards.where((c) => !c.isJoker).toList();
      for (final rank in Rank.values) {
        final cardsOfRank = nonJokerCards.where((c) => c.rank == rank).toList();
        expect(
          cardsOfRank.length,
          12,
          reason: 'Rank ${rank.symbol} should appear 12 times',
        );
      }
    });

    test('Test 1.5: Card Distribution - All Suits Present', () {
      // Arrange & Act
      final deck = Deck.forMarriage(deckCount: 4);

      // Assert - each suit should appear 52 times (13 ranks * 4 decks)
      // Exclude jokers from this count
      final nonJokerCards = deck.cards.where((c) => !c.isJoker).toList();
      for (final suit in Suit.values) {
        final cardsOfSuit = nonJokerCards.where((c) => c.suit == suit).toList();
        expect(
          cardsOfSuit.length,
          52,
          reason: 'Suit ${suit.symbol} should appear 52 times',
        );
      }
    });

    test('Test 1.6: Deck Shuffle - Changes Card Order', () {
      // Arrange
      final deck = Deck.forMarriage();
      final firstCard = deck.cards.first;

      // Act
      deck.shuffle();

      // Assert - probability of first card being same after shuffle is very low
      // This test might occasionally fail due to randomness, but extremely unlikely
      final newFirstCard = deck.cards.first;
      expect(firstCard.id == newFirstCard.id, isFalse);
    });

    test('Test 1.7: Deck Reset - Restores All Cards', () {
      // Arrange
      final deck = Deck.forMarriage();
      final originalCount = deck.cards.length;

      // Act - draw some cards
      deck.drawCard();
      deck.drawCard();
      deck.drawCard();
      expect(deck.cards.length, lessThan(originalCount));

      // Reset
      deck.reset();

      // Assert
      expect(deck.cards.length, originalCount);
    });

    test('Test 1.8: Card Dealing - Correct Distribution', () {
      // Arrange
      final deck = Deck.forMarriage(deckCount: 4);
      deck.shuffle();

      // Act - deal to 8 players, 21 cards each
      final hands = deck.deal(8, 21);

      // Assert
      expect(hands.length, 8);
      for (final hand in hands) {
        expect(hand.length, 21);
      }

      // Verify no duplicate cards across hands
      final allDealtCards = hands.expand((h) => h).toList();
      final uniqueCards = allDealtCards.map((c) => c.id).toSet();
      expect(
        uniqueCards.length,
        allDealtCards.length,
        reason: 'No duplicate cards should be dealt',
      );
    });
  });

  group('Single Deck vs Double Deck Tests', () {
    test('Single Deck - 52 Cards, No Jokers', () {
      final deck = Deck.standard();
      expect(deck.cards.length, 52);
      expect(deck.cards.where((c) => c.isJoker).toList().length, 0);
    });

    test('Double Deck - 104 Cards, No Jokers', () {
      final deck = Deck.double();
      expect(deck.cards.length, 104);
      expect(deck.cards.where((c) => c.isJoker).toList().length, 0);
    });
  });
}

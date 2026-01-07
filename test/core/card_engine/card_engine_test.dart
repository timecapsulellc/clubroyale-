import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/card_engine.dart';

void main() {
  group('Pile', () {
    test('starts empty', () {
      final pile = Pile();
      expect(pile.isEmpty, true);
      expect(pile.length, 0);
    });

    test('addCard increases length', () {
      final pile = Pile();
      pile.addCard(PlayingCard(rank: CardRank.ace, suit: CardSuit.spades));
      expect(pile.length, 1);
      expect(pile.isEmpty, false);
    });

    test('drawCard removes and returns top card', () {
      final pile = Pile();
      final card1 = PlayingCard(rank: CardRank.ace, suit: CardSuit.spades);
      final card2 = PlayingCard(rank: CardRank.king, suit: CardSuit.hearts);
      pile.addCard(card1);
      pile.addCard(card2);

      final drawn = pile.drawCard();
      expect(drawn?.rank, CardRank.king);
      expect(pile.length, 1);
    });

    test('shuffle changes card order', () {
      final pile = Pile();
      for (int i = 2; i <= 10; i++) {
        pile.addCard(PlayingCard(
          rank: CardRank.values[i - 2],
          suit: CardSuit.spades,
        ));
      }

      final originalOrder = pile.cards.map((c) => c.rank.value).toList();
      pile.shuffle();
      final shuffledOrder = pile.cards.map((c) => c.rank.value).toList();

      // Very unlikely to be same order (1 in 9!)
      expect(originalOrder, isNot(equals(shuffledOrder)));
    });

    test('clear empties pile', () {
      final pile = Pile();
      pile.addCard(PlayingCard(rank: CardRank.ace, suit: CardSuit.spades));
      pile.addCard(PlayingCard(rank: CardRank.king, suit: CardSuit.hearts));
      pile.clear();
      expect(pile.isEmpty, true);
    });
  });

  group('Deck', () {
    test('standard deck has 52 cards', () {
      final deck = Deck.standard();
      expect(deck.length, 52);
    });

    test('double deck has 104 cards', () {
      final deck = Deck.double();
      expect(deck.length, 104);
    });

    test('marriage deck (3 decks) has 162 cards with jokers', () {
      final deck = Deck.forMarriage(deckCount: 3);
      // 3 decks * 52 = 156 + 6 jokers = 162
      expect(deck.length, 162);
    });

    test('marriage deck (4 decks) has 216 cards with jokers', () {
      final deck = Deck.forMarriage(deckCount: 4);
      // 4 decks * 52 = 208 + 8 jokers = 216
      expect(deck.length, 216);
    });

    test('deal distributes cards to players', () {
      final deck = Deck.standard();
      final hands = deck.deal(4, 13); // 4 players, 13 cards each

      expect(hands.length, 4);
      for (final hand in hands) {
        expect(hand.length, 13);
      }
      expect(deck.length, 0); // All cards dealt
    });

    test('reset restores and shuffles deck', () {
      final deck = Deck.standard();
      deck.deal(4, 13);
      expect(deck.length, 0);

      deck.reset();
      expect(deck.length, 52);
    });
  });

  group('Hand', () {
    test('sortBySuit groups cards by suit', () {
      final hand = Hand();
      hand.addCard(PlayingCard(rank: CardRank.ace, suit: CardSuit.hearts));
      hand.addCard(PlayingCard(rank: CardRank.two, suit: CardSuit.spades));
      hand.addCard(PlayingCard(rank: CardRank.three, suit: CardSuit.hearts));

      hand.sortBySuit();

      expect(hand.cards[0].suit, CardSuit.hearts);
      expect(hand.cards[1].suit, CardSuit.hearts);
      expect(hand.cards[2].suit, CardSuit.spades);
    });

    test('sortByRank orders cards by value', () {
      final hand = Hand();
      hand.addCard(PlayingCard(rank: CardRank.king, suit: CardSuit.hearts));
      hand.addCard(PlayingCard(rank: CardRank.two, suit: CardSuit.spades));
      hand.addCard(PlayingCard(rank: CardRank.ace, suit: CardSuit.hearts));

      hand.sortByRank();

      expect(hand.cards[0].rank, CardRank.two);
      expect(hand.cards[1].rank, CardRank.king);
      expect(hand.cards[2].rank, CardRank.ace);
    });
  });

  group('PlayerStrategy', () {
    test('RandomStrategy has difficulty 1', () {
      final strategy = RandomStrategy();
      expect(strategy.difficulty, 1);
      expect(strategy.name, 'Random Bot');
    });

    test('ConservativeStrategy has difficulty 3', () {
      final strategy = ConservativeStrategy();
      expect(strategy.difficulty, 3);
      expect(strategy.name, 'Conservative Bot');
    });

    test('AggressiveStrategy has difficulty 4', () {
      final strategy = AggressiveStrategy();
      expect(strategy.difficulty, 4);
      expect(strategy.name, 'Aggressive Bot');
    });
    
    test('ExpertStrategy has difficulty 5', () {
      final strategy = ExpertStrategy();
      expect(strategy.difficulty, 5);
      expect(strategy.name, 'Expert Bot');
    });

    test('selectCardToDiscard returns card from hand', () {
      final strategy = ConservativeStrategy();
      final hand = Hand();
      hand.addCard(PlayingCard(rank: CardRank.ace, suit: CardSuit.spades));
      hand.addCard(PlayingCard(rank: CardRank.king, suit: CardSuit.hearts));

      final discard = strategy.selectCardToDiscard(hand, []);
      expect(hand.cards.contains(discard), true);
    });
  });
}

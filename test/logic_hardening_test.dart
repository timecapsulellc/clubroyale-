
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/core/models/playing_card.dart'; // Direct import
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/marriage/marriage_scorer.dart';

void main() {
  group('Gameplay Logic Hardening', () {
    test('RunMeld supports Q-K-A (High Ace)', () {
      final q = PlayingCard(rank: CardRank.queen, suit: CardSuit.spades, deckIndex: 0);
      final k = PlayingCard(rank: CardRank.king, suit: CardSuit.spades, deckIndex: 0);
      final a = PlayingCard(rank: CardRank.ace, suit: CardSuit.spades, deckIndex: 0);
      
      final meld = RunMeld([q, k, a]);
      expect(meld.isValid, isTrue, reason: 'Q-K-A should be a valid sequence');
    });

    test('RunMeld supports A-2-3 (Low Ace)', () {
      final a = PlayingCard(rank: CardRank.ace, suit: CardSuit.hearts, deckIndex: 0);
      final two = PlayingCard(rank: CardRank.two, suit: CardSuit.hearts, deckIndex: 0);
      final three = PlayingCard(rank: CardRank.three, suit: CardSuit.hearts, deckIndex: 0);
      
      final meld = RunMeld([a, two, three]);
      expect(meld.isValid, isTrue, reason: 'A-2-3 should be a valid sequence');
    });

    test('RunMeld rejects K-A-2 (Corner wrapping)', () {
      final k = PlayingCard(rank: CardRank.king, suit: CardSuit.diamonds, deckIndex: 0);
      final a = PlayingCard(rank: CardRank.ace, suit: CardSuit.diamonds, deckIndex: 0);
      final two = PlayingCard(rank: CardRank.two, suit: CardSuit.diamonds, deckIndex: 0);
      
      final meld = RunMeld([k, a, two]);
      expect(meld.isValid, isFalse, reason: 'K-A-2 should NOT be valid');
    });

    test('8 Dublee Win Condition', () {
      // Create 8 pairs (dublees) -> 16 cards
      // Marriage hand is usually 21 cards. Use config.cardsPerPlayer?
      // Standard rule: If you have 7+ Dublees, you can visit. 
      // If you have All Dublees (e.g. 10 pairs + 1 single?), that's a win?
      // "8 Dublee Win" usually means winning with 8 dublees in hand.
      // Let's assume a hand of 16 cards for simplicity or partial check.
      
      final config = MarriageGameConfig(eightDubleeWinEnabled: true);
      final scorer = MarriageScorer(config: config);
      
      final hand = <PlayingCard>[];
      final melds = <Meld>[];
      
      // Add 8 dublees
      for (int i=0; i<8; i++) {
        final rank = CardRank.values[i % 13];
        final suit = CardSuit.clubs;
        final c1 = PlayingCard(rank: rank, suit: suit, deckIndex: 0);
        final c2 = PlayingCard(rank: rank, suit: suit, deckIndex: 1); // diff deck
        hand.add(c1);
        hand.add(c2);
        melds.add(DubleeMeld([c1, c2]));
      }
      
      // Validate declaration
      // Pass an empty hand (simulating all melded)
      final (isValid, reason) = scorer.validateDeclaration([], melds);
      
      expect(isValid, isTrue, reason: 'Should be able to declare with 8 Dublees if allowed');
    });
  });
}

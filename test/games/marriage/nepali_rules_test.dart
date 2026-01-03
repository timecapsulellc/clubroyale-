
import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_scorer.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

void main() {
  group('Nepali Marriage Rules Verification', () {
    // Setup standard cards for testing
    // Tiplu = 8 of Hearts
    final tiplu = PlayingCard(suit: CardSuit.hearts, rank: CardRank.eight, deckIndex: 0);
    
    // Wildcards based on 8H:
    final poplu = PlayingCard(suit: CardSuit.hearts, rank: CardRank.nine, deckIndex: 0); // 9H
    final jhiplu = PlayingCard(suit: CardSuit.hearts, rank: CardRank.seven, deckIndex: 0); // 7H
    final alter = PlayingCard(suit: CardSuit.diamonds, rank: CardRank.eight, deckIndex: 0); // 8D
    final normal = PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, deckIndex: 0);

    test('WildcardHelper recognizes all Nepali wildcards', () {
      final helper = WildcardHelper(tiplu);
      
      expect(helper.isWildcard(tiplu), isTrue, reason: 'Tiplu should be wild');
      expect(helper.isWildcard(poplu), isTrue, reason: 'Poplu (Rank+1) should be wild');
      expect(helper.isWildcard(jhiplu), isTrue, reason: 'Jhiplu (Rank-1) should be wild');
      expect(helper.isWildcard(alter), isTrue, reason: 'Alter (Same Rank/Color) should be wild');
      expect(helper.isWildcard(normal), isFalse, reason: 'Normal card should not be wild');
    });

    test('DubleeMeld detects pairs from different decks', () {
      final c1 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0);
      final c2 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 1);
      final c3 = PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0); // Same deck as c1

      final validPair = DubleeMeld([c1, c2]);
      final invalidPair = DubleeMeld([c1, c3]);

      expect(validPair.isValid, isTrue);
      expect(invalidPair.isValid, isFalse, reason: 'Same deck cards cannot form Dublee');
    });
    
    test('MeldDetector finds Dublees', () {
      final hand = [
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0),
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 1),
        PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, deckIndex: 0),
      ];
      
      final dublees = MeldDetector.findDublees(hand);
      expect(dublees.length, 1);
      expect(dublees.first.isValid, isTrue);
    });

    test('Scorer awards 5 points for Tunnel', () {
      final scorer = MarriageScorer(tiplu: tiplu);
      final hand = <PlayingCard>[normal]; // Dummy hand
      
      // Create a valid Tunnel
      final tunnelCards = [
        PlayingCard(suit: CardSuit.clubs, rank: CardRank.five, deckIndex: 0),
        PlayingCard(suit: CardSuit.clubs, rank: CardRank.five, deckIndex: 1),
        PlayingCard(suit: CardSuit.clubs, rank: CardRank.five, deckIndex: 2),
      ];
      final tunnel = TunnelMeld(tunnelCards);
      
      final hands = {'p1': hand};
      final melds = {'p1': [tunnel]}; // p1 has a tunnel
      
      final scores = scorer.calculateFinalSettlement(
        hands: hands, 
        melds: melds, 
        winnerId: null
      );
      
      // In net settlement with self (and no other players), net score is 0.
      // But we can check internal calculation if we expose it, or check net against a dummy opponent.
      
      // Let's add an opponent p2 with nothing.
      final hands2 = {'p1': hand, 'p2': hand};
      final melds2 = {'p1': [tunnel], 'p2': <Meld>[]};
      
      final scores2 = scorer.calculateFinalSettlement(
        hands: hands2,
        melds: melds2,
        winnerId: null,
      );
      
      // P1 has Tunnel (5 pts). P2 has 0.
      // P1 vs P2: +5.
      // P1 Total = 5. P2 Total = -5.
      
      expect(scores2['p1'], 5, reason: 'P1 should get 5 points from P2 for Tunnel');
    });

    test('Kidnap logic enforces 3 pure sequences', () {
      final config = MarriageGameConfig(
        sequencesRequiredToVisit: 3, 
        enableKidnap: true,
        enableMurder: false,
      );
      final scorer = MarriageScorer(tiplu: tiplu, config: config);
      
      // Winner (P1)
      final p1Maal = [tiplu]; // 3 pts
      
      // Loser (P2) - Unvisited (only 1 sequence)
      // Needs 3 sequences to avoid kidnap.
      final p2Maal = [tiplu]; // 3 pts
      
      final seqCards = [
        PlayingCard(suit: CardSuit.spades, rank: CardRank.two, deckIndex: 0),
        PlayingCard(suit: CardSuit.spades, rank: CardRank.three, deckIndex: 0),
        PlayingCard(suit: CardSuit.spades, rank: CardRank.four, deckIndex: 0),
      ];
      final pureSeq = RunMeld(seqCards);
      
      final hands = {'p1': p1Maal, 'p2': p2Maal};
      final melds = {
        'p1': <Meld>[pureSeq, pureSeq, pureSeq], // Winner visited (irrelevant for kidnap check on victim?)
        'p2': <Meld>[pureSeq], // Only 1 sequence -> Should be Kidnapped!
      };
      
      // Expected:
      // P2 is kidnapped. P2 Maal (3) goes to P1.
      // P1 Effective Maal = 3 (own) + 3 (stolen) = 6.
      // P2 Effective Maal = 0.
      // Net Score:
      // P1 vs P2: 6 - 0 = +6.
      // Game Points: P2 pays game points (say 0 for simplicity if hand empty/ignored, but here hand has tiplu).
      // Let's ignore game points by setting winnerId to null? 
      // Kidnap logic only runs if winnerId != null.
      
      final scores = scorer.calculateFinalSettlement(
        hands: hands,
        melds: melds,
        winnerId: 'p1',
      );
      
      // Game Points: P2 has deadwood? Tiplu is 0 deadwood. Hand size 1.
      // Hand contains Tiplu. isWild(Tiplu) -> 0 points.
      // So Game Points = 0.
      // Only Maal exchange happens.
      // P1 gets +6 Maal diff + 0 Game = 6.
      // P2 gets -6 Maal diff - 0 Game = -6.
      
      expect(scores['p1'], 6, reason: 'P1 should kidnap P2 Maal');
      expect(scores['p2'], -6);
    });
  });
}

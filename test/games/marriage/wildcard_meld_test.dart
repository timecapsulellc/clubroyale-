import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/models/playing_card.dart';

void main() {
  group('Wildcard Meld Tests', () {
    // Create test cards
    final sevenHearts = PlayingCard(rank: CardRank.seven, suit: CardSuit.hearts);
    final eightHearts = PlayingCard(rank: CardRank.eight, suit: CardSuit.hearts);
    final nineHearts = PlayingCard(rank: CardRank.nine, suit: CardSuit.hearts);
    final tenHearts = PlayingCard(rank: CardRank.ten, suit: CardSuit.hearts);
    final joker = PlayingCard.joker();
    
    // Tiplu for this test: 7 of Hearts
    final tiplu = sevenHearts;
    
    test('Pure RunMeld is valid', () {
      final cards = [sevenHearts, eightHearts, nineHearts];
      final meld = RunMeld(cards);
      expect(meld.isValid, true);
      expect(meld.type, MeldType.run);
    });
    
    test('ImpureRunMeld with joker is valid', () {
      // 7♥, Joker, 9♥ - Joker substitutes for 8♥
      final cards = [sevenHearts, joker, nineHearts];
      final meld = ImpureRunMeld(cards, tiplu: tiplu);
      expect(meld.wildcardCount, greaterThan(0));
      expect(meld.isValid, true);
      expect(meld.type, MeldType.impureRun);
    });
    
    test('Pure SetMeld is valid', () {
      final sevenDiamonds = PlayingCard(rank: CardRank.seven, suit: CardSuit.diamonds);
      final sevenClubs = PlayingCard(rank: CardRank.seven, suit: CardSuit.clubs);
      final cards = [sevenHearts, sevenDiamonds, sevenClubs];
      final meld = SetMeld(cards);
      expect(meld.isValid, true);
      expect(meld.type, MeldType.set);
    });
    
    test('ImpureSetMeld with joker is valid', () {
      // 7♥, 7♦, Joker - Joker substitutes for 7♣
      final sevenDiamonds = PlayingCard(rank: CardRank.seven, suit: CardSuit.diamonds);
      final cards = [sevenHearts, sevenDiamonds, joker];
      final meld = ImpureSetMeld(cards, tiplu: tiplu);
      expect(meld.wildcardCount, greaterThan(0));
      expect(meld.isValid, true);
      expect(meld.type, MeldType.impureSet);
    });
    
    test('WildcardHelper identifies tiplu as wild', () {
      final helper = WildcardHelper(tiplu);
      expect(helper.isWildcard(tiplu), true);
      expect(helper.isWildcard(joker), true);
      expect(helper.isWildcard(eightHearts), false);
    });
    
    test('MeldDetector finds impure runs', () {
      final hand = [sevenHearts, joker, nineHearts, tenHearts];
      final melds = MeldDetector.findImpureRuns(hand, tiplu);
      expect(melds.isNotEmpty, true);
      expect(melds.any((m) => m.type == MeldType.impureRun), true);
    });
    
    test('MeldDetector findAllMelds includes impure melds', () {
      final hand = [sevenHearts, joker, nineHearts, tenHearts];
      final melds = MeldDetector.findAllMelds(hand, tiplu: tiplu);
      expect(melds.any((m) => m.type == MeldType.impureRun), true);
    });
  });
}

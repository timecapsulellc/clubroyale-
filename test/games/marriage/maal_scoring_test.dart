import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/core/card_engine/pile.dart'; // Ensure PlayingCard/Card is available
// Assuming Card/PlayingCard class structure based on existing files

void main() {
  group('Marriage Maal Calculator Tests', () {
    late MarriageMaalCalculator calculator;
    // We need to define Tiplu for the calculator
    // Tiplu: 8 of Spades
    final tiplu = Card(suit: Suit.spades, rank: Rank.eight); 
    
    setUp(() {
      calculator = MarriageMaalCalculator(
        tiplu: tiplu,
        config: const MarriageGameConfig(), // Default config
      );
    });

    test('Identifies Tiplu (Exact Match)', () {
      final card = Card(suit: Suit.spades, rank: Rank.eight);
      expect(calculator.getMaalType(card), MaalType.tiplu);
      expect(calculator.getMaalValue(MaalType.tiplu), 3); // Default value
    });

    test('Identifies Poplu (Rank + 1, Same Suit)', () {
      // Tiplu is 8 Spades -> Poplu should be 9 Spades
      final card = Card(suit: Suit.spades, rank: Rank.nine);
      expect(calculator.getMaalType(card), MaalType.poplu);
      expect(calculator.getMaalValue(MaalType.poplu), 2);
    });

    test('Identifies Jhiplu (Rank - 1, Same Suit)', () {
      // Tiplu is 8 Spades -> Jhiplu should be 7 Spades
      final card = Card(suit: Suit.spades, rank: Rank.seven);
      expect(calculator.getMaalType(card), MaalType.jhiplu);
      expect(calculator.getMaalValue(MaalType.jhiplu), 2);
    });

    test('Identifies Alter (Same Rank, Same Color, Diff Suit)', () {
      // Tiplu: 8 Spades (Black)
      // Alter: 8 Clubs (Black)
      final card = Card(suit: Suit.clubs, rank: Rank.eight);
      expect(calculator.getMaalType(card), MaalType.alter);
      expect(calculator.getMaalValue(MaalType.alter), 5);
    });

    test('Identifies Man (Joker)', () {
      final card = Card.joker();
      expect(calculator.getMaalType(card), MaalType.man);
      expect(calculator.getMaalValue(MaalType.man), 2);
    });

    test('Does NOT identify random card as Maal', () {
      final card = Card(suit: Suit.hearts, rank: Rank.two); // Totally unrelated
      expect(calculator.getMaalType(card), MaalType.none);
      expect(calculator.getMaalValue(MaalType.none), 0);
    });
    
    test('Calculates total points correctly', () {
      final hand = [
        Card(suit: Suit.spades, rank: Rank.eight), // Tiplu (3)
        Card(suit: Suit.spades, rank: Rank.nine),  // Poplu (2)
        Card(suit: Suit.clubs, rank: Rank.eight),  // Alter (5)
        Card(suit: Suit.hearts, rank: Rank.two),   // None (0)
      ];
      
      expect(calculator.calculateMaalPoints(hand), 3 + 2 + 5 + 0);
    });
    
    test('Handles Ace Wrapping for Poplu/Jhiplu', () {
         // Case: Tiplu is Ace (1) -> Jhiplu should be King (13)
         final tipluAce = Card(suit: Suit.spades, rank: Rank.ace);
         final calcAce = MarriageMaalCalculator(tiplu: tipluAce);
         
         final jhipluKing = Card(suit: Suit.spades, rank: Rank.king);
         expect(calcAce.getMaalType(jhipluKing), MaalType.jhiplu, reason: 'Ace Tiplu should have King Jhiplu');
         
         // Case: Tiplu is King (13) -> Poplu should be Ace (1)
         final tipluKing = Card(suit: Suit.spades, rank: Rank.king);
         final calcKing = MarriageMaalCalculator(tiplu: tipluKing);
         
         final popluAce = Card(suit: Suit.spades, rank: Rank.ace);
         expect(calcKing.getMaalType(popluAce), MaalType.poplu, reason: 'King Tiplu should have Ace Poplu');
    });
  });
}

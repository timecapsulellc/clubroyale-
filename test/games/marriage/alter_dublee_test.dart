/// Alter and Dublee Verification Tests
///
/// Tests for verifying Alter (same rank+color, different suit) and 
/// Dublee (pairs for 7-dublee visit and 8-dublee win) functionality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/games/marriage/marriage_visit_validator.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

void main() {
  group('Alter Detection Tests', () {
    // Tiplu = 7 of Hearts (red)
    final tiplu = PlayingCard(
      suit: CardSuit.hearts,
      rank: CardRank.seven,
      deckIndex: 0,
    );

    test('Alter card is correctly identified (same rank, same color, different suit)', () {
      final helper = WildcardHelper(tiplu);

      // 7 of Diamonds is Alter (same color as Hearts = red)
      final alterCard = PlayingCard(
        suit: CardSuit.diamonds,
        rank: CardRank.seven,
        deckIndex: 0,
      );
      expect(helper.isWildcard(alterCard), isTrue, 
        reason: 'Alter (7D for 7H tiplu) should be wild');

      // 7 of Spades is NOT Alter (different color = black)
      final notAlter = PlayingCard(
        suit: CardSuit.spades,
        rank: CardRank.seven,
        deckIndex: 0,
      );
      expect(helper.isWildcard(notAlter), isFalse, 
        reason: '7S should not be wild for 7H tiplu (different color)');

      // 7 of Clubs is also NOT Alter (different color = black)
      final notAlter2 = PlayingCard(
        suit: CardSuit.clubs,
        rank: CardRank.seven,
        deckIndex: 0,
      );
      expect(helper.isWildcard(notAlter2), isFalse, 
        reason: '7C should not be wild for 7H tiplu (different color)');
    });

    test('Alter is wild along with Tiplu, Poplu, Jhiplu', () {
      final helper = WildcardHelper(tiplu);

      // Tiplu = 7H
      expect(helper.isWildcard(tiplu), isTrue, reason: 'Tiplu should be wild');

      // Poplu = 8H (rank + 1, same suit)
      final poplu = PlayingCard(
        suit: CardSuit.hearts,
        rank: CardRank.eight,
        deckIndex: 0,
      );
      expect(helper.isWildcard(poplu), isTrue, reason: 'Poplu should be wild');

      // Jhiplu = 6H (rank - 1, same suit)
      final jhiplu = PlayingCard(
        suit: CardSuit.hearts,
        rank: CardRank.six,
        deckIndex: 0,
      );
      expect(helper.isWildcard(jhiplu), isTrue, reason: 'Jhiplu should be wild');

      // Alter = 7D (same rank, same color, different suit)
      final alter = PlayingCard(
        suit: CardSuit.diamonds,
        rank: CardRank.seven,
        deckIndex: 0,
      );
      expect(helper.isWildcard(alter), isTrue, reason: 'Alter should be wild');
    });
  });

  group('Dublee Detection Tests', () {
    test('MeldDetector correctly finds Dublees (pairs)', () {
      final hand = [
        // Pair 1: K♥ from deck 0 and K♥ from deck 1
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0),
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 1),
        // Non-pair card
        PlayingCard(suit: CardSuit.spades, rank: CardRank.ace, deckIndex: 0),
      ];

      final dublees = MeldDetector.findDublees(hand);
      expect(dublees.length, 1);
      expect(dublees.first.isValid, isTrue);
    });

    test('Dublee requires different deck indices', () {
      final hand = [
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0),
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0), // Same deck!
      ];

      final dublees = MeldDetector.findDublees(hand);
      // Should find no valid dublees as both are from same deck
      final validDublees = dublees.where((d) => d.isValid).toList();
      expect(validDublees, isEmpty);
    });

    test('Multiple Dublees are detected correctly', () {
      final hand = [
        // Pair 1: K♥
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 0),
        PlayingCard(suit: CardSuit.hearts, rank: CardRank.king, deckIndex: 1),
        // Pair 2: Q♠
        PlayingCard(suit: CardSuit.spades, rank: CardRank.queen, deckIndex: 0),
        PlayingCard(suit: CardSuit.spades, rank: CardRank.queen, deckIndex: 1),
        // Pair 3: A♦
        PlayingCard(suit: CardSuit.diamonds, rank: CardRank.ace, deckIndex: 0),
        PlayingCard(suit: CardSuit.diamonds, rank: CardRank.ace, deckIndex: 1),
      ];

      final dublees = MeldDetector.findDublees(hand);
      expect(dublees.length, greaterThanOrEqualTo(3));
    });
  });

  group('Dublee Visit Validation', () {
    final config = MarriageGameConfig.nepaliStandard;
    
    test('7-Dublee visit is allowed when config permits', () {
      expect(config.allowDubleeVisit, isTrue);
      expect(config.dubleeCountRequired, 7);
    });

    test('8-Dublee win condition is enabled', () {
      expect(config.eightDubleeWinEnabled, isTrue);
      expect(config.eightDubleeWinBonus, 5);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/marriage_bot.dart';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Marriage Bot Strategy Tests
void main() {
  group('MarriageBotStrategy Draw Decision', () {
    late MarriageBotStrategy easyBot;
    late MarriageBotStrategy mediumBot;
    late MarriageBotStrategy hardBot;
    
    setUp(() {
      easyBot = MarriageBotStrategy(difficulty: MarriageBotDifficulty.easy);
      mediumBot = MarriageBotStrategy(difficulty: MarriageBotDifficulty.medium);
      hardBot = MarriageBotStrategy(difficulty: MarriageBotDifficulty.hard);
    });

    test('Bot must draw from deck when discard is blocked', () {
      final hand = <Card>[
        Card(rank: Rank.five, suit: Suit.hearts),
        Card(rank: Rank.six, suit: Suit.hearts),
      ];
      
      final result = mediumBot.shouldDrawFromDeck(
        hand: hand,
        topDiscard: Card(rank: Rank.seven, suit: Suit.hearts),
        tiplu: null,
        hasVisited: false,
        canPickFromDiscard: false,
      );
      
      expect(result, isTrue);
    });

    test('Bot draws from deck when no discard available', () {
      final hand = <Card>[
        Card(rank: Rank.five, suit: Suit.hearts),
      ];
      
      final result = mediumBot.shouldDrawFromDeck(
        hand: hand,
        topDiscard: null,
        tiplu: null,
        hasVisited: false,
        canPickFromDiscard: true,
      );
      
      expect(result, isTrue);
    });
    
    test('Medium bot considers meld potential when drawing', () {
      final hand = <Card>[
        Card(rank: Rank.five, suit: Suit.hearts),
        Card(rank: Rank.six, suit: Suit.hearts),
      ];
      
      // Seven of hearts would help form a run
      final helpfulDiscard = Card(rank: Rank.seven, suit: Suit.hearts);
      
      final result = mediumBot.shouldDrawFromDeck(
        hand: hand,
        topDiscard: helpfulDiscard,
        tiplu: null,
        hasVisited: false,
        canPickFromDiscard: true,
      );
      
      // Medium bot should pick from discard when it helps a meld
      expect(result, isFalse);
    });
  });

  group('MarriageBotStrategy Discard Decision', () {
    test('Bot never discards wildcards when possible', () {
      final tiplu = Card(rank: Rank.king, suit: Suit.spades);
      // Create hand with a wildcard (same rank as tiplu = Jhiplu)
      final hand = <Card>[
        Card(rank: Rank.king, suit: Suit.hearts), // Jhiplu (wildcard)
        Card(rank: Rank.two, suit: Suit.diamonds),
        Card(rank: Rank.three, suit: Suit.clubs),
      ];
      
      final mediumBot = MarriageBotStrategy(difficulty: MarriageBotDifficulty.medium);
      final discard = mediumBot.chooseDiscard(
        hand: hand,
        tiplu: tiplu,
        lastDrawnCard: null,
      );
      
      // Should not discard the wildcard (King)
      expect(discard.rank, isNot(equals(Rank.king)));
    });

    test('Bot discards loose cards not in melds', () {
      final hand = <Card>[
        Card(rank: Rank.ace, suit: Suit.spades),
        Card(rank: Rank.two, suit: Suit.diamonds),
        Card(rank: Rank.three, suit: Suit.clubs),
      ];
      
      final mediumBot = MarriageBotStrategy(difficulty: MarriageBotDifficulty.medium);
      final discard = mediumBot.chooseDiscard(
        hand: hand,
        tiplu: null,
        lastDrawnCard: null,
      );
      
      // Should return a valid card from the hand
      expect(hand.contains(discard), isTrue);
    });
  });

  group('MarriageBotStrategy Visit Decision', () {
    test('Bot attempts visit when eligible', () {
      // Create cards that form 3 pure sequences
      final hand = <Card>[
        // Sequence 1: 2-3-4 of hearts
        Card(rank: Rank.two, suit: Suit.hearts),
        Card(rank: Rank.three, suit: Suit.hearts),
        Card(rank: Rank.four, suit: Suit.hearts),
        // Sequence 2: 5-6-7 of spades
        Card(rank: Rank.five, suit: Suit.spades),
        Card(rank: Rank.six, suit: Suit.spades),
        Card(rank: Rank.seven, suit: Suit.spades),
        // Sequence 3: 8-9-10 of diamonds
        Card(rank: Rank.eight, suit: Suit.diamonds),
        Card(rank: Rank.nine, suit: Suit.diamonds),
        Card(rank: Rank.ten, suit: Suit.diamonds),
      ];
      
      final mediumBot = MarriageBotStrategy(difficulty: MarriageBotDifficulty.medium);
      final shouldVisit = mediumBot.shouldAttemptVisit(
        hand: hand,
        tiplu: null,
        requiredSequences: 3,
      );
      
      // Medium bot should visit when eligible
      expect(shouldVisit, isTrue);
    });
  });

  group('MarriageBotStrategy Difficulty Differences', () {
    test('Different difficulties exist', () {
      expect(MarriageBotDifficulty.values.length, equals(3));
      expect(MarriageBotDifficulty.easy, isNotNull);
      expect(MarriageBotDifficulty.medium, isNotNull);
      expect(MarriageBotDifficulty.hard, isNotNull);
    });
  });
}

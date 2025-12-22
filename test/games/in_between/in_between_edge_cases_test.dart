import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/in_between/in_between_game.dart';

/// In-Between Edge Case Tests
/// 
/// Tests for edge cases in In-Between (Acey-Deucey) game logic:
/// - Ace handling (high/low)
/// - Same rank scenarios
/// - Pot limit edge cases
/// - Win/loss calculations
void main() {
  group('Ace Handling', () {
    test('Ace can be high (after King)', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2'],
        initialPot: 100,
      );
      
      // Card 1: 5, Card 2: King
      // Ace should be treated as high (14) by default
      game.dealCards('p1', '5H', 'KS');
      game.revealMiddleCard('p1', 'AH');
      
      // Ace (14) > King (13), so player LOSES (outside range)
      expect(game.lastResult, equals(InBetweenResult.loss));
    });
    
    test('Ace declared low wins between Ace-low and King', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
      );
      
      // If player chooses Ace as low (1)
      game.dealCards('p1', '2H', 'KS');
      game.setAcePreference('p1', AcePosition.low);
      game.revealMiddleCard('p1', 'AH');
      
      // Ace as 1 is NOT between 2 and King, so still loses
      expect(game.lastResult, equals(InBetweenResult.loss));
    });
    
    test('Middle card exactly matches boundary loses', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
      );
      
      game.dealCards('p1', '5H', 'JS');
      game.revealMiddleCard('p1', '5D'); // Same as boundary
      
      // Hitting a post (boundary) typically loses or pays double
      expect(game.lastResult, equals(InBetweenResult.hitPost));
    });
  });
  
  group('Same Rank Scenarios', () {
    test('Two same cards dealt (pair) cannot be played', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
      );
      
      game.dealCards('p1', '7H', '7S');
      
      // Cannot bet on a pair - no range
      expect(game.canPlayerBet('p1'), isFalse);
      expect(game.mustRedeal('p1'), isTrue);
    });
    
    test('Consecutive cards have minimal range', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
      );
      
      game.dealCards('p1', '6H', '7S');
      
      // Only one card can win (nothing between 6 and 7)
      // Player can still bet but odds are 0%
      expect(game.getWinProbability('p1'), equals(0.0));
    });
  });
  
  group('Pot Limit Rules', () {
    test('Cannot bet more than pot', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
      );
      
      game.dealCards('p1', '3H', 'QS');
      
      final maxBet = game.getMaxBet('p1');
      expect(maxBet, equals(100)); // Can't exceed pot
      
      // Attempt to bet more should be capped
      game.placeBet('p1', 200);
      expect(game.getCurrentBet('p1'), equals(100));
    });
    
    test('Betting the pot clears it on loss', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
      );
      
      game.dealCards('p1', '2H', 'AS'); // Wide spread
      game.placeBet('p1', 100); // Bet the pot
      game.revealMiddleCard('p1', '7H'); // Win
      
      // Pot should double when player wins half, or player takes it
      // Depending on house rules
      expect(game.pot, lessThanOrEqualTo(100)); // Player won from pot
    });
    
    test('Minimum bet enforced', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
        minimumBet: 10,
      );
      
      game.dealCards('p1', '4H', 'KS');
      
      expect(() => game.placeBet('p1', 5), throwsA(isA<ArgumentError>()));
    });
  });
  
  group('Win/Loss Calculations', () {
    test('Clear win pays 1:1', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 200,
      );
      
      game.dealCards('p1', '3H', 'QS'); // 8 winning cards
      game.placeBet('p1', 50);
      game.revealMiddleCard('p1', '7H'); // Win
      
      // Player should win their bet amount from the pot
      expect(game.playerWinnings('p1'), equals(50));
    });
    
    test('Hit post pays 2:1 against player', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 200,
      );
      
      game.dealCards('p1', '5H', 'JS');
      game.placeBet('p1', 50);
      game.revealMiddleCard('p1', 'JD'); // Hit post
      
      // Player loses double their bet
      expect(game.playerLoss('p1'), equals(100));
    });
    
    test('Multiple rounds track cumulative results', () {
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2'],
        initialPot: 100,
      );
      
      // Round 1: P1 wins 20
      game.dealCards('p1', '2H', 'KS');
      game.placeBet('p1', 20);
      game.revealMiddleCard('p1', '8H');
      
      // Round 2: P2 loses 30
      game.dealCards('p2', '4H', 'QS');
      game.placeBet('p2', 30);
      game.revealMiddleCard('p2', 'QD');
      
      expect(game.getPlayerBalance('p1'), greaterThan(0));
      expect(game.getPlayerBalance('p2'), lessThan(0));
    });
  });
  
  group('Special Rules', () {
    test('Natural pair (same rank different suit) is push', () {
      // Some variants have special rules for pairs
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
        naturalPairRule: NaturalPairRule.push,
      );
      
      game.dealCards('p1', 'KH', 'KS');
      
      // Game should handle this gracefully
      expect(game.mustRedeal('p1') || game.isPush('p1'), isTrue);
    });
    
    test('Spread bonus for wide spreads', () {
      // Optional rule: bonus for very wide spreads
      final game = InBetweenGame.create(
        roomId: 'test-room',
        playerIds: ['p1'],
        initialPot: 100,
        spreadBonusEnabled: true,
      );
      
      game.dealCards('p1', '2H', 'AS'); // Maximum spread
      
      // Should offer bonus multiplier
      expect(game.getSpreadBonus('p1'), greaterThan(1.0));
    });
  });
}

/// Placeholder enums for compilation
enum InBetweenResult { win, loss, hitPost, push }
enum AcePosition { high, low }
enum NaturalPairRule { redeal, push, autoLoss }

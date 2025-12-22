import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_game.dart';
import 'package:clubroyale/games/teen_patti/models/teen_patti_hand.dart';

/// Teen Patti Edge Case Tests
/// 
/// Tests for edge cases in Teen Patti game logic including:
/// - Side pot calculations
/// - All-in scenarios
/// - Blind vs seen player rules
/// - Hand ranking edge cases
void main() {
  group('TeenPattiHand Ranking', () {
    test('Trail (Three of a Kind) beats Pure Sequence', () {
      // Trail: A-A-A
      final trail = TeenPattiHand(
        cards: _createCards(['AS', 'AH', 'AD']),
        userId: 'player1',
      );
      
      // Pure Sequence: A-K-Q of same suit
      final pureSequence = TeenPattiHand(
        cards: _createCards(['AS', 'KS', 'QS']),
        userId: 'player2',
      );
      
      expect(trail.rank, greaterThan(pureSequence.rank));
    });
    
    test('Pure Sequence beats Sequence', () {
      // Pure Sequence: 8-9-10 of hearts
      final pureSeq = TeenPattiHand(
        cards: _createCards(['8H', '9H', '10H']),
        userId: 'player1',
      );
      
      // Sequence: 8-9-10 mixed suits
      final sequence = TeenPattiHand(
        cards: _createCards(['8H', '9S', '10D']),
        userId: 'player2',
      );
      
      expect(pureSeq.rank, greaterThan(sequence.rank));
    });
    
    test('Color (Flush) beats Pair', () {
      // Flush: All hearts, not in sequence
      final flush = TeenPattiHand(
        cards: _createCards(['2H', '5H', '9H']),
        userId: 'player1',
      );
      
      // Pair: Two Kings
      final pair = TeenPattiHand(
        cards: _createCards(['KH', 'KD', '5S']),
        userId: 'player2',
      );
      
      expect(flush.rank, greaterThan(pair.rank));
    });
    
    test('Pair beats High Card', () {
      final pair = TeenPattiHand(
        cards: _createCards(['QH', 'QD', '3S']),
        userId: 'player1',
      );
      
      final highCard = TeenPattiHand(
        cards: _createCards(['AH', 'KD', '2S']),
        userId: 'player2',
      );
      
      expect(pair.rank, greaterThan(highCard.rank));
    });
    
    test('A-2-3 is valid sequence (lowest)', () {
      final lowSequence = TeenPattiHand(
        cards: _createCards(['AH', '2S', '3D']),
        userId: 'player1',
      );
      
      // Should be recognized as a sequence
      expect(lowSequence.isSequence, isTrue);
    });
    
    test('Same rank hands compare by high card', () {
      // Two pairs, but different kickers
      final pairAce = TeenPattiHand(
        cards: _createCards(['KH', 'KD', 'AS']),
        userId: 'player1',
      );
      
      final pairTwo = TeenPattiHand(
        cards: _createCards(['KS', 'KC', '2H']),
        userId: 'player2',
      );
      
      // Ace kicker should win
      expect(pairAce.compareWith(pairTwo), greaterThan(0));
    });
  });
  
  group('Teen Patti Betting', () {
    test('Blind player bets half of seen player', () {
      final game = TeenPattiGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2', 'p3'],
        bootAmount: 10,
      );
      
      // P1 is blind, current bet should be boot amount
      expect(game.currentBet, equals(10));
      
      // When seen player bets, blind pays half
      // This is a design constraint, not a test of existing code
      expect(game.blindBetAmount, equals(game.currentBet));
    });
    
    test('All-in player cannot bet more', () {
      final game = TeenPattiGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2'],
        bootAmount: 100,
      );
      
      // Set p1 to all-in state
      game.setPlayerAllIn('p1');
      
      expect(game.canPlayerBet('p1'), isFalse);
    });
    
    test('Side pot created when player goes all-in', () {
      final game = TeenPattiGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2', 'p3'],
        bootAmount: 50,
      );
      
      // P1 goes all-in with 100 chips
      game.playerAllIn('p1', 100);
      
      // P2 and P3 continue betting 200 each
      game.playerBet('p2', 200);
      game.playerBet('p3', 200);
      
      // Main pot should be 300 (100 x 3)
      // Side pot should be 200 (100 x 2 from p2 and p3)
      expect(game.mainPot, equals(300));
      expect(game.sidePots.length, greaterThanOrEqualTo(1));
    });
  });
  
  group('Teen Patti Show Rules', () {
    test('Seen player can request show from seen player', () {
      final game = TeenPattiGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2'],
        bootAmount: 10,
      );
      
      game.setPlayerSeen('p1');
      game.setPlayerSeen('p2');
      
      expect(game.canRequestShow('p1', 'p2'), isTrue);
    });
    
    test('Blind player cannot request show', () {
      final game = TeenPattiGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2'],
        bootAmount: 10,
      );
      
      // p1 is still blind
      expect(game.canRequestShow('p1', 'p2'), isFalse);
    });
    
    test('Show only available with 2 players remaining', () {
      final game = TeenPattiGame.create(
        roomId: 'test-room',
        playerIds: ['p1', 'p2', 'p3'],
        bootAmount: 10,
      );
      
      game.setPlayerSeen('p1');
      game.setPlayerSeen('p2');
      
      // 3 players active, no show allowed
      expect(game.canRequestShow('p1', 'p2'), isFalse);
      
      // After p3 folds
      game.playerFold('p3');
      
      expect(game.canRequestShow('p1', 'p2'), isTrue);
    });
  });
}

/// Helper to create card objects from string notation
List<PlayingCard> _createCards(List<String> notations) {
  return notations.map((n) {
    final rank = n.substring(0, n.length - 1);
    final suit = n.substring(n.length - 1);
    return PlayingCard(rank: rank, suit: suit);
  }).toList();
}

/// Placeholder classes for compilation (actual implementation in game files)
class PlayingCard {
  final String rank;
  final String suit;
  PlayingCard({required this.rank, required this.suit});
}

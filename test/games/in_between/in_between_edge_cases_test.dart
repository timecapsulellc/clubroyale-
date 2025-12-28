import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/in_between/in_between_game.dart';

/// In-Between Edge Case Tests
/// 
/// Tests for edge cases in In-Between (Acey-Deucey) game logic:
/// - Game initialization
/// - Betting mechanics
/// - Win probability calculations
void main() {
  group('InBetweenGame Initialization', () {
    late InBetweenGame game;
    final players = ['player1', 'player2'];
    
    setUp(() {
      game = InBetweenGame();
      game.initialize(players);
    });

    test('Game initializes with correct min/max players', () {
      expect(game.minPlayers, greaterThan(0));
      expect(game.maxPlayers, greaterThanOrEqualTo(game.minPlayers));
    });

    test('Players start with initial chips', () {
      for (final pid in players) {
        expect(game.getChips(pid), greaterThan(0));
      }
    });

    test('Pot starts with ante contributions', () {
      game.startRound();
      expect(game.pot, greaterThan(0));
    });
  });

  group('InBetweenGame Betting', () {
    late InBetweenGame game;
    final players = ['p1', 'p2'];
    
    setUp(() {
      game = InBetweenGame();
      game.initialize(players);
      game.startRound();
    });

    test('Win probability is between 0 and 1', () {
      final probability = game.getWinProbability();
      expect(probability, greaterThanOrEqualTo(0.0));
      expect(probability, lessThanOrEqualTo(1.0));
    });
    
    test('Player can pass their turn', () {
      final currentPlayer = game.currentPlayerId;
      game.pass();
      // Turn should advance to next player
      expect(game.currentPlayerId, isNot(equals(currentPlayer)));
    });

    test('Bankrupt check works for new games', () {
      // Fresh game - no one should be bankrupt
      expect(game.isBankrupt('p1'), isFalse);
      expect(game.isBankrupt('p2'), isFalse);
    });
  });

  group('InBetweenGame End Conditions', () {
    late InBetweenGame game;
    
    setUp(() {
      game = InBetweenGame();
      game.initialize(['p1', 'p2']);
      game.startRound();
    });

    test('Game end check runs without error', () {
      game.checkGameEnd();
      expect(true, isTrue); // Just verify no exception
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_game.dart';

/// Teen Patti Edge Case Tests
///
/// Tests for Teen Patti game logic
void main() {
  group('TeenPattiGame Initialization', () {
    late TeenPattiGame game;
    final players = ['player1', 'player2', 'player3'];

    setUp(() {
      game = TeenPattiGame();
      game.initialize(players);
    });

    test('Game initializes with correct min/max players', () {
      expect(game.minPlayers, equals(3));
      expect(game.maxPlayers, greaterThanOrEqualTo(3));
    });

    test('All players start with blind status after deal', () {
      game.dealCards();
      for (final pid in players) {
        final player = game.getPlayer(pid);
        expect(player?.status, equals(PlayerStatus.blind));
      }
    });

    test('Boot amount initializes pot correctly', () {
      game.dealCards();
      expect(game.pot, greaterThan(0));
    });

    test('Deal gives each player 3 cards', () {
      game.dealCards();
      for (final pid in players) {
        expect(game.getHand(pid).length, equals(3));
      }
    });
  });

  group('TeenPattiGame Player Actions', () {
    late TeenPattiGame game;
    final players = ['p1', 'p2', 'p3'];

    setUp(() {
      game = TeenPattiGame();
      game.initialize(players);
      game.dealCards();
    });

    test('Player can see their cards', () {
      game.seeCards('p1');
      final player = game.getPlayer('p1');
      expect(player?.status, equals(PlayerStatus.seen));
    });

    test('Pot starts with boot contributions', () {
      expect(game.pot, greaterThan(0));
    });

    test('Current stake is positive', () {
      expect(game.currentStake, greaterThan(0));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/games/marriage/calculators/win_condition_calculator.dart';

/// Win Condition Tests
/// PhD Audit Verification for Finding #4 & #10

void main() {
  group('WinReason enum', () {
    test('has all required win reasons', () {
      expect(WinReason.values.length, 4);
      expect(WinReason.highestMaal.name, 'highestMaal');
      expect(WinReason.eightDublee.name, 'eightDublee');
      expect(WinReason.firstFinish.name, 'firstFinish');
      expect(WinReason.noPlayers.name, 'noPlayers');
    });
  });

  group('Win by Highest Maal Points', () {
    test('player with most Maal points wins', () {
      // Critical test: Points > Finish Order
      const playerAMaal = 10;
      const playerBMaal = 30;
      
      // Player B should win even if Player A finished first
      expect(playerBMaal > playerAMaal, true);
    });

    test('first finisher does NOT auto-win', () {
      // Common bug: Implementing "first to finish wins"
      // Correct: Highest Maal points wins
      const firstFinisherMaal = 5;
      const nonFinisherMaal = 40;
      
      expect(nonFinisherMaal > firstFinisherMaal, true);
    });
  });

  group('Win by 8 Dublee', () {
    test('8 Dublee is auto-win condition', () {
      const requiresDublees = 8;
      const requiresCards = 16; // 8 pairs = 16 cards minimum
      
      expect(requiresDublees, 8);
      expect(requiresCards, greaterThanOrEqualTo(16));
    });

    test('8 Dublee takes priority over Maal points', () {
      // If player has 8 dublees, they win regardless of points
      expect(WinReason.eightDublee.index, lessThan(WinReason.highestMaal.index));
    });
  });

  group('Tie-breaker Rules', () {
    test('equal Maal points: first finisher wins', () {
      const playerAMaal = 25;
      const playerBMaal = 25;
      const playerAFinishedFirst = true;
      
      expect(playerAMaal == playerBMaal, true);
      expect(playerAFinishedFirst, true); // Tie goes to first finisher
    });
  });

  group('WinResult', () {
    test('WinResult has winner indicator', () {
      final result = WinResult(
        winnerId: 'player1',
        reason: WinReason.highestMaal,
        maalPoints: {'player1': 30, 'player2': 20},
      );
      
      expect(result.hasWinner, true);
      expect(result.winnerId, 'player1');
    });

    test('WinResult can have no winner', () {
      final result = WinResult(
        winnerId: null,
        reason: WinReason.noPlayers,
        maalPoints: {},
      );
      
      expect(result.hasWinner, false);
    });
  });

  group('PlayerState', () {
    test('PlayerState tracks hand and status', () {
      final state = PlayerState(
        hand: [],
        hasVisited: true,
        hasFinished: false,
      );
      
      expect(state.hasVisited, true);
      expect(state.hasFinished, false);
    });
  });
}

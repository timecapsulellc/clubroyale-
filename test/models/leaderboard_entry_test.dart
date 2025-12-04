
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/leaderboard/leaderboard_screen.dart';

void main() {
  group('LeaderboardEntry Tests', () {
    test('should calculate win rate correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 100,
        gamesPlayed: 10,
        gamesWon: 5,
      );

      expect(entry.winRate, 0.5);
    });

    test('should handle zero games for win rate', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 0,
        gamesPlayed: 0,
        gamesWon: 0,
      );

      expect(entry.winRate, 0.0);
    });

    test('should calculate average score correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 100,
        gamesPlayed: 4,
        gamesWon: 2,
      );

      expect(entry.averageScore, 25.0);
    });

    test('should handle zero games for average score', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 0,
        gamesPlayed: 0,
        gamesWon: 0,
      );

      expect(entry.averageScore, 0.0);
    });

    test('should store avatar URL correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        avatarUrl: 'https://example.com/avatar.jpg',
        totalScore: 100,
        gamesPlayed: 5,
        gamesWon: 3,
      );

      expect(entry.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should handle null avatar URL', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 100,
        gamesPlayed: 5,
        gamesWon: 3,
      );

      expect(entry.avatarUrl, null);
    });

    test('should calculate 100% win rate correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 50,
        gamesPlayed: 5,
        gamesWon: 5,
      );

      expect(entry.winRate, 1.0);
    });

    test('should calculate 0% win rate correctly', () {
      final entry = LeaderboardEntry(
        odayerId: 'player1',
        playerName: 'Alice',
        totalScore: 10,
        gamesPlayed: 5,
        gamesWon: 0,
      );

      expect(entry.winRate, 0.0);
    });
  });
}

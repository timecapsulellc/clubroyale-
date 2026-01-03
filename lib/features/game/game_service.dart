import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_room.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../../core/services/toast_service.dart';

final gameServiceProvider = Provider<GameService>((ref) => GameService());

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference _gamesRef;

  GameService() {
    _gamesRef = _db.collection('games');
  }

  // Retrieves a game room from Firestore.
  Future<GameRoom?> getGame(String gameId) async {
    try {
      final doc = await _gamesRef.doc(gameId).get();
      if (doc.exists) {
        return GameRoom.fromJson(
          doc.data() as Map<String, dynamic>,
        ).copyWith(id: doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting game: $e');
      return null;
    }
  }

  // Retrieves a real-time stream of a game room from Firestore.
  Stream<GameRoom?> getGameStream(String gameId) {
    return _gamesRef.doc(gameId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return GameRoom.fromJson(
          snapshot.data() as Map<String, dynamic>,
        ).copyWith(id: snapshot.id);
      }
      return null;
    });
  }

  // Retrieves all finished games as a real-time stream.
  Stream<List<GameRoom>> getFinishedGames() {
    return _gamesRef
        .where('isFinished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GameRoom.fromJson(
              doc.data() as Map<String, dynamic>,
            ).copyWith(id: doc.id);
          }).toList();
        });
  }

  // Aggregates player stats across all finished games for leaderboard.
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final snapshot = await _gamesRef
          .where('isFinished', isEqualTo: true)
          .get();

      // Aggregate stats per player
      final Map<String, _PlayerStats> playerStats = {};

      for (final doc in snapshot.docs) {
        final game = GameRoom.fromJson(
          doc.data() as Map<String, dynamic>,
        ).copyWith(id: doc.id);

        // Find winner (highest score)
        String? winnerId;
        int highestScore = 0;
        game.scores.forEach((playerId, score) {
          if (score > highestScore) {
            highestScore = score;
            winnerId = playerId;
          }
        });

        // Update stats for each player
        for (final player in game.players) {
          final score = game.scores[player.id] ?? 0;
          final isWinner = player.id == winnerId && highestScore > 0;

          if (!playerStats.containsKey(player.id)) {
            playerStats[player.id] = _PlayerStats(
              playerId: player.id,
              playerName: player.profile?.displayName ?? player.name,
              avatarUrl: player.profile?.avatarUrl,
            );
          }

          playerStats[player.id]!.totalScore += score;
          playerStats[player.id]!.gamesPlayed += 1;
          if (isWinner) {
            playerStats[player.id]!.gamesWon += 1;
          }
        }
      }

      // Convert to list and sort by total score
      final entries = playerStats.values
          .map(
            (stats) => LeaderboardEntry(
              odayerId: stats.playerId,
              playerName: stats.playerName,
              avatarUrl: stats.avatarUrl,
              totalScore: stats.totalScore,
              gamesPlayed: stats.gamesPlayed,
              gamesWon: stats.gamesWon,
            ),
          )
          .toList();

      entries.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      return entries;
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      ToastService.showError('Failed to load leaderboard');
      return [];
    }
  }

  // Updates the score of a player in a game.
  Future<void> updatePlayerScore(
    String gameId,
    String playerId,
    int increment,
  ) async {
    try {
      await _gamesRef.doc(gameId).update({
        'scores.$playerId': FieldValue.increment(increment),
      });
    } catch (e) {
      debugPrint('Error updating player score: $e');
      ToastService.showError('Failed to update score');
    }
  }

  // Updates the scores of a game in Firestore.
  Future<void> updateScores(String gameId, Map<String, int> scores) async {
    try {
      await _gamesRef.doc(gameId).update({'scores': scores});
    } catch (e) {
      debugPrint('Error updating scores: $e');
      ToastService.showError('Failed to update scores');
    }
  }

  // Marks a game as finished.
  Future<void> finishGame(String gameId) async {
    try {
      await _gamesRef.doc(gameId).update({
        'isFinished': true,
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error finishing game: $e');
      ToastService.showError('Failed to finish game');
    }
  }

  // Deletes a game from Firestore.
  Future<void> deleteGame(String gameId) async {
    try {
      await _gamesRef.doc(gameId).delete();
    } catch (e) {
      debugPrint('Error deleting game: $e');
      ToastService.showError('Failed to delete game');
    }
  }
}

// Helper class for aggregating player stats
class _PlayerStats {
  final String playerId;
  final String playerName;
  final String? avatarUrl;
  int totalScore = 0;
  int gamesPlayed = 0;
  int gamesWon = 0;

  _PlayerStats({
    required this.playerId,
    required this.playerName,
    this.avatarUrl,
  });
}

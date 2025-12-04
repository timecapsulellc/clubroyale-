
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_room.dart';

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
        return GameRoom.fromJson(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id);
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
        return GameRoom.fromJson(snapshot.data() as Map<String, dynamic>)
            .copyWith(id: snapshot.id);
      }
      return null;
    });
  }

  // Updates the score of a player in a game.
  Future<void> updatePlayerScore(
      String gameId, String playerId, int increment) async {
    try {
      await _gamesRef.doc(gameId).update({
        'scores.$playerId': FieldValue.increment(increment),
      });
    } catch (e) {
      debugPrint('Error updating player score: $e');
    }
  }

  // Updates the scores of a game in Firestore.
  Future<void> updateScores(String gameId, Map<String, int> scores) async {
    try {
      await _gamesRef.doc(gameId).update({'scores': scores});
    } catch (e) {
      debugPrint('Error updating scores: $e');
    }
  }

  // Marks a game as finished.
  Future<void> finishGame(String gameId) async {
    try {
      await _gamesRef.doc(gameId).update({
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error finishing game: $e');
    }
  }
}

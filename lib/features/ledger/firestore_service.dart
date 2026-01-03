import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, int>> getPlayerScores(String gameId) async {
    try {
      final doc = await _db.collection('games').doc(gameId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!['playerScores'];
        if (data is Map<String, dynamic>) {
          return data.map((key, value) => MapEntry(key, value as int));
        }
      }
      return {};
    } catch (e) {
      debugPrint("Error getting player scores: $e");
      return {};
    }
  }

  Future<void> seedDatabase(String gameId) async {
    final gameRef = _db.collection('games').doc(gameId);
    await gameRef.set({
      'playerScores': {
        'Player A': 50,
        'Player B': -20,
        'Player C': -30,
        'Player D': 0,
      },
    });
  }
}

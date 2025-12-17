/// Matchmaking Service
/// 
/// ELO-based matchmaking with Quick Match functionality.
/// Uses GenKit for intelligent player grouping.
library;

import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';

/// Provider for matchmaking service
final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final lobbyService = ref.watch(lobbyServiceProvider);
  return MatchmakingService(authService, lobbyService);
});

/// Player rating data
class PlayerRating {
  final String userId;
  final int elo;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final String rank;
  final DateTime lastPlayed;

  PlayerRating({
    required this.userId,
    required this.elo,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.rank,
    required this.lastPlayed,
  });

  factory PlayerRating.initial(String userId) {
    return PlayerRating(
      userId: userId,
      elo: 1000,  // Starting ELO
      gamesPlayed: 0,
      wins: 0,
      losses: 0,
      rank: 'Bronze',
      lastPlayed: DateTime.now(),
    );
  }

  factory PlayerRating.fromJson(Map<String, dynamic> json, String oderId) {
    return PlayerRating(
      userId: oderId,
      elo: json['elo'] ?? 1000,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      rank: json['rank'] ?? 'Bronze',
      lastPlayed: (json['lastPlayed'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'elo': elo,
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'losses': losses,
    'rank': rank,
    'lastPlayed': FieldValue.serverTimestamp(),
  };

  double get winRate => gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

  static String getRank(int elo) {
    if (elo >= 2000) return 'Diamond';
    if (elo >= 1700) return 'Platinum';
    if (elo >= 1400) return 'Gold';
    if (elo >= 1100) return 'Silver';
    return 'Bronze';
  }
}

/// Matchmaking queue entry
class QueueEntry {
  final String userId;
  final String displayName;
  final int elo;
  final String gameType;
  final DateTime joinedAt;

  QueueEntry({
    required this.userId,
    required this.displayName,
    required this.elo,
    required this.gameType,
    required this.joinedAt,
  });

  factory QueueEntry.fromJson(Map<String, dynamic> json, String oderId) {
    return QueueEntry(
      userId: oderId,
      displayName: json['displayName'] ?? 'Player',
      elo: json['elo'] ?? 1000,
      gameType: json['gameType'] ?? 'call_break',
      joinedAt: (json['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Matchmaking service
class MatchmakingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final AuthService _authService;
  final LobbyService _lobbyService;

  /// ELO constants
  static const int kFactor = 32; // K-factor for ELO calculation
  static const int initialRatingRange = 200; // Initial ELO range for matching
  static const int rangeExpansionPerSecond = 10; // Expand range over time

  MatchmakingService(this._authService, this._lobbyService);

  /// Get or create player rating
  Future<PlayerRating> getPlayerRating(String userId) async {
    final doc = await _db.collection('ratings').doc(userId).get();
    if (!doc.exists) {
      final newRating = PlayerRating.initial(userId);
      await _db.collection('ratings').doc(userId).set(newRating.toJson());
      return newRating;
    }
    return PlayerRating.fromJson(doc.data()!, userId);
  }

  /// Update player rating after game result
  Future<void> updateRating({
    required String userId,
    required String opponentId,
    required bool won,
    required String gameType,
  }) async {
    final playerDoc = await _db.collection('ratings').doc(userId).get();
    final opponentDoc = await _db.collection('ratings').doc(opponentId).get();

    final playerRating = playerDoc.exists 
        ? PlayerRating.fromJson(playerDoc.data()!, userId)
        : PlayerRating.initial(userId);
    final opponentRating = opponentDoc.exists
        ? PlayerRating.fromJson(opponentDoc.data()!, opponentId)
        : PlayerRating.initial(opponentId);

    // Calculate new ELO
    final newPlayerElo = calculateNewElo(
        playerRating.elo, opponentRating.elo, won);
    final newOpponentElo = calculateNewElo(
        opponentRating.elo, playerRating.elo, !won);

    // Update player rating
    await _db.collection('ratings').doc(userId).set({
      'elo': newPlayerElo,
      'gamesPlayed': FieldValue.increment(1),
      'wins': won ? FieldValue.increment(1) : FieldValue.increment(0),
      'losses': won ? FieldValue.increment(0) : FieldValue.increment(1),
      'rank': PlayerRating.getRank(newPlayerElo),
      'lastPlayed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update opponent rating
    await _db.collection('ratings').doc(opponentId).set({
      'elo': newOpponentElo,
      'gamesPlayed': FieldValue.increment(1),
      'wins': !won ? FieldValue.increment(1) : FieldValue.increment(0),
      'losses': !won ? FieldValue.increment(0) : FieldValue.increment(1),
      'rank': PlayerRating.getRank(newOpponentElo),
      'lastPlayed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Calculate new ELO rating
  int calculateNewElo(int playerElo, int opponentElo, bool won) {
    // Expected score
    final double expected = 1 / (1 + pow(10, (opponentElo - playerElo) / 400));
    
    // Actual score
    final double actual = won ? 1.0 : 0.0;
    
    // New rating
    final newElo = playerElo + (kFactor * (actual - expected)).round();
    
    // Don't go below 100
    return max(100, newElo);
  }

  /// Join matchmaking queue
  Future<String?> joinQueue(String gameType) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;

    final rating = await getPlayerRating(currentUser.uid);

    // Add to queue
    final queueRef = _db.collection('matchmaking_queue');
    await queueRef.doc(currentUser.uid).set({
      'userId': currentUser.uid,
      'displayName': currentUser.displayName ?? 'Player',
      'elo': rating.elo,
      'gameType': gameType,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Try to find a match
    return await _findMatch(currentUser.uid, rating.elo, gameType);
  }

  /// Leave matchmaking queue
  Future<void> leaveQueue() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    await _db.collection('matchmaking_queue').doc(currentUser.uid).delete();
  }

  /// Find a match for a player
  Future<String?> _findMatch(String userId, int elo, String gameType) async {
    // Get queue entries for same game type
    final queueSnapshot = await _db
        .collection('matchmaking_queue')
        .where('gameType', isEqualTo: gameType)
        .get();

    final entries = queueSnapshot.docs
        .where((doc) => doc.id != userId)
        .map((doc) => QueueEntry.fromJson(doc.data(), doc.id))
        .toList();

    // Find closest ELO match within range
    final now = DateTime.now();
    for (final entry in entries) {
      final waitTime = now.difference(entry.joinedAt).inSeconds;
      final eloRange = initialRatingRange + (waitTime * rangeExpansionPerSecond);
      
      if ((entry.elo - elo).abs() <= eloRange) {
        // Found a match! Create room
        final roomId = await _createMatchedRoom(
          [userId, entry.userId],
          gameType,
        );

        // Remove both from queue
        await _db.collection('matchmaking_queue').doc(userId).delete();
        await _db.collection('matchmaking_queue').doc(entry.userId).delete();

        return roomId;
      }
    }

    // No match found yet
    return null;
  }

  /// Create room for matched players
  Future<String> _createMatchedRoom(List<String> playerIds, String gameType) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final players = playerIds.map((id) => Player(
      id: id,
      name: 'Player ${playerIds.indexOf(id) + 1}',
      isReady: true,
    )).toList();

    final room = GameRoom(
      name: 'Ranked Match',
      hostId: currentUser.uid,
      gameType: gameType,
      players: players,
      scores: {for (var p in players) p.id: 0},
      isPublic: false,
    );

    return await _lobbyService.createGame(room);
  }

  /// Get leaderboard
  Future<List<PlayerRating>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _db
        .collection('ratings')
        .orderBy('elo', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => PlayerRating.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Watch queue status
  Stream<bool> watchQueueStatus(String userId) {
    return _db
        .collection('matchmaking_queue')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Use GenKit for AI-powered matchmaking suggestions
  Future<List<String>> getAiMatchSuggestions({
    required String userId,
    required String gameType,
    required int elo,
  }) async {
    try {
      final callable = _functions.httpsCallable('getMatchSuggestions');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'gameType': gameType,
        'elo': elo,
      });
      return List<String>.from(result.data['suggestions'] ?? []);
    } catch (e) {
      debugPrint('AI matchmaking error: $e');
      return [];
    }
  }
}

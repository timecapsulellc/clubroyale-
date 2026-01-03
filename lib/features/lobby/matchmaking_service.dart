/// Matchmaking Service
///
/// Auto-match algorithm to pair players for games
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Matchmaking service provider
final matchmakingServiceProvider = Provider((ref) => MatchmakingService());

/// Queue entry for a player looking for a match
class QueueEntry {
  final String oderId;
  final String playerId;
  final String playerName;
  final String gameType;
  final int playerRating;
  final DateTime queuedAt;
  final int? preferredMinPlayers;
  final int? preferredMaxPlayers;

  QueueEntry({
    required this.playerId,
    required this.playerName,
    required this.gameType,
    required this.playerRating,
    required this.queuedAt,
    this.preferredMinPlayers,
    this.preferredMaxPlayers,
  }) : oderId = '${playerId}_${queuedAt.millisecondsSinceEpoch}';

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'playerName': playerName,
    'gameType': gameType,
    'playerRating': playerRating,
    'queuedAt': Timestamp.fromDate(queuedAt),
    'preferredMinPlayers': preferredMinPlayers,
    'preferredMaxPlayers': preferredMaxPlayers,
  };

  factory QueueEntry.fromJson(Map<String, dynamic> json, String id) {
    return QueueEntry(
      playerId: json['playerId'] ?? '',
      playerName: json['playerName'] ?? 'Player',
      gameType: json['gameType'] ?? 'call_break',
      playerRating: json['playerRating'] ?? 1000,
      queuedAt: (json['queuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferredMinPlayers: json['preferredMinPlayers'],
      preferredMaxPlayers: json['preferredMaxPlayers'],
    );
  }

  /// Time in queue
  Duration get waitTime => DateTime.now().difference(queuedAt);
}

/// Match result when players are paired
class MatchResult {
  final String matchId;
  final String gameType;
  final List<String> playerIds;
  final List<String> playerNames;
  final DateTime matchedAt;

  MatchResult({
    required this.matchId,
    required this.gameType,
    required this.playerIds,
    required this.playerNames,
    required this.matchedAt,
  });

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'gameType': gameType,
    'playerIds': playerIds,
    'playerNames': playerNames,
    'matchedAt': Timestamp.fromDate(matchedAt),
    'status': 'pending',
  };
}

/// Queue status for UI
enum QueueStatus { idle, searching, found, cancelled, timeout }

/// Matchmaking service
class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configuration
  static const Duration searchTimeout = Duration(minutes: 2);
  static const Duration matchCheckInterval = Duration(seconds: 3);
  static const int ratingRange = 200; // +/- rating for matching

  // Current state
  StreamSubscription? _queueSubscription;
  StreamSubscription? _matchSubscription;
  Timer? _matchCheckTimer;

  // Controllers
  final _statusController = StreamController<QueueStatus>.broadcast();
  final _matchController = StreamController<MatchResult?>.broadcast();

  /// Stream of queue status
  Stream<QueueStatus> get statusStream => _statusController.stream;

  /// Stream of match results
  Stream<MatchResult?> get matchStream => _matchController.stream;

  /// Join matchmaking queue
  Future<void> joinQueue({
    required String playerId,
    required String playerName,
    required String gameType,
    int playerRating = 1000,
    int? minPlayers,
    int? maxPlayers,
  }) async {
    final entry = QueueEntry(
      playerId: playerId,
      playerName: playerName,
      gameType: gameType,
      playerRating: playerRating,
      queuedAt: DateTime.now(),
      preferredMinPlayers: minPlayers,
      preferredMaxPlayers: maxPlayers,
    );

    // Add to queue
    await _firestore
        .collection('matchmaking_queue')
        .doc(entry.oderId)
        .set(entry.toJson());

    _statusController.add(QueueStatus.searching);

    // Start watching for matches
    _startMatchWatching(playerId, gameType);

    // Set timeout
    Future.delayed(searchTimeout, () {
      _checkTimeout(playerId);
    });
  }

  /// Leave matchmaking queue
  Future<void> leaveQueue(String playerId) async {
    // Remove from queue
    final query = await _firestore
        .collection('matchmaking_queue')
        .where('playerId', isEqualTo: playerId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }

    _statusController.add(QueueStatus.cancelled);
    _stopWatching();
  }

  void _startMatchWatching(String playerId, String gameType) {
    // Watch for match assignments
    _matchSubscription = _firestore
        .collection('matches')
        .where('playerIds', arrayContains: playerId)
        .where('status', isEqualTo: 'pending')
        .orderBy('matchedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs.first.data();
            final match = MatchResult(
              matchId: snapshot.docs.first.id,
              gameType: data['gameType'] ?? gameType,
              playerIds: List<String>.from(data['playerIds'] ?? []),
              playerNames: List<String>.from(data['playerNames'] ?? []),
              matchedAt:
                  (data['matchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
            _matchController.add(match);
            _statusController.add(QueueStatus.found);
            _stopWatching();
          }
        });

    // Periodically try to find matches
    _matchCheckTimer = Timer.periodic(matchCheckInterval, (_) {
      _tryFindMatch(playerId, gameType);
    });

    // Immediate first check
    _tryFindMatch(playerId, gameType);
  }

  Future<void> _tryFindMatch(String playerId, String gameType) async {
    // Get required player count for game type
    final requiredPlayers = _getRequiredPlayers(gameType);

    // Query queue for same game type
    final query = await _firestore
        .collection('matchmaking_queue')
        .where('gameType', isEqualTo: gameType)
        .orderBy('queuedAt')
        .limit(requiredPlayers * 2) // Get more than needed for rating matching
        .get();

    if (query.docs.length < requiredPlayers) {
      return; // Not enough players
    }

    // Get current player's entry
    final myEntry = query.docs
        .map((d) => QueueEntry.fromJson(d.data(), d.id))
        .where((e) => e.playerId == playerId)
        .firstOrNull;

    if (myEntry == null) return;

    // Find compatible players within rating range
    final candidates = query.docs
        .map((d) => QueueEntry.fromJson(d.data(), d.id))
        .where((e) => e.playerId != playerId)
        .where(
          (e) => (e.playerRating - myEntry.playerRating).abs() <= ratingRange,
        )
        .toList();

    if (candidates.length < requiredPlayers - 1) {
      return; // Not enough compatible players
    }

    // Select players for match
    final matchPlayers = [myEntry, ...candidates.take(requiredPlayers - 1)];

    // Create match
    await _createMatch(gameType, matchPlayers);
  }

  Future<void> _createMatch(String gameType, List<QueueEntry> players) async {
    final matchId = 'match_${DateTime.now().millisecondsSinceEpoch}';

    final match = MatchResult(
      matchId: matchId,
      gameType: gameType,
      playerIds: players.map((p) => p.playerId).toList(),
      playerNames: players.map((p) => p.playerName).toList(),
      matchedAt: DateTime.now(),
    );

    // Create match document
    await _firestore.collection('matches').doc(matchId).set(match.toJson());

    // Remove players from queue
    for (final player in players) {
      await _firestore
          .collection('matchmaking_queue')
          .doc(player.oderId)
          .delete();
    }
  }

  int _getRequiredPlayers(String gameType) {
    switch (gameType) {
      case 'call_break':
        return 4;
      case 'marriage':
        return 4; // Default, supports 2-8
      case 'teen_patti':
        return 4;
      case 'in_between':
        return 4;
      default:
        return 4;
    }
  }

  void _checkTimeout(String playerId) async {
    // Check if still in queue
    final query = await _firestore
        .collection('matchmaking_queue')
        .where('playerId', isEqualTo: playerId)
        .get();

    if (query.docs.isNotEmpty) {
      // Still waiting - timeout
      await leaveQueue(playerId);
      _statusController.add(QueueStatus.timeout);
    }
  }

  void _stopWatching() {
    _queueSubscription?.cancel();
    _matchSubscription?.cancel();
    _matchCheckTimer?.cancel();
  }

  /// Accept a match
  Future<void> acceptMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': 'accepted',
    });
  }

  /// Decline a match
  Future<void> declineMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': 'declined',
    });
  }

  /// Clean up
  void dispose() {
    _stopWatching();
    _statusController.close();
    _matchController.close();
  }
}

/// Tournament Service
/// 
/// Manages tournament creation, registration, and bracket management
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';

/// Tournament Service
class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference<Map<String, dynamic>> get _tournamentsRef =>
      _firestore.collection('tournaments');

  /// Get tournament document reference
  DocumentReference<Map<String, dynamic>> _tournamentDoc(String id) =>
      _tournamentsRef.doc(id);

  /// Create a new tournament
  Future<String> createTournament({
    required String hostId,
    required String hostName,
    required String name,
    required String description,
    required String gameType,
    required TournamentFormat format,
    required int maxParticipants,
    int? prizePool,
    int? entryFee,
    DateTime? startTime,
  }) async {
    final doc = _tournamentsRef.doc();
    
    await doc.set({
      'id': doc.id,
      'name': name,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'gameType': gameType,
      'format': format.name,
      'status': TournamentStatus.registration.name,
      'maxParticipants': maxParticipants,
      'minParticipants': 2,
      'prizePool': prizePool,
      'entryFee': entryFee,
      'startTime': startTime,
      'participantIds': [hostId], // Host auto-joins
      'brackets': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add host as first participant
    await _tournamentDoc(doc.id).collection('participants').doc(hostId).set({
      'oderId': hostId,
      'userName': hostName,
      'joinedAt': FieldValue.serverTimestamp(),
      'wins': 0,
      'losses': 0,
      'pointsScored': 0,
    });

    debugPrint('🏆 Tournament created: ${doc.id}');
    return doc.id;
  }

  /// Join a tournament
  Future<bool> joinTournament({
    required String tournamentId,
    required String oderId,
    required String userName,
    String? avatarUrl,
  }) async {
    try {
      final doc = await _tournamentDoc(tournamentId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final status = TournamentStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => TournamentStatus.cancelled,
      );
      
      if (status != TournamentStatus.registration) {
        debugPrint('Tournament not accepting registrations');
        return false;
      }

      final participants = List<String>.from(data['participantIds'] ?? []);
      if (participants.contains(oderId)) {
        debugPrint('Already registered');
        return false;
      }

      if (participants.length >= (data['maxParticipants'] as int)) {
        debugPrint('Tournament is full');
        return false;
      }

      // Add to participants
      await _tournamentDoc(tournamentId).update({
        'participantIds': FieldValue.arrayUnion([oderId]),
      });

      await _tournamentDoc(tournamentId).collection('participants').doc(oderId).set({
        'oderId': oderId,
        'userName': userName,
        'avatarUrl': avatarUrl,
        'joinedAt': FieldValue.serverTimestamp(),
        'wins': 0,
        'losses': 0,
        'pointsScored': 0,
      });

      debugPrint('✅ Joined tournament: $tournamentId');
      return true;
    } catch (e) {
      debugPrint('Error joining tournament: $e');
      return false;
    }
  }

  /// Leave a tournament (before it starts)
  Future<bool> leaveTournament({
    required String tournamentId,
    required String oderId,
  }) async {
    try {
      await _tournamentDoc(tournamentId).update({
        'participantIds': FieldValue.arrayRemove([oderId]),
      });

      await _tournamentDoc(tournamentId).collection('participants').doc(oderId).delete();

      return true;
    } catch (e) {
      debugPrint('Error leaving tournament: $e');
      return false;
    }
  }

  /// Start the tournament (generate brackets)
  Future<bool> startTournament(String tournamentId) async {
    try {
      final doc = await _tournamentDoc(tournamentId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final participantIds = List<String>.from(data['participantIds'] ?? []);

      if (participantIds.length < 2) {
        debugPrint('Not enough participants');
        return false;
      }

      // Get participant details
      final participantsSnapshot = await _tournamentDoc(tournamentId)
          .collection('participants')
          .get();
      
      final participants = participantsSnapshot.docs
          .map((d) => MapEntry(d.id, d.data()['userName'] as String))
          .toList();

      // Shuffle for random seeding
      participants.shuffle();

      // Generate brackets for single elimination
      final brackets = _generateBrackets(participants);

      await _tournamentDoc(tournamentId).update({
        'status': TournamentStatus.inProgress.name,
        'brackets': brackets.map((b) => b.toJson()).toList(),
        'startTime': FieldValue.serverTimestamp(),
      });

      debugPrint('🚀 Tournament started with ${participants.length} players');
      return true;
    } catch (e) {
      debugPrint('Error starting tournament: $e');
      return false;
    }
  }

  /// Generate single elimination brackets
  List<TournamentBracket> _generateBrackets(List<MapEntry<String, String>> participants) {
    final brackets = <TournamentBracket>[];
    var round = 1;
    var matchNumber = 1;

    // First round matches
    for (var i = 0; i < participants.length; i += 2) {
      final player1 = participants[i];
      final player2 = i + 1 < participants.length ? participants[i + 1] : null;

      brackets.add(TournamentBracket(
        id: 'r${round}_m$matchNumber',
        round: round,
        matchNumber: matchNumber,
        player1Id: player1.key,
        player1Name: player1.value,
        player2Id: player2?.key,
        player2Name: player2?.value,
        status: player2 == null ? BracketStatus.completed : BracketStatus.pending,
        winnerId: player2 == null ? player1.key : null, // Bye
      ));
      matchNumber++;
    }

    return brackets;
  }

  /// Report match result
  Future<void> reportMatchResult({
    required String tournamentId,
    required String bracketId,
    required String winnerId,
    required int player1Score,
    required int player2Score,
  }) async {
    try {
      final doc = await _tournamentDoc(tournamentId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final brackets = (data['brackets'] as List)
          .map((b) => TournamentBracket.fromJson(b as Map<String, dynamic>))
          .toList();

      // Update the specific bracket
      final bracketIndex = brackets.indexWhere((b) => b.id == bracketId);
      if (bracketIndex == -1) return;

      final updatedBracket = brackets[bracketIndex].copyWith(
        winnerId: winnerId,
        player1Score: player1Score,
        player2Score: player2Score,
        status: BracketStatus.completed,
        completedTime: DateTime.now(),
      );

      brackets[bracketIndex] = updatedBracket;

      // Update participant stats
      await _updateParticipantStats(
        tournamentId: tournamentId,
        winnerId: winnerId,
        loserId: winnerId == updatedBracket.player1Id 
            ? updatedBracket.player2Id 
            : updatedBracket.player1Id,
        winnerPoints: winnerId == updatedBracket.player1Id 
            ? player1Score 
            : player2Score,
        loserPoints: winnerId == updatedBracket.player1Id 
            ? player2Score 
            : player1Score,
      );

      // Check if tournament is complete
      final allComplete = brackets.every((b) => b.status == BracketStatus.completed);

      await _tournamentDoc(tournamentId).update({
        'brackets': brackets.map((b) => b.toJson()).toList(),
        if (allComplete) 'status': TournamentStatus.completed.name,
        if (allComplete) 'winnerId': winnerId,
        if (allComplete) 'endTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reporting match result: $e');
    }
  }

  Future<void> _updateParticipantStats({
    required String tournamentId,
    required String winnerId,
    required String? loserId,
    required int winnerPoints,
    required int loserPoints,
  }) async {
    final batch = _firestore.batch();

    final winnerRef = _tournamentDoc(tournamentId).collection('participants').doc(winnerId);
    batch.update(winnerRef, {
      'wins': FieldValue.increment(1),
      'pointsScored': FieldValue.increment(winnerPoints),
    });

    if (loserId != null) {
      final loserRef = _tournamentDoc(tournamentId).collection('participants').doc(loserId);
      batch.update(loserRef, {
        'losses': FieldValue.increment(1),
        'pointsScored': FieldValue.increment(loserPoints),
        'isEliminated': true,
      });
    }

    await batch.commit();
  }

  /// Watch tournament updates
  Stream<Tournament?> watchTournament(String id) {
    return _tournamentDoc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Tournament.fromJson(doc.data()!);
    });
  }

  /// Get all tournaments (for lobby)
  Stream<List<Tournament>> watchAllTournaments({TournamentStatus? status}) {
    var query = _tournamentsRef.orderBy('createdAt', descending: true).limit(50);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Tournament.fromJson(doc.data())).toList();
    });
  }

  /// Get standings
  Future<List<TournamentStanding>> getStandings(String tournamentId) async {
    final snapshot = await _tournamentDoc(tournamentId)
        .collection('participants')
        .orderBy('wins', descending: true)
        .orderBy('pointsScored', descending: true)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      final data = entry.value.data();
      return TournamentStanding(
        rank: entry.key + 1,
        oderId: data['oderId'] as String,
        userName: data['userName'] as String,
        avatarUrl: data['avatarUrl'] as String?,
        wins: data['wins'] as int? ?? 0,
        losses: data['losses'] as int? ?? 0,
        totalPoints: data['pointsScored'] as int? ?? 0,
      );
    }).toList();
  }
}

/// Provider for tournament service
final tournamentServiceProvider = Provider<TournamentService>((ref) {
  return TournamentService();
});

/// Provider for watching a specific tournament
final tournamentProvider = StreamProvider.family<Tournament?, String>((ref, id) {
  return ref.watch(tournamentServiceProvider).watchTournament(id);
});

/// Provider for all tournaments
final allTournamentsProvider = StreamProvider<List<Tournament>>((ref) {
  return ref.watch(tournamentServiceProvider).watchAllTournaments();
});

/// Provider for open tournaments (registration phase)
final openTournamentsProvider = StreamProvider<List<Tournament>>((ref) {
  return ref.watch(tournamentServiceProvider).watchAllTournaments(
    status: TournamentStatus.registration,
  );
});

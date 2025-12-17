/// Spectator Service
/// 
/// Enables watching live games without participating
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Spectator mode status
enum SpectatorStatus {
  idle,
  joining,
  watching,
  error,
}

/// Spectator state
class SpectatorState {
  final SpectatorStatus status;
  final String? roomId;
  final String? gameType;
  final List<String> spectators;
  final String? error;
  final Map<String, dynamic>? gameState;

  const SpectatorState({
    this.status = SpectatorStatus.idle,
    this.roomId,
    this.gameType,
    this.spectators = const [],
    this.error,
    this.gameState,
  });

  SpectatorState copyWith({
    SpectatorStatus? status,
    String? roomId,
    String? gameType,
    List<String>? spectators,
    String? error,
    Map<String, dynamic>? gameState,
  }) {
    return SpectatorState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      gameType: gameType ?? this.gameType,
      spectators: spectators ?? this.spectators,
      error: error ?? this.error,
      gameState: gameState ?? this.gameState,
    );
  }
}

/// Spectator Service - Riverpod 3.x Notifier pattern
class SpectatorService extends Notifier<SpectatorState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  SpectatorState build() => const SpectatorState();

  /// Get game room reference
  DocumentReference<Map<String, dynamic>> _roomRef(String roomId) =>
      _firestore.collection('rooms').doc(roomId);

  /// Get spectators subcollection
  CollectionReference<Map<String, dynamic>> _spectatorsRef(String roomId) =>
      _roomRef(roomId).collection('spectators');

  /// Join a game as spectator
  Future<bool> joinAsSpectator({
    required String roomId,
    required String userId,
    required String userName,
  }) async {
    try {
      state = state.copyWith(status: SpectatorStatus.joining);

      // Get room info
      final roomDoc = await _roomRef(roomId).get();
      if (!roomDoc.exists) {
        state = state.copyWith(
          status: SpectatorStatus.error,
          error: 'Room not found',
        );
        return false;
      }

      final roomData = roomDoc.data()!;
      final gameType = roomData['gameType'] as String?;
      final isLive = roomData['status'] == 'playing';

      if (!isLive) {
        state = state.copyWith(
          status: SpectatorStatus.error,
          error: 'Game is not currently in progress',
        );
        return false;
      }

      // Add to spectators subcollection
      await _spectatorsRef(roomId).doc(userId).set({
        'userId': userId,
        'userName': userName,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Update spectator count on room
      await _roomRef(roomId).update({
        'spectatorCount': FieldValue.increment(1),
      });

      state = state.copyWith(
        status: SpectatorStatus.watching,
        roomId: roomId,
        gameType: gameType,
      );

      debugPrint('👀 Joined as spectator: $roomId');
      return true;
    } catch (e) {
      debugPrint('Error joining as spectator: $e');
      state = state.copyWith(
        status: SpectatorStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Leave spectating
  Future<void> leaveSpectating({
    required String userId,
  }) async {
    if (state.roomId == null) return;

    try {
      final roomId = state.roomId!;

      // Remove from spectators collection
      await _spectatorsRef(roomId).doc(userId).delete();

      // Decrement spectator count
      await _roomRef(roomId).update({
        'spectatorCount': FieldValue.increment(-1),
      });

      state = const SpectatorState();
      debugPrint('👋 Left spectating');
    } catch (e) {
      debugPrint('Error leaving spectating: $e');
    }
  }

  /// Watch game state in real-time
  Stream<Map<String, dynamic>?> watchGameState(String roomId) {
    return _roomRef(roomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  /// Watch spectator list
  Stream<List<String>> watchSpectators(String roomId) {
    return _spectatorsRef(roomId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['userName'] as String).toList();
    });
  }

  /// Get current spectator count for a room
  Future<int> getSpectatorCount(String roomId) async {
    final snapshot = await _spectatorsRef(roomId).count().get();
    return snapshot.count ?? 0;
  }

  /// Check if a room allows spectators
  Future<bool> canSpectate(String roomId) async {
    try {
      final doc = await _roomRef(roomId).get();
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final status = data['status'] as String?;
      final allowSpectators = data['allowSpectators'] as bool? ?? true;
      
      return status == 'playing' && allowSpectators;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for spectator service - Riverpod 3.x Notifier pattern
final spectatorServiceProvider =
    NotifierProvider<SpectatorService, SpectatorState>(SpectatorService.new);

/// Provider for room spectator count
final spectatorCountProvider = StreamProvider.family<int, String>((ref, roomId) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('rooms')
      .doc(roomId)
      .collection('spectators')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider for game state stream (for spectators)
final spectatorGameStateProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, roomId) {
  return ref.watch(spectatorServiceProvider.notifier).watchGameState(roomId);
});

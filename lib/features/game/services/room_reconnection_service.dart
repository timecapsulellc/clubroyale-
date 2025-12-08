// Room Reconnection Service
//
// Allows players to resume their exact seat after WiFi drops.
// Chief Architect Audit: Prevents "new player" blocking issue.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Player reconnection state
enum ReconnectionState {
  connected,
  disconnected,
  reconnecting,
  replaced, // Bot took over
}

/// Room reconnection service
class RoomReconnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Attempt to reconnect to a room
  Future<ReconnectionResult> reconnect({
    required String roomCode,
    required String userId,
  }) async {
    final roomRef = _firestore.collection('matches').doc(roomCode);
    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      return ReconnectionResult.roomNotFound();
    }

    final roomData = roomDoc.data()!;
    final players = roomData['players'] as Map<String, dynamic>? ?? {};
    final disconnectedPlayers = roomData['disconnectedPlayers'] as Map<String, dynamic>? ?? {};

    // Check if user was previously in this room
    if (players.containsKey(userId)) {
      // Still in room, just reconnect
      await roomRef.update({
        'players.$userId.lastSeen': FieldValue.serverTimestamp(),
        'players.$userId.isConnected': true,
      });
      return ReconnectionResult.success(
        seat: players[userId]['seat'] as int,
        wasReplaced: false,
      );
    }

    // Check if user was disconnected and bot replaced them
    if (disconnectedPlayers.containsKey(userId)) {
      final disconnectedData = disconnectedPlayers[userId] as Map<String, dynamic>;
      final seat = disconnectedData['seat'] as int;
      final botId = disconnectedData['replacedBy'] as String?;

      // Remove bot and restore player
      if (botId != null) {
        await roomRef.update({
          'players.$botId': FieldValue.delete(),
          'players.$userId': {
            'userId': userId,
            'displayName': disconnectedData['displayName'],
            'seat': seat,
            'isHost': disconnectedData['isHost'] ?? false,
            'isAI': false,
            'isConnected': true,
            'lastSeen': FieldValue.serverTimestamp(),
            'hand': disconnectedData['hand'], // Restore their cards!
          },
          'disconnectedPlayers.$userId': FieldValue.delete(),
        });
      }

      return ReconnectionResult.success(
        seat: seat,
        wasReplaced: true,
      );
    }

    // User was never in this room
    return ReconnectionResult.notInRoom();
  }

  /// Mark player as disconnected (called when WiFi drops)
  Future<void> markDisconnected({
    required String roomCode,
    required String userId,
  }) async {
    final roomRef = _firestore.collection('matches').doc(roomCode);
    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) return;

    final roomData = roomDoc.data()!;
    final players = roomData['players'] as Map<String, dynamic>? ?? {};

    if (!players.containsKey(userId)) return;

    final playerData = players[userId] as Map<String, dynamic>;

    // Store disconnected player data
    await roomRef.update({
      'players.$userId.isConnected': false,
      'players.$userId.disconnectedAt': FieldValue.serverTimestamp(),
      'disconnectedPlayers.$userId': {
        'userId': userId,
        'displayName': playerData['displayName'],
        'seat': playerData['seat'],
        'isHost': playerData['isHost'],
        'hand': playerData['hand'],
        'disconnectedAt': FieldValue.serverTimestamp(),
      },
    });

    // Schedule bot replacement after 30 seconds
    // (This would be handled by a Cloud Function)
  }

  /// Spawn bot to replace disconnected player
  Future<void> spawnReplacementBot({
    required String roomCode,
    required String disconnectedUserId,
  }) async {
    final roomRef = _firestore.collection('matches').doc(roomCode);
    final roomDoc = await roomRef.get();

    if (!roomDoc.exists) return;

    final roomData = roomDoc.data()!;
    final disconnectedPlayers = roomData['disconnectedPlayers'] as Map<String, dynamic>? ?? {};

    if (!disconnectedPlayers.containsKey(disconnectedUserId)) return;

    final disconnectedData = disconnectedPlayers[disconnectedUserId] as Map<String, dynamic>;
    final botId = 'bot_${DateTime.now().millisecondsSinceEpoch}';

    // Create bot player with same cards
    await roomRef.update({
      'players.$disconnectedUserId': FieldValue.delete(),
      'players.$botId': {
        'userId': botId,
        'displayName': '🤖 ${disconnectedData['displayName']}',
        'seat': disconnectedData['seat'],
        'isHost': false,
        'isAI': true,
        'aiDifficulty': 'medium',
        'hand': disconnectedData['hand'],
        'replacedPlayer': disconnectedUserId,
      },
      'disconnectedPlayers.$disconnectedUserId.replacedBy': botId,
    });
  }
}

/// Result of reconnection attempt
class ReconnectionResult {
  final bool success;
  final int? seat;
  final bool? wasReplaced;
  final String? error;

  ReconnectionResult._({
    required this.success,
    this.seat,
    this.wasReplaced,
    this.error,
  });

  factory ReconnectionResult.success({
    required int seat,
    required bool wasReplaced,
  }) {
    return ReconnectionResult._(
      success: true,
      seat: seat,
      wasReplaced: wasReplaced,
    );
  }

  factory ReconnectionResult.roomNotFound() {
    return ReconnectionResult._(
      success: false,
      error: 'Room not found',
    );
  }

  factory ReconnectionResult.notInRoom() {
    return ReconnectionResult._(
      success: false,
      error: 'You were not in this room',
    );
  }
}

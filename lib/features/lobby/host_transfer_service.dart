// Host Transfer Service
//
// Handles automatic host transfer when host leaves.
// Prevents room abandonment when host disconnects.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Host transfer result status
enum HostTransferStatus { success, roomNotFound, noEligibleHost, roomAbandoned }

/// Result of host transfer attempt
class HostTransferResult {
  final HostTransferStatus status;
  final String? newHostId;
  final String? newHostName;
  final String? message;

  HostTransferResult._({
    required this.status,
    this.newHostId,
    this.newHostName,
    this.message,
  });

  factory HostTransferResult.success(String newHostId, String newHostName) =>
      HostTransferResult._(
        status: HostTransferStatus.success,
        newHostId: newHostId,
        newHostName: newHostName,
      );

  factory HostTransferResult.roomNotFound() => HostTransferResult._(
    status: HostTransferStatus.roomNotFound,
    message: 'Room not found',
  );

  factory HostTransferResult.noEligibleHost() => HostTransferResult._(
    status: HostTransferStatus.noEligibleHost,
    message: 'No eligible host found',
  );

  factory HostTransferResult.roomAbandoned() => HostTransferResult._(
    status: HostTransferStatus.roomAbandoned,
    message: 'Room abandoned - all players are bots',
  );

  bool get isSuccess => status == HostTransferStatus.success;
}

/// Host Transfer Service
class HostTransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Transfer host to next eligible player
  Future<HostTransferResult> transferHost(
    String roomId,
    String currentHostId,
  ) async {
    final roomRef = _firestore.collection('matches').doc(roomId);

    return await _firestore.runTransaction<HostTransferResult>((txn) async {
      final doc = await txn.get(roomRef);
      if (!doc.exists) {
        return HostTransferResult.roomNotFound();
      }

      final data = doc.data()!;
      final players = Map<String, dynamic>.from(data['players'] ?? {});

      // Find eligible new host (not a bot, still connected)
      String? newHostId;
      String? newHostName;

      for (final entry in players.entries) {
        final playerId = entry.key;
        final playerData = entry.value as Map<String, dynamic>;

        if (playerId != currentHostId &&
            playerData['isAI'] != true &&
            playerData['isConnected'] != false) {
          newHostId = playerId;
          newHostName = playerData['displayName'] as String? ?? 'Player';
          break;
        }
      }

      if (newHostId == null) {
        // Check if all remaining players are bots
        final humanCount = players.entries
            .where(
              (e) => e.key != currentHostId && (e.value as Map)['isAI'] != true,
            )
            .length;

        if (humanCount == 0) {
          // Mark room as abandoned
          txn.update(roomRef, {
            'status': 'abandoned',
            'abandonedAt': FieldValue.serverTimestamp(),
            'abandonReason': 'host_left_no_humans',
          });
          return HostTransferResult.roomAbandoned();
        }

        return HostTransferResult.noEligibleHost();
      }

      // Remove old host from players
      players.remove(currentHostId);

      // Update room with new host
      txn.update(roomRef, {
        'hostId': newHostId,
        'players': players,
        'hostTransferredAt': FieldValue.serverTimestamp(),
        'previousHostId': currentHostId,
      });

      // Log audit event
      txn.set(_firestore.collection('audit_logs').doc(), {
        'type': 'HOST_TRANSFER',
        'roomId': roomId,
        'fromHostId': currentHostId,
        'toHostId': newHostId,
        'toHostName': newHostName,
        'reason': 'host_left',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return HostTransferResult.success(newHostId, newHostName!);
    });
  }

  /// Handle host leaving during game
  Future<HostTransferResult> handleHostLeave(
    String roomId,
    String hostId,
  ) async {
    final result = await transferHost(roomId, hostId);

    if (result.isSuccess) {
      // Notify all players about new host
      await _notifyHostChange(roomId, result.newHostId!, result.newHostName!);
    }

    return result;
  }

  Future<void> _notifyHostChange(
    String roomId,
    String newHostId,
    String newHostName,
  ) async {
    // Update room with notification flag
    await _firestore.collection('matches').doc(roomId).update({
      'notifications': FieldValue.arrayUnion([
        {
          'type': 'HOST_CHANGED',
          'newHostId': newHostId,
          'newHostName': newHostName,
          'message': '$newHostName is now the host',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ]),
    });
  }

  /// Check if user is eligible to become host
  Future<bool> canBecomeHost(String roomId, String userId) async {
    final doc = await _firestore.collection('matches').doc(roomId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    final players = Map<String, dynamic>.from(data['players'] ?? {});

    if (!players.containsKey(userId)) return false;

    final playerData = players[userId] as Map<String, dynamic>;
    return playerData['isAI'] != true && playerData['isConnected'] != false;
  }

  /// Voluntarily transfer host to another player
  Future<HostTransferResult> voluntaryTransfer(
    String roomId,
    String currentHostId,
    String newHostId,
  ) async {
    final roomRef = _firestore.collection('matches').doc(roomId);

    return await _firestore.runTransaction<HostTransferResult>((txn) async {
      final doc = await txn.get(roomRef);
      if (!doc.exists) {
        return HostTransferResult.roomNotFound();
      }

      final data = doc.data()!;

      // Verify current user is host
      if (data['hostId'] != currentHostId) {
        return HostTransferResult.noEligibleHost();
      }

      final players = Map<String, dynamic>.from(data['players'] ?? {});

      // Verify new host is in room and eligible
      if (!players.containsKey(newHostId)) {
        return HostTransferResult.noEligibleHost();
      }

      final newHostData = players[newHostId] as Map<String, dynamic>;
      if (newHostData['isAI'] == true) {
        return HostTransferResult.noEligibleHost();
      }

      final newHostName = newHostData['displayName'] as String? ?? 'Player';

      // Transfer host
      txn.update(roomRef, {
        'hostId': newHostId,
        'hostTransferredAt': FieldValue.serverTimestamp(),
        'previousHostId': currentHostId,
      });

      // Log
      txn.set(_firestore.collection('audit_logs').doc(), {
        'type': 'HOST_TRANSFER',
        'roomId': roomId,
        'fromHostId': currentHostId,
        'toHostId': newHostId,
        'reason': 'voluntary',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return HostTransferResult.success(newHostId, newHostName);
    });
  }
}

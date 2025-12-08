/// Invite Service
/// 
/// Manages game invitations between users.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Provider for InviteService
final inviteServiceProvider = Provider<InviteService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return InviteService(authService);
});

/// Provider for watching incoming invites
final myInvitesProvider = StreamProvider<List<GameInvite>>((ref) {
  final inviteService = ref.watch(inviteServiceProvider);
  final userId = ref.watch(authServiceProvider).currentUser?.uid;
  if (userId == null) return Stream.value([]);
  return inviteService.watchMyInvites(userId);
});

/// Invite status
enum InviteStatus {
  pending,
  accepted,
  declined,
  expired,
}

/// Game invitation data
class GameInvite {
  final String id;
  final String fromUserId;
  final String fromDisplayName;
  final String? fromAvatarUrl;
  final String toUserId;
  final String roomId;
  final String? roomCode;
  final String gameType;
  final InviteStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  GameInvite({
    required this.id,
    required this.fromUserId,
    required this.fromDisplayName,
    this.fromAvatarUrl,
    required this.toUserId,
    required this.roomId,
    this.roomCode,
    required this.gameType,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory GameInvite.fromJson(Map<String, dynamic> json, String id) {
    return GameInvite(
      id: id,
      fromUserId: json['fromUserId'] ?? '',
      fromDisplayName: json['fromDisplayName'] ?? 'Player',
      fromAvatarUrl: json['fromAvatarUrl'],
      toUserId: json['toUserId'] ?? '',
      roomId: json['roomId'] ?? '',
      roomCode: json['roomCode'],
      gameType: json['gameType'] ?? 'unknown',
      status: InviteStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InviteStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (json['expiresAt'] as Timestamp?)?.toDate() ?? 
                 DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Service for managing game invitations
class InviteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;

  /// Invite expiration time in minutes
  static const int inviteExpirationMinutes = 5;

  InviteService(this._authService);

  /// Send a game invite
  Future<bool> sendInvite({
    required String toUserId,
    required String roomId,
    String? roomCode,
    required String gameType,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    try {
      // Check for existing pending invite
      final existing = await _db
          .collection('invites')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: toUserId)
          .where('roomId', isEqualTo: roomId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('Invite already sent');
        return false;
      }

      final expiresAt = DateTime.now().add(
        Duration(minutes: inviteExpirationMinutes),
      );

      await _db.collection('invites').add({
        'fromUserId': currentUser.uid,
        'fromDisplayName': currentUser.displayName ?? 'Player',
        'fromAvatarUrl': currentUser.photoURL,
        'toUserId': toUserId,
        'roomId': roomId,
        'roomCode': roomCode,
        'gameType': gameType,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });

      debugPrint('Invite sent to $toUserId for room $roomId');
      return true;
    } catch (e) {
      debugPrint('Error sending invite: $e');
      return false;
    }
  }

  /// Accept an invite
  Future<String?> acceptInvite(String inviteId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;

    try {
      final inviteDoc = await _db.collection('invites').doc(inviteId).get();
      if (!inviteDoc.exists) return null;

      final invite = GameInvite.fromJson(inviteDoc.data()!, inviteId);

      // Verify invite is for current user
      if (invite.toUserId != currentUser.uid) return null;

      // Check if expired
      if (invite.isExpired) {
        await _db.collection('invites').doc(inviteId).update({
          'status': 'expired',
        });
        return null;
      }

      // Update status
      await _db.collection('invites').doc(inviteId).update({
        'status': 'accepted',
      });

      return invite.roomId;
    } catch (e) {
      debugPrint('Error accepting invite: $e');
      return null;
    }
  }

  /// Decline an invite
  Future<bool> declineInvite(String inviteId) async {
    try {
      await _db.collection('invites').doc(inviteId).update({
        'status': 'declined',
      });
      return true;
    } catch (e) {
      debugPrint('Error declining invite: $e');
      return false;
    }
  }

  /// Watch incoming invites for a user
  Stream<List<GameInvite>> watchMyInvites(String userId) {
    return _db
        .collection('invites')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) => GameInvite.fromJson(doc.data(), doc.id))
              .where((invite) => !invite.isExpired) // Filter expired
              .toList();
        });
  }

  /// Get invite by ID
  Future<GameInvite?> getInvite(String inviteId) async {
    try {
      final doc = await _db.collection('invites').doc(inviteId).get();
      if (!doc.exists) return null;
      return GameInvite.fromJson(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Invite multiple friends at once
  Future<int> inviteFriends({
    required List<String> friendIds,
    required String roomId,
    String? roomCode,
    required String gameType,
  }) async {
    int successCount = 0;
    
    for (final friendId in friendIds) {
      final success = await sendInvite(
        toUserId: friendId,
        roomId: roomId,
        roomCode: roomCode,
        gameType: gameType,
      );
      if (success) successCount++;
    }
    
    return successCount;
  }

  /// Cancel a sent invite
  Future<bool> cancelInvite(String inviteId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    try {
      final inviteDoc = await _db.collection('invites').doc(inviteId).get();
      if (!inviteDoc.exists) return false;

      final data = inviteDoc.data()!;
      if (data['fromUserId'] != currentUser.uid) return false;

      await _db.collection('invites').doc(inviteId).delete();
      return true;
    } catch (e) {
      debugPrint('Error canceling invite: $e');
      return false;
    }
  }

  /// Cleanup expired invites (can be run periodically)
  Future<void> cleanupExpiredInvites() async {
    try {
      final now = DateTime.now();
      final expiredInvites = await _db
          .collection('invites')
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      final batch = _db.batch();
      for (final doc in expiredInvites.docs) {
        batch.update(doc.reference, {'status': 'expired'});
      }
      await batch.commit();

      debugPrint('Cleaned up ${expiredInvites.docs.length} expired invites');
    } catch (e) {
      debugPrint('Error cleaning up expired invites: $e');
    }
  }
}

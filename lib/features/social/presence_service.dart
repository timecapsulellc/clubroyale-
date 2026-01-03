/// Presence Service
///
/// Tracks user online/offline status in real-time using Firestore.
/// Uses Firestore's offline capabilities for presence detection.
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Provider for PresenceService
final presenceServiceProvider = Provider<PresenceService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return PresenceService(authService);
});

/// Provider for watching online users
final onlineUsersProvider = StreamProvider<List<UserPresence>>((ref) {
  final presenceService = ref.watch(presenceServiceProvider);
  return presenceService.watchOnlineUsers();
});

/// User presence data
class UserPresence {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime lastSeen;
  final String? currentGameId;
  final String? currentGameType;

  UserPresence({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.isOnline,
    required this.lastSeen,
    this.currentGameId,
    this.currentGameType,
  });

  factory UserPresence.fromJson(Map<String, dynamic> json, String oderId) {
    return UserPresence(
      userId: oderId,
      displayName: json['displayName'] ?? 'Player',
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: (json['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentGameId: json['currentGameId'],
      currentGameType: json['currentGameType'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'isOnline': isOnline,
    'lastSeen': FieldValue.serverTimestamp(),
    'currentGameId': currentGameId,
    'currentGameType': currentGameType,
  };
}

/// Service for managing user presence (online/offline status)
class PresenceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;
  Timer? _heartbeatTimer;
  bool _isTracking = false;

  PresenceService(this._authService);

  /// Start tracking presence for current user
  Future<void> startTracking() async {
    if (_isTracking) return;

    final user = _authService.currentUser;
    if (user == null) return;

    _isTracking = true;
    await _setOnline(user.uid, user.displayName ?? 'Player');

    // Heartbeat every 30 seconds to maintain online status
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateHeartbeat(user.uid);
    });

    debugPrint('Presence tracking started for ${user.uid}');
  }

  /// Stop tracking presence
  Future<void> stopTracking() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _isTracking = false;

    final user = _authService.currentUser;
    if (user != null) {
      await _setOffline(user.uid);
    }

    debugPrint('Presence tracking stopped');
  }

  /// Set user as online
  Future<void> _setOnline(String userId, String displayName) async {
    try {
      await _db.collection('presence').doc(userId).set({
        'userId': userId,
        'displayName': displayName,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'currentGameId': null,
        'currentGameType': null,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error setting online: $e');
    }
  }

  /// Set user as offline
  Future<void> _setOffline(String userId) async {
    try {
      await _db.collection('presence').doc(userId).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'currentGameId': null,
      });
    } catch (e) {
      debugPrint('Error setting offline: $e');
    }
  }

  /// Update heartbeat timestamp
  Future<void> _updateHeartbeat(String userId) async {
    try {
      await _db.collection('presence').doc(userId).update({
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
      });
    } catch (e) {
      debugPrint('Error updating heartbeat: $e');
    }
  }

  /// Set current game (when user joins a room)
  Future<void> setCurrentGame(
    String userId,
    String gameId,
    String gameType,
  ) async {
    try {
      await _db.collection('presence').doc(userId).update({
        'currentGameId': gameId,
        'currentGameType': gameType,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error setting current game: $e');
    }
  }

  /// Clear current game (when user leaves a room)
  Future<void> clearCurrentGame(String userId) async {
    try {
      await _db.collection('presence').doc(userId).update({
        'currentGameId': null,
        'currentGameType': null,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error clearing current game: $e');
    }
  }

  /// Watch all online users (excluding current user)
  Stream<List<UserPresence>> watchOnlineUsers() {
    final currentUserId = _authService.currentUser?.uid;

    return _db
        .collection('presence')
        .where('isOnline', isEqualTo: true)
        .orderBy('lastSeen', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => doc.id != currentUserId)
              .map((doc) => UserPresence.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Watch specific user's presence
  Stream<UserPresence?> watchUserPresence(String userId) {
    return _db.collection('presence').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserPresence.fromJson(doc.data()!, doc.id);
    });
  }

  /// Get online user count
  Future<int> getOnlineUserCount() async {
    try {
      final snapshot = await _db
          .collection('presence')
          .where('isOnline', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting online count: $e');
      return 0;
    }
  }

  /// Check if a user is online (with 2-minute timeout)
  bool isUserOnline(UserPresence presence) {
    if (!presence.isOnline) return false;

    final now = DateTime.now();
    final diff = now.difference(presence.lastSeen);

    // Consider offline if no heartbeat for 2 minutes
    return diff.inMinutes < 2;
  }

  /// Cleanup stale presence records (run periodically or via Cloud Function)
  Future<void> cleanupStalePresence() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(minutes: 5));

      final staleUsers = await _db
          .collection('presence')
          .where('isOnline', isEqualTo: true)
          .where('lastSeen', isLessThan: Timestamp.fromDate(cutoff))
          .get();

      final batch = _db.batch();
      for (final doc in staleUsers.docs) {
        batch.update(doc.reference, {'isOnline': false});
      }
      await batch.commit();

      debugPrint('Cleaned up ${staleUsers.docs.length} stale presence records');
    } catch (e) {
      debugPrint('Error cleaning up stale presence: $e');
    }
  }
}

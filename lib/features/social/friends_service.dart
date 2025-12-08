/// Friends Service
/// 
/// Manages friend relationships: sending requests, accepting, listing friends.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Provider for FriendsService
final friendsServiceProvider = Provider<FriendsService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return FriendsService(authService);
});

/// Provider for watching current user's friends
final myFriendsProvider = StreamProvider<List<Friend>>((ref) {
  final friendsService = ref.watch(friendsServiceProvider);
  final userId = ref.watch(authServiceProvider).currentUser?.uid;
  if (userId == null) return Stream.value([]);
  return friendsService.watchFriends(userId);
});

/// Provider for watching pending friend requests
final pendingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final friendsService = ref.watch(friendsServiceProvider);
  final userId = ref.watch(authServiceProvider).currentUser?.uid;
  if (userId == null) return Stream.value([]);
  return friendsService.watchPendingRequests(userId);
});

/// Friend relationship status
enum FriendStatus {
  pending,
  accepted,
  blocked,
}

/// Friend data model
class Friend {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final FriendStatus status;
  final DateTime addedAt;
  final bool isOnline;

  Friend({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.status,
    required this.addedAt,
    this.isOnline = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json, String oderId) {
    return Friend(
      userId: oderId,
      displayName: json['displayName'] ?? 'Player',
      avatarUrl: json['avatarUrl'],
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      addedAt: (json['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnline: json['isOnline'] ?? false,
    );
  }
}

/// Friend request data
class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromDisplayName;
  final String? fromAvatarUrl;
  final String toUserId;
  final FriendStatus status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromDisplayName,
    this.fromAvatarUrl,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json, String id) {
    return FriendRequest(
      id: id,
      fromUserId: json['fromUserId'] ?? '',
      fromDisplayName: json['fromDisplayName'] ?? 'Player',
      fromAvatarUrl: json['fromAvatarUrl'],
      toUserId: json['toUserId'] ?? '',
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Service for managing friend relationships
class FriendsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;

  FriendsService(this._authService);

  /// Send a friend request
  Future<bool> sendFriendRequest(String toUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    try {
      // Check if request already exists
      final existing = await _db
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('Friend request already exists');
        return false;
      }

      // Check if already friends
      final alreadyFriends = await _db
          .collection('friends')
          .doc(currentUser.uid)
          .collection('list')
          .doc(toUserId)
          .get();

      if (alreadyFriends.exists && 
          alreadyFriends.data()?['status'] == 'accepted') {
        debugPrint('Already friends');
        return false;
      }

      // Create friend request
      await _db.collection('friendRequests').add({
        'fromUserId': currentUser.uid,
        'fromDisplayName': currentUser.displayName ?? 'Player',
        'fromAvatarUrl': currentUser.photoURL,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Friend request sent to $toUserId');
      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    try {
      // Get the request
      final requestDoc = await _db.collection('friendRequests').doc(requestId).get();
      if (!requestDoc.exists) return false;

      final request = FriendRequest.fromJson(requestDoc.data()!, requestId);
      
      // Verify this request is for current user
      if (request.toUserId != currentUser.uid) return false;

      // Update request status
      await _db.collection('friendRequests').doc(requestId).update({
        'status': 'accepted',
      });

      // Add to both users' friend lists
      final batch = _db.batch();

      // Add to current user's friend list
      batch.set(
        _db.collection('friends').doc(currentUser.uid).collection('list').doc(request.fromUserId),
        {
          'displayName': request.fromDisplayName,
          'avatarUrl': request.fromAvatarUrl,
          'status': 'accepted',
          'addedAt': FieldValue.serverTimestamp(),
        },
      );

      // Add current user to sender's friend list
      batch.set(
        _db.collection('friends').doc(request.fromUserId).collection('list').doc(currentUser.uid),
        {
          'displayName': currentUser.displayName ?? 'Player',
          'avatarUrl': currentUser.photoURL,
          'status': 'accepted',
          'addedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      debugPrint('Friend request accepted');
      return true;
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  /// Decline a friend request
  Future<bool> declineFriendRequest(String requestId) async {
    try {
      await _db.collection('friendRequests').doc(requestId).update({
        'status': 'declined',
      });
      return true;
    } catch (e) {
      debugPrint('Error declining friend request: $e');
      return false;
    }
  }

  /// Remove a friend
  Future<bool> removeFriend(String friendId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    try {
      final batch = _db.batch();

      // Remove from current user's list
      batch.delete(
        _db.collection('friends').doc(currentUser.uid).collection('list').doc(friendId),
      );

      // Remove from friend's list
      batch.delete(
        _db.collection('friends').doc(friendId).collection('list').doc(currentUser.uid),
      );

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error removing friend: $e');
      return false;
    }
  }

  /// Watch user's friends list
  Stream<List<Friend>> watchFriends(String userId) {
    return _db
        .collection('friends')
        .doc(userId)
        .collection('list')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Friend.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Watch pending friend requests (received)
  Stream<List<FriendRequest>> watchPendingRequests(String userId) {
    return _db
        .collection('friendRequests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FriendRequest.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Check if two users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final doc = await _db
          .collection('friends')
          .doc(userId1)
          .collection('list')
          .doc(userId2)
          .get();

      return doc.exists && doc.data()?['status'] == 'accepted';
    } catch (e) {
      return false;
    }
  }

  /// Get friend count
  Future<int> getFriendCount(String userId) async {
    try {
      final snapshot = await _db
          .collection('friends')
          .doc(userId)
          .collection('list')
          .where('status', isEqualTo: 'accepted')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/social/voice_rooms/models/voice_room.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/social/models/social_activity.dart';
import 'package:clubroyale/features/social/models/social_activity.dart';

// Unread chats count provider
final unreadChatsCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(0);
  
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: userId)
      .where('unreadBy', arrayContains: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Online friends count provider
final onlineFriendsCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(0);
  
  // Note: Firestore doesn't support subcollection queries across parents easily without collection groups
  // But here we query a specific user's friends subcollection
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('friends')
      .where('isOnline', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Active voice rooms provider
final activeVoiceRoomsProvider = StreamProvider<List<VoiceRoom>>((ref) {
  return FirebaseFirestore.instance
      .collection('voice_rooms')
      .where('isActive', isEqualTo: true)
      .orderBy('participantCount', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => VoiceRoom.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

// Spectatable games provider
final spectatorGamesProvider = StreamProvider<List<GameRoom>>((ref) {
  return FirebaseFirestore.instance
      .collection('games')
      .where('status', isEqualTo: 'playing')
      .where('allowSpectators', isEqualTo: true)
      .orderBy('spectatorCount', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => GameRoom.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

// Pending friend requests provider
final pendingFriendRequestsProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(0);
  
  return FirebaseFirestore.instance
      .collection('friendships')
      .where('toUserId', isEqualTo: userId)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

// Activity feed provider
final activityFeedProvider = StreamProvider.family<List<SocialActivity>, int>((ref, limit) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('activity_feed')
      .where('targetUserId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(limit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SocialActivity.fromFirestore(doc))
          .toList());
});

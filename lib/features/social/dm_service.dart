/// Direct Messages Service
/// 
/// Private 1:1 messaging between friends.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Provider for DM service
final dmServiceProvider = Provider<DirectMessageService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return DirectMessageService(authService);
});

/// Provider for watching conversations
final myConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final dmService = ref.watch(dmServiceProvider);
  final userId = ref.watch(authServiceProvider).currentUser?.uid;
  if (userId == null) return Stream.value([]);
  return dmService.watchConversations(userId);
});

/// Direct message
class DirectMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  DirectMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json, String id) {
    return DirectMessage(
      id: id,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Player',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

/// Conversation (chat thread with another user)
class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String id, String currentUserId) {
    // Determine which user is "other"
    final participants = List<String>.from(json['participants'] ?? []);
    final otherUserId = participants.firstWhere((p) => p != currentUserId, orElse: () => '');
    
    return Conversation(
      id: id,
      otherUserId: otherUserId,
      otherUserName: json['participantNames']?[otherUserId] ?? 'Player',
      otherUserAvatar: json['participantAvatars']?[otherUserId],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: json['unreadCount_$currentUserId'] ?? 0,
    );
  }
}

/// Service for direct messaging
class DirectMessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final AuthService _authService;

  DirectMessageService(this._authService);

  /// Get or create conversation between two users
  Future<String> getOrCreateConversation(String otherUserId, String otherUserName) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    // Create sorted participant list for consistent ID
    final participants = [currentUser.uid, otherUserId]..sort();
    final conversationId = '${participants[0]}_${participants[1]}';

    final docRef = _db.collection('conversations').doc(conversationId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create new conversation
      await docRef.set({
        'participants': participants,
        'participantNames': {
          currentUser.uid: currentUser.displayName ?? 'Player',
          otherUserId: otherUserName,
        },
        'participantAvatars': {
          currentUser.uid: currentUser.photoURL,
          otherUserId: null,
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCount_${currentUser.uid}': 0,
        'unreadCount_$otherUserId': 0,
      });
    }

    return conversationId;
  }

  /// Send a direct message
  Future<bool> sendMessage(String conversationId, String content) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    if (content.trim().isEmpty || content.length > 500) return false;

    try {
      // Moderate message
      final isAllowed = await _moderateMessage(content);
      if (!isAllowed) return false;

      // Add message
      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Player',
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update conversation metadata
      final docRef = _db.collection('conversations').doc(conversationId);
      final doc = await docRef.get();
      final participants = List<String>.from(doc.data()?['participants'] ?? []);
      final otherUserId = participants.firstWhere((p) => p != currentUser.uid, orElse: () => '');

      await docRef.update({
        'lastMessage': content.length > 50 ? '${content.substring(0, 50)}...' : content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount_$otherUserId': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      debugPrint('Error sending DM: $e');
      return false;
    }
  }

  /// Watch messages in a conversation
  Stream<List<DirectMessage>> watchMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DirectMessage.fromJson(doc.data(), doc.id))
              .toList()
              .reversed
              .toList();
        });
  }

  /// Watch all conversations for a user
  Stream<List<Conversation>> watchConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Conversation.fromJson(doc.data(), doc.id, userId))
              .toList();
        });
  }

  /// Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    await _db.collection('conversations').doc(conversationId).update({
      'unreadCount_${currentUser.uid}': 0,
    });
  }

  /// Moderate message using GenKit
  Future<bool> _moderateMessage(String content) async {
    try {
      final callable = _functions.httpsCallable('moderateChat');
      final result = await callable.call<Map<String, dynamic>>({
        'message': content,
        'senderName': _authService.currentUser?.displayName ?? 'Player',
        'roomId': 'dm',
        'recentMessages': <String>[],
      });
      return result.data['isAllowed'] == true;
    } catch (e) {
      return true; // Fail open
    }
  }
}

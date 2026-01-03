/// Global Lobby Chat Service
///
/// Chat for users in the lobby area (not in a game room).
/// Uses GenKit moderation for content filtering.
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/chat/chat_message.dart';

/// Provider for lobby chat service
final lobbyChatServiceProvider =
    Provider.family<LobbyChatService, LobbyChatParams>(
      (ref, params) =>
          LobbyChatService(userId: params.userId, userName: params.userName),
    );

/// Provider for lobby chat messages
final lobbyChatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final service = LobbyChatService(userId: '', userName: '');
  return service.messagesStream;
});

class LobbyChatParams {
  final String userId;
  final String userName;

  LobbyChatParams({required this.userId, required this.userName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LobbyChatParams && userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

/// Service for global lobby chat
class LobbyChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final String userId;
  final String userName;

  LobbyChatService({required this.userId, required this.userName});

  /// Reference to lobby chat collection
  CollectionReference<Map<String, dynamic>> get _chatRef =>
      _firestore.collection('lobby_chat');

  /// Stream of lobby chat messages
  Stream<List<ChatMessage>> get messagesStream {
    return _chatRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList()
              .reversed
              .toList(),
        );
  }

  /// Send a message to lobby chat
  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty || content.length > 200) {
      return false;
    }

    try {
      // Moderate message using GenKit
      final moderationResult = await _moderateMessage(content);
      if (!moderationResult['isAllowed']) {
        return false;
      }

      final finalContent = moderationResult['editedMessage'] ?? content;

      final message = ChatMessage(
        senderId: userId,
        senderName: userName,
        content: finalContent,
        type: MessageType.text,
      );

      await _chatRef.add(message.toFirestore());
      return true;
    } catch (e) {
      // Fail open - allow if moderation fails
      final message = ChatMessage(
        senderId: userId,
        senderName: userName,
        content: content,
        type: MessageType.text,
      );
      await _chatRef.add(message.toFirestore());
      return true;
    }
  }

  /// Moderate using GenKit
  Future<Map<String, dynamic>> _moderateMessage(String content) async {
    try {
      final callable = _functions.httpsCallable('moderateChat');
      final result = await callable.call<Map<String, dynamic>>({
        'message': content,
        'senderName': userName,
        'roomId': 'lobby',
        'recentMessages': <String>[],
      });
      return result.data;
    } catch (e) {
      return {'isAllowed': true};
    }
  }

  /// Clean up old messages (keep last 200)
  Future<void> cleanupOldMessages() async {
    final snapshot = await _chatRef
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .get();

    if (snapshot.docs.length > 200) {
      final batch = _firestore.batch();
      for (int i = 200; i < snapshot.docs.length; i++) {
        batch.delete(snapshot.docs[i].reference);
      }
      await batch.commit();
    }
  }
}

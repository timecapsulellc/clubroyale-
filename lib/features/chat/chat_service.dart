import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_message.dart';

/// Service for managing in-game chat
class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final String roomId;
  final String userId;
  final String userName;

  // Cache for recent messages (for spam detection)
  final List<String> _recentMessages = [];
  static const int _recentMessageLimit = 5;

  ChatService({
    required this.roomId,
    required this.userId,
    required this.userName,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  /// Get reference to chat collection
  CollectionReference<Map<String, dynamic>> get _chatRef =>
      _firestore.collection('games').doc(roomId).collection('chat');

  /// Stream of chat messages (real-time)
  Stream<List<ChatMessage>> get messagesStream {
    return _chatRef
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit to last 100 messages
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .where((msg) => !msg.isDeleted) // Filter deleted messages
              .toList()
              .reversed // Reverse to show oldest first in UI
              .toList(),
        );
  }

  /// Send a text message
  Future<SendResult> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      return SendResult(success: false, reason: 'Message cannot be empty');
    }

    if (content.length > 500) {
      return SendResult(
        success: false,
        reason: 'Message too long (max 500 chars)',
      );
    }

    // Check for AI moderation
    try {
      final moderationResult = await _moderateMessage(content);

      if (!moderationResult.isAllowed) {
        return SendResult(
          success: false,
          reason: moderationResult.reason ?? 'Message blocked by moderation',
          wasModerated: true,
        );
      }

      // Use edited message if provided (censored version)
      final finalContent = moderationResult.editedMessage ?? content;

      // Add to Firestore
      final message = ChatMessage(
        senderId: userId,
        senderName: userName,
        content: finalContent,
        type: MessageType.text,
      );

      await _chatRef.add(message.toFirestore());

      // Track for spam detection
      _trackMessage(content);

      return SendResult(success: true);
    } catch (e) {
      // If moderation fails, still send (fail open for UX)
      final message = ChatMessage(
        senderId: userId,
        senderName: userName,
        content: content,
        type: MessageType.text,
      );

      await _chatRef.add(message.toFirestore());
      return SendResult(success: true);
    }
  }

  /// Send a quick emoji (no moderation needed)
  Future<void> sendQuickEmoji(String emoji) async {
    final message = ChatMessage(
      senderId: userId,
      senderName: userName,
      content: emoji,
      type: MessageType.emoji,
    );

    await _chatRef.add(message.toFirestore());
  }

  /// Send a system message (for game events)
  Future<void> sendSystemMessage(String content) async {
    final message = ChatMessage(
      senderId: 'system',
      senderName: 'System',
      content: content,
      type: MessageType.system,
    );

    await _chatRef.add(message.toFirestore());
  }

  /// Send a game event message
  Future<void> sendGameEvent(String event) async {
    final message = ChatMessage(
      senderId: 'game',
      senderName: 'Game',
      content: event,
      type: MessageType.gameEvent,
    );

    await _chatRef.add(message.toFirestore());
  }

  /// Reply to a message
  Future<SendResult> replyToMessage(
    String content,
    ChatMessage originalMessage,
  ) async {
    if (content.trim().isEmpty) {
      return SendResult(success: false, reason: 'Reply cannot be empty');
    }

    // Moderate the reply
    final moderationResult = await _moderateMessage(content);

    if (!moderationResult.isAllowed) {
      return SendResult(
        success: false,
        reason: moderationResult.reason ?? 'Reply blocked',
        wasModerated: true,
      );
    }

    final finalContent = moderationResult.editedMessage ?? content;

    final message = ChatMessage(
      senderId: userId,
      senderName: userName,
      content: finalContent,
      type: MessageType.text,
      replyToId: originalMessage.id,
      replyPreview: originalMessage.content.length > 50
          ? '${originalMessage.content.substring(0, 50)}...'
          : originalMessage.content,
    );

    await _chatRef.add(message.toFirestore());
    return SendResult(success: true);
  }

  /// Add reaction to a message
  Future<void> addReaction(String messageId, String emoji) async {
    await _chatRef.doc(messageId).update({'reactions.$userId': emoji});
  }

  /// Remove reaction from a message
  Future<void> removeReaction(String messageId) async {
    await _chatRef.doc(messageId).update({
      'reactions.$userId': FieldValue.delete(),
    });
  }

  /// Delete a message (admin only or own message)
  Future<void> deleteMessage(String messageId, {bool isAdmin = false}) async {
    final doc = await _chatRef.doc(messageId).get();
    final message = ChatMessage.fromFirestore(doc);

    // Only allow deletion of own messages or if admin
    if (message.senderId == userId || isAdmin) {
      await _chatRef.doc(messageId).update({
        'isDeleted': true,
        'content': '[Message deleted]',
      });
    }
  }

  /// Mark a message as read by the current user
  Future<void> markAsRead(String messageId) async {
    await _chatRef.doc(messageId).update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }

  /// Mark multiple messages as read
  Future<void> markMultipleAsRead(List<String> messageIds) async {
    final batch = _firestore.batch();
    for (final id in messageIds) {
      batch.update(_chatRef.doc(id), {
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
    await batch.commit();
  }

  /// Set typing indicator for current user
  Future<void> setTyping(bool isTyping) async {
    final typingRef = _firestore
        .collection('games')
        .doc(roomId)
        .collection('typing')
        .doc(userId);

    if (isTyping) {
      await typingRef.set({
        'userId': userId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await typingRef.delete();
    }
  }

  /// Stream of currently typing users
  Stream<List<TypingUser>> get typingUsersStream {
    return _firestore
        .collection('games')
        .doc(roomId)
        .collection('typing')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .where((doc) => doc.id != userId) // Exclude self
              .map((doc) {
                final data = doc.data();
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                // Only include if typed within last 5 seconds
                if (timestamp != null &&
                    DateTime.now().difference(timestamp).inSeconds < 5) {
                  return TypingUser(
                    userId: doc.id,
                    userName: data['userName'] as String? ?? 'Someone',
                  );
                }
                return null;
              })
              .whereType<TypingUser>()
              .toList(),
        );
  }

  /// Edit a message (only own messages)
  Future<void> editMessage(String messageId, String newContent) async {
    final doc = await _chatRef.doc(messageId).get();
    final message = ChatMessage.fromFirestore(doc);

    if (message.senderId == userId) {
      // Moderate the edited message
      final moderationResult = await _moderateMessage(newContent);
      if (!moderationResult.isAllowed) {
        throw Exception(moderationResult.reason ?? 'Edit blocked');
      }

      final finalContent = moderationResult.editedMessage ?? newContent;

      await _chatRef.doc(messageId).update({
        'content': finalContent,
        'isEdited': true,
      });
    }
  }

  /// Moderate a message using AI
  Future<ModerationResult> _moderateMessage(String content) async {
    try {
      final callable = _functions.httpsCallable('moderateChat');
      final result = await callable.call<Map<String, dynamic>>({
        'message': content,
        'senderName': userName,
        'roomId': roomId,
        'recentMessages': _recentMessages,
      });

      final data = result.data;
      return ModerationResult(
        isAllowed: data['isAllowed'] as bool,
        reason: data['reason'] as String?,
        category: data['category'] as String,
        action: data['action'] as String,
        editedMessage: data['editedMessage'] as String?,
      );
    } catch (e) {
      // Fail open - allow message if moderation service is down
      return ModerationResult(
        isAllowed: true,
        category: 'unknown',
        action: 'allow',
      );
    }
  }

  /// Track message for spam detection
  void _trackMessage(String content) {
    _recentMessages.add(content);
    if (_recentMessages.length > _recentMessageLimit) {
      _recentMessages.removeAt(0);
    }
  }

  /// Clear chat history (admin only)
  Future<void> clearChat() async {
    final batch = _firestore.batch();
    final messages = await _chatRef.get();

    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

/// Result of sending a message
class SendResult {
  final bool success;
  final String? reason;
  final bool wasModerated;

  SendResult({required this.success, this.reason, this.wasModerated = false});
}

/// Result from AI moderation
class ModerationResult {
  final bool isAllowed;
  final String? reason;
  final String category;
  final String action;
  final String? editedMessage;

  ModerationResult({
    required this.isAllowed,
    this.reason,
    required this.category,
    required this.action,
    this.editedMessage,
  });
}

/// Typing user info
class TypingUser {
  final String userId;
  final String userName;

  TypingUser({required this.userId, required this.userName});
}

// =====================================================
// RIVERPOD PROVIDERS
// =====================================================

/// Parameters for chat service
class ChatServiceParams {
  final String roomId;
  final String userId;
  final String userName;

  ChatServiceParams({
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatServiceParams &&
          roomId == other.roomId &&
          userId == other.userId;

  @override
  int get hashCode => roomId.hashCode ^ userId.hashCode;
}

/// Provider for chat service
final chatServiceProvider = Provider.family<ChatService, ChatServiceParams>(
  (ref, params) => ChatService(
    roomId: params.roomId,
    userId: params.userId,
    userName: params.userName,
  ),
);

/// Provider for chat messages stream
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessage>, ChatServiceParams>((ref, params) {
      final chatService = ref.watch(chatServiceProvider(params));
      return chatService.messagesStream;
    });

/// Provider for typing users stream
final typingUsersProvider =
    StreamProvider.family<List<TypingUser>, ChatServiceParams>((ref, params) {
      final chatService = ref.watch(chatServiceProvider(params));
      return chatService.typingUsersStream;
    });

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Chat message model for Firestore
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    /// Firestore document ID
    String? id,

    /// Sender user ID
    required String senderId,

    /// Sender display name
    required String senderName,

    /// Message content
    required String content,

    /// Message type
    @Default(MessageType.text) MessageType type,

    /// Emoji reactions (userId -> emoji)
    @Default({}) Map<String, String> reactions,

    /// Whether message was moderated/blocked
    @Default(false) bool isModerated,

    /// Moderation reason if blocked
    String? moderationReason,

    /// Timestamp when sent
    DateTime? timestamp,

    /// Whether message is deleted (soft delete)
    @Default(false) bool isDeleted,

    /// ID of message being replied to
    String? replyToId,

    /// Preview of replied message
    String? replyPreview,

    /// List of user IDs who have read this message
    @Default([]) List<String> readBy,

    /// Whether message was edited
    @Default(false) bool isEdited,

    /// Original sender photo URL for display
    String? senderPhotoUrl,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Create from Firestore document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      content: data['content'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MessageType.text,
      ),
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      isModerated: data['isModerated'] as bool? ?? false,
      moderationReason: data['moderationReason'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      replyToId: data['replyToId'] as String?,
      replyPreview: data['replyPreview'] as String?,
      readBy: List<String>.from(data['readBy'] ?? []),
      isEdited: data['isEdited'] as bool? ?? false,
      senderPhotoUrl: data['senderPhotoUrl'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.name,
      'reactions': reactions,
      'isModerated': isModerated,
      'moderationReason': moderationReason,
      'timestamp': FieldValue.serverTimestamp(),
      'isDeleted': isDeleted,
      'replyToId': replyToId,
      'replyPreview': replyPreview,
      'readBy': readBy,
      'isEdited': isEdited,
      'senderPhotoUrl': senderPhotoUrl,
    };
  }
}

/// Type of chat message
enum MessageType {
  text, // Regular text message
  emoji, // Single emoji (quick emoji)
  system, // System message (player joined, etc.)
  gameEvent, // Game event (trick won, round started)
}

/// Quick emoji reactions available in chat
class QuickEmojis {
  static const List<String> reactions = [
    '👍',
    '👎',
    '😂',
    '😮',
    '😢',
    '🔥',
    '💯',
    '🎉',
  ];

  static const List<String> quickPlay = [
    '🃏',
    '♠️',
    '♥️',
    '♦️',
    '♣️',
    '🏆',
    '💪',
    '🤔',
  ];

  static const List<String> taunts = [
    '😏',
    '🎯',
    '💣',
    '🔥',
    '😎',
    '🤣',
    '😱',
    '👀',
  ];
}

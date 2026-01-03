import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// Reuse MessageType if possible, or redefine? We'll redefine for rich types.

part 'social_chat_model.freezed.dart';
part 'social_chat_model.g.dart';

enum ChatType { direct, group, club, gameRoom, voiceRoom }

@freezed
abstract class SocialChat with _$SocialChat {
  const SocialChat._();

  const factory SocialChat({
    required String id,
    @Default(ChatType.direct) ChatType type,

    // Participants
    @Default([]) List<String> participants,
    @Default([]) List<String> admins,

    // Group Metadata
    String? name,
    String? description,
    String? avatarUrl,

    // Timestamps
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,

    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? updatedAt,

    // Last Message Preview
    SocialMessagePreview? lastMessage,

    // Unread Counts (Map<UserId, Count>)
    @Default({}) Map<String, int> unreadCounts,

    // Settings
    @Default(false) bool isMuted,
    @Default(false) bool isArchived,

    // Generic Metadata (e.g. for Club ID, specific game params)
    @Default({}) Map<String, dynamic> metadata,
  }) = _SocialChat;

  factory SocialChat.fromJson(Map<String, dynamic> json) =>
      _$SocialChatFromJson(json);
}

@freezed
abstract class SocialMessagePreview with _$SocialMessagePreview {
  const SocialMessagePreview._();

  const factory SocialMessagePreview({
    @Default('') String messageId,
    @Default('') String senderId,
    @Default('Unknown') String senderName,
    @Default('') String content,
    @Default('text') String type, // 'text', 'image', etc.
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime timestamp,
  }) = _SocialMessagePreview;

  factory SocialMessagePreview.fromJson(Map<String, dynamic> json) =>
      _$SocialMessagePreviewFromJson(json);
}

// Helper for Firestore Timestamps
DateTime _timestampFromJson(dynamic date) {
  if (date is Timestamp) {
    return date.toDate();
  } else if (date is String) {
    return DateTime.parse(date);
  } else {
    return DateTime.now();
  }
}

dynamic _timestampToJson(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;

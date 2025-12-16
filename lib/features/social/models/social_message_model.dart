import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_message_model.freezed.dart';
part 'social_message_model.g.dart';

enum SocialMessageType {
  text,
  image,
  video,
  audio,
  sticker,
  gif,
  gameInvite,
  gameResult,
  diamondGift,
  location,
  system,
}

@freezed
abstract class SocialMessage with _$SocialMessage {
  const SocialMessage._();
  
  const factory SocialMessage({
    required String id,
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    
    required SocialMessageType type,
    
    // Content payload
    required SocialMessageContent content,
    
    // Metadata
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime timestamp,
    
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? editedAt,
    
    @Default(false) bool isDeleted,
    
    // Status
    @Default([]) List<String> readBy,
    @Default({}) Map<String, String> reactions, // UserId -> Emoji
    
    // Reply
    String? replyToMessageId,
    SocialMessagePreviewData? replyToPreview,
    
  }) = _SocialMessage;

  factory SocialMessage.fromJson(Map<String, dynamic> json) => _$SocialMessageFromJson(json);
}

@freezed
abstract class SocialMessageContent with _$SocialMessageContent {
  const SocialMessageContent._();
  
  const factory SocialMessageContent({
    String? text,
    String? mediaUrl,
    String? thumbnailUrl,
    int? duration, // Seconds (audio/video)
    
    // Game Invite Data
    String? gameRoomId,
    String? gameType,
    
    // Diamond Gift Data
    int? diamondAmount,
    
    // Location Data
    double? latitude,
    double? longitude,
    
  }) = _SocialMessageContent;

  factory SocialMessageContent.fromJson(Map<String, dynamic> json) => _$SocialMessageContentFromJson(json);
}

@freezed
abstract class SocialMessagePreviewData with _$SocialMessagePreviewData {
  const SocialMessagePreviewData._();
  
  const factory SocialMessagePreviewData({
    required String id,
    required String senderName,
    required String contentPreview,
  }) = _SocialMessagePreviewData;

  factory SocialMessagePreviewData.fromJson(Map<String, dynamic> json) => _$SocialMessagePreviewDataFromJson(json);
}

// Helpers
DateTime _timestampFromJson(dynamic date) {
  if (date is Timestamp) {
    return date.toDate();
  } else if (date is String) {
    return DateTime.parse(date);
  } else {
    return DateTime.now();
  }
}

dynamic _timestampToJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialMessage _$SocialMessageFromJson(Map<String, dynamic> json) =>
    _SocialMessage(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      type: $enumDecode(_$SocialMessageTypeEnumMap, json['type']),
      content: SocialMessageContent.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      timestamp: _timestampFromJson(json['timestamp']),
      editedAt: _timestampFromJson(json['editedAt']),
      isDeleted: json['isDeleted'] as bool? ?? false,
      readBy:
          (json['readBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToPreview: json['replyToPreview'] == null
          ? null
          : SocialMessagePreviewData.fromJson(
              json['replyToPreview'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SocialMessageToJson(_SocialMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatarUrl': instance.senderAvatarUrl,
      'type': _$SocialMessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'timestamp': _timestampToJson(instance.timestamp),
      'editedAt': _timestampToJson(instance.editedAt),
      'isDeleted': instance.isDeleted,
      'readBy': instance.readBy,
      'reactions': instance.reactions,
      'replyToMessageId': instance.replyToMessageId,
      'replyToPreview': instance.replyToPreview,
    };

const _$SocialMessageTypeEnumMap = {
  SocialMessageType.text: 'text',
  SocialMessageType.image: 'image',
  SocialMessageType.video: 'video',
  SocialMessageType.audio: 'audio',
  SocialMessageType.sticker: 'sticker',
  SocialMessageType.gif: 'gif',
  SocialMessageType.gameInvite: 'gameInvite',
  SocialMessageType.gameResult: 'gameResult',
  SocialMessageType.diamondGift: 'diamondGift',
  SocialMessageType.location: 'location',
  SocialMessageType.system: 'system',
};

_SocialMessageContent _$SocialMessageContentFromJson(
  Map<String, dynamic> json,
) => _SocialMessageContent(
  text: json['text'] as String?,
  mediaUrl: json['mediaUrl'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  duration: (json['duration'] as num?)?.toInt(),
  gameRoomId: json['gameRoomId'] as String?,
  gameType: json['gameType'] as String?,
  diamondAmount: (json['diamondAmount'] as num?)?.toInt(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SocialMessageContentToJson(
  _SocialMessageContent instance,
) => <String, dynamic>{
  'text': instance.text,
  'mediaUrl': instance.mediaUrl,
  'thumbnailUrl': instance.thumbnailUrl,
  'duration': instance.duration,
  'gameRoomId': instance.gameRoomId,
  'gameType': instance.gameType,
  'diamondAmount': instance.diamondAmount,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_SocialMessagePreviewData _$SocialMessagePreviewDataFromJson(
  Map<String, dynamic> json,
) => _SocialMessagePreviewData(
  id: json['id'] as String,
  senderName: json['senderName'] as String,
  contentPreview: json['contentPreview'] as String,
);

Map<String, dynamic> _$SocialMessagePreviewDataToJson(
  _SocialMessagePreviewData instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderName': instance.senderName,
  'contentPreview': instance.contentPreview,
};

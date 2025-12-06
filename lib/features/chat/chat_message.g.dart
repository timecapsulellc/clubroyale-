// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String?,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  reactions:
      (json['reactions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  isModerated: json['isModerated'] as bool? ?? false,
  moderationReason: json['moderationReason'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  replyToId: json['replyToId'] as String?,
  replyPreview: json['replyPreview'] as String?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'reactions': instance.reactions,
      'isModerated': instance.isModerated,
      'moderationReason': instance.moderationReason,
      'timestamp': instance.timestamp?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'replyToId': instance.replyToId,
      'replyPreview': instance.replyPreview,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.emoji: 'emoji',
  MessageType.system: 'system',
  MessageType.gameEvent: 'gameEvent',
};

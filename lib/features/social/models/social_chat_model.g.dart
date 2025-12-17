// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialChat _$SocialChatFromJson(Map<String, dynamic> json) => _SocialChat(
  id: json['id'] as String,
  type: $enumDecodeNullable(_$ChatTypeEnumMap, json['type']) ?? ChatType.direct,
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  admins:
      (json['admins'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  name: json['name'] as String?,
  description: json['description'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
  lastMessage: json['lastMessage'] == null
      ? null
      : SocialMessagePreview.fromJson(
          json['lastMessage'] as Map<String, dynamic>,
        ),
  unreadCounts:
      (json['unreadCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  isMuted: json['isMuted'] as bool? ?? false,
  isArchived: json['isArchived'] as bool? ?? false,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SocialChatToJson(_SocialChat instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ChatTypeEnumMap[instance.type]!,
      'participants': instance.participants,
      'admins': instance.admins,
      'name': instance.name,
      'description': instance.description,
      'avatarUrl': instance.avatarUrl,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
      'lastMessage': instance.lastMessage,
      'unreadCounts': instance.unreadCounts,
      'isMuted': instance.isMuted,
      'isArchived': instance.isArchived,
      'metadata': instance.metadata,
    };

const _$ChatTypeEnumMap = {
  ChatType.direct: 'direct',
  ChatType.group: 'group',
  ChatType.club: 'club',
  ChatType.gameRoom: 'gameRoom',
  ChatType.voiceRoom: 'voiceRoom',
};

_SocialMessagePreview _$SocialMessagePreviewFromJson(
  Map<String, dynamic> json,
) => _SocialMessagePreview(
  messageId: json['messageId'] as String? ?? '',
  senderId: json['senderId'] as String? ?? '',
  senderName: json['senderName'] as String? ?? 'Unknown',
  content: json['content'] as String? ?? '',
  type: json['type'] as String? ?? 'text',
  timestamp: _timestampFromJson(json['timestamp']),
);

Map<String, dynamic> _$SocialMessagePreviewToJson(
  _SocialMessagePreview instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'content': instance.content,
  'type': instance.type,
  'timestamp': _timestampToJson(instance.timestamp),
};

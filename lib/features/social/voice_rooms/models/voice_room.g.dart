// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoiceParticipant _$VoiceParticipantFromJson(Map<String, dynamic> json) =>
    _VoiceParticipant(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
      isSpeaking: json['isSpeaking'] as bool? ?? false,
      isDeafened: json['isDeafened'] as bool? ?? false,
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$VoiceParticipantToJson(_VoiceParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'isMuted': instance.isMuted,
      'isSpeaking': instance.isSpeaking,
      'isDeafened': instance.isDeafened,
      'joinedAt': instance.joinedAt?.toIso8601String(),
    };

_VoiceRoom _$VoiceRoomFromJson(Map<String, dynamic> json) => _VoiceRoom(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  hostId: json['hostId'] as String,
  hostName: json['hostName'] as String,
  participants:
      (json['participants'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, VoiceParticipant.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 8,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  isPrivate: json['isPrivate'] as bool? ?? false,
  linkedGameId: json['linkedGameId'] as String?,
  linkedLobbyId: json['linkedLobbyId'] as String?,
);

Map<String, dynamic> _$VoiceRoomToJson(_VoiceRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'participants': instance.participants,
      'maxParticipants': instance.maxParticipants,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'isPrivate': instance.isPrivate,
      'linkedGameId': instance.linkedGameId,
      'linkedLobbyId': instance.linkedLobbyId,
    };

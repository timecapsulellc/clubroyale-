// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialUser _$SocialUserFromJson(Map<String, dynamic> json) => _SocialUser(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.offline,
  lastSeen: _timestampFromJson(json['lastSeen']),
  currentActivityType: json['currentActivityType'] as String?,
  currentActivityId: json['currentActivityId'] as String?,
  currentActivityName: json['currentActivityName'] as String?,
  isFriend: json['isFriend'] as bool? ?? false,
);

Map<String, dynamic> _$SocialUserToJson(_SocialUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'status': _$UserStatusEnumMap[instance.status]!,
      'lastSeen': _timestampToJson(instance.lastSeen),
      'currentActivityType': instance.currentActivityType,
      'currentActivityId': instance.currentActivityId,
      'currentActivityName': instance.currentActivityName,
      'isFriend': instance.isFriend,
    };

const _$UserStatusEnumMap = {
  UserStatus.online: 'online',
  UserStatus.away: 'away',
  UserStatus.busy: 'busy',
  UserStatus.inGame: 'inGame',
  UserStatus.offline: 'offline',
};

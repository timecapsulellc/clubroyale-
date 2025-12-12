// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Club _$ClubFromJson(Map<String, dynamic> json) => _Club(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  ownerId: json['ownerId'] as String,
  ownerName: json['ownerName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  privacy:
      $enumDecodeNullable(_$ClubPrivacyEnumMap, json['privacy']) ??
      ClubPrivacy.public,
  memberIds:
      (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  gameTypes:
      (json['gameTypes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  discordLink: json['discordLink'] as String?,
  rules: json['rules'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  isVerified: json['isVerified'] as bool? ?? false,
  totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
  weeklyActiveMembers: (json['weeklyActiveMembers'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ClubToJson(_Club instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'avatarUrl': instance.avatarUrl,
  'bannerUrl': instance.bannerUrl,
  'privacy': _$ClubPrivacyEnumMap[instance.privacy]!,
  'memberIds': instance.memberIds,
  'memberCount': instance.memberCount,
  'gameTypes': instance.gameTypes,
  'discordLink': instance.discordLink,
  'rules': instance.rules,
  'createdAt': instance.createdAt?.toIso8601String(),
  'isVerified': instance.isVerified,
  'totalGamesPlayed': instance.totalGamesPlayed,
  'weeklyActiveMembers': instance.weeklyActiveMembers,
};

const _$ClubPrivacyEnumMap = {
  ClubPrivacy.public: 'public',
  ClubPrivacy.private: 'private',
  ClubPrivacy.hidden: 'hidden',
};

_ClubMember _$ClubMemberFromJson(Map<String, dynamic> json) => _ClubMember(
  oderId: json['oderId'] as String,
  userName: json['userName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  role: $enumDecodeNullable(_$ClubRoleEnumMap, json['role']) ?? ClubRole.member,
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
  gamesPlayedInClub: (json['gamesPlayedInClub'] as num?)?.toInt() ?? 0,
  winsInClub: (json['winsInClub'] as num?)?.toInt() ?? 0,
  totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  isMuted: json['isMuted'] as bool? ?? false,
);

Map<String, dynamic> _$ClubMemberToJson(_ClubMember instance) =>
    <String, dynamic>{
      'oderId': instance.oderId,
      'userName': instance.userName,
      'avatarUrl': instance.avatarUrl,
      'role': _$ClubRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'gamesPlayedInClub': instance.gamesPlayedInClub,
      'winsInClub': instance.winsInClub,
      'totalPoints': instance.totalPoints,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'isMuted': instance.isMuted,
    };

const _$ClubRoleEnumMap = {
  ClubRole.owner: 'owner',
  ClubRole.admin: 'admin',
  ClubRole.member: 'member',
};

_ClubInvite _$ClubInviteFromJson(Map<String, dynamic> json) => _ClubInvite(
  id: json['id'] as String,
  clubId: json['clubId'] as String,
  clubName: json['clubName'] as String,
  inviterId: json['inviterId'] as String,
  inviterName: json['inviterName'] as String,
  inviteeId: json['inviteeId'] as String,
  message: json['message'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  isAccepted: json['isAccepted'] as bool? ?? false,
  isDeclined: json['isDeclined'] as bool? ?? false,
);

Map<String, dynamic> _$ClubInviteToJson(_ClubInvite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clubId': instance.clubId,
      'clubName': instance.clubName,
      'inviterId': instance.inviterId,
      'inviterName': instance.inviterName,
      'inviteeId': instance.inviteeId,
      'message': instance.message,
      'createdAt': instance.createdAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isAccepted': instance.isAccepted,
      'isDeclined': instance.isDeclined,
    };

_ClubLeaderboardEntry _$ClubLeaderboardEntryFromJson(
  Map<String, dynamic> json,
) => _ClubLeaderboardEntry(
  rank: (json['rank'] as num).toInt(),
  oderId: json['oderId'] as String,
  userName: json['userName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  games: (json['games'] as num).toInt(),
  wins: (json['wins'] as num).toInt(),
  points: (json['points'] as num).toInt(),
  winRate: (json['winRate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ClubLeaderboardEntryToJson(
  _ClubLeaderboardEntry instance,
) => <String, dynamic>{
  'rank': instance.rank,
  'oderId': instance.oderId,
  'userName': instance.userName,
  'avatarUrl': instance.avatarUrl,
  'games': instance.games,
  'wins': instance.wins,
  'points': instance.points,
  'winRate': instance.winRate,
};

_ClubActivity _$ClubActivityFromJson(Map<String, dynamic> json) =>
    _ClubActivity(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      oderId: json['oderId'] as String,
      userName: json['userName'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      type: $enumDecode(_$ClubActivityTypeEnumMap, json['type']),
      content: json['content'] as String,
      gameId: json['gameId'] as String?,
      gameType: json['gameType'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      likedBy:
          (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ClubActivityToJson(_ClubActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clubId': instance.clubId,
      'oderId': instance.oderId,
      'userName': instance.userName,
      'userAvatarUrl': instance.userAvatarUrl,
      'type': _$ClubActivityTypeEnumMap[instance.type]!,
      'content': instance.content,
      'gameId': instance.gameId,
      'gameType': instance.gameType,
      'createdAt': instance.createdAt?.toIso8601String(),
      'likedBy': instance.likedBy,
      'likesCount': instance.likesCount,
    };

const _$ClubActivityTypeEnumMap = {
  ClubActivityType.gameResult: 'gameResult',
  ClubActivityType.memberJoined: 'memberJoined',
  ClubActivityType.announcement: 'announcement',
  ClubActivityType.achievement: 'achievement',
  ClubActivityType.milestone: 'milestone',
};

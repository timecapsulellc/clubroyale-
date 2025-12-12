// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedItem _$FeedItemFromJson(Map<String, dynamic> json) => _FeedItem(
  id: json['id'] as String,
  oderId: json['oderId'] as String,
  userName: json['userName'] as String,
  userAvatarUrl: json['userAvatarUrl'] as String?,
  type: $enumDecode(_$FeedItemTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  gameType: json['gameType'] as String?,
  score: (json['score'] as num?)?.toInt(),
  isWin: json['isWin'] as bool?,
  gameScores: (json['gameScores'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  achievementId: json['achievementId'] as String?,
  achievementRarity: json['achievementRarity'] as String?,
  likedBy:
      (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$FeedItemToJson(_FeedItem instance) => <String, dynamic>{
  'id': instance.id,
  'oderId': instance.oderId,
  'userName': instance.userName,
  'userAvatarUrl': instance.userAvatarUrl,
  'type': _$FeedItemTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'gameType': instance.gameType,
  'score': instance.score,
  'isWin': instance.isWin,
  'gameScores': instance.gameScores,
  'achievementId': instance.achievementId,
  'achievementRarity': instance.achievementRarity,
  'likedBy': instance.likedBy,
  'likesCount': instance.likesCount,
  'commentsCount': instance.commentsCount,
};

const _$FeedItemTypeEnumMap = {
  FeedItemType.gameResult: 'gameResult',
  FeedItemType.achievement: 'achievement',
  FeedItemType.friendJoined: 'friendJoined',
  FeedItemType.storyPost: 'storyPost',
  FeedItemType.clubJoined: 'clubJoined',
  FeedItemType.tournamentWin: 'tournamentWin',
};

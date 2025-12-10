// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  coverPhotoUrl: json['coverPhotoUrl'] as String?,
  bio: json['bio'] as String?,
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
  postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
  gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
  gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
  winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
  eloRating: (json['eloRating'] as num?)?.toInt() ?? 1000,
  totalDiamondsEarned: (json['totalDiamondsEarned'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  achievements:
      (json['achievements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  profileTheme: json['profileTheme'] as String?,
  accentColor: json['accentColor'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  isCreator: json['isCreator'] as bool? ?? false,
  isPrivate: json['isPrivate'] as bool? ?? false,
  instagramHandle: json['instagramHandle'] as String?,
  twitterHandle: json['twitterHandle'] as String?,
  discordTag: json['discordTag'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  featuredPostId: json['featuredPostId'] as String?,
  highlightedStoryIds:
      (json['highlightedStoryIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'bio': instance.bio,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'postsCount': instance.postsCount,
      'gamesPlayed': instance.gamesPlayed,
      'gamesWon': instance.gamesWon,
      'winRate': instance.winRate,
      'eloRating': instance.eloRating,
      'totalDiamondsEarned': instance.totalDiamondsEarned,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'achievements': instance.achievements,
      'badges': instance.badges,
      'profileTheme': instance.profileTheme,
      'accentColor': instance.accentColor,
      'isVerified': instance.isVerified,
      'isCreator': instance.isCreator,
      'isPrivate': instance.isPrivate,
      'instagramHandle': instance.instagramHandle,
      'twitterHandle': instance.twitterHandle,
      'discordTag': instance.discordTag,
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'featuredPostId': instance.featuredPostId,
      'highlightedStoryIds': instance.highlightedStoryIds,
    };

_UserPost _$UserPostFromJson(Map<String, dynamic> json) => _UserPost(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userAvatarUrl: json['userAvatarUrl'] as String?,
  content: json['content'] as String,
  mediaUrl: json['mediaUrl'] as String?,
  mediaType:
      $enumDecodeNullable(_$PostMediaTypeEnumMap, json['mediaType']) ??
      PostMediaType.none,
  likedBy:
      (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  gameId: json['gameId'] as String?,
  gameType: json['gameType'] as String?,
);

Map<String, dynamic> _$UserPostToJson(_UserPost instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userAvatarUrl': instance.userAvatarUrl,
  'content': instance.content,
  'mediaUrl': instance.mediaUrl,
  'mediaType': _$PostMediaTypeEnumMap[instance.mediaType]!,
  'likedBy': instance.likedBy,
  'likesCount': instance.likesCount,
  'commentsCount': instance.commentsCount,
  'sharesCount': instance.sharesCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'isDeleted': instance.isDeleted,
  'gameId': instance.gameId,
  'gameType': instance.gameType,
};

const _$PostMediaTypeEnumMap = {
  PostMediaType.none: 'none',
  PostMediaType.image: 'image',
  PostMediaType.video: 'video',
  PostMediaType.gameHighlight: 'gameHighlight',
  PostMediaType.achievement: 'achievement',
};

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  iconUrl: json['iconUrl'] as String,
  rarity:
      $enumDecodeNullable(_$AchievementRarityEnumMap, json['rarity']) ??
      AchievementRarity.common,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  progress: (json['progress'] as num?)?.toInt(),
  maxProgress: (json['maxProgress'] as num?)?.toInt(),
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'rarity': _$AchievementRarityEnumMap[instance.rarity]!,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'isUnlocked': instance.isUnlocked,
      'progress': instance.progress,
      'maxProgress': instance.maxProgress,
    };

const _$AchievementRarityEnumMap = {
  AchievementRarity.common: 'common',
  AchievementRarity.uncommon: 'uncommon',
  AchievementRarity.rare: 'rare',
  AchievementRarity.epic: 'epic',
  AchievementRarity.legendary: 'legendary',
};

_ProfileBadge _$ProfileBadgeFromJson(Map<String, dynamic> json) =>
    _ProfileBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      description: json['description'] as String?,
      type:
          $enumDecodeNullable(_$BadgeTypeEnumMap, json['type']) ??
          BadgeType.general,
      earnedAt: json['earnedAt'] == null
          ? null
          : DateTime.parse(json['earnedAt'] as String),
    );

Map<String, dynamic> _$ProfileBadgeToJson(_ProfileBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconUrl': instance.iconUrl,
      'description': instance.description,
      'type': _$BadgeTypeEnumMap[instance.type]!,
      'earnedAt': instance.earnedAt?.toIso8601String(),
    };

const _$BadgeTypeEnumMap = {
  BadgeType.general: 'general',
  BadgeType.game: 'game',
  BadgeType.social: 'social',
  BadgeType.achievement: 'achievement',
  BadgeType.seasonal: 'seasonal',
  BadgeType.verified: 'verified',
  BadgeType.creator: 'creator',
};

_FollowRelation _$FollowRelationFromJson(Map<String, dynamic> json) =>
    _FollowRelation(
      followerId: json['followerId'] as String,
      followingId: json['followingId'] as String,
      followedAt: DateTime.parse(json['followedAt'] as String),
      isCloseFriend: json['isCloseFriend'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
    );

Map<String, dynamic> _$FollowRelationToJson(_FollowRelation instance) =>
    <String, dynamic>{
      'followerId': instance.followerId,
      'followingId': instance.followingId,
      'followedAt': instance.followedAt.toIso8601String(),
      'isCloseFriend': instance.isCloseFriend,
      'isMuted': instance.isMuted,
    };

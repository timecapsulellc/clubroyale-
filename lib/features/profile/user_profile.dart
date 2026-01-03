import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Enhanced user profile with social features
@freezed
abstract class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String id,
    required String displayName,
    String? avatarUrl,
    String? coverPhotoUrl,
    String? bio,

    // Social counts
    @Default(0) int followersCount,
    @Default(0) int followingCount,
    @Default(0) int postsCount,

    // Game stats
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    @Default(0) double winRate,
    @Default(1000) int eloRating,
    @Default(0) int totalDiamondsEarned,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,

    // Achievements
    @Default([]) List<String> achievements,
    @Default([]) List<String> badges,

    // Profile customization
    String? profileTheme,
    String? accentColor,
    @Default(false) bool isVerified,
    @Default(false) bool isCreator,
    @Default(false) bool isPrivate,

    // Social links
    String? instagramHandle,
    String? twitterHandle,
    String? discordTag,

    // Timestamps
    DateTime? createdAt,
    DateTime? lastActiveAt,

    // Featured content
    String? featuredPostId,
    @Default([]) List<String> highlightedStoryIds,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Check if profile has premium features
  bool get isPremium => isVerified || isCreator;

  /// Get rank title based on ELO
  String get rankTitle {
    if (eloRating >= 2000) return 'Grandmaster';
    if (eloRating >= 1800) return 'Master';
    if (eloRating >= 1600) return 'Expert';
    if (eloRating >= 1400) return 'Advanced';
    if (eloRating >= 1200) return 'Intermediate';
    return 'Beginner';
  }
}

/// User post for profile feed
@freezed
abstract class UserPost with _$UserPost {
  const UserPost._();

  const factory UserPost({
    required String id,
    required String userId,
    required String userName,
    String? userAvatarUrl,
    required String content,
    String? mediaUrl,
    @Default(PostMediaType.none) PostMediaType mediaType,
    @Default([]) List<String> likedBy,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    @Default(0) int sharesCount,
    required DateTime createdAt,
    @Default(false) bool isDeleted,
    String? gameId,
    String? gameType,
  }) = _UserPost;

  factory UserPost.fromJson(Map<String, dynamic> json) =>
      _$UserPostFromJson(json);
}

/// Post media type
enum PostMediaType { none, image, video, gameHighlight, achievement }

/// Achievement definition
@freezed
abstract class Achievement with _$Achievement {
  const Achievement._();

  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String iconUrl,
    @Default(AchievementRarity.common) AchievementRarity rarity,
    DateTime? unlockedAt,
    @Default(false) bool isUnlocked,
    int? progress,
    int? maxProgress,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Achievement rarity tier
enum AchievementRarity { common, uncommon, rare, epic, legendary }

/// Profile badge
@freezed
abstract class ProfileBadge with _$ProfileBadge {
  const ProfileBadge._();

  const factory ProfileBadge({
    required String id,
    required String name,
    required String iconUrl,
    String? description,
    @Default(BadgeType.general) BadgeType type,
    DateTime? earnedAt,
  }) = _ProfileBadge;

  factory ProfileBadge.fromJson(Map<String, dynamic> json) =>
      _$ProfileBadgeFromJson(json);
}

/// Badge types
enum BadgeType {
  general,
  game,
  social,
  achievement,
  seasonal,
  verified,
  creator,
}

/// Follow relationship
@freezed
abstract class FollowRelation with _$FollowRelation {
  const FollowRelation._();

  const factory FollowRelation({
    required String followerId,
    required String followingId,
    required DateTime followedAt,
    @Default(false) bool isCloseFriend,
    @Default(false) bool isMuted,
  }) = _FollowRelation;

  factory FollowRelation.fromJson(Map<String, dynamic> json) =>
      _$FollowRelationFromJson(json);
}

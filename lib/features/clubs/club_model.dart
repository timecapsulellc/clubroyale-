/// Club Models
/// 
/// Models for gaming clubs/groups feature
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_model.freezed.dart';
part 'club_model.g.dart';

/// Club membership role
enum ClubRole {
  owner,    // Created the club
  admin,    // Can manage members
  member,   // Regular member
}

/// Club privacy setting
enum ClubPrivacy {
  public,     // Anyone can join
  private,    // Invite only
  hidden,     // Not visible in search
}

/// Gaming club model
@freezed
abstract class Club with _$Club {
  const Club._();

  const factory Club({
    required String id,
    required String name,
    required String description,
    required String ownerId,
    required String ownerName,
    String? avatarUrl,
    String? bannerUrl,
    String? chatId, // Link to Social Chat
    @Default(ClubPrivacy.public) ClubPrivacy privacy,
    @Default([]) List<String> memberIds,
    @Default(0) int memberCount,
    @Default([]) List<String> gameTypes,
    String? discordLink,
    String? rules,
    DateTime? createdAt,
    @Default(false) bool isVerified,
    @Default(0) int totalGamesPlayed,
    @Default(0) int weeklyActiveMembers,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);

  /// Check if user is owner
  bool isOwner(String oderId) => ownerId == oderId;

  /// Check if user is member
  bool isMember(String oderId) => memberIds.contains(oderId);
}

/// Club member
@freezed
abstract class ClubMember with _$ClubMember {
  const ClubMember._();

  const factory ClubMember({
    required String oderId,
    required String userName,
    String? avatarUrl,
    @Default(ClubRole.member) ClubRole role,
    DateTime? joinedAt,
    @Default(0) int gamesPlayedInClub,
    @Default(0) int winsInClub,
    @Default(0) int totalPoints,
    DateTime? lastActiveAt,
    @Default(false) bool isMuted,
  }) = _ClubMember;

  factory ClubMember.fromJson(Map<String, dynamic> json) =>
      _$ClubMemberFromJson(json);
}

/// Club invite
@freezed
abstract class ClubInvite with _$ClubInvite {
  const ClubInvite._();

  const factory ClubInvite({
    required String id,
    required String clubId,
    required String clubName,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
    String? message,
    DateTime? createdAt,
    DateTime? expiresAt,
    @Default(false) bool isAccepted,
    @Default(false) bool isDeclined,
  }) = _ClubInvite;

  factory ClubInvite.fromJson(Map<String, dynamic> json) =>
      _$ClubInviteFromJson(json);

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isPending => !isAccepted && !isDeclined && !isExpired;
}

/// Club leaderboard entry
@freezed
abstract class ClubLeaderboardEntry with _$ClubLeaderboardEntry {
  const ClubLeaderboardEntry._();

  const factory ClubLeaderboardEntry({
    required int rank,
    required String oderId,
    required String userName,
    String? avatarUrl,
    required int games,
    required int wins,
    required int points,
    double? winRate,
  }) = _ClubLeaderboardEntry;

  factory ClubLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$ClubLeaderboardEntryFromJson(json);
}

/// Club activity/post
@freezed
abstract class ClubActivity with _$ClubActivity {
  const ClubActivity._();

  const factory ClubActivity({
    required String id,
    required String clubId,
    required String oderId,
    required String userName,
    String? userAvatarUrl,
    required ClubActivityType type,
    required String content,
    String? gameId,
    String? gameType,
    DateTime? createdAt,
    @Default([]) List<String> likedBy,
    @Default(0) int likesCount,
  }) = _ClubActivity;

  factory ClubActivity.fromJson(Map<String, dynamic> json) =>
      _$ClubActivityFromJson(json);
}

/// Club activity type
enum ClubActivityType {
  gameResult,     // Member finished a game
  memberJoined,   // New member joined
  announcement,   // Admin announcement
  achievement,    // Member earned achievement
  milestone,      // Club milestone (e.g., 100 games)
}

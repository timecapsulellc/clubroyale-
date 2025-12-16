import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

/// Story media type
enum StoryMediaType {
  @JsonValue('photo')
  photo,
  @JsonValue('video')
  video,
  @JsonValue('gameResult')
  gameResult,
}

/// Story model for 24-hour ephemeral content
@freezed
abstract class Story with _$Story {
  const Story._();

  const factory Story({
    required String id,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    String? mediaUrl, // Optional - not needed for gameResult type
    @Default(StoryMediaType.photo) StoryMediaType mediaType,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default([]) List<String> viewedBy,
    @Default(0) int viewCount,
    String? caption,
    String? textOverlay,
    String? textColor,
    // Game result fields (for gameResult type)
    String? gameType,
    String? winnerId,
    String? winnerName,
    Map<String, int>? scores, // playerId -> score
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}

/// Story viewer info
@freezed
abstract class StoryViewer with _$StoryViewer {
  const StoryViewer._();

  const factory StoryViewer({
    required String id,
    required String name,
    String? photoUrl,
    required DateTime viewedAt,
  }) = _StoryViewer;

  factory StoryViewer.fromJson(Map<String, dynamic> json) =>
      _$StoryViewerFromJson(json);
}

/// User stories aggregation (for story bar display)
@freezed
abstract class UserStories with _$UserStories {
  const UserStories._();

  const factory UserStories({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required List<Story> stories,
    @Default(false) bool hasUnviewed,
    DateTime? latestStoryAt,
  }) = _UserStories;

  factory UserStories.fromJson(Map<String, dynamic> json) =>
      _$UserStoriesFromJson(json);
}

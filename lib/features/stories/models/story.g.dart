// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Story _$StoryFromJson(Map<String, dynamic> json) => _Story(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userPhotoUrl: json['userPhotoUrl'] as String?,
  mediaUrl: json['mediaUrl'] as String,
  mediaType:
      $enumDecodeNullable(_$StoryMediaTypeEnumMap, json['mediaType']) ??
      StoryMediaType.photo,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  viewedBy:
      (json['viewedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  caption: json['caption'] as String?,
  textOverlay: json['textOverlay'] as String?,
  textColor: json['textColor'] as String?,
);

Map<String, dynamic> _$StoryToJson(_Story instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'userPhotoUrl': instance.userPhotoUrl,
  'mediaUrl': instance.mediaUrl,
  'mediaType': _$StoryMediaTypeEnumMap[instance.mediaType]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'viewedBy': instance.viewedBy,
  'viewCount': instance.viewCount,
  'caption': instance.caption,
  'textOverlay': instance.textOverlay,
  'textColor': instance.textColor,
};

const _$StoryMediaTypeEnumMap = {
  StoryMediaType.photo: 'photo',
  StoryMediaType.video: 'video',
};

_StoryViewer _$StoryViewerFromJson(Map<String, dynamic> json) => _StoryViewer(
  id: json['id'] as String,
  name: json['name'] as String,
  photoUrl: json['photoUrl'] as String?,
  viewedAt: DateTime.parse(json['viewedAt'] as String),
);

Map<String, dynamic> _$StoryViewerToJson(_StoryViewer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'viewedAt': instance.viewedAt.toIso8601String(),
    };

_UserStories _$UserStoriesFromJson(Map<String, dynamic> json) => _UserStories(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  userPhotoUrl: json['userPhotoUrl'] as String?,
  stories: (json['stories'] as List<dynamic>)
      .map((e) => Story.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasUnviewed: json['hasUnviewed'] as bool? ?? false,
  latestStoryAt: json['latestStoryAt'] == null
      ? null
      : DateTime.parse(json['latestStoryAt'] as String),
);

Map<String, dynamic> _$UserStoriesToJson(_UserStories instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userPhotoUrl': instance.userPhotoUrl,
      'stories': instance.stories,
      'hasUnviewed': instance.hasUnviewed,
      'latestStoryAt': instance.latestStoryAt?.toIso8601String(),
    };

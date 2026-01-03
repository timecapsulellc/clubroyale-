import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_user_model.freezed.dart';
part 'social_user_model.g.dart';

enum UserStatus { online, away, busy, inGame, offline }

@freezed
abstract class SocialUser with _$SocialUser {
  const SocialUser._();

  const factory SocialUser({
    @Default('') String id,
    @Default('Player') String displayName,
    String? avatarUrl,

    // Presence
    @Default(UserStatus.offline) UserStatus status,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? lastSeen,

    // Current Activity
    String? currentActivityType, // 'game', 'voice_room'
    String? currentActivityId, // roomId
    String? currentActivityName, // 'Playing Marriage'

    @Default(false) bool isFriend,
  }) = _SocialUser;

  factory SocialUser.fromJson(Map<String, dynamic> json) =>
      _$SocialUserFromJson(json);
}

DateTime? _timestampFromJson(dynamic date) {
  if (date == null) return null;
  if (date is Timestamp) {
    return date.toDate();
  } else if (date is String) {
    return DateTime.parse(date);
  } else {
    return DateTime.now();
  }
}

dynamic _timestampToJson(DateTime? date) =>
    date != null ? Timestamp.fromDate(date) : null;

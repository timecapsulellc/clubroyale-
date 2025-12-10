// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String get displayName; String? get avatarUrl; String? get coverPhotoUrl; String? get bio;// Social counts
 int get followersCount; int get followingCount; int get postsCount;// Game stats
 int get gamesPlayed; int get gamesWon; double get winRate; int get eloRating; int get totalDiamondsEarned; int get currentStreak; int get longestStreak;// Achievements
 List<String> get achievements; List<String> get badges;// Profile customization
 String? get profileTheme; String? get accentColor; bool get isVerified; bool get isCreator; bool get isPrivate;// Social links
 String? get instagramHandle; String? get twitterHandle; String? get discordTag;// Timestamps
 DateTime? get createdAt; DateTime? get lastActiveAt;// Featured content
 String? get featuredPostId; List<String> get highlightedStoryIds;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverPhotoUrl, coverPhotoUrl) || other.coverPhotoUrl == coverPhotoUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.gamesWon, gamesWon) || other.gamesWon == gamesWon)&&(identical(other.winRate, winRate) || other.winRate == winRate)&&(identical(other.eloRating, eloRating) || other.eloRating == eloRating)&&(identical(other.totalDiamondsEarned, totalDiamondsEarned) || other.totalDiamondsEarned == totalDiamondsEarned)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&const DeepCollectionEquality().equals(other.achievements, achievements)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.profileTheme, profileTheme) || other.profileTheme == profileTheme)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isCreator, isCreator) || other.isCreator == isCreator)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.twitterHandle, twitterHandle) || other.twitterHandle == twitterHandle)&&(identical(other.discordTag, discordTag) || other.discordTag == discordTag)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.featuredPostId, featuredPostId) || other.featuredPostId == featuredPostId)&&const DeepCollectionEquality().equals(other.highlightedStoryIds, highlightedStoryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,displayName,avatarUrl,coverPhotoUrl,bio,followersCount,followingCount,postsCount,gamesPlayed,gamesWon,winRate,eloRating,totalDiamondsEarned,currentStreak,longestStreak,const DeepCollectionEquality().hash(achievements),const DeepCollectionEquality().hash(badges),profileTheme,accentColor,isVerified,isCreator,isPrivate,instagramHandle,twitterHandle,discordTag,createdAt,lastActiveAt,featuredPostId,const DeepCollectionEquality().hash(highlightedStoryIds)]);

@override
String toString() {
  return 'UserProfile(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, coverPhotoUrl: $coverPhotoUrl, bio: $bio, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, winRate: $winRate, eloRating: $eloRating, totalDiamondsEarned: $totalDiamondsEarned, currentStreak: $currentStreak, longestStreak: $longestStreak, achievements: $achievements, badges: $badges, profileTheme: $profileTheme, accentColor: $accentColor, isVerified: $isVerified, isCreator: $isCreator, isPrivate: $isPrivate, instagramHandle: $instagramHandle, twitterHandle: $twitterHandle, discordTag: $discordTag, createdAt: $createdAt, lastActiveAt: $lastActiveAt, featuredPostId: $featuredPostId, highlightedStoryIds: $highlightedStoryIds)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String? avatarUrl, String? coverPhotoUrl, String? bio, int followersCount, int followingCount, int postsCount, int gamesPlayed, int gamesWon, double winRate, int eloRating, int totalDiamondsEarned, int currentStreak, int longestStreak, List<String> achievements, List<String> badges, String? profileTheme, String? accentColor, bool isVerified, bool isCreator, bool isPrivate, String? instagramHandle, String? twitterHandle, String? discordTag, DateTime? createdAt, DateTime? lastActiveAt, String? featuredPostId, List<String> highlightedStoryIds
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = freezed,Object? coverPhotoUrl = freezed,Object? bio = freezed,Object? followersCount = null,Object? followingCount = null,Object? postsCount = null,Object? gamesPlayed = null,Object? gamesWon = null,Object? winRate = null,Object? eloRating = null,Object? totalDiamondsEarned = null,Object? currentStreak = null,Object? longestStreak = null,Object? achievements = null,Object? badges = null,Object? profileTheme = freezed,Object? accentColor = freezed,Object? isVerified = null,Object? isCreator = null,Object? isPrivate = null,Object? instagramHandle = freezed,Object? twitterHandle = freezed,Object? discordTag = freezed,Object? createdAt = freezed,Object? lastActiveAt = freezed,Object? featuredPostId = freezed,Object? highlightedStoryIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoUrl: freezed == coverPhotoUrl ? _self.coverPhotoUrl : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,gamesWon: null == gamesWon ? _self.gamesWon : gamesWon // ignore: cast_nullable_to_non_nullable
as int,winRate: null == winRate ? _self.winRate : winRate // ignore: cast_nullable_to_non_nullable
as double,eloRating: null == eloRating ? _self.eloRating : eloRating // ignore: cast_nullable_to_non_nullable
as int,totalDiamondsEarned: null == totalDiamondsEarned ? _self.totalDiamondsEarned : totalDiamondsEarned // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<String>,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,profileTheme: freezed == profileTheme ? _self.profileTheme : profileTheme // ignore: cast_nullable_to_non_nullable
as String?,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isCreator: null == isCreator ? _self.isCreator : isCreator // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,twitterHandle: freezed == twitterHandle ? _self.twitterHandle : twitterHandle // ignore: cast_nullable_to_non_nullable
as String?,discordTag: freezed == discordTag ? _self.discordTag : discordTag // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,featuredPostId: freezed == featuredPostId ? _self.featuredPostId : featuredPostId // ignore: cast_nullable_to_non_nullable
as String?,highlightedStoryIds: null == highlightedStoryIds ? _self.highlightedStoryIds : highlightedStoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String? avatarUrl,  String? coverPhotoUrl,  String? bio,  int followersCount,  int followingCount,  int postsCount,  int gamesPlayed,  int gamesWon,  double winRate,  int eloRating,  int totalDiamondsEarned,  int currentStreak,  int longestStreak,  List<String> achievements,  List<String> badges,  String? profileTheme,  String? accentColor,  bool isVerified,  bool isCreator,  bool isPrivate,  String? instagramHandle,  String? twitterHandle,  String? discordTag,  DateTime? createdAt,  DateTime? lastActiveAt,  String? featuredPostId,  List<String> highlightedStoryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.coverPhotoUrl,_that.bio,_that.followersCount,_that.followingCount,_that.postsCount,_that.gamesPlayed,_that.gamesWon,_that.winRate,_that.eloRating,_that.totalDiamondsEarned,_that.currentStreak,_that.longestStreak,_that.achievements,_that.badges,_that.profileTheme,_that.accentColor,_that.isVerified,_that.isCreator,_that.isPrivate,_that.instagramHandle,_that.twitterHandle,_that.discordTag,_that.createdAt,_that.lastActiveAt,_that.featuredPostId,_that.highlightedStoryIds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String? avatarUrl,  String? coverPhotoUrl,  String? bio,  int followersCount,  int followingCount,  int postsCount,  int gamesPlayed,  int gamesWon,  double winRate,  int eloRating,  int totalDiamondsEarned,  int currentStreak,  int longestStreak,  List<String> achievements,  List<String> badges,  String? profileTheme,  String? accentColor,  bool isVerified,  bool isCreator,  bool isPrivate,  String? instagramHandle,  String? twitterHandle,  String? discordTag,  DateTime? createdAt,  DateTime? lastActiveAt,  String? featuredPostId,  List<String> highlightedStoryIds)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.coverPhotoUrl,_that.bio,_that.followersCount,_that.followingCount,_that.postsCount,_that.gamesPlayed,_that.gamesWon,_that.winRate,_that.eloRating,_that.totalDiamondsEarned,_that.currentStreak,_that.longestStreak,_that.achievements,_that.badges,_that.profileTheme,_that.accentColor,_that.isVerified,_that.isCreator,_that.isPrivate,_that.instagramHandle,_that.twitterHandle,_that.discordTag,_that.createdAt,_that.lastActiveAt,_that.featuredPostId,_that.highlightedStoryIds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String? avatarUrl,  String? coverPhotoUrl,  String? bio,  int followersCount,  int followingCount,  int postsCount,  int gamesPlayed,  int gamesWon,  double winRate,  int eloRating,  int totalDiamondsEarned,  int currentStreak,  int longestStreak,  List<String> achievements,  List<String> badges,  String? profileTheme,  String? accentColor,  bool isVerified,  bool isCreator,  bool isPrivate,  String? instagramHandle,  String? twitterHandle,  String? discordTag,  DateTime? createdAt,  DateTime? lastActiveAt,  String? featuredPostId,  List<String> highlightedStoryIds)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.coverPhotoUrl,_that.bio,_that.followersCount,_that.followingCount,_that.postsCount,_that.gamesPlayed,_that.gamesWon,_that.winRate,_that.eloRating,_that.totalDiamondsEarned,_that.currentStreak,_that.longestStreak,_that.achievements,_that.badges,_that.profileTheme,_that.accentColor,_that.isVerified,_that.isCreator,_that.isPrivate,_that.instagramHandle,_that.twitterHandle,_that.discordTag,_that.createdAt,_that.lastActiveAt,_that.featuredPostId,_that.highlightedStoryIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile extends UserProfile {
  const _UserProfile({required this.id, required this.displayName, this.avatarUrl, this.coverPhotoUrl, this.bio, this.followersCount = 0, this.followingCount = 0, this.postsCount = 0, this.gamesPlayed = 0, this.gamesWon = 0, this.winRate = 0, this.eloRating = 1000, this.totalDiamondsEarned = 0, this.currentStreak = 0, this.longestStreak = 0, final  List<String> achievements = const [], final  List<String> badges = const [], this.profileTheme, this.accentColor, this.isVerified = false, this.isCreator = false, this.isPrivate = false, this.instagramHandle, this.twitterHandle, this.discordTag, this.createdAt, this.lastActiveAt, this.featuredPostId, final  List<String> highlightedStoryIds = const []}): _achievements = achievements,_badges = badges,_highlightedStoryIds = highlightedStoryIds,super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String? avatarUrl;
@override final  String? coverPhotoUrl;
@override final  String? bio;
// Social counts
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  int postsCount;
// Game stats
@override@JsonKey() final  int gamesPlayed;
@override@JsonKey() final  int gamesWon;
@override@JsonKey() final  double winRate;
@override@JsonKey() final  int eloRating;
@override@JsonKey() final  int totalDiamondsEarned;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
// Achievements
 final  List<String> _achievements;
// Achievements
@override@JsonKey() List<String> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}

 final  List<String> _badges;
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

// Profile customization
@override final  String? profileTheme;
@override final  String? accentColor;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  bool isCreator;
@override@JsonKey() final  bool isPrivate;
// Social links
@override final  String? instagramHandle;
@override final  String? twitterHandle;
@override final  String? discordTag;
// Timestamps
@override final  DateTime? createdAt;
@override final  DateTime? lastActiveAt;
// Featured content
@override final  String? featuredPostId;
 final  List<String> _highlightedStoryIds;
@override@JsonKey() List<String> get highlightedStoryIds {
  if (_highlightedStoryIds is EqualUnmodifiableListView) return _highlightedStoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlightedStoryIds);
}


/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.coverPhotoUrl, coverPhotoUrl) || other.coverPhotoUrl == coverPhotoUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.gamesWon, gamesWon) || other.gamesWon == gamesWon)&&(identical(other.winRate, winRate) || other.winRate == winRate)&&(identical(other.eloRating, eloRating) || other.eloRating == eloRating)&&(identical(other.totalDiamondsEarned, totalDiamondsEarned) || other.totalDiamondsEarned == totalDiamondsEarned)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.profileTheme, profileTheme) || other.profileTheme == profileTheme)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isCreator, isCreator) || other.isCreator == isCreator)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.twitterHandle, twitterHandle) || other.twitterHandle == twitterHandle)&&(identical(other.discordTag, discordTag) || other.discordTag == discordTag)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.featuredPostId, featuredPostId) || other.featuredPostId == featuredPostId)&&const DeepCollectionEquality().equals(other._highlightedStoryIds, _highlightedStoryIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,displayName,avatarUrl,coverPhotoUrl,bio,followersCount,followingCount,postsCount,gamesPlayed,gamesWon,winRate,eloRating,totalDiamondsEarned,currentStreak,longestStreak,const DeepCollectionEquality().hash(_achievements),const DeepCollectionEquality().hash(_badges),profileTheme,accentColor,isVerified,isCreator,isPrivate,instagramHandle,twitterHandle,discordTag,createdAt,lastActiveAt,featuredPostId,const DeepCollectionEquality().hash(_highlightedStoryIds)]);

@override
String toString() {
  return 'UserProfile(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, coverPhotoUrl: $coverPhotoUrl, bio: $bio, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, winRate: $winRate, eloRating: $eloRating, totalDiamondsEarned: $totalDiamondsEarned, currentStreak: $currentStreak, longestStreak: $longestStreak, achievements: $achievements, badges: $badges, profileTheme: $profileTheme, accentColor: $accentColor, isVerified: $isVerified, isCreator: $isCreator, isPrivate: $isPrivate, instagramHandle: $instagramHandle, twitterHandle: $twitterHandle, discordTag: $discordTag, createdAt: $createdAt, lastActiveAt: $lastActiveAt, featuredPostId: $featuredPostId, highlightedStoryIds: $highlightedStoryIds)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String? avatarUrl, String? coverPhotoUrl, String? bio, int followersCount, int followingCount, int postsCount, int gamesPlayed, int gamesWon, double winRate, int eloRating, int totalDiamondsEarned, int currentStreak, int longestStreak, List<String> achievements, List<String> badges, String? profileTheme, String? accentColor, bool isVerified, bool isCreator, bool isPrivate, String? instagramHandle, String? twitterHandle, String? discordTag, DateTime? createdAt, DateTime? lastActiveAt, String? featuredPostId, List<String> highlightedStoryIds
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = freezed,Object? coverPhotoUrl = freezed,Object? bio = freezed,Object? followersCount = null,Object? followingCount = null,Object? postsCount = null,Object? gamesPlayed = null,Object? gamesWon = null,Object? winRate = null,Object? eloRating = null,Object? totalDiamondsEarned = null,Object? currentStreak = null,Object? longestStreak = null,Object? achievements = null,Object? badges = null,Object? profileTheme = freezed,Object? accentColor = freezed,Object? isVerified = null,Object? isCreator = null,Object? isPrivate = null,Object? instagramHandle = freezed,Object? twitterHandle = freezed,Object? discordTag = freezed,Object? createdAt = freezed,Object? lastActiveAt = freezed,Object? featuredPostId = freezed,Object? highlightedStoryIds = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,coverPhotoUrl: freezed == coverPhotoUrl ? _self.coverPhotoUrl : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,gamesWon: null == gamesWon ? _self.gamesWon : gamesWon // ignore: cast_nullable_to_non_nullable
as int,winRate: null == winRate ? _self.winRate : winRate // ignore: cast_nullable_to_non_nullable
as double,eloRating: null == eloRating ? _self.eloRating : eloRating // ignore: cast_nullable_to_non_nullable
as int,totalDiamondsEarned: null == totalDiamondsEarned ? _self.totalDiamondsEarned : totalDiamondsEarned // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<String>,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,profileTheme: freezed == profileTheme ? _self.profileTheme : profileTheme // ignore: cast_nullable_to_non_nullable
as String?,accentColor: freezed == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isCreator: null == isCreator ? _self.isCreator : isCreator // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,twitterHandle: freezed == twitterHandle ? _self.twitterHandle : twitterHandle // ignore: cast_nullable_to_non_nullable
as String?,discordTag: freezed == discordTag ? _self.discordTag : discordTag // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,featuredPostId: freezed == featuredPostId ? _self.featuredPostId : featuredPostId // ignore: cast_nullable_to_non_nullable
as String?,highlightedStoryIds: null == highlightedStoryIds ? _self._highlightedStoryIds : highlightedStoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$UserPost {

 String get id; String get userId; String get userName; String? get userAvatarUrl; String get content; String? get mediaUrl; PostMediaType get mediaType; List<String> get likedBy; int get likesCount; int get commentsCount; int get sharesCount; DateTime get createdAt; bool get isDeleted; String? get gameId; String? get gameType;
/// Create a copy of UserPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPostCopyWith<UserPost> get copyWith => _$UserPostCopyWithImpl<UserPost>(this as UserPost, _$identity);

  /// Serializes this UserPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPost&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.content, content) || other.content == content)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&const DeepCollectionEquality().equals(other.likedBy, likedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.sharesCount, sharesCount) || other.sharesCount == sharesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameType, gameType) || other.gameType == gameType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userAvatarUrl,content,mediaUrl,mediaType,const DeepCollectionEquality().hash(likedBy),likesCount,commentsCount,sharesCount,createdAt,isDeleted,gameId,gameType);

@override
String toString() {
  return 'UserPost(id: $id, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, content: $content, mediaUrl: $mediaUrl, mediaType: $mediaType, likedBy: $likedBy, likesCount: $likesCount, commentsCount: $commentsCount, sharesCount: $sharesCount, createdAt: $createdAt, isDeleted: $isDeleted, gameId: $gameId, gameType: $gameType)';
}


}

/// @nodoc
abstract mixin class $UserPostCopyWith<$Res>  {
  factory $UserPostCopyWith(UserPost value, $Res Function(UserPost) _then) = _$UserPostCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String userName, String? userAvatarUrl, String content, String? mediaUrl, PostMediaType mediaType, List<String> likedBy, int likesCount, int commentsCount, int sharesCount, DateTime createdAt, bool isDeleted, String? gameId, String? gameType
});




}
/// @nodoc
class _$UserPostCopyWithImpl<$Res>
    implements $UserPostCopyWith<$Res> {
  _$UserPostCopyWithImpl(this._self, this._then);

  final UserPost _self;
  final $Res Function(UserPost) _then;

/// Create a copy of UserPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? content = null,Object? mediaUrl = freezed,Object? mediaType = null,Object? likedBy = null,Object? likesCount = null,Object? commentsCount = null,Object? sharesCount = null,Object? createdAt = null,Object? isDeleted = null,Object? gameId = freezed,Object? gameType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as PostMediaType,likedBy: null == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,sharesCount: null == sharesCount ? _self.sharesCount : sharesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPost].
extension UserPostPatterns on UserPost {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPost() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPost value)  $default,){
final _that = this;
switch (_that) {
case _UserPost():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPost value)?  $default,){
final _that = this;
switch (_that) {
case _UserPost() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? userAvatarUrl,  String content,  String? mediaUrl,  PostMediaType mediaType,  List<String> likedBy,  int likesCount,  int commentsCount,  int sharesCount,  DateTime createdAt,  bool isDeleted,  String? gameId,  String? gameType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPost() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userAvatarUrl,_that.content,_that.mediaUrl,_that.mediaType,_that.likedBy,_that.likesCount,_that.commentsCount,_that.sharesCount,_that.createdAt,_that.isDeleted,_that.gameId,_that.gameType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? userAvatarUrl,  String content,  String? mediaUrl,  PostMediaType mediaType,  List<String> likedBy,  int likesCount,  int commentsCount,  int sharesCount,  DateTime createdAt,  bool isDeleted,  String? gameId,  String? gameType)  $default,) {final _that = this;
switch (_that) {
case _UserPost():
return $default(_that.id,_that.userId,_that.userName,_that.userAvatarUrl,_that.content,_that.mediaUrl,_that.mediaType,_that.likedBy,_that.likesCount,_that.commentsCount,_that.sharesCount,_that.createdAt,_that.isDeleted,_that.gameId,_that.gameType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String userName,  String? userAvatarUrl,  String content,  String? mediaUrl,  PostMediaType mediaType,  List<String> likedBy,  int likesCount,  int commentsCount,  int sharesCount,  DateTime createdAt,  bool isDeleted,  String? gameId,  String? gameType)?  $default,) {final _that = this;
switch (_that) {
case _UserPost() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userAvatarUrl,_that.content,_that.mediaUrl,_that.mediaType,_that.likedBy,_that.likesCount,_that.commentsCount,_that.sharesCount,_that.createdAt,_that.isDeleted,_that.gameId,_that.gameType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPost extends UserPost {
  const _UserPost({required this.id, required this.userId, required this.userName, this.userAvatarUrl, required this.content, this.mediaUrl, this.mediaType = PostMediaType.none, final  List<String> likedBy = const [], this.likesCount = 0, this.commentsCount = 0, this.sharesCount = 0, required this.createdAt, this.isDeleted = false, this.gameId, this.gameType}): _likedBy = likedBy,super._();
  factory _UserPost.fromJson(Map<String, dynamic> json) => _$UserPostFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String userName;
@override final  String? userAvatarUrl;
@override final  String content;
@override final  String? mediaUrl;
@override@JsonKey() final  PostMediaType mediaType;
 final  List<String> _likedBy;
@override@JsonKey() List<String> get likedBy {
  if (_likedBy is EqualUnmodifiableListView) return _likedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedBy);
}

@override@JsonKey() final  int likesCount;
@override@JsonKey() final  int commentsCount;
@override@JsonKey() final  int sharesCount;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isDeleted;
@override final  String? gameId;
@override final  String? gameType;

/// Create a copy of UserPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPostCopyWith<_UserPost> get copyWith => __$UserPostCopyWithImpl<_UserPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPost&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.content, content) || other.content == content)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&const DeepCollectionEquality().equals(other._likedBy, _likedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&(identical(other.sharesCount, sharesCount) || other.sharesCount == sharesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameType, gameType) || other.gameType == gameType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userAvatarUrl,content,mediaUrl,mediaType,const DeepCollectionEquality().hash(_likedBy),likesCount,commentsCount,sharesCount,createdAt,isDeleted,gameId,gameType);

@override
String toString() {
  return 'UserPost(id: $id, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, content: $content, mediaUrl: $mediaUrl, mediaType: $mediaType, likedBy: $likedBy, likesCount: $likesCount, commentsCount: $commentsCount, sharesCount: $sharesCount, createdAt: $createdAt, isDeleted: $isDeleted, gameId: $gameId, gameType: $gameType)';
}


}

/// @nodoc
abstract mixin class _$UserPostCopyWith<$Res> implements $UserPostCopyWith<$Res> {
  factory _$UserPostCopyWith(_UserPost value, $Res Function(_UserPost) _then) = __$UserPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String userName, String? userAvatarUrl, String content, String? mediaUrl, PostMediaType mediaType, List<String> likedBy, int likesCount, int commentsCount, int sharesCount, DateTime createdAt, bool isDeleted, String? gameId, String? gameType
});




}
/// @nodoc
class __$UserPostCopyWithImpl<$Res>
    implements _$UserPostCopyWith<$Res> {
  __$UserPostCopyWithImpl(this._self, this._then);

  final _UserPost _self;
  final $Res Function(_UserPost) _then;

/// Create a copy of UserPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? content = null,Object? mediaUrl = freezed,Object? mediaType = null,Object? likedBy = null,Object? likesCount = null,Object? commentsCount = null,Object? sharesCount = null,Object? createdAt = null,Object? isDeleted = null,Object? gameId = freezed,Object? gameType = freezed,}) {
  return _then(_UserPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,mediaUrl: freezed == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as PostMediaType,likedBy: null == likedBy ? _self._likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,sharesCount: null == sharesCount ? _self.sharesCount : sharesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Achievement {

 String get id; String get title; String get description; String get iconUrl; AchievementRarity get rarity; DateTime? get unlockedAt; bool get isUnlocked; int? get progress; int? get maxProgress;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.maxProgress, maxProgress) || other.maxProgress == maxProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,iconUrl,rarity,unlockedAt,isUnlocked,progress,maxProgress);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, iconUrl: $iconUrl, rarity: $rarity, unlockedAt: $unlockedAt, isUnlocked: $isUnlocked, progress: $progress, maxProgress: $maxProgress)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String iconUrl, AchievementRarity rarity, DateTime? unlockedAt, bool isUnlocked, int? progress, int? maxProgress
});




}
/// @nodoc
class _$AchievementCopyWithImpl<$Res>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? iconUrl = null,Object? rarity = null,Object? unlockedAt = freezed,Object? isUnlocked = null,Object? progress = freezed,Object? maxProgress = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int?,maxProgress: freezed == maxProgress ? _self.maxProgress : maxProgress // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Achievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Achievement value)  $default,){
final _that = this;
switch (_that) {
case _Achievement():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Achievement value)?  $default,){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String iconUrl,  AchievementRarity rarity,  DateTime? unlockedAt,  bool isUnlocked,  int? progress,  int? maxProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.iconUrl,_that.rarity,_that.unlockedAt,_that.isUnlocked,_that.progress,_that.maxProgress);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String iconUrl,  AchievementRarity rarity,  DateTime? unlockedAt,  bool isUnlocked,  int? progress,  int? maxProgress)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.id,_that.title,_that.description,_that.iconUrl,_that.rarity,_that.unlockedAt,_that.isUnlocked,_that.progress,_that.maxProgress);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String iconUrl,  AchievementRarity rarity,  DateTime? unlockedAt,  bool isUnlocked,  int? progress,  int? maxProgress)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.iconUrl,_that.rarity,_that.unlockedAt,_that.isUnlocked,_that.progress,_that.maxProgress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement extends Achievement {
  const _Achievement({required this.id, required this.title, required this.description, required this.iconUrl, this.rarity = AchievementRarity.common, this.unlockedAt, this.isUnlocked = false, this.progress, this.maxProgress}): super._();
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String iconUrl;
@override@JsonKey() final  AchievementRarity rarity;
@override final  DateTime? unlockedAt;
@override@JsonKey() final  bool isUnlocked;
@override final  int? progress;
@override final  int? maxProgress;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementCopyWith<_Achievement> get copyWith => __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.rarity, rarity) || other.rarity == rarity)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.maxProgress, maxProgress) || other.maxProgress == maxProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,iconUrl,rarity,unlockedAt,isUnlocked,progress,maxProgress);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, iconUrl: $iconUrl, rarity: $rarity, unlockedAt: $unlockedAt, isUnlocked: $isUnlocked, progress: $progress, maxProgress: $maxProgress)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String iconUrl, AchievementRarity rarity, DateTime? unlockedAt, bool isUnlocked, int? progress, int? maxProgress
});




}
/// @nodoc
class __$AchievementCopyWithImpl<$Res>
    implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? iconUrl = null,Object? rarity = null,Object? unlockedAt = freezed,Object? isUnlocked = null,Object? progress = freezed,Object? maxProgress = freezed,}) {
  return _then(_Achievement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,rarity: null == rarity ? _self.rarity : rarity // ignore: cast_nullable_to_non_nullable
as AchievementRarity,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int?,maxProgress: freezed == maxProgress ? _self.maxProgress : maxProgress // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ProfileBadge {

 String get id; String get name; String get iconUrl; String? get description; BadgeType get type; DateTime? get earnedAt;
/// Create a copy of ProfileBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileBadgeCopyWith<ProfileBadge> get copyWith => _$ProfileBadgeCopyWithImpl<ProfileBadge>(this as ProfileBadge, _$identity);

  /// Serializes this ProfileBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,description,type,earnedAt);

@override
String toString() {
  return 'ProfileBadge(id: $id, name: $name, iconUrl: $iconUrl, description: $description, type: $type, earnedAt: $earnedAt)';
}


}

/// @nodoc
abstract mixin class $ProfileBadgeCopyWith<$Res>  {
  factory $ProfileBadgeCopyWith(ProfileBadge value, $Res Function(ProfileBadge) _then) = _$ProfileBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String iconUrl, String? description, BadgeType type, DateTime? earnedAt
});




}
/// @nodoc
class _$ProfileBadgeCopyWithImpl<$Res>
    implements $ProfileBadgeCopyWith<$Res> {
  _$ProfileBadgeCopyWithImpl(this._self, this._then);

  final ProfileBadge _self;
  final $Res Function(ProfileBadge) _then;

/// Create a copy of ProfileBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = null,Object? description = freezed,Object? type = null,Object? earnedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BadgeType,earnedAt: freezed == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileBadge].
extension ProfileBadgePatterns on ProfileBadge {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileBadge() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileBadge value)  $default,){
final _that = this;
switch (_that) {
case _ProfileBadge():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileBadge value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileBadge() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String iconUrl,  String? description,  BadgeType type,  DateTime? earnedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileBadge() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl,_that.description,_that.type,_that.earnedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String iconUrl,  String? description,  BadgeType type,  DateTime? earnedAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileBadge():
return $default(_that.id,_that.name,_that.iconUrl,_that.description,_that.type,_that.earnedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String iconUrl,  String? description,  BadgeType type,  DateTime? earnedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileBadge() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl,_that.description,_that.type,_that.earnedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileBadge extends ProfileBadge {
  const _ProfileBadge({required this.id, required this.name, required this.iconUrl, this.description, this.type = BadgeType.general, this.earnedAt}): super._();
  factory _ProfileBadge.fromJson(Map<String, dynamic> json) => _$ProfileBadgeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String iconUrl;
@override final  String? description;
@override@JsonKey() final  BadgeType type;
@override final  DateTime? earnedAt;

/// Create a copy of ProfileBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileBadgeCopyWith<_ProfileBadge> get copyWith => __$ProfileBadgeCopyWithImpl<_ProfileBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,description,type,earnedAt);

@override
String toString() {
  return 'ProfileBadge(id: $id, name: $name, iconUrl: $iconUrl, description: $description, type: $type, earnedAt: $earnedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileBadgeCopyWith<$Res> implements $ProfileBadgeCopyWith<$Res> {
  factory _$ProfileBadgeCopyWith(_ProfileBadge value, $Res Function(_ProfileBadge) _then) = __$ProfileBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String iconUrl, String? description, BadgeType type, DateTime? earnedAt
});




}
/// @nodoc
class __$ProfileBadgeCopyWithImpl<$Res>
    implements _$ProfileBadgeCopyWith<$Res> {
  __$ProfileBadgeCopyWithImpl(this._self, this._then);

  final _ProfileBadge _self;
  final $Res Function(_ProfileBadge) _then;

/// Create a copy of ProfileBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = null,Object? description = freezed,Object? type = null,Object? earnedAt = freezed,}) {
  return _then(_ProfileBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: null == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BadgeType,earnedAt: freezed == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FollowRelation {

 String get followerId; String get followingId; DateTime get followedAt; bool get isCloseFriend; bool get isMuted;
/// Create a copy of FollowRelation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowRelationCopyWith<FollowRelation> get copyWith => _$FollowRelationCopyWithImpl<FollowRelation>(this as FollowRelation, _$identity);

  /// Serializes this FollowRelation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowRelation&&(identical(other.followerId, followerId) || other.followerId == followerId)&&(identical(other.followingId, followingId) || other.followingId == followingId)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.isCloseFriend, isCloseFriend) || other.isCloseFriend == isCloseFriend)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followerId,followingId,followedAt,isCloseFriend,isMuted);

@override
String toString() {
  return 'FollowRelation(followerId: $followerId, followingId: $followingId, followedAt: $followedAt, isCloseFriend: $isCloseFriend, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class $FollowRelationCopyWith<$Res>  {
  factory $FollowRelationCopyWith(FollowRelation value, $Res Function(FollowRelation) _then) = _$FollowRelationCopyWithImpl;
@useResult
$Res call({
 String followerId, String followingId, DateTime followedAt, bool isCloseFriend, bool isMuted
});




}
/// @nodoc
class _$FollowRelationCopyWithImpl<$Res>
    implements $FollowRelationCopyWith<$Res> {
  _$FollowRelationCopyWithImpl(this._self, this._then);

  final FollowRelation _self;
  final $Res Function(FollowRelation) _then;

/// Create a copy of FollowRelation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? followerId = null,Object? followingId = null,Object? followedAt = null,Object? isCloseFriend = null,Object? isMuted = null,}) {
  return _then(_self.copyWith(
followerId: null == followerId ? _self.followerId : followerId // ignore: cast_nullable_to_non_nullable
as String,followingId: null == followingId ? _self.followingId : followingId // ignore: cast_nullable_to_non_nullable
as String,followedAt: null == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isCloseFriend: null == isCloseFriend ? _self.isCloseFriend : isCloseFriend // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowRelation].
extension FollowRelationPatterns on FollowRelation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowRelation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowRelation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowRelation value)  $default,){
final _that = this;
switch (_that) {
case _FollowRelation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowRelation value)?  $default,){
final _that = this;
switch (_that) {
case _FollowRelation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String followerId,  String followingId,  DateTime followedAt,  bool isCloseFriend,  bool isMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowRelation() when $default != null:
return $default(_that.followerId,_that.followingId,_that.followedAt,_that.isCloseFriend,_that.isMuted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String followerId,  String followingId,  DateTime followedAt,  bool isCloseFriend,  bool isMuted)  $default,) {final _that = this;
switch (_that) {
case _FollowRelation():
return $default(_that.followerId,_that.followingId,_that.followedAt,_that.isCloseFriend,_that.isMuted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String followerId,  String followingId,  DateTime followedAt,  bool isCloseFriend,  bool isMuted)?  $default,) {final _that = this;
switch (_that) {
case _FollowRelation() when $default != null:
return $default(_that.followerId,_that.followingId,_that.followedAt,_that.isCloseFriend,_that.isMuted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowRelation extends FollowRelation {
  const _FollowRelation({required this.followerId, required this.followingId, required this.followedAt, this.isCloseFriend = false, this.isMuted = false}): super._();
  factory _FollowRelation.fromJson(Map<String, dynamic> json) => _$FollowRelationFromJson(json);

@override final  String followerId;
@override final  String followingId;
@override final  DateTime followedAt;
@override@JsonKey() final  bool isCloseFriend;
@override@JsonKey() final  bool isMuted;

/// Create a copy of FollowRelation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowRelationCopyWith<_FollowRelation> get copyWith => __$FollowRelationCopyWithImpl<_FollowRelation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowRelationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowRelation&&(identical(other.followerId, followerId) || other.followerId == followerId)&&(identical(other.followingId, followingId) || other.followingId == followingId)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.isCloseFriend, isCloseFriend) || other.isCloseFriend == isCloseFriend)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followerId,followingId,followedAt,isCloseFriend,isMuted);

@override
String toString() {
  return 'FollowRelation(followerId: $followerId, followingId: $followingId, followedAt: $followedAt, isCloseFriend: $isCloseFriend, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class _$FollowRelationCopyWith<$Res> implements $FollowRelationCopyWith<$Res> {
  factory _$FollowRelationCopyWith(_FollowRelation value, $Res Function(_FollowRelation) _then) = __$FollowRelationCopyWithImpl;
@override @useResult
$Res call({
 String followerId, String followingId, DateTime followedAt, bool isCloseFriend, bool isMuted
});




}
/// @nodoc
class __$FollowRelationCopyWithImpl<$Res>
    implements _$FollowRelationCopyWith<$Res> {
  __$FollowRelationCopyWithImpl(this._self, this._then);

  final _FollowRelation _self;
  final $Res Function(_FollowRelation) _then;

/// Create a copy of FollowRelation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? followerId = null,Object? followingId = null,Object? followedAt = null,Object? isCloseFriend = null,Object? isMuted = null,}) {
  return _then(_FollowRelation(
followerId: null == followerId ? _self.followerId : followerId // ignore: cast_nullable_to_non_nullable
as String,followingId: null == followingId ? _self.followingId : followingId // ignore: cast_nullable_to_non_nullable
as String,followedAt: null == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isCloseFriend: null == isCloseFriend ? _self.isCloseFriend : isCloseFriend // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

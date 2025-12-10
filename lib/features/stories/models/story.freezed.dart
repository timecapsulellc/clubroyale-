// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Story {

 String get id; String get userId; String get userName; String? get userPhotoUrl; String get mediaUrl; StoryMediaType get mediaType; DateTime get createdAt; DateTime get expiresAt; List<String> get viewedBy; int get viewCount; String? get caption; String? get textOverlay; String? get textColor;
/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryCopyWith<Story> get copyWith => _$StoryCopyWithImpl<Story>(this as Story, _$identity);

  /// Serializes this Story to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Story&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.viewedBy, viewedBy)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.textOverlay, textOverlay) || other.textOverlay == textOverlay)&&(identical(other.textColor, textColor) || other.textColor == textColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userPhotoUrl,mediaUrl,mediaType,createdAt,expiresAt,const DeepCollectionEquality().hash(viewedBy),viewCount,caption,textOverlay,textColor);

@override
String toString() {
  return 'Story(id: $id, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, mediaUrl: $mediaUrl, mediaType: $mediaType, createdAt: $createdAt, expiresAt: $expiresAt, viewedBy: $viewedBy, viewCount: $viewCount, caption: $caption, textOverlay: $textOverlay, textColor: $textColor)';
}


}

/// @nodoc
abstract mixin class $StoryCopyWith<$Res>  {
  factory $StoryCopyWith(Story value, $Res Function(Story) _then) = _$StoryCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String userName, String? userPhotoUrl, String mediaUrl, StoryMediaType mediaType, DateTime createdAt, DateTime expiresAt, List<String> viewedBy, int viewCount, String? caption, String? textOverlay, String? textColor
});




}
/// @nodoc
class _$StoryCopyWithImpl<$Res>
    implements $StoryCopyWith<$Res> {
  _$StoryCopyWithImpl(this._self, this._then);

  final Story _self;
  final $Res Function(Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? mediaUrl = null,Object? mediaType = null,Object? createdAt = null,Object? expiresAt = null,Object? viewedBy = null,Object? viewCount = null,Object? caption = freezed,Object? textOverlay = freezed,Object? textColor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as StoryMediaType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,viewedBy: null == viewedBy ? _self.viewedBy : viewedBy // ignore: cast_nullable_to_non_nullable
as List<String>,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,textOverlay: freezed == textOverlay ? _self.textOverlay : textOverlay // ignore: cast_nullable_to_non_nullable
as String?,textColor: freezed == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Story].
extension StoryPatterns on Story {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Story value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Story() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Story value)  $default,){
final _that = this;
switch (_that) {
case _Story():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Story value)?  $default,){
final _that = this;
switch (_that) {
case _Story() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? userPhotoUrl,  String mediaUrl,  StoryMediaType mediaType,  DateTime createdAt,  DateTime expiresAt,  List<String> viewedBy,  int viewCount,  String? caption,  String? textOverlay,  String? textColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userPhotoUrl,_that.mediaUrl,_that.mediaType,_that.createdAt,_that.expiresAt,_that.viewedBy,_that.viewCount,_that.caption,_that.textOverlay,_that.textColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String userName,  String? userPhotoUrl,  String mediaUrl,  StoryMediaType mediaType,  DateTime createdAt,  DateTime expiresAt,  List<String> viewedBy,  int viewCount,  String? caption,  String? textOverlay,  String? textColor)  $default,) {final _that = this;
switch (_that) {
case _Story():
return $default(_that.id,_that.userId,_that.userName,_that.userPhotoUrl,_that.mediaUrl,_that.mediaType,_that.createdAt,_that.expiresAt,_that.viewedBy,_that.viewCount,_that.caption,_that.textOverlay,_that.textColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String userName,  String? userPhotoUrl,  String mediaUrl,  StoryMediaType mediaType,  DateTime createdAt,  DateTime expiresAt,  List<String> viewedBy,  int viewCount,  String? caption,  String? textOverlay,  String? textColor)?  $default,) {final _that = this;
switch (_that) {
case _Story() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.userPhotoUrl,_that.mediaUrl,_that.mediaType,_that.createdAt,_that.expiresAt,_that.viewedBy,_that.viewCount,_that.caption,_that.textOverlay,_that.textColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Story extends Story {
  const _Story({required this.id, required this.userId, required this.userName, this.userPhotoUrl, required this.mediaUrl, this.mediaType = StoryMediaType.photo, required this.createdAt, required this.expiresAt, final  List<String> viewedBy = const [], this.viewCount = 0, this.caption, this.textOverlay, this.textColor}): _viewedBy = viewedBy,super._();
  factory _Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String userName;
@override final  String? userPhotoUrl;
@override final  String mediaUrl;
@override@JsonKey() final  StoryMediaType mediaType;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
 final  List<String> _viewedBy;
@override@JsonKey() List<String> get viewedBy {
  if (_viewedBy is EqualUnmodifiableListView) return _viewedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_viewedBy);
}

@override@JsonKey() final  int viewCount;
@override final  String? caption;
@override final  String? textOverlay;
@override final  String? textColor;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryCopyWith<_Story> get copyWith => __$StoryCopyWithImpl<_Story>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Story&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&(identical(other.mediaUrl, mediaUrl) || other.mediaUrl == mediaUrl)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._viewedBy, _viewedBy)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.textOverlay, textOverlay) || other.textOverlay == textOverlay)&&(identical(other.textColor, textColor) || other.textColor == textColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,userPhotoUrl,mediaUrl,mediaType,createdAt,expiresAt,const DeepCollectionEquality().hash(_viewedBy),viewCount,caption,textOverlay,textColor);

@override
String toString() {
  return 'Story(id: $id, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, mediaUrl: $mediaUrl, mediaType: $mediaType, createdAt: $createdAt, expiresAt: $expiresAt, viewedBy: $viewedBy, viewCount: $viewCount, caption: $caption, textOverlay: $textOverlay, textColor: $textColor)';
}


}

/// @nodoc
abstract mixin class _$StoryCopyWith<$Res> implements $StoryCopyWith<$Res> {
  factory _$StoryCopyWith(_Story value, $Res Function(_Story) _then) = __$StoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String userName, String? userPhotoUrl, String mediaUrl, StoryMediaType mediaType, DateTime createdAt, DateTime expiresAt, List<String> viewedBy, int viewCount, String? caption, String? textOverlay, String? textColor
});




}
/// @nodoc
class __$StoryCopyWithImpl<$Res>
    implements _$StoryCopyWith<$Res> {
  __$StoryCopyWithImpl(this._self, this._then);

  final _Story _self;
  final $Res Function(_Story) _then;

/// Create a copy of Story
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? mediaUrl = null,Object? mediaType = null,Object? createdAt = null,Object? expiresAt = null,Object? viewedBy = null,Object? viewCount = null,Object? caption = freezed,Object? textOverlay = freezed,Object? textColor = freezed,}) {
  return _then(_Story(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaUrl: null == mediaUrl ? _self.mediaUrl : mediaUrl // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as StoryMediaType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,viewedBy: null == viewedBy ? _self._viewedBy : viewedBy // ignore: cast_nullable_to_non_nullable
as List<String>,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,textOverlay: freezed == textOverlay ? _self.textOverlay : textOverlay // ignore: cast_nullable_to_non_nullable
as String?,textColor: freezed == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StoryViewer {

 String get id; String get name; String? get photoUrl; DateTime get viewedAt;
/// Create a copy of StoryViewer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryViewerCopyWith<StoryViewer> get copyWith => _$StoryViewerCopyWithImpl<StoryViewer>(this as StoryViewer, _$identity);

  /// Serializes this StoryViewer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryViewer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,viewedAt);

@override
String toString() {
  return 'StoryViewer(id: $id, name: $name, photoUrl: $photoUrl, viewedAt: $viewedAt)';
}


}

/// @nodoc
abstract mixin class $StoryViewerCopyWith<$Res>  {
  factory $StoryViewerCopyWith(StoryViewer value, $Res Function(StoryViewer) _then) = _$StoryViewerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? photoUrl, DateTime viewedAt
});




}
/// @nodoc
class _$StoryViewerCopyWithImpl<$Res>
    implements $StoryViewerCopyWith<$Res> {
  _$StoryViewerCopyWithImpl(this._self, this._then);

  final StoryViewer _self;
  final $Res Function(StoryViewer) _then;

/// Create a copy of StoryViewer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? viewedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,viewedAt: null == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryViewer].
extension StoryViewerPatterns on StoryViewer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryViewer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryViewer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryViewer value)  $default,){
final _that = this;
switch (_that) {
case _StoryViewer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryViewer value)?  $default,){
final _that = this;
switch (_that) {
case _StoryViewer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  DateTime viewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryViewer() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.viewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  DateTime viewedAt)  $default,) {final _that = this;
switch (_that) {
case _StoryViewer():
return $default(_that.id,_that.name,_that.photoUrl,_that.viewedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? photoUrl,  DateTime viewedAt)?  $default,) {final _that = this;
switch (_that) {
case _StoryViewer() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.viewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoryViewer extends StoryViewer {
  const _StoryViewer({required this.id, required this.name, this.photoUrl, required this.viewedAt}): super._();
  factory _StoryViewer.fromJson(Map<String, dynamic> json) => _$StoryViewerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? photoUrl;
@override final  DateTime viewedAt;

/// Create a copy of StoryViewer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryViewerCopyWith<_StoryViewer> get copyWith => __$StoryViewerCopyWithImpl<_StoryViewer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryViewerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryViewer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,viewedAt);

@override
String toString() {
  return 'StoryViewer(id: $id, name: $name, photoUrl: $photoUrl, viewedAt: $viewedAt)';
}


}

/// @nodoc
abstract mixin class _$StoryViewerCopyWith<$Res> implements $StoryViewerCopyWith<$Res> {
  factory _$StoryViewerCopyWith(_StoryViewer value, $Res Function(_StoryViewer) _then) = __$StoryViewerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? photoUrl, DateTime viewedAt
});




}
/// @nodoc
class __$StoryViewerCopyWithImpl<$Res>
    implements _$StoryViewerCopyWith<$Res> {
  __$StoryViewerCopyWithImpl(this._self, this._then);

  final _StoryViewer _self;
  final $Res Function(_StoryViewer) _then;

/// Create a copy of StoryViewer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? viewedAt = null,}) {
  return _then(_StoryViewer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,viewedAt: null == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserStories {

 String get userId; String get userName; String? get userPhotoUrl; List<Story> get stories; bool get hasUnviewed; DateTime? get latestStoryAt;
/// Create a copy of UserStories
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStoriesCopyWith<UserStories> get copyWith => _$UserStoriesCopyWithImpl<UserStories>(this as UserStories, _$identity);

  /// Serializes this UserStories to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStories&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&const DeepCollectionEquality().equals(other.stories, stories)&&(identical(other.hasUnviewed, hasUnviewed) || other.hasUnviewed == hasUnviewed)&&(identical(other.latestStoryAt, latestStoryAt) || other.latestStoryAt == latestStoryAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userName,userPhotoUrl,const DeepCollectionEquality().hash(stories),hasUnviewed,latestStoryAt);

@override
String toString() {
  return 'UserStories(userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, stories: $stories, hasUnviewed: $hasUnviewed, latestStoryAt: $latestStoryAt)';
}


}

/// @nodoc
abstract mixin class $UserStoriesCopyWith<$Res>  {
  factory $UserStoriesCopyWith(UserStories value, $Res Function(UserStories) _then) = _$UserStoriesCopyWithImpl;
@useResult
$Res call({
 String userId, String userName, String? userPhotoUrl, List<Story> stories, bool hasUnviewed, DateTime? latestStoryAt
});




}
/// @nodoc
class _$UserStoriesCopyWithImpl<$Res>
    implements $UserStoriesCopyWith<$Res> {
  _$UserStoriesCopyWithImpl(this._self, this._then);

  final UserStories _self;
  final $Res Function(UserStories) _then;

/// Create a copy of UserStories
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? stories = null,Object? hasUnviewed = null,Object? latestStoryAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,stories: null == stories ? _self.stories : stories // ignore: cast_nullable_to_non_nullable
as List<Story>,hasUnviewed: null == hasUnviewed ? _self.hasUnviewed : hasUnviewed // ignore: cast_nullable_to_non_nullable
as bool,latestStoryAt: freezed == latestStoryAt ? _self.latestStoryAt : latestStoryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStories].
extension UserStoriesPatterns on UserStories {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStories value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStories() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStories value)  $default,){
final _that = this;
switch (_that) {
case _UserStories():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStories value)?  $default,){
final _that = this;
switch (_that) {
case _UserStories() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String userName,  String? userPhotoUrl,  List<Story> stories,  bool hasUnviewed,  DateTime? latestStoryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStories() when $default != null:
return $default(_that.userId,_that.userName,_that.userPhotoUrl,_that.stories,_that.hasUnviewed,_that.latestStoryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String userName,  String? userPhotoUrl,  List<Story> stories,  bool hasUnviewed,  DateTime? latestStoryAt)  $default,) {final _that = this;
switch (_that) {
case _UserStories():
return $default(_that.userId,_that.userName,_that.userPhotoUrl,_that.stories,_that.hasUnviewed,_that.latestStoryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String userName,  String? userPhotoUrl,  List<Story> stories,  bool hasUnviewed,  DateTime? latestStoryAt)?  $default,) {final _that = this;
switch (_that) {
case _UserStories() when $default != null:
return $default(_that.userId,_that.userName,_that.userPhotoUrl,_that.stories,_that.hasUnviewed,_that.latestStoryAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserStories extends UserStories {
  const _UserStories({required this.userId, required this.userName, this.userPhotoUrl, required final  List<Story> stories, this.hasUnviewed = false, this.latestStoryAt}): _stories = stories,super._();
  factory _UserStories.fromJson(Map<String, dynamic> json) => _$UserStoriesFromJson(json);

@override final  String userId;
@override final  String userName;
@override final  String? userPhotoUrl;
 final  List<Story> _stories;
@override List<Story> get stories {
  if (_stories is EqualUnmodifiableListView) return _stories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stories);
}

@override@JsonKey() final  bool hasUnviewed;
@override final  DateTime? latestStoryAt;

/// Create a copy of UserStories
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStoriesCopyWith<_UserStories> get copyWith => __$UserStoriesCopyWithImpl<_UserStories>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserStoriesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStories&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userPhotoUrl, userPhotoUrl) || other.userPhotoUrl == userPhotoUrl)&&const DeepCollectionEquality().equals(other._stories, _stories)&&(identical(other.hasUnviewed, hasUnviewed) || other.hasUnviewed == hasUnviewed)&&(identical(other.latestStoryAt, latestStoryAt) || other.latestStoryAt == latestStoryAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userName,userPhotoUrl,const DeepCollectionEquality().hash(_stories),hasUnviewed,latestStoryAt);

@override
String toString() {
  return 'UserStories(userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, stories: $stories, hasUnviewed: $hasUnviewed, latestStoryAt: $latestStoryAt)';
}


}

/// @nodoc
abstract mixin class _$UserStoriesCopyWith<$Res> implements $UserStoriesCopyWith<$Res> {
  factory _$UserStoriesCopyWith(_UserStories value, $Res Function(_UserStories) _then) = __$UserStoriesCopyWithImpl;
@override @useResult
$Res call({
 String userId, String userName, String? userPhotoUrl, List<Story> stories, bool hasUnviewed, DateTime? latestStoryAt
});




}
/// @nodoc
class __$UserStoriesCopyWithImpl<$Res>
    implements _$UserStoriesCopyWith<$Res> {
  __$UserStoriesCopyWithImpl(this._self, this._then);

  final _UserStories _self;
  final $Res Function(_UserStories) _then;

/// Create a copy of UserStories
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? userName = null,Object? userPhotoUrl = freezed,Object? stories = null,Object? hasUnviewed = null,Object? latestStoryAt = freezed,}) {
  return _then(_UserStories(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userPhotoUrl: freezed == userPhotoUrl ? _self.userPhotoUrl : userPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,stories: null == stories ? _self._stories : stories // ignore: cast_nullable_to_non_nullable
as List<Story>,hasUnviewed: null == hasUnviewed ? _self.hasUnviewed : hasUnviewed // ignore: cast_nullable_to_non_nullable
as bool,latestStoryAt: freezed == latestStoryAt ? _self.latestStoryAt : latestStoryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

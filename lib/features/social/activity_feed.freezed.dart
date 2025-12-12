// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_feed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedItem {

 String get id; String get oderId; String get userName; String? get userAvatarUrl; FeedItemType get type; String get title; String get description; String? get imageUrl; DateTime get createdAt;// Game result specific
 String? get gameType; int? get score; bool? get isWin; Map<String, int>? get gameScores;// Achievement specific
 String? get achievementId; String? get achievementRarity;// Reactions
 List<String> get likedBy; int get likesCount; int get commentsCount;
/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedItemCopyWith<FeedItem> get copyWith => _$FeedItemCopyWithImpl<FeedItem>(this as FeedItem, _$identity);

  /// Serializes this FeedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.score, score) || other.score == score)&&(identical(other.isWin, isWin) || other.isWin == isWin)&&const DeepCollectionEquality().equals(other.gameScores, gameScores)&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.achievementRarity, achievementRarity) || other.achievementRarity == achievementRarity)&&const DeepCollectionEquality().equals(other.likedBy, likedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,oderId,userName,userAvatarUrl,type,title,description,imageUrl,createdAt,gameType,score,isWin,const DeepCollectionEquality().hash(gameScores),achievementId,achievementRarity,const DeepCollectionEquality().hash(likedBy),likesCount,commentsCount);

@override
String toString() {
  return 'FeedItem(id: $id, oderId: $oderId, userName: $userName, userAvatarUrl: $userAvatarUrl, type: $type, title: $title, description: $description, imageUrl: $imageUrl, createdAt: $createdAt, gameType: $gameType, score: $score, isWin: $isWin, gameScores: $gameScores, achievementId: $achievementId, achievementRarity: $achievementRarity, likedBy: $likedBy, likesCount: $likesCount, commentsCount: $commentsCount)';
}


}

/// @nodoc
abstract mixin class $FeedItemCopyWith<$Res>  {
  factory $FeedItemCopyWith(FeedItem value, $Res Function(FeedItem) _then) = _$FeedItemCopyWithImpl;
@useResult
$Res call({
 String id, String oderId, String userName, String? userAvatarUrl, FeedItemType type, String title, String description, String? imageUrl, DateTime createdAt, String? gameType, int? score, bool? isWin, Map<String, int>? gameScores, String? achievementId, String? achievementRarity, List<String> likedBy, int likesCount, int commentsCount
});




}
/// @nodoc
class _$FeedItemCopyWithImpl<$Res>
    implements $FeedItemCopyWith<$Res> {
  _$FeedItemCopyWithImpl(this._self, this._then);

  final FeedItem _self;
  final $Res Function(FeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? oderId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? type = null,Object? title = null,Object? description = null,Object? imageUrl = freezed,Object? createdAt = null,Object? gameType = freezed,Object? score = freezed,Object? isWin = freezed,Object? gameScores = freezed,Object? achievementId = freezed,Object? achievementRarity = freezed,Object? likedBy = null,Object? likesCount = null,Object? commentsCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedItemType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int?,isWin: freezed == isWin ? _self.isWin : isWin // ignore: cast_nullable_to_non_nullable
as bool?,gameScores: freezed == gameScores ? _self.gameScores : gameScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,achievementId: freezed == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String?,achievementRarity: freezed == achievementRarity ? _self.achievementRarity : achievementRarity // ignore: cast_nullable_to_non_nullable
as String?,likedBy: null == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedItem].
extension FeedItemPatterns on FeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedItem value)  $default,){
final _that = this;
switch (_that) {
case _FeedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedItem value)?  $default,){
final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String oderId,  String userName,  String? userAvatarUrl,  FeedItemType type,  String title,  String description,  String? imageUrl,  DateTime createdAt,  String? gameType,  int? score,  bool? isWin,  Map<String, int>? gameScores,  String? achievementId,  String? achievementRarity,  List<String> likedBy,  int likesCount,  int commentsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
return $default(_that.id,_that.oderId,_that.userName,_that.userAvatarUrl,_that.type,_that.title,_that.description,_that.imageUrl,_that.createdAt,_that.gameType,_that.score,_that.isWin,_that.gameScores,_that.achievementId,_that.achievementRarity,_that.likedBy,_that.likesCount,_that.commentsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String oderId,  String userName,  String? userAvatarUrl,  FeedItemType type,  String title,  String description,  String? imageUrl,  DateTime createdAt,  String? gameType,  int? score,  bool? isWin,  Map<String, int>? gameScores,  String? achievementId,  String? achievementRarity,  List<String> likedBy,  int likesCount,  int commentsCount)  $default,) {final _that = this;
switch (_that) {
case _FeedItem():
return $default(_that.id,_that.oderId,_that.userName,_that.userAvatarUrl,_that.type,_that.title,_that.description,_that.imageUrl,_that.createdAt,_that.gameType,_that.score,_that.isWin,_that.gameScores,_that.achievementId,_that.achievementRarity,_that.likedBy,_that.likesCount,_that.commentsCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String oderId,  String userName,  String? userAvatarUrl,  FeedItemType type,  String title,  String description,  String? imageUrl,  DateTime createdAt,  String? gameType,  int? score,  bool? isWin,  Map<String, int>? gameScores,  String? achievementId,  String? achievementRarity,  List<String> likedBy,  int likesCount,  int commentsCount)?  $default,) {final _that = this;
switch (_that) {
case _FeedItem() when $default != null:
return $default(_that.id,_that.oderId,_that.userName,_that.userAvatarUrl,_that.type,_that.title,_that.description,_that.imageUrl,_that.createdAt,_that.gameType,_that.score,_that.isWin,_that.gameScores,_that.achievementId,_that.achievementRarity,_that.likedBy,_that.likesCount,_that.commentsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedItem extends FeedItem {
  const _FeedItem({required this.id, required this.oderId, required this.userName, this.userAvatarUrl, required this.type, required this.title, required this.description, this.imageUrl, required this.createdAt, this.gameType, this.score, this.isWin, final  Map<String, int>? gameScores, this.achievementId, this.achievementRarity, final  List<String> likedBy = const [], this.likesCount = 0, this.commentsCount = 0}): _gameScores = gameScores,_likedBy = likedBy,super._();
  factory _FeedItem.fromJson(Map<String, dynamic> json) => _$FeedItemFromJson(json);

@override final  String id;
@override final  String oderId;
@override final  String userName;
@override final  String? userAvatarUrl;
@override final  FeedItemType type;
@override final  String title;
@override final  String description;
@override final  String? imageUrl;
@override final  DateTime createdAt;
// Game result specific
@override final  String? gameType;
@override final  int? score;
@override final  bool? isWin;
 final  Map<String, int>? _gameScores;
@override Map<String, int>? get gameScores {
  final value = _gameScores;
  if (value == null) return null;
  if (_gameScores is EqualUnmodifiableMapView) return _gameScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Achievement specific
@override final  String? achievementId;
@override final  String? achievementRarity;
// Reactions
 final  List<String> _likedBy;
// Reactions
@override@JsonKey() List<String> get likedBy {
  if (_likedBy is EqualUnmodifiableListView) return _likedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedBy);
}

@override@JsonKey() final  int likesCount;
@override@JsonKey() final  int commentsCount;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemCopyWith<_FeedItem> get copyWith => __$FeedItemCopyWithImpl<_FeedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.score, score) || other.score == score)&&(identical(other.isWin, isWin) || other.isWin == isWin)&&const DeepCollectionEquality().equals(other._gameScores, _gameScores)&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.achievementRarity, achievementRarity) || other.achievementRarity == achievementRarity)&&const DeepCollectionEquality().equals(other._likedBy, _likedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,oderId,userName,userAvatarUrl,type,title,description,imageUrl,createdAt,gameType,score,isWin,const DeepCollectionEquality().hash(_gameScores),achievementId,achievementRarity,const DeepCollectionEquality().hash(_likedBy),likesCount,commentsCount);

@override
String toString() {
  return 'FeedItem(id: $id, oderId: $oderId, userName: $userName, userAvatarUrl: $userAvatarUrl, type: $type, title: $title, description: $description, imageUrl: $imageUrl, createdAt: $createdAt, gameType: $gameType, score: $score, isWin: $isWin, gameScores: $gameScores, achievementId: $achievementId, achievementRarity: $achievementRarity, likedBy: $likedBy, likesCount: $likesCount, commentsCount: $commentsCount)';
}


}

/// @nodoc
abstract mixin class _$FeedItemCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemCopyWith(_FeedItem value, $Res Function(_FeedItem) _then) = __$FeedItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String oderId, String userName, String? userAvatarUrl, FeedItemType type, String title, String description, String? imageUrl, DateTime createdAt, String? gameType, int? score, bool? isWin, Map<String, int>? gameScores, String? achievementId, String? achievementRarity, List<String> likedBy, int likesCount, int commentsCount
});




}
/// @nodoc
class __$FeedItemCopyWithImpl<$Res>
    implements _$FeedItemCopyWith<$Res> {
  __$FeedItemCopyWithImpl(this._self, this._then);

  final _FeedItem _self;
  final $Res Function(_FeedItem) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? oderId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? type = null,Object? title = null,Object? description = null,Object? imageUrl = freezed,Object? createdAt = null,Object? gameType = freezed,Object? score = freezed,Object? isWin = freezed,Object? gameScores = freezed,Object? achievementId = freezed,Object? achievementRarity = freezed,Object? likedBy = null,Object? likesCount = null,Object? commentsCount = null,}) {
  return _then(_FeedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FeedItemType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,score: freezed == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int?,isWin: freezed == isWin ? _self.isWin : isWin // ignore: cast_nullable_to_non_nullable
as bool?,gameScores: freezed == gameScores ? _self._gameScores : gameScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,achievementId: freezed == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String?,achievementRarity: freezed == achievementRarity ? _self.achievementRarity : achievementRarity // ignore: cast_nullable_to_non_nullable
as String?,likedBy: null == likedBy ? _self._likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

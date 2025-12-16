// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialUser {

 String get id; String get displayName; String? get avatarUrl;// Presence
 UserStatus get status;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get lastSeen;// Current Activity
 String? get currentActivityType;// 'game', 'voice_room'
 String? get currentActivityId;// roomId
 String? get currentActivityName;// 'Playing Marriage'
 bool get isFriend;
/// Create a copy of SocialUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialUserCopyWith<SocialUser> get copyWith => _$SocialUserCopyWithImpl<SocialUser>(this as SocialUser, _$identity);

  /// Serializes this SocialUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialUser&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.currentActivityType, currentActivityType) || other.currentActivityType == currentActivityType)&&(identical(other.currentActivityId, currentActivityId) || other.currentActivityId == currentActivityId)&&(identical(other.currentActivityName, currentActivityName) || other.currentActivityName == currentActivityName)&&(identical(other.isFriend, isFriend) || other.isFriend == isFriend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,avatarUrl,status,lastSeen,currentActivityType,currentActivityId,currentActivityName,isFriend);

@override
String toString() {
  return 'SocialUser(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, status: $status, lastSeen: $lastSeen, currentActivityType: $currentActivityType, currentActivityId: $currentActivityId, currentActivityName: $currentActivityName, isFriend: $isFriend)';
}


}

/// @nodoc
abstract mixin class $SocialUserCopyWith<$Res>  {
  factory $SocialUserCopyWith(SocialUser value, $Res Function(SocialUser) _then) = _$SocialUserCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String? avatarUrl, UserStatus status,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastSeen, String? currentActivityType, String? currentActivityId, String? currentActivityName, bool isFriend
});




}
/// @nodoc
class _$SocialUserCopyWithImpl<$Res>
    implements $SocialUserCopyWith<$Res> {
  _$SocialUserCopyWithImpl(this._self, this._then);

  final SocialUser _self;
  final $Res Function(SocialUser) _then;

/// Create a copy of SocialUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = freezed,Object? status = null,Object? lastSeen = freezed,Object? currentActivityType = freezed,Object? currentActivityId = freezed,Object? currentActivityName = freezed,Object? isFriend = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,currentActivityType: freezed == currentActivityType ? _self.currentActivityType : currentActivityType // ignore: cast_nullable_to_non_nullable
as String?,currentActivityId: freezed == currentActivityId ? _self.currentActivityId : currentActivityId // ignore: cast_nullable_to_non_nullable
as String?,currentActivityName: freezed == currentActivityName ? _self.currentActivityName : currentActivityName // ignore: cast_nullable_to_non_nullable
as String?,isFriend: null == isFriend ? _self.isFriend : isFriend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialUser].
extension SocialUserPatterns on SocialUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialUser value)  $default,){
final _that = this;
switch (_that) {
case _SocialUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialUser value)?  $default,){
final _that = this;
switch (_that) {
case _SocialUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String? avatarUrl,  UserStatus status, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastSeen,  String? currentActivityType,  String? currentActivityId,  String? currentActivityName,  bool isFriend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialUser() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.status,_that.lastSeen,_that.currentActivityType,_that.currentActivityId,_that.currentActivityName,_that.isFriend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String? avatarUrl,  UserStatus status, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastSeen,  String? currentActivityType,  String? currentActivityId,  String? currentActivityName,  bool isFriend)  $default,) {final _that = this;
switch (_that) {
case _SocialUser():
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.status,_that.lastSeen,_that.currentActivityType,_that.currentActivityId,_that.currentActivityName,_that.isFriend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String? avatarUrl,  UserStatus status, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastSeen,  String? currentActivityType,  String? currentActivityId,  String? currentActivityName,  bool isFriend)?  $default,) {final _that = this;
switch (_that) {
case _SocialUser() when $default != null:
return $default(_that.id,_that.displayName,_that.avatarUrl,_that.status,_that.lastSeen,_that.currentActivityType,_that.currentActivityId,_that.currentActivityName,_that.isFriend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialUser extends SocialUser {
  const _SocialUser({required this.id, required this.displayName, this.avatarUrl, this.status = UserStatus.offline, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.lastSeen, this.currentActivityType, this.currentActivityId, this.currentActivityName, this.isFriend = false}): super._();
  factory _SocialUser.fromJson(Map<String, dynamic> json) => _$SocialUserFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String? avatarUrl;
// Presence
@override@JsonKey() final  UserStatus status;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? lastSeen;
// Current Activity
@override final  String? currentActivityType;
// 'game', 'voice_room'
@override final  String? currentActivityId;
// roomId
@override final  String? currentActivityName;
// 'Playing Marriage'
@override@JsonKey() final  bool isFriend;

/// Create a copy of SocialUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialUserCopyWith<_SocialUser> get copyWith => __$SocialUserCopyWithImpl<_SocialUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialUser&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.currentActivityType, currentActivityType) || other.currentActivityType == currentActivityType)&&(identical(other.currentActivityId, currentActivityId) || other.currentActivityId == currentActivityId)&&(identical(other.currentActivityName, currentActivityName) || other.currentActivityName == currentActivityName)&&(identical(other.isFriend, isFriend) || other.isFriend == isFriend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,avatarUrl,status,lastSeen,currentActivityType,currentActivityId,currentActivityName,isFriend);

@override
String toString() {
  return 'SocialUser(id: $id, displayName: $displayName, avatarUrl: $avatarUrl, status: $status, lastSeen: $lastSeen, currentActivityType: $currentActivityType, currentActivityId: $currentActivityId, currentActivityName: $currentActivityName, isFriend: $isFriend)';
}


}

/// @nodoc
abstract mixin class _$SocialUserCopyWith<$Res> implements $SocialUserCopyWith<$Res> {
  factory _$SocialUserCopyWith(_SocialUser value, $Res Function(_SocialUser) _then) = __$SocialUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String? avatarUrl, UserStatus status,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastSeen, String? currentActivityType, String? currentActivityId, String? currentActivityName, bool isFriend
});




}
/// @nodoc
class __$SocialUserCopyWithImpl<$Res>
    implements _$SocialUserCopyWith<$Res> {
  __$SocialUserCopyWithImpl(this._self, this._then);

  final _SocialUser _self;
  final $Res Function(_SocialUser) _then;

/// Create a copy of SocialUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? avatarUrl = freezed,Object? status = null,Object? lastSeen = freezed,Object? currentActivityType = freezed,Object? currentActivityId = freezed,Object? currentActivityName = freezed,Object? isFriend = null,}) {
  return _then(_SocialUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,currentActivityType: freezed == currentActivityType ? _self.currentActivityType : currentActivityType // ignore: cast_nullable_to_non_nullable
as String?,currentActivityId: freezed == currentActivityId ? _self.currentActivityId : currentActivityId // ignore: cast_nullable_to_non_nullable
as String?,currentActivityName: freezed == currentActivityName ? _self.currentActivityName : currentActivityName // ignore: cast_nullable_to_non_nullable
as String?,isFriend: null == isFriend ? _self.isFriend : isFriend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

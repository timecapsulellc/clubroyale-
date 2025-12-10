// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoiceParticipant {

 String get id; String get name; String? get photoUrl; bool get isMuted; bool get isSpeaking; bool get isDeafened; DateTime? get joinedAt;
/// Create a copy of VoiceParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceParticipantCopyWith<VoiceParticipant> get copyWith => _$VoiceParticipantCopyWithImpl<VoiceParticipant>(this as VoiceParticipant, _$identity);

  /// Serializes this VoiceParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.isDeafened, isDeafened) || other.isDeafened == isDeafened)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,isMuted,isSpeaking,isDeafened,joinedAt);

@override
String toString() {
  return 'VoiceParticipant(id: $id, name: $name, photoUrl: $photoUrl, isMuted: $isMuted, isSpeaking: $isSpeaking, isDeafened: $isDeafened, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $VoiceParticipantCopyWith<$Res>  {
  factory $VoiceParticipantCopyWith(VoiceParticipant value, $Res Function(VoiceParticipant) _then) = _$VoiceParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? photoUrl, bool isMuted, bool isSpeaking, bool isDeafened, DateTime? joinedAt
});




}
/// @nodoc
class _$VoiceParticipantCopyWithImpl<$Res>
    implements $VoiceParticipantCopyWith<$Res> {
  _$VoiceParticipantCopyWithImpl(this._self, this._then);

  final VoiceParticipant _self;
  final $Res Function(VoiceParticipant) _then;

/// Create a copy of VoiceParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? isMuted = null,Object? isSpeaking = null,Object? isDeafened = null,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,isDeafened: null == isDeafened ? _self.isDeafened : isDeafened // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceParticipant].
extension VoiceParticipantPatterns on VoiceParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceParticipant value)  $default,){
final _that = this;
switch (_that) {
case _VoiceParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  bool isMuted,  bool isSpeaking,  bool isDeafened,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceParticipant() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.isMuted,_that.isSpeaking,_that.isDeafened,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? photoUrl,  bool isMuted,  bool isSpeaking,  bool isDeafened,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _VoiceParticipant():
return $default(_that.id,_that.name,_that.photoUrl,_that.isMuted,_that.isSpeaking,_that.isDeafened,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? photoUrl,  bool isMuted,  bool isSpeaking,  bool isDeafened,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _VoiceParticipant() when $default != null:
return $default(_that.id,_that.name,_that.photoUrl,_that.isMuted,_that.isSpeaking,_that.isDeafened,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceParticipant extends VoiceParticipant {
  const _VoiceParticipant({required this.id, required this.name, this.photoUrl, this.isMuted = false, this.isSpeaking = false, this.isDeafened = false, this.joinedAt}): super._();
  factory _VoiceParticipant.fromJson(Map<String, dynamic> json) => _$VoiceParticipantFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? photoUrl;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool isSpeaking;
@override@JsonKey() final  bool isDeafened;
@override final  DateTime? joinedAt;

/// Create a copy of VoiceParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceParticipantCopyWith<_VoiceParticipant> get copyWith => __$VoiceParticipantCopyWithImpl<_VoiceParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceParticipant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.isSpeaking, isSpeaking) || other.isSpeaking == isSpeaking)&&(identical(other.isDeafened, isDeafened) || other.isDeafened == isDeafened)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,photoUrl,isMuted,isSpeaking,isDeafened,joinedAt);

@override
String toString() {
  return 'VoiceParticipant(id: $id, name: $name, photoUrl: $photoUrl, isMuted: $isMuted, isSpeaking: $isSpeaking, isDeafened: $isDeafened, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$VoiceParticipantCopyWith<$Res> implements $VoiceParticipantCopyWith<$Res> {
  factory _$VoiceParticipantCopyWith(_VoiceParticipant value, $Res Function(_VoiceParticipant) _then) = __$VoiceParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? photoUrl, bool isMuted, bool isSpeaking, bool isDeafened, DateTime? joinedAt
});




}
/// @nodoc
class __$VoiceParticipantCopyWithImpl<$Res>
    implements _$VoiceParticipantCopyWith<$Res> {
  __$VoiceParticipantCopyWithImpl(this._self, this._then);

  final _VoiceParticipant _self;
  final $Res Function(_VoiceParticipant) _then;

/// Create a copy of VoiceParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? photoUrl = freezed,Object? isMuted = null,Object? isSpeaking = null,Object? isDeafened = null,Object? joinedAt = freezed,}) {
  return _then(_VoiceParticipant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,isSpeaking: null == isSpeaking ? _self.isSpeaking : isSpeaking // ignore: cast_nullable_to_non_nullable
as bool,isDeafened: null == isDeafened ? _self.isDeafened : isDeafened // ignore: cast_nullable_to_non_nullable
as bool,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$VoiceRoom {

 String get id; String get name; String? get description; String get hostId; String get hostName; Map<String, VoiceParticipant> get participants; int get maxParticipants; DateTime get createdAt; bool get isActive; bool get isPrivate; String? get linkedGameId; String? get linkedLobbyId;
/// Create a copy of VoiceRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceRoomCopyWith<VoiceRoom> get copyWith => _$VoiceRoomCopyWithImpl<VoiceRoom>(this as VoiceRoom, _$identity);

  /// Serializes this VoiceRoom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.linkedGameId, linkedGameId) || other.linkedGameId == linkedGameId)&&(identical(other.linkedLobbyId, linkedLobbyId) || other.linkedLobbyId == linkedLobbyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,hostId,hostName,const DeepCollectionEquality().hash(participants),maxParticipants,createdAt,isActive,isPrivate,linkedGameId,linkedLobbyId);

@override
String toString() {
  return 'VoiceRoom(id: $id, name: $name, description: $description, hostId: $hostId, hostName: $hostName, participants: $participants, maxParticipants: $maxParticipants, createdAt: $createdAt, isActive: $isActive, isPrivate: $isPrivate, linkedGameId: $linkedGameId, linkedLobbyId: $linkedLobbyId)';
}


}

/// @nodoc
abstract mixin class $VoiceRoomCopyWith<$Res>  {
  factory $VoiceRoomCopyWith(VoiceRoom value, $Res Function(VoiceRoom) _then) = _$VoiceRoomCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String hostId, String hostName, Map<String, VoiceParticipant> participants, int maxParticipants, DateTime createdAt, bool isActive, bool isPrivate, String? linkedGameId, String? linkedLobbyId
});




}
/// @nodoc
class _$VoiceRoomCopyWithImpl<$Res>
    implements $VoiceRoomCopyWith<$Res> {
  _$VoiceRoomCopyWithImpl(this._self, this._then);

  final VoiceRoom _self;
  final $Res Function(VoiceRoom) _then;

/// Create a copy of VoiceRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? hostId = null,Object? hostName = null,Object? participants = null,Object? maxParticipants = null,Object? createdAt = null,Object? isActive = null,Object? isPrivate = null,Object? linkedGameId = freezed,Object? linkedLobbyId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as Map<String, VoiceParticipant>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,linkedGameId: freezed == linkedGameId ? _self.linkedGameId : linkedGameId // ignore: cast_nullable_to_non_nullable
as String?,linkedLobbyId: freezed == linkedLobbyId ? _self.linkedLobbyId : linkedLobbyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceRoom].
extension VoiceRoomPatterns on VoiceRoom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceRoom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceRoom value)  $default,){
final _that = this;
switch (_that) {
case _VoiceRoom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceRoom value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceRoom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String hostId,  String hostName,  Map<String, VoiceParticipant> participants,  int maxParticipants,  DateTime createdAt,  bool isActive,  bool isPrivate,  String? linkedGameId,  String? linkedLobbyId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceRoom() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.hostId,_that.hostName,_that.participants,_that.maxParticipants,_that.createdAt,_that.isActive,_that.isPrivate,_that.linkedGameId,_that.linkedLobbyId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String hostId,  String hostName,  Map<String, VoiceParticipant> participants,  int maxParticipants,  DateTime createdAt,  bool isActive,  bool isPrivate,  String? linkedGameId,  String? linkedLobbyId)  $default,) {final _that = this;
switch (_that) {
case _VoiceRoom():
return $default(_that.id,_that.name,_that.description,_that.hostId,_that.hostName,_that.participants,_that.maxParticipants,_that.createdAt,_that.isActive,_that.isPrivate,_that.linkedGameId,_that.linkedLobbyId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String hostId,  String hostName,  Map<String, VoiceParticipant> participants,  int maxParticipants,  DateTime createdAt,  bool isActive,  bool isPrivate,  String? linkedGameId,  String? linkedLobbyId)?  $default,) {final _that = this;
switch (_that) {
case _VoiceRoom() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.hostId,_that.hostName,_that.participants,_that.maxParticipants,_that.createdAt,_that.isActive,_that.isPrivate,_that.linkedGameId,_that.linkedLobbyId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceRoom extends VoiceRoom {
  const _VoiceRoom({required this.id, required this.name, this.description, required this.hostId, required this.hostName, final  Map<String, VoiceParticipant> participants = const {}, this.maxParticipants = 8, required this.createdAt, this.isActive = true, this.isPrivate = false, this.linkedGameId, this.linkedLobbyId}): _participants = participants,super._();
  factory _VoiceRoom.fromJson(Map<String, dynamic> json) => _$VoiceRoomFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String hostId;
@override final  String hostName;
 final  Map<String, VoiceParticipant> _participants;
@override@JsonKey() Map<String, VoiceParticipant> get participants {
  if (_participants is EqualUnmodifiableMapView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_participants);
}

@override@JsonKey() final  int maxParticipants;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isPrivate;
@override final  String? linkedGameId;
@override final  String? linkedLobbyId;

/// Create a copy of VoiceRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceRoomCopyWith<_VoiceRoom> get copyWith => __$VoiceRoomCopyWithImpl<_VoiceRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.linkedGameId, linkedGameId) || other.linkedGameId == linkedGameId)&&(identical(other.linkedLobbyId, linkedLobbyId) || other.linkedLobbyId == linkedLobbyId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,hostId,hostName,const DeepCollectionEquality().hash(_participants),maxParticipants,createdAt,isActive,isPrivate,linkedGameId,linkedLobbyId);

@override
String toString() {
  return 'VoiceRoom(id: $id, name: $name, description: $description, hostId: $hostId, hostName: $hostName, participants: $participants, maxParticipants: $maxParticipants, createdAt: $createdAt, isActive: $isActive, isPrivate: $isPrivate, linkedGameId: $linkedGameId, linkedLobbyId: $linkedLobbyId)';
}


}

/// @nodoc
abstract mixin class _$VoiceRoomCopyWith<$Res> implements $VoiceRoomCopyWith<$Res> {
  factory _$VoiceRoomCopyWith(_VoiceRoom value, $Res Function(_VoiceRoom) _then) = __$VoiceRoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String hostId, String hostName, Map<String, VoiceParticipant> participants, int maxParticipants, DateTime createdAt, bool isActive, bool isPrivate, String? linkedGameId, String? linkedLobbyId
});




}
/// @nodoc
class __$VoiceRoomCopyWithImpl<$Res>
    implements _$VoiceRoomCopyWith<$Res> {
  __$VoiceRoomCopyWithImpl(this._self, this._then);

  final _VoiceRoom _self;
  final $Res Function(_VoiceRoom) _then;

/// Create a copy of VoiceRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? hostId = null,Object? hostName = null,Object? participants = null,Object? maxParticipants = null,Object? createdAt = null,Object? isActive = null,Object? isPrivate = null,Object? linkedGameId = freezed,Object? linkedLobbyId = freezed,}) {
  return _then(_VoiceRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as Map<String, VoiceParticipant>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,linkedGameId: freezed == linkedGameId ? _self.linkedGameId : linkedGameId // ignore: cast_nullable_to_non_nullable
as String?,linkedLobbyId: freezed == linkedLobbyId ? _self.linkedLobbyId : linkedLobbyId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

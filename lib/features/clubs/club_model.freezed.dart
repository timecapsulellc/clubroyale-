// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Club {

 String get id; String get name; String get description; String get ownerId; String get ownerName; String? get avatarUrl; String? get bannerUrl; String? get chatId;// Link to Social Chat
 ClubPrivacy get privacy; List<String> get memberIds; int get memberCount; List<String> get gameTypes; String? get discordLink; String? get rules; DateTime? get createdAt; bool get isVerified; int get totalGamesPlayed; int get weeklyActiveMembers;
/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubCopyWith<Club> get copyWith => _$ClubCopyWithImpl<Club>(this as Club, _$identity);

  /// Serializes this Club to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Club&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&const DeepCollectionEquality().equals(other.gameTypes, gameTypes)&&(identical(other.discordLink, discordLink) || other.discordLink == discordLink)&&(identical(other.rules, rules) || other.rules == rules)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.totalGamesPlayed, totalGamesPlayed) || other.totalGamesPlayed == totalGamesPlayed)&&(identical(other.weeklyActiveMembers, weeklyActiveMembers) || other.weeklyActiveMembers == weeklyActiveMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,ownerId,ownerName,avatarUrl,bannerUrl,chatId,privacy,const DeepCollectionEquality().hash(memberIds),memberCount,const DeepCollectionEquality().hash(gameTypes),discordLink,rules,createdAt,isVerified,totalGamesPlayed,weeklyActiveMembers);

@override
String toString() {
  return 'Club(id: $id, name: $name, description: $description, ownerId: $ownerId, ownerName: $ownerName, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, chatId: $chatId, privacy: $privacy, memberIds: $memberIds, memberCount: $memberCount, gameTypes: $gameTypes, discordLink: $discordLink, rules: $rules, createdAt: $createdAt, isVerified: $isVerified, totalGamesPlayed: $totalGamesPlayed, weeklyActiveMembers: $weeklyActiveMembers)';
}


}

/// @nodoc
abstract mixin class $ClubCopyWith<$Res>  {
  factory $ClubCopyWith(Club value, $Res Function(Club) _then) = _$ClubCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String ownerId, String ownerName, String? avatarUrl, String? bannerUrl, String? chatId, ClubPrivacy privacy, List<String> memberIds, int memberCount, List<String> gameTypes, String? discordLink, String? rules, DateTime? createdAt, bool isVerified, int totalGamesPlayed, int weeklyActiveMembers
});




}
/// @nodoc
class _$ClubCopyWithImpl<$Res>
    implements $ClubCopyWith<$Res> {
  _$ClubCopyWithImpl(this._self, this._then);

  final Club _self;
  final $Res Function(Club) _then;

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? ownerId = null,Object? ownerName = null,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? chatId = freezed,Object? privacy = null,Object? memberIds = null,Object? memberCount = null,Object? gameTypes = null,Object? discordLink = freezed,Object? rules = freezed,Object? createdAt = freezed,Object? isVerified = null,Object? totalGamesPlayed = null,Object? weeklyActiveMembers = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,chatId: freezed == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ClubPrivacy,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,gameTypes: null == gameTypes ? _self.gameTypes : gameTypes // ignore: cast_nullable_to_non_nullable
as List<String>,discordLink: freezed == discordLink ? _self.discordLink : discordLink // ignore: cast_nullable_to_non_nullable
as String?,rules: freezed == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,totalGamesPlayed: null == totalGamesPlayed ? _self.totalGamesPlayed : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,weeklyActiveMembers: null == weeklyActiveMembers ? _self.weeklyActiveMembers : weeklyActiveMembers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Club].
extension ClubPatterns on Club {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Club value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Club() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Club value)  $default,){
final _that = this;
switch (_that) {
case _Club():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Club value)?  $default,){
final _that = this;
switch (_that) {
case _Club() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String ownerId,  String ownerName,  String? avatarUrl,  String? bannerUrl,  String? chatId,  ClubPrivacy privacy,  List<String> memberIds,  int memberCount,  List<String> gameTypes,  String? discordLink,  String? rules,  DateTime? createdAt,  bool isVerified,  int totalGamesPlayed,  int weeklyActiveMembers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Club() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.ownerId,_that.ownerName,_that.avatarUrl,_that.bannerUrl,_that.chatId,_that.privacy,_that.memberIds,_that.memberCount,_that.gameTypes,_that.discordLink,_that.rules,_that.createdAt,_that.isVerified,_that.totalGamesPlayed,_that.weeklyActiveMembers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String ownerId,  String ownerName,  String? avatarUrl,  String? bannerUrl,  String? chatId,  ClubPrivacy privacy,  List<String> memberIds,  int memberCount,  List<String> gameTypes,  String? discordLink,  String? rules,  DateTime? createdAt,  bool isVerified,  int totalGamesPlayed,  int weeklyActiveMembers)  $default,) {final _that = this;
switch (_that) {
case _Club():
return $default(_that.id,_that.name,_that.description,_that.ownerId,_that.ownerName,_that.avatarUrl,_that.bannerUrl,_that.chatId,_that.privacy,_that.memberIds,_that.memberCount,_that.gameTypes,_that.discordLink,_that.rules,_that.createdAt,_that.isVerified,_that.totalGamesPlayed,_that.weeklyActiveMembers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String ownerId,  String ownerName,  String? avatarUrl,  String? bannerUrl,  String? chatId,  ClubPrivacy privacy,  List<String> memberIds,  int memberCount,  List<String> gameTypes,  String? discordLink,  String? rules,  DateTime? createdAt,  bool isVerified,  int totalGamesPlayed,  int weeklyActiveMembers)?  $default,) {final _that = this;
switch (_that) {
case _Club() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.ownerId,_that.ownerName,_that.avatarUrl,_that.bannerUrl,_that.chatId,_that.privacy,_that.memberIds,_that.memberCount,_that.gameTypes,_that.discordLink,_that.rules,_that.createdAt,_that.isVerified,_that.totalGamesPlayed,_that.weeklyActiveMembers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Club extends Club {
  const _Club({required this.id, required this.name, required this.description, required this.ownerId, required this.ownerName, this.avatarUrl, this.bannerUrl, this.chatId, this.privacy = ClubPrivacy.public, final  List<String> memberIds = const [], this.memberCount = 0, final  List<String> gameTypes = const [], this.discordLink, this.rules, this.createdAt, this.isVerified = false, this.totalGamesPlayed = 0, this.weeklyActiveMembers = 0}): _memberIds = memberIds,_gameTypes = gameTypes,super._();
  factory _Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String ownerId;
@override final  String ownerName;
@override final  String? avatarUrl;
@override final  String? bannerUrl;
@override final  String? chatId;
// Link to Social Chat
@override@JsonKey() final  ClubPrivacy privacy;
 final  List<String> _memberIds;
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override@JsonKey() final  int memberCount;
 final  List<String> _gameTypes;
@override@JsonKey() List<String> get gameTypes {
  if (_gameTypes is EqualUnmodifiableListView) return _gameTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gameTypes);
}

@override final  String? discordLink;
@override final  String? rules;
@override final  DateTime? createdAt;
@override@JsonKey() final  bool isVerified;
@override@JsonKey() final  int totalGamesPlayed;
@override@JsonKey() final  int weeklyActiveMembers;

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubCopyWith<_Club> get copyWith => __$ClubCopyWithImpl<_Club>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Club&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.privacy, privacy) || other.privacy == privacy)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&const DeepCollectionEquality().equals(other._gameTypes, _gameTypes)&&(identical(other.discordLink, discordLink) || other.discordLink == discordLink)&&(identical(other.rules, rules) || other.rules == rules)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.totalGamesPlayed, totalGamesPlayed) || other.totalGamesPlayed == totalGamesPlayed)&&(identical(other.weeklyActiveMembers, weeklyActiveMembers) || other.weeklyActiveMembers == weeklyActiveMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,ownerId,ownerName,avatarUrl,bannerUrl,chatId,privacy,const DeepCollectionEquality().hash(_memberIds),memberCount,const DeepCollectionEquality().hash(_gameTypes),discordLink,rules,createdAt,isVerified,totalGamesPlayed,weeklyActiveMembers);

@override
String toString() {
  return 'Club(id: $id, name: $name, description: $description, ownerId: $ownerId, ownerName: $ownerName, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, chatId: $chatId, privacy: $privacy, memberIds: $memberIds, memberCount: $memberCount, gameTypes: $gameTypes, discordLink: $discordLink, rules: $rules, createdAt: $createdAt, isVerified: $isVerified, totalGamesPlayed: $totalGamesPlayed, weeklyActiveMembers: $weeklyActiveMembers)';
}


}

/// @nodoc
abstract mixin class _$ClubCopyWith<$Res> implements $ClubCopyWith<$Res> {
  factory _$ClubCopyWith(_Club value, $Res Function(_Club) _then) = __$ClubCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String ownerId, String ownerName, String? avatarUrl, String? bannerUrl, String? chatId, ClubPrivacy privacy, List<String> memberIds, int memberCount, List<String> gameTypes, String? discordLink, String? rules, DateTime? createdAt, bool isVerified, int totalGamesPlayed, int weeklyActiveMembers
});




}
/// @nodoc
class __$ClubCopyWithImpl<$Res>
    implements _$ClubCopyWith<$Res> {
  __$ClubCopyWithImpl(this._self, this._then);

  final _Club _self;
  final $Res Function(_Club) _then;

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? ownerId = null,Object? ownerName = null,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? chatId = freezed,Object? privacy = null,Object? memberIds = null,Object? memberCount = null,Object? gameTypes = null,Object? discordLink = freezed,Object? rules = freezed,Object? createdAt = freezed,Object? isVerified = null,Object? totalGamesPlayed = null,Object? weeklyActiveMembers = null,}) {
  return _then(_Club(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,chatId: freezed == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String?,privacy: null == privacy ? _self.privacy : privacy // ignore: cast_nullable_to_non_nullable
as ClubPrivacy,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,gameTypes: null == gameTypes ? _self._gameTypes : gameTypes // ignore: cast_nullable_to_non_nullable
as List<String>,discordLink: freezed == discordLink ? _self.discordLink : discordLink // ignore: cast_nullable_to_non_nullable
as String?,rules: freezed == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,totalGamesPlayed: null == totalGamesPlayed ? _self.totalGamesPlayed : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
as int,weeklyActiveMembers: null == weeklyActiveMembers ? _self.weeklyActiveMembers : weeklyActiveMembers // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ClubMember {

 String get oderId; String get userName; String? get avatarUrl; ClubRole get role; DateTime? get joinedAt; int get gamesPlayedInClub; int get winsInClub; int get totalPoints; DateTime? get lastActiveAt; bool get isMuted;
/// Create a copy of ClubMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubMemberCopyWith<ClubMember> get copyWith => _$ClubMemberCopyWithImpl<ClubMember>(this as ClubMember, _$identity);

  /// Serializes this ClubMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubMember&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.gamesPlayedInClub, gamesPlayedInClub) || other.gamesPlayedInClub == gamesPlayedInClub)&&(identical(other.winsInClub, winsInClub) || other.winsInClub == winsInClub)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oderId,userName,avatarUrl,role,joinedAt,gamesPlayedInClub,winsInClub,totalPoints,lastActiveAt,isMuted);

@override
String toString() {
  return 'ClubMember(oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, role: $role, joinedAt: $joinedAt, gamesPlayedInClub: $gamesPlayedInClub, winsInClub: $winsInClub, totalPoints: $totalPoints, lastActiveAt: $lastActiveAt, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class $ClubMemberCopyWith<$Res>  {
  factory $ClubMemberCopyWith(ClubMember value, $Res Function(ClubMember) _then) = _$ClubMemberCopyWithImpl;
@useResult
$Res call({
 String oderId, String userName, String? avatarUrl, ClubRole role, DateTime? joinedAt, int gamesPlayedInClub, int winsInClub, int totalPoints, DateTime? lastActiveAt, bool isMuted
});




}
/// @nodoc
class _$ClubMemberCopyWithImpl<$Res>
    implements $ClubMemberCopyWith<$Res> {
  _$ClubMemberCopyWithImpl(this._self, this._then);

  final ClubMember _self;
  final $Res Function(ClubMember) _then;

/// Create a copy of ClubMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? role = null,Object? joinedAt = freezed,Object? gamesPlayedInClub = null,Object? winsInClub = null,Object? totalPoints = null,Object? lastActiveAt = freezed,Object? isMuted = null,}) {
  return _then(_self.copyWith(
oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ClubRole,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gamesPlayedInClub: null == gamesPlayedInClub ? _self.gamesPlayedInClub : gamesPlayedInClub // ignore: cast_nullable_to_non_nullable
as int,winsInClub: null == winsInClub ? _self.winsInClub : winsInClub // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubMember].
extension ClubMemberPatterns on ClubMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubMember value)  $default,){
final _that = this;
switch (_that) {
case _ClubMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubMember value)?  $default,){
final _that = this;
switch (_that) {
case _ClubMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String oderId,  String userName,  String? avatarUrl,  ClubRole role,  DateTime? joinedAt,  int gamesPlayedInClub,  int winsInClub,  int totalPoints,  DateTime? lastActiveAt,  bool isMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubMember() when $default != null:
return $default(_that.oderId,_that.userName,_that.avatarUrl,_that.role,_that.joinedAt,_that.gamesPlayedInClub,_that.winsInClub,_that.totalPoints,_that.lastActiveAt,_that.isMuted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String oderId,  String userName,  String? avatarUrl,  ClubRole role,  DateTime? joinedAt,  int gamesPlayedInClub,  int winsInClub,  int totalPoints,  DateTime? lastActiveAt,  bool isMuted)  $default,) {final _that = this;
switch (_that) {
case _ClubMember():
return $default(_that.oderId,_that.userName,_that.avatarUrl,_that.role,_that.joinedAt,_that.gamesPlayedInClub,_that.winsInClub,_that.totalPoints,_that.lastActiveAt,_that.isMuted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String oderId,  String userName,  String? avatarUrl,  ClubRole role,  DateTime? joinedAt,  int gamesPlayedInClub,  int winsInClub,  int totalPoints,  DateTime? lastActiveAt,  bool isMuted)?  $default,) {final _that = this;
switch (_that) {
case _ClubMember() when $default != null:
return $default(_that.oderId,_that.userName,_that.avatarUrl,_that.role,_that.joinedAt,_that.gamesPlayedInClub,_that.winsInClub,_that.totalPoints,_that.lastActiveAt,_that.isMuted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubMember extends ClubMember {
  const _ClubMember({required this.oderId, required this.userName, this.avatarUrl, this.role = ClubRole.member, this.joinedAt, this.gamesPlayedInClub = 0, this.winsInClub = 0, this.totalPoints = 0, this.lastActiveAt, this.isMuted = false}): super._();
  factory _ClubMember.fromJson(Map<String, dynamic> json) => _$ClubMemberFromJson(json);

@override final  String oderId;
@override final  String userName;
@override final  String? avatarUrl;
@override@JsonKey() final  ClubRole role;
@override final  DateTime? joinedAt;
@override@JsonKey() final  int gamesPlayedInClub;
@override@JsonKey() final  int winsInClub;
@override@JsonKey() final  int totalPoints;
@override final  DateTime? lastActiveAt;
@override@JsonKey() final  bool isMuted;

/// Create a copy of ClubMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubMemberCopyWith<_ClubMember> get copyWith => __$ClubMemberCopyWithImpl<_ClubMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubMember&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.gamesPlayedInClub, gamesPlayedInClub) || other.gamesPlayedInClub == gamesPlayedInClub)&&(identical(other.winsInClub, winsInClub) || other.winsInClub == winsInClub)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.lastActiveAt, lastActiveAt) || other.lastActiveAt == lastActiveAt)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oderId,userName,avatarUrl,role,joinedAt,gamesPlayedInClub,winsInClub,totalPoints,lastActiveAt,isMuted);

@override
String toString() {
  return 'ClubMember(oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, role: $role, joinedAt: $joinedAt, gamesPlayedInClub: $gamesPlayedInClub, winsInClub: $winsInClub, totalPoints: $totalPoints, lastActiveAt: $lastActiveAt, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class _$ClubMemberCopyWith<$Res> implements $ClubMemberCopyWith<$Res> {
  factory _$ClubMemberCopyWith(_ClubMember value, $Res Function(_ClubMember) _then) = __$ClubMemberCopyWithImpl;
@override @useResult
$Res call({
 String oderId, String userName, String? avatarUrl, ClubRole role, DateTime? joinedAt, int gamesPlayedInClub, int winsInClub, int totalPoints, DateTime? lastActiveAt, bool isMuted
});




}
/// @nodoc
class __$ClubMemberCopyWithImpl<$Res>
    implements _$ClubMemberCopyWith<$Res> {
  __$ClubMemberCopyWithImpl(this._self, this._then);

  final _ClubMember _self;
  final $Res Function(_ClubMember) _then;

/// Create a copy of ClubMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? role = null,Object? joinedAt = freezed,Object? gamesPlayedInClub = null,Object? winsInClub = null,Object? totalPoints = null,Object? lastActiveAt = freezed,Object? isMuted = null,}) {
  return _then(_ClubMember(
oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ClubRole,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,gamesPlayedInClub: null == gamesPlayedInClub ? _self.gamesPlayedInClub : gamesPlayedInClub // ignore: cast_nullable_to_non_nullable
as int,winsInClub: null == winsInClub ? _self.winsInClub : winsInClub // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,lastActiveAt: freezed == lastActiveAt ? _self.lastActiveAt : lastActiveAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ClubInvite {

 String get id; String get clubId; String get clubName; String get inviterId; String get inviterName; String get inviteeId; String? get message; DateTime? get createdAt; DateTime? get expiresAt; bool get isAccepted; bool get isDeclined;
/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubInviteCopyWith<ClubInvite> get copyWith => _$ClubInviteCopyWithImpl<ClubInvite>(this as ClubInvite, _$identity);

  /// Serializes this ClubInvite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.clubName, clubName) || other.clubName == clubName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.inviteeId, inviteeId) || other.inviteeId == inviteeId)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isAccepted, isAccepted) || other.isAccepted == isAccepted)&&(identical(other.isDeclined, isDeclined) || other.isDeclined == isDeclined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clubId,clubName,inviterId,inviterName,inviteeId,message,createdAt,expiresAt,isAccepted,isDeclined);

@override
String toString() {
  return 'ClubInvite(id: $id, clubId: $clubId, clubName: $clubName, inviterId: $inviterId, inviterName: $inviterName, inviteeId: $inviteeId, message: $message, createdAt: $createdAt, expiresAt: $expiresAt, isAccepted: $isAccepted, isDeclined: $isDeclined)';
}


}

/// @nodoc
abstract mixin class $ClubInviteCopyWith<$Res>  {
  factory $ClubInviteCopyWith(ClubInvite value, $Res Function(ClubInvite) _then) = _$ClubInviteCopyWithImpl;
@useResult
$Res call({
 String id, String clubId, String clubName, String inviterId, String inviterName, String inviteeId, String? message, DateTime? createdAt, DateTime? expiresAt, bool isAccepted, bool isDeclined
});




}
/// @nodoc
class _$ClubInviteCopyWithImpl<$Res>
    implements $ClubInviteCopyWith<$Res> {
  _$ClubInviteCopyWithImpl(this._self, this._then);

  final ClubInvite _self;
  final $Res Function(ClubInvite) _then;

/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clubId = null,Object? clubName = null,Object? inviterId = null,Object? inviterName = null,Object? inviteeId = null,Object? message = freezed,Object? createdAt = freezed,Object? expiresAt = freezed,Object? isAccepted = null,Object? isDeclined = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,clubName: null == clubName ? _self.clubName : clubName // ignore: cast_nullable_to_non_nullable
as String,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,inviterName: null == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String,inviteeId: null == inviteeId ? _self.inviteeId : inviteeId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAccepted: null == isAccepted ? _self.isAccepted : isAccepted // ignore: cast_nullable_to_non_nullable
as bool,isDeclined: null == isDeclined ? _self.isDeclined : isDeclined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubInvite].
extension ClubInvitePatterns on ClubInvite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubInvite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubInvite value)  $default,){
final _that = this;
switch (_that) {
case _ClubInvite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubInvite value)?  $default,){
final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clubId,  String clubName,  String inviterId,  String inviterName,  String inviteeId,  String? message,  DateTime? createdAt,  DateTime? expiresAt,  bool isAccepted,  bool isDeclined)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
return $default(_that.id,_that.clubId,_that.clubName,_that.inviterId,_that.inviterName,_that.inviteeId,_that.message,_that.createdAt,_that.expiresAt,_that.isAccepted,_that.isDeclined);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clubId,  String clubName,  String inviterId,  String inviterName,  String inviteeId,  String? message,  DateTime? createdAt,  DateTime? expiresAt,  bool isAccepted,  bool isDeclined)  $default,) {final _that = this;
switch (_that) {
case _ClubInvite():
return $default(_that.id,_that.clubId,_that.clubName,_that.inviterId,_that.inviterName,_that.inviteeId,_that.message,_that.createdAt,_that.expiresAt,_that.isAccepted,_that.isDeclined);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clubId,  String clubName,  String inviterId,  String inviterName,  String inviteeId,  String? message,  DateTime? createdAt,  DateTime? expiresAt,  bool isAccepted,  bool isDeclined)?  $default,) {final _that = this;
switch (_that) {
case _ClubInvite() when $default != null:
return $default(_that.id,_that.clubId,_that.clubName,_that.inviterId,_that.inviterName,_that.inviteeId,_that.message,_that.createdAt,_that.expiresAt,_that.isAccepted,_that.isDeclined);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubInvite extends ClubInvite {
  const _ClubInvite({required this.id, required this.clubId, required this.clubName, required this.inviterId, required this.inviterName, required this.inviteeId, this.message, this.createdAt, this.expiresAt, this.isAccepted = false, this.isDeclined = false}): super._();
  factory _ClubInvite.fromJson(Map<String, dynamic> json) => _$ClubInviteFromJson(json);

@override final  String id;
@override final  String clubId;
@override final  String clubName;
@override final  String inviterId;
@override final  String inviterName;
@override final  String inviteeId;
@override final  String? message;
@override final  DateTime? createdAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool isAccepted;
@override@JsonKey() final  bool isDeclined;

/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubInviteCopyWith<_ClubInvite> get copyWith => __$ClubInviteCopyWithImpl<_ClubInvite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubInviteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubInvite&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.clubName, clubName) || other.clubName == clubName)&&(identical(other.inviterId, inviterId) || other.inviterId == inviterId)&&(identical(other.inviterName, inviterName) || other.inviterName == inviterName)&&(identical(other.inviteeId, inviteeId) || other.inviteeId == inviteeId)&&(identical(other.message, message) || other.message == message)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isAccepted, isAccepted) || other.isAccepted == isAccepted)&&(identical(other.isDeclined, isDeclined) || other.isDeclined == isDeclined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clubId,clubName,inviterId,inviterName,inviteeId,message,createdAt,expiresAt,isAccepted,isDeclined);

@override
String toString() {
  return 'ClubInvite(id: $id, clubId: $clubId, clubName: $clubName, inviterId: $inviterId, inviterName: $inviterName, inviteeId: $inviteeId, message: $message, createdAt: $createdAt, expiresAt: $expiresAt, isAccepted: $isAccepted, isDeclined: $isDeclined)';
}


}

/// @nodoc
abstract mixin class _$ClubInviteCopyWith<$Res> implements $ClubInviteCopyWith<$Res> {
  factory _$ClubInviteCopyWith(_ClubInvite value, $Res Function(_ClubInvite) _then) = __$ClubInviteCopyWithImpl;
@override @useResult
$Res call({
 String id, String clubId, String clubName, String inviterId, String inviterName, String inviteeId, String? message, DateTime? createdAt, DateTime? expiresAt, bool isAccepted, bool isDeclined
});




}
/// @nodoc
class __$ClubInviteCopyWithImpl<$Res>
    implements _$ClubInviteCopyWith<$Res> {
  __$ClubInviteCopyWithImpl(this._self, this._then);

  final _ClubInvite _self;
  final $Res Function(_ClubInvite) _then;

/// Create a copy of ClubInvite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clubId = null,Object? clubName = null,Object? inviterId = null,Object? inviterName = null,Object? inviteeId = null,Object? message = freezed,Object? createdAt = freezed,Object? expiresAt = freezed,Object? isAccepted = null,Object? isDeclined = null,}) {
  return _then(_ClubInvite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,clubName: null == clubName ? _self.clubName : clubName // ignore: cast_nullable_to_non_nullable
as String,inviterId: null == inviterId ? _self.inviterId : inviterId // ignore: cast_nullable_to_non_nullable
as String,inviterName: null == inviterName ? _self.inviterName : inviterName // ignore: cast_nullable_to_non_nullable
as String,inviteeId: null == inviteeId ? _self.inviteeId : inviteeId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAccepted: null == isAccepted ? _self.isAccepted : isAccepted // ignore: cast_nullable_to_non_nullable
as bool,isDeclined: null == isDeclined ? _self.isDeclined : isDeclined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ClubLeaderboardEntry {

 int get rank; String get oderId; String get userName; String? get avatarUrl; int get games; int get wins; int get points; double? get winRate;
/// Create a copy of ClubLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubLeaderboardEntryCopyWith<ClubLeaderboardEntry> get copyWith => _$ClubLeaderboardEntryCopyWithImpl<ClubLeaderboardEntry>(this as ClubLeaderboardEntry, _$identity);

  /// Serializes this ClubLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubLeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.games, games) || other.games == games)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.points, points) || other.points == points)&&(identical(other.winRate, winRate) || other.winRate == winRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,oderId,userName,avatarUrl,games,wins,points,winRate);

@override
String toString() {
  return 'ClubLeaderboardEntry(rank: $rank, oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, games: $games, wins: $wins, points: $points, winRate: $winRate)';
}


}

/// @nodoc
abstract mixin class $ClubLeaderboardEntryCopyWith<$Res>  {
  factory $ClubLeaderboardEntryCopyWith(ClubLeaderboardEntry value, $Res Function(ClubLeaderboardEntry) _then) = _$ClubLeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 int rank, String oderId, String userName, String? avatarUrl, int games, int wins, int points, double? winRate
});




}
/// @nodoc
class _$ClubLeaderboardEntryCopyWithImpl<$Res>
    implements $ClubLeaderboardEntryCopyWith<$Res> {
  _$ClubLeaderboardEntryCopyWithImpl(this._self, this._then);

  final ClubLeaderboardEntry _self;
  final $Res Function(ClubLeaderboardEntry) _then;

/// Create a copy of ClubLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? games = null,Object? wins = null,Object? points = null,Object? winRate = freezed,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,games: null == games ? _self.games : games // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,winRate: freezed == winRate ? _self.winRate : winRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubLeaderboardEntry].
extension ClubLeaderboardEntryPatterns on ClubLeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubLeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubLeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _ClubLeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubLeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ClubLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String oderId,  String userName,  String? avatarUrl,  int games,  int wins,  int points,  double? winRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubLeaderboardEntry() when $default != null:
return $default(_that.rank,_that.oderId,_that.userName,_that.avatarUrl,_that.games,_that.wins,_that.points,_that.winRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String oderId,  String userName,  String? avatarUrl,  int games,  int wins,  int points,  double? winRate)  $default,) {final _that = this;
switch (_that) {
case _ClubLeaderboardEntry():
return $default(_that.rank,_that.oderId,_that.userName,_that.avatarUrl,_that.games,_that.wins,_that.points,_that.winRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String oderId,  String userName,  String? avatarUrl,  int games,  int wins,  int points,  double? winRate)?  $default,) {final _that = this;
switch (_that) {
case _ClubLeaderboardEntry() when $default != null:
return $default(_that.rank,_that.oderId,_that.userName,_that.avatarUrl,_that.games,_that.wins,_that.points,_that.winRate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubLeaderboardEntry extends ClubLeaderboardEntry {
  const _ClubLeaderboardEntry({required this.rank, required this.oderId, required this.userName, this.avatarUrl, required this.games, required this.wins, required this.points, this.winRate}): super._();
  factory _ClubLeaderboardEntry.fromJson(Map<String, dynamic> json) => _$ClubLeaderboardEntryFromJson(json);

@override final  int rank;
@override final  String oderId;
@override final  String userName;
@override final  String? avatarUrl;
@override final  int games;
@override final  int wins;
@override final  int points;
@override final  double? winRate;

/// Create a copy of ClubLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubLeaderboardEntryCopyWith<_ClubLeaderboardEntry> get copyWith => __$ClubLeaderboardEntryCopyWithImpl<_ClubLeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubLeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubLeaderboardEntry&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.games, games) || other.games == games)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.points, points) || other.points == points)&&(identical(other.winRate, winRate) || other.winRate == winRate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,oderId,userName,avatarUrl,games,wins,points,winRate);

@override
String toString() {
  return 'ClubLeaderboardEntry(rank: $rank, oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, games: $games, wins: $wins, points: $points, winRate: $winRate)';
}


}

/// @nodoc
abstract mixin class _$ClubLeaderboardEntryCopyWith<$Res> implements $ClubLeaderboardEntryCopyWith<$Res> {
  factory _$ClubLeaderboardEntryCopyWith(_ClubLeaderboardEntry value, $Res Function(_ClubLeaderboardEntry) _then) = __$ClubLeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 int rank, String oderId, String userName, String? avatarUrl, int games, int wins, int points, double? winRate
});




}
/// @nodoc
class __$ClubLeaderboardEntryCopyWithImpl<$Res>
    implements _$ClubLeaderboardEntryCopyWith<$Res> {
  __$ClubLeaderboardEntryCopyWithImpl(this._self, this._then);

  final _ClubLeaderboardEntry _self;
  final $Res Function(_ClubLeaderboardEntry) _then;

/// Create a copy of ClubLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? games = null,Object? wins = null,Object? points = null,Object? winRate = freezed,}) {
  return _then(_ClubLeaderboardEntry(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,games: null == games ? _self.games : games // ignore: cast_nullable_to_non_nullable
as int,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,winRate: freezed == winRate ? _self.winRate : winRate // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ClubActivity {

 String get id; String get clubId; String get oderId; String get userName; String? get userAvatarUrl; ClubActivityType get type; String get content; String? get gameId; String? get gameType; DateTime? get createdAt; List<String> get likedBy; int get likesCount;
/// Create a copy of ClubActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubActivityCopyWith<ClubActivity> get copyWith => _$ClubActivityCopyWithImpl<ClubActivity>(this as ClubActivity, _$identity);

  /// Serializes this ClubActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.likedBy, likedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clubId,oderId,userName,userAvatarUrl,type,content,gameId,gameType,createdAt,const DeepCollectionEquality().hash(likedBy),likesCount);

@override
String toString() {
  return 'ClubActivity(id: $id, clubId: $clubId, oderId: $oderId, userName: $userName, userAvatarUrl: $userAvatarUrl, type: $type, content: $content, gameId: $gameId, gameType: $gameType, createdAt: $createdAt, likedBy: $likedBy, likesCount: $likesCount)';
}


}

/// @nodoc
abstract mixin class $ClubActivityCopyWith<$Res>  {
  factory $ClubActivityCopyWith(ClubActivity value, $Res Function(ClubActivity) _then) = _$ClubActivityCopyWithImpl;
@useResult
$Res call({
 String id, String clubId, String oderId, String userName, String? userAvatarUrl, ClubActivityType type, String content, String? gameId, String? gameType, DateTime? createdAt, List<String> likedBy, int likesCount
});




}
/// @nodoc
class _$ClubActivityCopyWithImpl<$Res>
    implements $ClubActivityCopyWith<$Res> {
  _$ClubActivityCopyWithImpl(this._self, this._then);

  final ClubActivity _self;
  final $Res Function(ClubActivity) _then;

/// Create a copy of ClubActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clubId = null,Object? oderId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? type = null,Object? content = null,Object? gameId = freezed,Object? gameType = freezed,Object? createdAt = freezed,Object? likedBy = null,Object? likesCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClubActivityType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,likedBy: null == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubActivity].
extension ClubActivityPatterns on ClubActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubActivity value)  $default,){
final _that = this;
switch (_that) {
case _ClubActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubActivity value)?  $default,){
final _that = this;
switch (_that) {
case _ClubActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clubId,  String oderId,  String userName,  String? userAvatarUrl,  ClubActivityType type,  String content,  String? gameId,  String? gameType,  DateTime? createdAt,  List<String> likedBy,  int likesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubActivity() when $default != null:
return $default(_that.id,_that.clubId,_that.oderId,_that.userName,_that.userAvatarUrl,_that.type,_that.content,_that.gameId,_that.gameType,_that.createdAt,_that.likedBy,_that.likesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clubId,  String oderId,  String userName,  String? userAvatarUrl,  ClubActivityType type,  String content,  String? gameId,  String? gameType,  DateTime? createdAt,  List<String> likedBy,  int likesCount)  $default,) {final _that = this;
switch (_that) {
case _ClubActivity():
return $default(_that.id,_that.clubId,_that.oderId,_that.userName,_that.userAvatarUrl,_that.type,_that.content,_that.gameId,_that.gameType,_that.createdAt,_that.likedBy,_that.likesCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clubId,  String oderId,  String userName,  String? userAvatarUrl,  ClubActivityType type,  String content,  String? gameId,  String? gameType,  DateTime? createdAt,  List<String> likedBy,  int likesCount)?  $default,) {final _that = this;
switch (_that) {
case _ClubActivity() when $default != null:
return $default(_that.id,_that.clubId,_that.oderId,_that.userName,_that.userAvatarUrl,_that.type,_that.content,_that.gameId,_that.gameType,_that.createdAt,_that.likedBy,_that.likesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubActivity extends ClubActivity {
  const _ClubActivity({required this.id, required this.clubId, required this.oderId, required this.userName, this.userAvatarUrl, required this.type, required this.content, this.gameId, this.gameType, this.createdAt, final  List<String> likedBy = const [], this.likesCount = 0}): _likedBy = likedBy,super._();
  factory _ClubActivity.fromJson(Map<String, dynamic> json) => _$ClubActivityFromJson(json);

@override final  String id;
@override final  String clubId;
@override final  String oderId;
@override final  String userName;
@override final  String? userAvatarUrl;
@override final  ClubActivityType type;
@override final  String content;
@override final  String? gameId;
@override final  String? gameType;
@override final  DateTime? createdAt;
 final  List<String> _likedBy;
@override@JsonKey() List<String> get likedBy {
  if (_likedBy is EqualUnmodifiableListView) return _likedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedBy);
}

@override@JsonKey() final  int likesCount;

/// Create a copy of ClubActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubActivityCopyWith<_ClubActivity> get copyWith => __$ClubActivityCopyWithImpl<_ClubActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubActivity&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userAvatarUrl, userAvatarUrl) || other.userAvatarUrl == userAvatarUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._likedBy, _likedBy)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,clubId,oderId,userName,userAvatarUrl,type,content,gameId,gameType,createdAt,const DeepCollectionEquality().hash(_likedBy),likesCount);

@override
String toString() {
  return 'ClubActivity(id: $id, clubId: $clubId, oderId: $oderId, userName: $userName, userAvatarUrl: $userAvatarUrl, type: $type, content: $content, gameId: $gameId, gameType: $gameType, createdAt: $createdAt, likedBy: $likedBy, likesCount: $likesCount)';
}


}

/// @nodoc
abstract mixin class _$ClubActivityCopyWith<$Res> implements $ClubActivityCopyWith<$Res> {
  factory _$ClubActivityCopyWith(_ClubActivity value, $Res Function(_ClubActivity) _then) = __$ClubActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String clubId, String oderId, String userName, String? userAvatarUrl, ClubActivityType type, String content, String? gameId, String? gameType, DateTime? createdAt, List<String> likedBy, int likesCount
});




}
/// @nodoc
class __$ClubActivityCopyWithImpl<$Res>
    implements _$ClubActivityCopyWith<$Res> {
  __$ClubActivityCopyWithImpl(this._self, this._then);

  final _ClubActivity _self;
  final $Res Function(_ClubActivity) _then;

/// Create a copy of ClubActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clubId = null,Object? oderId = null,Object? userName = null,Object? userAvatarUrl = freezed,Object? type = null,Object? content = null,Object? gameId = freezed,Object? gameType = freezed,Object? createdAt = freezed,Object? likedBy = null,Object? likesCount = null,}) {
  return _then(_ClubActivity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userAvatarUrl: freezed == userAvatarUrl ? _self.userAvatarUrl : userAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ClubActivityType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,gameType: freezed == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,likedBy: null == likedBy ? _self._likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

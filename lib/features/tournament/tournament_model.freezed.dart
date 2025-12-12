// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tournament {

 String get id; String get name; String get description; String get hostId; String get hostName; String get gameType; TournamentFormat get format; TournamentStatus get status; int get maxParticipants; int get minParticipants; int? get prizePool; int? get entryFee; DateTime? get registrationDeadline; DateTime? get startTime; DateTime? get endTime; List<String> get participantIds; List<TournamentBracket> get brackets; String? get winnerId; String? get winnerName; DateTime? get createdAt;
/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentCopyWith<Tournament> get copyWith => _$TournamentCopyWithImpl<Tournament>(this as Tournament, _$identity);

  /// Serializes this Tournament to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tournament&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.format, format) || other.format == format)&&(identical(other.status, status) || other.status == status)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.minParticipants, minParticipants) || other.minParticipants == minParticipants)&&(identical(other.prizePool, prizePool) || other.prizePool == prizePool)&&(identical(other.entryFee, entryFee) || other.entryFee == entryFee)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&const DeepCollectionEquality().equals(other.brackets, brackets)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,hostId,hostName,gameType,format,status,maxParticipants,minParticipants,prizePool,entryFee,registrationDeadline,startTime,endTime,const DeepCollectionEquality().hash(participantIds),const DeepCollectionEquality().hash(brackets),winnerId,winnerName,createdAt]);

@override
String toString() {
  return 'Tournament(id: $id, name: $name, description: $description, hostId: $hostId, hostName: $hostName, gameType: $gameType, format: $format, status: $status, maxParticipants: $maxParticipants, minParticipants: $minParticipants, prizePool: $prizePool, entryFee: $entryFee, registrationDeadline: $registrationDeadline, startTime: $startTime, endTime: $endTime, participantIds: $participantIds, brackets: $brackets, winnerId: $winnerId, winnerName: $winnerName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TournamentCopyWith<$Res>  {
  factory $TournamentCopyWith(Tournament value, $Res Function(Tournament) _then) = _$TournamentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String hostId, String hostName, String gameType, TournamentFormat format, TournamentStatus status, int maxParticipants, int minParticipants, int? prizePool, int? entryFee, DateTime? registrationDeadline, DateTime? startTime, DateTime? endTime, List<String> participantIds, List<TournamentBracket> brackets, String? winnerId, String? winnerName, DateTime? createdAt
});




}
/// @nodoc
class _$TournamentCopyWithImpl<$Res>
    implements $TournamentCopyWith<$Res> {
  _$TournamentCopyWithImpl(this._self, this._then);

  final Tournament _self;
  final $Res Function(Tournament) _then;

/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? hostId = null,Object? hostName = null,Object? gameType = null,Object? format = null,Object? status = null,Object? maxParticipants = null,Object? minParticipants = null,Object? prizePool = freezed,Object? entryFee = freezed,Object? registrationDeadline = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? participantIds = null,Object? brackets = null,Object? winnerId = freezed,Object? winnerName = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as TournamentFormat,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TournamentStatus,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,minParticipants: null == minParticipants ? _self.minParticipants : minParticipants // ignore: cast_nullable_to_non_nullable
as int,prizePool: freezed == prizePool ? _self.prizePool : prizePool // ignore: cast_nullable_to_non_nullable
as int?,entryFee: freezed == entryFee ? _self.entryFee : entryFee // ignore: cast_nullable_to_non_nullable
as int?,registrationDeadline: freezed == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,brackets: null == brackets ? _self.brackets : brackets // ignore: cast_nullable_to_non_nullable
as List<TournamentBracket>,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tournament].
extension TournamentPatterns on Tournament {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tournament value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tournament() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tournament value)  $default,){
final _that = this;
switch (_that) {
case _Tournament():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tournament value)?  $default,){
final _that = this;
switch (_that) {
case _Tournament() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String hostId,  String hostName,  String gameType,  TournamentFormat format,  TournamentStatus status,  int maxParticipants,  int minParticipants,  int? prizePool,  int? entryFee,  DateTime? registrationDeadline,  DateTime? startTime,  DateTime? endTime,  List<String> participantIds,  List<TournamentBracket> brackets,  String? winnerId,  String? winnerName,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tournament() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.hostId,_that.hostName,_that.gameType,_that.format,_that.status,_that.maxParticipants,_that.minParticipants,_that.prizePool,_that.entryFee,_that.registrationDeadline,_that.startTime,_that.endTime,_that.participantIds,_that.brackets,_that.winnerId,_that.winnerName,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String hostId,  String hostName,  String gameType,  TournamentFormat format,  TournamentStatus status,  int maxParticipants,  int minParticipants,  int? prizePool,  int? entryFee,  DateTime? registrationDeadline,  DateTime? startTime,  DateTime? endTime,  List<String> participantIds,  List<TournamentBracket> brackets,  String? winnerId,  String? winnerName,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Tournament():
return $default(_that.id,_that.name,_that.description,_that.hostId,_that.hostName,_that.gameType,_that.format,_that.status,_that.maxParticipants,_that.minParticipants,_that.prizePool,_that.entryFee,_that.registrationDeadline,_that.startTime,_that.endTime,_that.participantIds,_that.brackets,_that.winnerId,_that.winnerName,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String hostId,  String hostName,  String gameType,  TournamentFormat format,  TournamentStatus status,  int maxParticipants,  int minParticipants,  int? prizePool,  int? entryFee,  DateTime? registrationDeadline,  DateTime? startTime,  DateTime? endTime,  List<String> participantIds,  List<TournamentBracket> brackets,  String? winnerId,  String? winnerName,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Tournament() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.hostId,_that.hostName,_that.gameType,_that.format,_that.status,_that.maxParticipants,_that.minParticipants,_that.prizePool,_that.entryFee,_that.registrationDeadline,_that.startTime,_that.endTime,_that.participantIds,_that.brackets,_that.winnerId,_that.winnerName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tournament extends Tournament {
  const _Tournament({required this.id, required this.name, required this.description, required this.hostId, required this.hostName, required this.gameType, required this.format, this.status = TournamentStatus.draft, this.maxParticipants = 8, this.minParticipants = 2, this.prizePool, this.entryFee, this.registrationDeadline, this.startTime, this.endTime, final  List<String> participantIds = const [], final  List<TournamentBracket> brackets = const [], this.winnerId, this.winnerName, this.createdAt}): _participantIds = participantIds,_brackets = brackets,super._();
  factory _Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String hostId;
@override final  String hostName;
@override final  String gameType;
@override final  TournamentFormat format;
@override@JsonKey() final  TournamentStatus status;
@override@JsonKey() final  int maxParticipants;
@override@JsonKey() final  int minParticipants;
@override final  int? prizePool;
@override final  int? entryFee;
@override final  DateTime? registrationDeadline;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

 final  List<TournamentBracket> _brackets;
@override@JsonKey() List<TournamentBracket> get brackets {
  if (_brackets is EqualUnmodifiableListView) return _brackets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_brackets);
}

@override final  String? winnerId;
@override final  String? winnerName;
@override final  DateTime? createdAt;

/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentCopyWith<_Tournament> get copyWith => __$TournamentCopyWithImpl<_Tournament>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tournament&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.format, format) || other.format == format)&&(identical(other.status, status) || other.status == status)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.minParticipants, minParticipants) || other.minParticipants == minParticipants)&&(identical(other.prizePool, prizePool) || other.prizePool == prizePool)&&(identical(other.entryFee, entryFee) || other.entryFee == entryFee)&&(identical(other.registrationDeadline, registrationDeadline) || other.registrationDeadline == registrationDeadline)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&const DeepCollectionEquality().equals(other._brackets, _brackets)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,hostId,hostName,gameType,format,status,maxParticipants,minParticipants,prizePool,entryFee,registrationDeadline,startTime,endTime,const DeepCollectionEquality().hash(_participantIds),const DeepCollectionEquality().hash(_brackets),winnerId,winnerName,createdAt]);

@override
String toString() {
  return 'Tournament(id: $id, name: $name, description: $description, hostId: $hostId, hostName: $hostName, gameType: $gameType, format: $format, status: $status, maxParticipants: $maxParticipants, minParticipants: $minParticipants, prizePool: $prizePool, entryFee: $entryFee, registrationDeadline: $registrationDeadline, startTime: $startTime, endTime: $endTime, participantIds: $participantIds, brackets: $brackets, winnerId: $winnerId, winnerName: $winnerName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TournamentCopyWith<$Res> implements $TournamentCopyWith<$Res> {
  factory _$TournamentCopyWith(_Tournament value, $Res Function(_Tournament) _then) = __$TournamentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String hostId, String hostName, String gameType, TournamentFormat format, TournamentStatus status, int maxParticipants, int minParticipants, int? prizePool, int? entryFee, DateTime? registrationDeadline, DateTime? startTime, DateTime? endTime, List<String> participantIds, List<TournamentBracket> brackets, String? winnerId, String? winnerName, DateTime? createdAt
});




}
/// @nodoc
class __$TournamentCopyWithImpl<$Res>
    implements _$TournamentCopyWith<$Res> {
  __$TournamentCopyWithImpl(this._self, this._then);

  final _Tournament _self;
  final $Res Function(_Tournament) _then;

/// Create a copy of Tournament
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? hostId = null,Object? hostName = null,Object? gameType = null,Object? format = null,Object? status = null,Object? maxParticipants = null,Object? minParticipants = null,Object? prizePool = freezed,Object? entryFee = freezed,Object? registrationDeadline = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? participantIds = null,Object? brackets = null,Object? winnerId = freezed,Object? winnerName = freezed,Object? createdAt = freezed,}) {
  return _then(_Tournament(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as TournamentFormat,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TournamentStatus,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,minParticipants: null == minParticipants ? _self.minParticipants : minParticipants // ignore: cast_nullable_to_non_nullable
as int,prizePool: freezed == prizePool ? _self.prizePool : prizePool // ignore: cast_nullable_to_non_nullable
as int?,entryFee: freezed == entryFee ? _self.entryFee : entryFee // ignore: cast_nullable_to_non_nullable
as int?,registrationDeadline: freezed == registrationDeadline ? _self.registrationDeadline : registrationDeadline // ignore: cast_nullable_to_non_nullable
as DateTime?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,brackets: null == brackets ? _self._brackets : brackets // ignore: cast_nullable_to_non_nullable
as List<TournamentBracket>,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TournamentBracket {

 String get id; int get round; int get matchNumber; String get player1Id; String get player1Name; String? get player2Id; String? get player2Name; int? get player1Score; int? get player2Score; String? get winnerId; String? get gameRoomId; BracketStatus get status; DateTime? get scheduledTime; DateTime? get completedTime;
/// Create a copy of TournamentBracket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentBracketCopyWith<TournamentBracket> get copyWith => _$TournamentBracketCopyWithImpl<TournamentBracket>(this as TournamentBracket, _$identity);

  /// Serializes this TournamentBracket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentBracket&&(identical(other.id, id) || other.id == id)&&(identical(other.round, round) || other.round == round)&&(identical(other.matchNumber, matchNumber) || other.matchNumber == matchNumber)&&(identical(other.player1Id, player1Id) || other.player1Id == player1Id)&&(identical(other.player1Name, player1Name) || other.player1Name == player1Name)&&(identical(other.player2Id, player2Id) || other.player2Id == player2Id)&&(identical(other.player2Name, player2Name) || other.player2Name == player2Name)&&(identical(other.player1Score, player1Score) || other.player1Score == player1Score)&&(identical(other.player2Score, player2Score) || other.player2Score == player2Score)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.gameRoomId, gameRoomId) || other.gameRoomId == gameRoomId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.completedTime, completedTime) || other.completedTime == completedTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,round,matchNumber,player1Id,player1Name,player2Id,player2Name,player1Score,player2Score,winnerId,gameRoomId,status,scheduledTime,completedTime);

@override
String toString() {
  return 'TournamentBracket(id: $id, round: $round, matchNumber: $matchNumber, player1Id: $player1Id, player1Name: $player1Name, player2Id: $player2Id, player2Name: $player2Name, player1Score: $player1Score, player2Score: $player2Score, winnerId: $winnerId, gameRoomId: $gameRoomId, status: $status, scheduledTime: $scheduledTime, completedTime: $completedTime)';
}


}

/// @nodoc
abstract mixin class $TournamentBracketCopyWith<$Res>  {
  factory $TournamentBracketCopyWith(TournamentBracket value, $Res Function(TournamentBracket) _then) = _$TournamentBracketCopyWithImpl;
@useResult
$Res call({
 String id, int round, int matchNumber, String player1Id, String player1Name, String? player2Id, String? player2Name, int? player1Score, int? player2Score, String? winnerId, String? gameRoomId, BracketStatus status, DateTime? scheduledTime, DateTime? completedTime
});




}
/// @nodoc
class _$TournamentBracketCopyWithImpl<$Res>
    implements $TournamentBracketCopyWith<$Res> {
  _$TournamentBracketCopyWithImpl(this._self, this._then);

  final TournamentBracket _self;
  final $Res Function(TournamentBracket) _then;

/// Create a copy of TournamentBracket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? round = null,Object? matchNumber = null,Object? player1Id = null,Object? player1Name = null,Object? player2Id = freezed,Object? player2Name = freezed,Object? player1Score = freezed,Object? player2Score = freezed,Object? winnerId = freezed,Object? gameRoomId = freezed,Object? status = null,Object? scheduledTime = freezed,Object? completedTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,matchNumber: null == matchNumber ? _self.matchNumber : matchNumber // ignore: cast_nullable_to_non_nullable
as int,player1Id: null == player1Id ? _self.player1Id : player1Id // ignore: cast_nullable_to_non_nullable
as String,player1Name: null == player1Name ? _self.player1Name : player1Name // ignore: cast_nullable_to_non_nullable
as String,player2Id: freezed == player2Id ? _self.player2Id : player2Id // ignore: cast_nullable_to_non_nullable
as String?,player2Name: freezed == player2Name ? _self.player2Name : player2Name // ignore: cast_nullable_to_non_nullable
as String?,player1Score: freezed == player1Score ? _self.player1Score : player1Score // ignore: cast_nullable_to_non_nullable
as int?,player2Score: freezed == player2Score ? _self.player2Score : player2Score // ignore: cast_nullable_to_non_nullable
as int?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,gameRoomId: freezed == gameRoomId ? _self.gameRoomId : gameRoomId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BracketStatus,scheduledTime: freezed == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime?,completedTime: freezed == completedTime ? _self.completedTime : completedTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentBracket].
extension TournamentBracketPatterns on TournamentBracket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentBracket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentBracket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentBracket value)  $default,){
final _that = this;
switch (_that) {
case _TournamentBracket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentBracket value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentBracket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int round,  int matchNumber,  String player1Id,  String player1Name,  String? player2Id,  String? player2Name,  int? player1Score,  int? player2Score,  String? winnerId,  String? gameRoomId,  BracketStatus status,  DateTime? scheduledTime,  DateTime? completedTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentBracket() when $default != null:
return $default(_that.id,_that.round,_that.matchNumber,_that.player1Id,_that.player1Name,_that.player2Id,_that.player2Name,_that.player1Score,_that.player2Score,_that.winnerId,_that.gameRoomId,_that.status,_that.scheduledTime,_that.completedTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int round,  int matchNumber,  String player1Id,  String player1Name,  String? player2Id,  String? player2Name,  int? player1Score,  int? player2Score,  String? winnerId,  String? gameRoomId,  BracketStatus status,  DateTime? scheduledTime,  DateTime? completedTime)  $default,) {final _that = this;
switch (_that) {
case _TournamentBracket():
return $default(_that.id,_that.round,_that.matchNumber,_that.player1Id,_that.player1Name,_that.player2Id,_that.player2Name,_that.player1Score,_that.player2Score,_that.winnerId,_that.gameRoomId,_that.status,_that.scheduledTime,_that.completedTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int round,  int matchNumber,  String player1Id,  String player1Name,  String? player2Id,  String? player2Name,  int? player1Score,  int? player2Score,  String? winnerId,  String? gameRoomId,  BracketStatus status,  DateTime? scheduledTime,  DateTime? completedTime)?  $default,) {final _that = this;
switch (_that) {
case _TournamentBracket() when $default != null:
return $default(_that.id,_that.round,_that.matchNumber,_that.player1Id,_that.player1Name,_that.player2Id,_that.player2Name,_that.player1Score,_that.player2Score,_that.winnerId,_that.gameRoomId,_that.status,_that.scheduledTime,_that.completedTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentBracket extends TournamentBracket {
  const _TournamentBracket({required this.id, required this.round, required this.matchNumber, required this.player1Id, required this.player1Name, this.player2Id, this.player2Name, this.player1Score, this.player2Score, this.winnerId, this.gameRoomId, this.status = BracketStatus.pending, this.scheduledTime, this.completedTime}): super._();
  factory _TournamentBracket.fromJson(Map<String, dynamic> json) => _$TournamentBracketFromJson(json);

@override final  String id;
@override final  int round;
@override final  int matchNumber;
@override final  String player1Id;
@override final  String player1Name;
@override final  String? player2Id;
@override final  String? player2Name;
@override final  int? player1Score;
@override final  int? player2Score;
@override final  String? winnerId;
@override final  String? gameRoomId;
@override@JsonKey() final  BracketStatus status;
@override final  DateTime? scheduledTime;
@override final  DateTime? completedTime;

/// Create a copy of TournamentBracket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentBracketCopyWith<_TournamentBracket> get copyWith => __$TournamentBracketCopyWithImpl<_TournamentBracket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentBracketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentBracket&&(identical(other.id, id) || other.id == id)&&(identical(other.round, round) || other.round == round)&&(identical(other.matchNumber, matchNumber) || other.matchNumber == matchNumber)&&(identical(other.player1Id, player1Id) || other.player1Id == player1Id)&&(identical(other.player1Name, player1Name) || other.player1Name == player1Name)&&(identical(other.player2Id, player2Id) || other.player2Id == player2Id)&&(identical(other.player2Name, player2Name) || other.player2Name == player2Name)&&(identical(other.player1Score, player1Score) || other.player1Score == player1Score)&&(identical(other.player2Score, player2Score) || other.player2Score == player2Score)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.gameRoomId, gameRoomId) || other.gameRoomId == gameRoomId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.completedTime, completedTime) || other.completedTime == completedTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,round,matchNumber,player1Id,player1Name,player2Id,player2Name,player1Score,player2Score,winnerId,gameRoomId,status,scheduledTime,completedTime);

@override
String toString() {
  return 'TournamentBracket(id: $id, round: $round, matchNumber: $matchNumber, player1Id: $player1Id, player1Name: $player1Name, player2Id: $player2Id, player2Name: $player2Name, player1Score: $player1Score, player2Score: $player2Score, winnerId: $winnerId, gameRoomId: $gameRoomId, status: $status, scheduledTime: $scheduledTime, completedTime: $completedTime)';
}


}

/// @nodoc
abstract mixin class _$TournamentBracketCopyWith<$Res> implements $TournamentBracketCopyWith<$Res> {
  factory _$TournamentBracketCopyWith(_TournamentBracket value, $Res Function(_TournamentBracket) _then) = __$TournamentBracketCopyWithImpl;
@override @useResult
$Res call({
 String id, int round, int matchNumber, String player1Id, String player1Name, String? player2Id, String? player2Name, int? player1Score, int? player2Score, String? winnerId, String? gameRoomId, BracketStatus status, DateTime? scheduledTime, DateTime? completedTime
});




}
/// @nodoc
class __$TournamentBracketCopyWithImpl<$Res>
    implements _$TournamentBracketCopyWith<$Res> {
  __$TournamentBracketCopyWithImpl(this._self, this._then);

  final _TournamentBracket _self;
  final $Res Function(_TournamentBracket) _then;

/// Create a copy of TournamentBracket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? round = null,Object? matchNumber = null,Object? player1Id = null,Object? player1Name = null,Object? player2Id = freezed,Object? player2Name = freezed,Object? player1Score = freezed,Object? player2Score = freezed,Object? winnerId = freezed,Object? gameRoomId = freezed,Object? status = null,Object? scheduledTime = freezed,Object? completedTime = freezed,}) {
  return _then(_TournamentBracket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,matchNumber: null == matchNumber ? _self.matchNumber : matchNumber // ignore: cast_nullable_to_non_nullable
as int,player1Id: null == player1Id ? _self.player1Id : player1Id // ignore: cast_nullable_to_non_nullable
as String,player1Name: null == player1Name ? _self.player1Name : player1Name // ignore: cast_nullable_to_non_nullable
as String,player2Id: freezed == player2Id ? _self.player2Id : player2Id // ignore: cast_nullable_to_non_nullable
as String?,player2Name: freezed == player2Name ? _self.player2Name : player2Name // ignore: cast_nullable_to_non_nullable
as String?,player1Score: freezed == player1Score ? _self.player1Score : player1Score // ignore: cast_nullable_to_non_nullable
as int?,player2Score: freezed == player2Score ? _self.player2Score : player2Score // ignore: cast_nullable_to_non_nullable
as int?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,gameRoomId: freezed == gameRoomId ? _self.gameRoomId : gameRoomId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BracketStatus,scheduledTime: freezed == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime?,completedTime: freezed == completedTime ? _self.completedTime : completedTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TournamentParticipant {

 String get oderId; String get userName; String? get avatarUrl; DateTime get joinedAt; int get wins; int get losses; int get pointsScored; bool? get isEliminated; int? get finalPlacement;
/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentParticipantCopyWith<TournamentParticipant> get copyWith => _$TournamentParticipantCopyWithImpl<TournamentParticipant>(this as TournamentParticipant, _$identity);

  /// Serializes this TournamentParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentParticipant&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.pointsScored, pointsScored) || other.pointsScored == pointsScored)&&(identical(other.isEliminated, isEliminated) || other.isEliminated == isEliminated)&&(identical(other.finalPlacement, finalPlacement) || other.finalPlacement == finalPlacement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oderId,userName,avatarUrl,joinedAt,wins,losses,pointsScored,isEliminated,finalPlacement);

@override
String toString() {
  return 'TournamentParticipant(oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, joinedAt: $joinedAt, wins: $wins, losses: $losses, pointsScored: $pointsScored, isEliminated: $isEliminated, finalPlacement: $finalPlacement)';
}


}

/// @nodoc
abstract mixin class $TournamentParticipantCopyWith<$Res>  {
  factory $TournamentParticipantCopyWith(TournamentParticipant value, $Res Function(TournamentParticipant) _then) = _$TournamentParticipantCopyWithImpl;
@useResult
$Res call({
 String oderId, String userName, String? avatarUrl, DateTime joinedAt, int wins, int losses, int pointsScored, bool? isEliminated, int? finalPlacement
});




}
/// @nodoc
class _$TournamentParticipantCopyWithImpl<$Res>
    implements $TournamentParticipantCopyWith<$Res> {
  _$TournamentParticipantCopyWithImpl(this._self, this._then);

  final TournamentParticipant _self;
  final $Res Function(TournamentParticipant) _then;

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? joinedAt = null,Object? wins = null,Object? losses = null,Object? pointsScored = null,Object? isEliminated = freezed,Object? finalPlacement = freezed,}) {
  return _then(_self.copyWith(
oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,pointsScored: null == pointsScored ? _self.pointsScored : pointsScored // ignore: cast_nullable_to_non_nullable
as int,isEliminated: freezed == isEliminated ? _self.isEliminated : isEliminated // ignore: cast_nullable_to_non_nullable
as bool?,finalPlacement: freezed == finalPlacement ? _self.finalPlacement : finalPlacement // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentParticipant].
extension TournamentParticipantPatterns on TournamentParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentParticipant value)  $default,){
final _that = this;
switch (_that) {
case _TournamentParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String oderId,  String userName,  String? avatarUrl,  DateTime joinedAt,  int wins,  int losses,  int pointsScored,  bool? isEliminated,  int? finalPlacement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
return $default(_that.oderId,_that.userName,_that.avatarUrl,_that.joinedAt,_that.wins,_that.losses,_that.pointsScored,_that.isEliminated,_that.finalPlacement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String oderId,  String userName,  String? avatarUrl,  DateTime joinedAt,  int wins,  int losses,  int pointsScored,  bool? isEliminated,  int? finalPlacement)  $default,) {final _that = this;
switch (_that) {
case _TournamentParticipant():
return $default(_that.oderId,_that.userName,_that.avatarUrl,_that.joinedAt,_that.wins,_that.losses,_that.pointsScored,_that.isEliminated,_that.finalPlacement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String oderId,  String userName,  String? avatarUrl,  DateTime joinedAt,  int wins,  int losses,  int pointsScored,  bool? isEliminated,  int? finalPlacement)?  $default,) {final _that = this;
switch (_that) {
case _TournamentParticipant() when $default != null:
return $default(_that.oderId,_that.userName,_that.avatarUrl,_that.joinedAt,_that.wins,_that.losses,_that.pointsScored,_that.isEliminated,_that.finalPlacement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentParticipant extends TournamentParticipant {
  const _TournamentParticipant({required this.oderId, required this.userName, this.avatarUrl, required this.joinedAt, this.wins = 0, this.losses = 0, this.pointsScored = 0, this.isEliminated, this.finalPlacement}): super._();
  factory _TournamentParticipant.fromJson(Map<String, dynamic> json) => _$TournamentParticipantFromJson(json);

@override final  String oderId;
@override final  String userName;
@override final  String? avatarUrl;
@override final  DateTime joinedAt;
@override@JsonKey() final  int wins;
@override@JsonKey() final  int losses;
@override@JsonKey() final  int pointsScored;
@override final  bool? isEliminated;
@override final  int? finalPlacement;

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentParticipantCopyWith<_TournamentParticipant> get copyWith => __$TournamentParticipantCopyWithImpl<_TournamentParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentParticipant&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.pointsScored, pointsScored) || other.pointsScored == pointsScored)&&(identical(other.isEliminated, isEliminated) || other.isEliminated == isEliminated)&&(identical(other.finalPlacement, finalPlacement) || other.finalPlacement == finalPlacement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,oderId,userName,avatarUrl,joinedAt,wins,losses,pointsScored,isEliminated,finalPlacement);

@override
String toString() {
  return 'TournamentParticipant(oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, joinedAt: $joinedAt, wins: $wins, losses: $losses, pointsScored: $pointsScored, isEliminated: $isEliminated, finalPlacement: $finalPlacement)';
}


}

/// @nodoc
abstract mixin class _$TournamentParticipantCopyWith<$Res> implements $TournamentParticipantCopyWith<$Res> {
  factory _$TournamentParticipantCopyWith(_TournamentParticipant value, $Res Function(_TournamentParticipant) _then) = __$TournamentParticipantCopyWithImpl;
@override @useResult
$Res call({
 String oderId, String userName, String? avatarUrl, DateTime joinedAt, int wins, int losses, int pointsScored, bool? isEliminated, int? finalPlacement
});




}
/// @nodoc
class __$TournamentParticipantCopyWithImpl<$Res>
    implements _$TournamentParticipantCopyWith<$Res> {
  __$TournamentParticipantCopyWithImpl(this._self, this._then);

  final _TournamentParticipant _self;
  final $Res Function(_TournamentParticipant) _then;

/// Create a copy of TournamentParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? joinedAt = null,Object? wins = null,Object? losses = null,Object? pointsScored = null,Object? isEliminated = freezed,Object? finalPlacement = freezed,}) {
  return _then(_TournamentParticipant(
oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,pointsScored: null == pointsScored ? _self.pointsScored : pointsScored // ignore: cast_nullable_to_non_nullable
as int,isEliminated: freezed == isEliminated ? _self.isEliminated : isEliminated // ignore: cast_nullable_to_non_nullable
as bool?,finalPlacement: freezed == finalPlacement ? _self.finalPlacement : finalPlacement // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TournamentStanding {

 int get rank; String get oderId; String get userName; String? get avatarUrl; int get wins; int get losses; int get totalPoints; int? get prizeDiamonds;
/// Create a copy of TournamentStanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentStandingCopyWith<TournamentStanding> get copyWith => _$TournamentStandingCopyWithImpl<TournamentStanding>(this as TournamentStanding, _$identity);

  /// Serializes this TournamentStanding to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentStanding&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.prizeDiamonds, prizeDiamonds) || other.prizeDiamonds == prizeDiamonds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,oderId,userName,avatarUrl,wins,losses,totalPoints,prizeDiamonds);

@override
String toString() {
  return 'TournamentStanding(rank: $rank, oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, wins: $wins, losses: $losses, totalPoints: $totalPoints, prizeDiamonds: $prizeDiamonds)';
}


}

/// @nodoc
abstract mixin class $TournamentStandingCopyWith<$Res>  {
  factory $TournamentStandingCopyWith(TournamentStanding value, $Res Function(TournamentStanding) _then) = _$TournamentStandingCopyWithImpl;
@useResult
$Res call({
 int rank, String oderId, String userName, String? avatarUrl, int wins, int losses, int totalPoints, int? prizeDiamonds
});




}
/// @nodoc
class _$TournamentStandingCopyWithImpl<$Res>
    implements $TournamentStandingCopyWith<$Res> {
  _$TournamentStandingCopyWithImpl(this._self, this._then);

  final TournamentStanding _self;
  final $Res Function(TournamentStanding) _then;

/// Create a copy of TournamentStanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? wins = null,Object? losses = null,Object? totalPoints = null,Object? prizeDiamonds = freezed,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,prizeDiamonds: freezed == prizeDiamonds ? _self.prizeDiamonds : prizeDiamonds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentStanding].
extension TournamentStandingPatterns on TournamentStanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentStanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentStanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentStanding value)  $default,){
final _that = this;
switch (_that) {
case _TournamentStanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentStanding value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentStanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String oderId,  String userName,  String? avatarUrl,  int wins,  int losses,  int totalPoints,  int? prizeDiamonds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentStanding() when $default != null:
return $default(_that.rank,_that.oderId,_that.userName,_that.avatarUrl,_that.wins,_that.losses,_that.totalPoints,_that.prizeDiamonds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String oderId,  String userName,  String? avatarUrl,  int wins,  int losses,  int totalPoints,  int? prizeDiamonds)  $default,) {final _that = this;
switch (_that) {
case _TournamentStanding():
return $default(_that.rank,_that.oderId,_that.userName,_that.avatarUrl,_that.wins,_that.losses,_that.totalPoints,_that.prizeDiamonds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String oderId,  String userName,  String? avatarUrl,  int wins,  int losses,  int totalPoints,  int? prizeDiamonds)?  $default,) {final _that = this;
switch (_that) {
case _TournamentStanding() when $default != null:
return $default(_that.rank,_that.oderId,_that.userName,_that.avatarUrl,_that.wins,_that.losses,_that.totalPoints,_that.prizeDiamonds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentStanding extends TournamentStanding {
  const _TournamentStanding({required this.rank, required this.oderId, required this.userName, this.avatarUrl, required this.wins, required this.losses, required this.totalPoints, this.prizeDiamonds}): super._();
  factory _TournamentStanding.fromJson(Map<String, dynamic> json) => _$TournamentStandingFromJson(json);

@override final  int rank;
@override final  String oderId;
@override final  String userName;
@override final  String? avatarUrl;
@override final  int wins;
@override final  int losses;
@override final  int totalPoints;
@override final  int? prizeDiamonds;

/// Create a copy of TournamentStanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentStandingCopyWith<_TournamentStanding> get copyWith => __$TournamentStandingCopyWithImpl<_TournamentStanding>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentStandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentStanding&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.oderId, oderId) || other.oderId == oderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.prizeDiamonds, prizeDiamonds) || other.prizeDiamonds == prizeDiamonds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,oderId,userName,avatarUrl,wins,losses,totalPoints,prizeDiamonds);

@override
String toString() {
  return 'TournamentStanding(rank: $rank, oderId: $oderId, userName: $userName, avatarUrl: $avatarUrl, wins: $wins, losses: $losses, totalPoints: $totalPoints, prizeDiamonds: $prizeDiamonds)';
}


}

/// @nodoc
abstract mixin class _$TournamentStandingCopyWith<$Res> implements $TournamentStandingCopyWith<$Res> {
  factory _$TournamentStandingCopyWith(_TournamentStanding value, $Res Function(_TournamentStanding) _then) = __$TournamentStandingCopyWithImpl;
@override @useResult
$Res call({
 int rank, String oderId, String userName, String? avatarUrl, int wins, int losses, int totalPoints, int? prizeDiamonds
});




}
/// @nodoc
class __$TournamentStandingCopyWithImpl<$Res>
    implements _$TournamentStandingCopyWith<$Res> {
  __$TournamentStandingCopyWithImpl(this._self, this._then);

  final _TournamentStanding _self;
  final $Res Function(_TournamentStanding) _then;

/// Create a copy of TournamentStanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? oderId = null,Object? userName = null,Object? avatarUrl = freezed,Object? wins = null,Object? losses = null,Object? totalPoints = null,Object? prizeDiamonds = freezed,}) {
  return _then(_TournamentStanding(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,oderId: null == oderId ? _self.oderId : oderId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,prizeDiamonds: freezed == prizeDiamonds ? _self.prizeDiamonds : prizeDiamonds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

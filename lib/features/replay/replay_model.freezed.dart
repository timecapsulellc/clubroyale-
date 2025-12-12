// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replay_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReplayEvent {

 int get sequenceNumber; ReplayEventType get type; int get timestamp;// Milliseconds from game start
 String? get playerId; String? get playerName; Map<String, dynamic>? get data; String? get description;
/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplayEventCopyWith<ReplayEvent> get copyWith => _$ReplayEventCopyWithImpl<ReplayEvent>(this as ReplayEvent, _$identity);

  /// Serializes this ReplayEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayEvent&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sequenceNumber,type,timestamp,playerId,playerName,const DeepCollectionEquality().hash(data),description);

@override
String toString() {
  return 'ReplayEvent(sequenceNumber: $sequenceNumber, type: $type, timestamp: $timestamp, playerId: $playerId, playerName: $playerName, data: $data, description: $description)';
}


}

/// @nodoc
abstract mixin class $ReplayEventCopyWith<$Res>  {
  factory $ReplayEventCopyWith(ReplayEvent value, $Res Function(ReplayEvent) _then) = _$ReplayEventCopyWithImpl;
@useResult
$Res call({
 int sequenceNumber, ReplayEventType type, int timestamp, String? playerId, String? playerName, Map<String, dynamic>? data, String? description
});




}
/// @nodoc
class _$ReplayEventCopyWithImpl<$Res>
    implements $ReplayEventCopyWith<$Res> {
  _$ReplayEventCopyWithImpl(this._self, this._then);

  final ReplayEvent _self;
  final $Res Function(ReplayEvent) _then;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sequenceNumber = null,Object? type = null,Object? timestamp = null,Object? playerId = freezed,Object? playerName = freezed,Object? data = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReplayEventType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,playerName: freezed == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplayEvent].
extension ReplayEventPatterns on ReplayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplayEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplayEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplayEvent value)  $default,){
final _that = this;
switch (_that) {
case _ReplayEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplayEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ReplayEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sequenceNumber,  ReplayEventType type,  int timestamp,  String? playerId,  String? playerName,  Map<String, dynamic>? data,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplayEvent() when $default != null:
return $default(_that.sequenceNumber,_that.type,_that.timestamp,_that.playerId,_that.playerName,_that.data,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sequenceNumber,  ReplayEventType type,  int timestamp,  String? playerId,  String? playerName,  Map<String, dynamic>? data,  String? description)  $default,) {final _that = this;
switch (_that) {
case _ReplayEvent():
return $default(_that.sequenceNumber,_that.type,_that.timestamp,_that.playerId,_that.playerName,_that.data,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sequenceNumber,  ReplayEventType type,  int timestamp,  String? playerId,  String? playerName,  Map<String, dynamic>? data,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _ReplayEvent() when $default != null:
return $default(_that.sequenceNumber,_that.type,_that.timestamp,_that.playerId,_that.playerName,_that.data,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplayEvent extends ReplayEvent {
  const _ReplayEvent({required this.sequenceNumber, required this.type, required this.timestamp, this.playerId, this.playerName, final  Map<String, dynamic>? data, this.description}): _data = data,super._();
  factory _ReplayEvent.fromJson(Map<String, dynamic> json) => _$ReplayEventFromJson(json);

@override final  int sequenceNumber;
@override final  ReplayEventType type;
@override final  int timestamp;
// Milliseconds from game start
@override final  String? playerId;
@override final  String? playerName;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? description;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplayEventCopyWith<_ReplayEvent> get copyWith => __$ReplayEventCopyWithImpl<_ReplayEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplayEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplayEvent&&(identical(other.sequenceNumber, sequenceNumber) || other.sequenceNumber == sequenceNumber)&&(identical(other.type, type) || other.type == type)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sequenceNumber,type,timestamp,playerId,playerName,const DeepCollectionEquality().hash(_data),description);

@override
String toString() {
  return 'ReplayEvent(sequenceNumber: $sequenceNumber, type: $type, timestamp: $timestamp, playerId: $playerId, playerName: $playerName, data: $data, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ReplayEventCopyWith<$Res> implements $ReplayEventCopyWith<$Res> {
  factory _$ReplayEventCopyWith(_ReplayEvent value, $Res Function(_ReplayEvent) _then) = __$ReplayEventCopyWithImpl;
@override @useResult
$Res call({
 int sequenceNumber, ReplayEventType type, int timestamp, String? playerId, String? playerName, Map<String, dynamic>? data, String? description
});




}
/// @nodoc
class __$ReplayEventCopyWithImpl<$Res>
    implements _$ReplayEventCopyWith<$Res> {
  __$ReplayEventCopyWithImpl(this._self, this._then);

  final _ReplayEvent _self;
  final $Res Function(_ReplayEvent) _then;

/// Create a copy of ReplayEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequenceNumber = null,Object? type = null,Object? timestamp = null,Object? playerId = freezed,Object? playerName = freezed,Object? data = freezed,Object? description = freezed,}) {
  return _then(_ReplayEvent(
sequenceNumber: null == sequenceNumber ? _self.sequenceNumber : sequenceNumber // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ReplayEventType,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,playerName: freezed == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GameReplay {

 String get id; String get gameType; String get roomId; List<String> get playerIds; List<String> get playerNames; DateTime get gameDate; int get durationMs; String? get winnerId; String? get winnerName; Map<String, int>? get finalScores; List<ReplayEvent> get events; String? get savedBy;// User who saved this replay
 String? get title; bool get isPublic; int get views; List<String> get likedBy;
/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameReplayCopyWith<GameReplay> get copyWith => _$GameReplayCopyWithImpl<GameReplay>(this as GameReplay, _$identity);

  /// Serializes this GameReplay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameReplay&&(identical(other.id, id) || other.id == id)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&const DeepCollectionEquality().equals(other.playerIds, playerIds)&&const DeepCollectionEquality().equals(other.playerNames, playerNames)&&(identical(other.gameDate, gameDate) || other.gameDate == gameDate)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName)&&const DeepCollectionEquality().equals(other.finalScores, finalScores)&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.savedBy, savedBy) || other.savedBy == savedBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.views, views) || other.views == views)&&const DeepCollectionEquality().equals(other.likedBy, likedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gameType,roomId,const DeepCollectionEquality().hash(playerIds),const DeepCollectionEquality().hash(playerNames),gameDate,durationMs,winnerId,winnerName,const DeepCollectionEquality().hash(finalScores),const DeepCollectionEquality().hash(events),savedBy,title,isPublic,views,const DeepCollectionEquality().hash(likedBy));

@override
String toString() {
  return 'GameReplay(id: $id, gameType: $gameType, roomId: $roomId, playerIds: $playerIds, playerNames: $playerNames, gameDate: $gameDate, durationMs: $durationMs, winnerId: $winnerId, winnerName: $winnerName, finalScores: $finalScores, events: $events, savedBy: $savedBy, title: $title, isPublic: $isPublic, views: $views, likedBy: $likedBy)';
}


}

/// @nodoc
abstract mixin class $GameReplayCopyWith<$Res>  {
  factory $GameReplayCopyWith(GameReplay value, $Res Function(GameReplay) _then) = _$GameReplayCopyWithImpl;
@useResult
$Res call({
 String id, String gameType, String roomId, List<String> playerIds, List<String> playerNames, DateTime gameDate, int durationMs, String? winnerId, String? winnerName, Map<String, int>? finalScores, List<ReplayEvent> events, String? savedBy, String? title, bool isPublic, int views, List<String> likedBy
});




}
/// @nodoc
class _$GameReplayCopyWithImpl<$Res>
    implements $GameReplayCopyWith<$Res> {
  _$GameReplayCopyWithImpl(this._self, this._then);

  final GameReplay _self;
  final $Res Function(GameReplay) _then;

/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gameType = null,Object? roomId = null,Object? playerIds = null,Object? playerNames = null,Object? gameDate = null,Object? durationMs = null,Object? winnerId = freezed,Object? winnerName = freezed,Object? finalScores = freezed,Object? events = null,Object? savedBy = freezed,Object? title = freezed,Object? isPublic = null,Object? views = null,Object? likedBy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,playerIds: null == playerIds ? _self.playerIds : playerIds // ignore: cast_nullable_to_non_nullable
as List<String>,playerNames: null == playerNames ? _self.playerNames : playerNames // ignore: cast_nullable_to_non_nullable
as List<String>,gameDate: null == gameDate ? _self.gameDate : gameDate // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,finalScores: freezed == finalScores ? _self.finalScores : finalScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<ReplayEvent>,savedBy: freezed == savedBy ? _self.savedBy : savedBy // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int,likedBy: null == likedBy ? _self.likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GameReplay].
extension GameReplayPatterns on GameReplay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameReplay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameReplay value)  $default,){
final _that = this;
switch (_that) {
case _GameReplay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameReplay value)?  $default,){
final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gameType,  String roomId,  List<String> playerIds,  List<String> playerNames,  DateTime gameDate,  int durationMs,  String? winnerId,  String? winnerName,  Map<String, int>? finalScores,  List<ReplayEvent> events,  String? savedBy,  String? title,  bool isPublic,  int views,  List<String> likedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
return $default(_that.id,_that.gameType,_that.roomId,_that.playerIds,_that.playerNames,_that.gameDate,_that.durationMs,_that.winnerId,_that.winnerName,_that.finalScores,_that.events,_that.savedBy,_that.title,_that.isPublic,_that.views,_that.likedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gameType,  String roomId,  List<String> playerIds,  List<String> playerNames,  DateTime gameDate,  int durationMs,  String? winnerId,  String? winnerName,  Map<String, int>? finalScores,  List<ReplayEvent> events,  String? savedBy,  String? title,  bool isPublic,  int views,  List<String> likedBy)  $default,) {final _that = this;
switch (_that) {
case _GameReplay():
return $default(_that.id,_that.gameType,_that.roomId,_that.playerIds,_that.playerNames,_that.gameDate,_that.durationMs,_that.winnerId,_that.winnerName,_that.finalScores,_that.events,_that.savedBy,_that.title,_that.isPublic,_that.views,_that.likedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gameType,  String roomId,  List<String> playerIds,  List<String> playerNames,  DateTime gameDate,  int durationMs,  String? winnerId,  String? winnerName,  Map<String, int>? finalScores,  List<ReplayEvent> events,  String? savedBy,  String? title,  bool isPublic,  int views,  List<String> likedBy)?  $default,) {final _that = this;
switch (_that) {
case _GameReplay() when $default != null:
return $default(_that.id,_that.gameType,_that.roomId,_that.playerIds,_that.playerNames,_that.gameDate,_that.durationMs,_that.winnerId,_that.winnerName,_that.finalScores,_that.events,_that.savedBy,_that.title,_that.isPublic,_that.views,_that.likedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameReplay extends GameReplay {
  const _GameReplay({required this.id, required this.gameType, required this.roomId, required final  List<String> playerIds, required final  List<String> playerNames, required this.gameDate, required this.durationMs, this.winnerId, this.winnerName, final  Map<String, int>? finalScores, final  List<ReplayEvent> events = const [], this.savedBy, this.title, this.isPublic = false, this.views = 0, final  List<String> likedBy = const []}): _playerIds = playerIds,_playerNames = playerNames,_finalScores = finalScores,_events = events,_likedBy = likedBy,super._();
  factory _GameReplay.fromJson(Map<String, dynamic> json) => _$GameReplayFromJson(json);

@override final  String id;
@override final  String gameType;
@override final  String roomId;
 final  List<String> _playerIds;
@override List<String> get playerIds {
  if (_playerIds is EqualUnmodifiableListView) return _playerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playerIds);
}

 final  List<String> _playerNames;
@override List<String> get playerNames {
  if (_playerNames is EqualUnmodifiableListView) return _playerNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playerNames);
}

@override final  DateTime gameDate;
@override final  int durationMs;
@override final  String? winnerId;
@override final  String? winnerName;
 final  Map<String, int>? _finalScores;
@override Map<String, int>? get finalScores {
  final value = _finalScores;
  if (value == null) return null;
  if (_finalScores is EqualUnmodifiableMapView) return _finalScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<ReplayEvent> _events;
@override@JsonKey() List<ReplayEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override final  String? savedBy;
// User who saved this replay
@override final  String? title;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  int views;
 final  List<String> _likedBy;
@override@JsonKey() List<String> get likedBy {
  if (_likedBy is EqualUnmodifiableListView) return _likedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedBy);
}


/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameReplayCopyWith<_GameReplay> get copyWith => __$GameReplayCopyWithImpl<_GameReplay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameReplayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameReplay&&(identical(other.id, id) || other.id == id)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&const DeepCollectionEquality().equals(other._playerIds, _playerIds)&&const DeepCollectionEquality().equals(other._playerNames, _playerNames)&&(identical(other.gameDate, gameDate) || other.gameDate == gameDate)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.winnerName, winnerName) || other.winnerName == winnerName)&&const DeepCollectionEquality().equals(other._finalScores, _finalScores)&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.savedBy, savedBy) || other.savedBy == savedBy)&&(identical(other.title, title) || other.title == title)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.views, views) || other.views == views)&&const DeepCollectionEquality().equals(other._likedBy, _likedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gameType,roomId,const DeepCollectionEquality().hash(_playerIds),const DeepCollectionEquality().hash(_playerNames),gameDate,durationMs,winnerId,winnerName,const DeepCollectionEquality().hash(_finalScores),const DeepCollectionEquality().hash(_events),savedBy,title,isPublic,views,const DeepCollectionEquality().hash(_likedBy));

@override
String toString() {
  return 'GameReplay(id: $id, gameType: $gameType, roomId: $roomId, playerIds: $playerIds, playerNames: $playerNames, gameDate: $gameDate, durationMs: $durationMs, winnerId: $winnerId, winnerName: $winnerName, finalScores: $finalScores, events: $events, savedBy: $savedBy, title: $title, isPublic: $isPublic, views: $views, likedBy: $likedBy)';
}


}

/// @nodoc
abstract mixin class _$GameReplayCopyWith<$Res> implements $GameReplayCopyWith<$Res> {
  factory _$GameReplayCopyWith(_GameReplay value, $Res Function(_GameReplay) _then) = __$GameReplayCopyWithImpl;
@override @useResult
$Res call({
 String id, String gameType, String roomId, List<String> playerIds, List<String> playerNames, DateTime gameDate, int durationMs, String? winnerId, String? winnerName, Map<String, int>? finalScores, List<ReplayEvent> events, String? savedBy, String? title, bool isPublic, int views, List<String> likedBy
});




}
/// @nodoc
class __$GameReplayCopyWithImpl<$Res>
    implements _$GameReplayCopyWith<$Res> {
  __$GameReplayCopyWithImpl(this._self, this._then);

  final _GameReplay _self;
  final $Res Function(_GameReplay) _then;

/// Create a copy of GameReplay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gameType = null,Object? roomId = null,Object? playerIds = null,Object? playerNames = null,Object? gameDate = null,Object? durationMs = null,Object? winnerId = freezed,Object? winnerName = freezed,Object? finalScores = freezed,Object? events = null,Object? savedBy = freezed,Object? title = freezed,Object? isPublic = null,Object? views = null,Object? likedBy = null,}) {
  return _then(_GameReplay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,playerIds: null == playerIds ? _self._playerIds : playerIds // ignore: cast_nullable_to_non_nullable
as List<String>,playerNames: null == playerNames ? _self._playerNames : playerNames // ignore: cast_nullable_to_non_nullable
as List<String>,gameDate: null == gameDate ? _self.gameDate : gameDate // ignore: cast_nullable_to_non_nullable
as DateTime,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,winnerName: freezed == winnerName ? _self.winnerName : winnerName // ignore: cast_nullable_to_non_nullable
as String?,finalScores: freezed == finalScores ? _self._finalScores : finalScores // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<ReplayEvent>,savedBy: freezed == savedBy ? _self.savedBy : savedBy // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int,likedBy: null == likedBy ? _self._likedBy : likedBy // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ReplayBookmark {

 String get id; String get replayId; int get timestamp; String get title; String? get description; String? get createdBy;
/// Create a copy of ReplayBookmark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplayBookmarkCopyWith<ReplayBookmark> get copyWith => _$ReplayBookmarkCopyWithImpl<ReplayBookmark>(this as ReplayBookmark, _$identity);

  /// Serializes this ReplayBookmark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplayBookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.replayId, replayId) || other.replayId == replayId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,replayId,timestamp,title,description,createdBy);

@override
String toString() {
  return 'ReplayBookmark(id: $id, replayId: $replayId, timestamp: $timestamp, title: $title, description: $description, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $ReplayBookmarkCopyWith<$Res>  {
  factory $ReplayBookmarkCopyWith(ReplayBookmark value, $Res Function(ReplayBookmark) _then) = _$ReplayBookmarkCopyWithImpl;
@useResult
$Res call({
 String id, String replayId, int timestamp, String title, String? description, String? createdBy
});




}
/// @nodoc
class _$ReplayBookmarkCopyWithImpl<$Res>
    implements $ReplayBookmarkCopyWith<$Res> {
  _$ReplayBookmarkCopyWithImpl(this._self, this._then);

  final ReplayBookmark _self;
  final $Res Function(ReplayBookmark) _then;

/// Create a copy of ReplayBookmark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? replayId = null,Object? timestamp = null,Object? title = null,Object? description = freezed,Object? createdBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,replayId: null == replayId ? _self.replayId : replayId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplayBookmark].
extension ReplayBookmarkPatterns on ReplayBookmark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplayBookmark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplayBookmark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplayBookmark value)  $default,){
final _that = this;
switch (_that) {
case _ReplayBookmark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplayBookmark value)?  $default,){
final _that = this;
switch (_that) {
case _ReplayBookmark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String replayId,  int timestamp,  String title,  String? description,  String? createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplayBookmark() when $default != null:
return $default(_that.id,_that.replayId,_that.timestamp,_that.title,_that.description,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String replayId,  int timestamp,  String title,  String? description,  String? createdBy)  $default,) {final _that = this;
switch (_that) {
case _ReplayBookmark():
return $default(_that.id,_that.replayId,_that.timestamp,_that.title,_that.description,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String replayId,  int timestamp,  String title,  String? description,  String? createdBy)?  $default,) {final _that = this;
switch (_that) {
case _ReplayBookmark() when $default != null:
return $default(_that.id,_that.replayId,_that.timestamp,_that.title,_that.description,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplayBookmark extends ReplayBookmark {
  const _ReplayBookmark({required this.id, required this.replayId, required this.timestamp, required this.title, this.description, this.createdBy}): super._();
  factory _ReplayBookmark.fromJson(Map<String, dynamic> json) => _$ReplayBookmarkFromJson(json);

@override final  String id;
@override final  String replayId;
@override final  int timestamp;
@override final  String title;
@override final  String? description;
@override final  String? createdBy;

/// Create a copy of ReplayBookmark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplayBookmarkCopyWith<_ReplayBookmark> get copyWith => __$ReplayBookmarkCopyWithImpl<_ReplayBookmark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplayBookmarkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplayBookmark&&(identical(other.id, id) || other.id == id)&&(identical(other.replayId, replayId) || other.replayId == replayId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,replayId,timestamp,title,description,createdBy);

@override
String toString() {
  return 'ReplayBookmark(id: $id, replayId: $replayId, timestamp: $timestamp, title: $title, description: $description, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$ReplayBookmarkCopyWith<$Res> implements $ReplayBookmarkCopyWith<$Res> {
  factory _$ReplayBookmarkCopyWith(_ReplayBookmark value, $Res Function(_ReplayBookmark) _then) = __$ReplayBookmarkCopyWithImpl;
@override @useResult
$Res call({
 String id, String replayId, int timestamp, String title, String? description, String? createdBy
});




}
/// @nodoc
class __$ReplayBookmarkCopyWithImpl<$Res>
    implements _$ReplayBookmarkCopyWith<$Res> {
  __$ReplayBookmarkCopyWithImpl(this._self, this._then);

  final _ReplayBookmark _self;
  final $Res Function(_ReplayBookmark) _then;

/// Create a copy of ReplayBookmark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? replayId = null,Object? timestamp = null,Object? title = null,Object? description = freezed,Object? createdBy = freezed,}) {
  return _then(_ReplayBookmark(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,replayId: null == replayId ? _self.replayId : replayId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

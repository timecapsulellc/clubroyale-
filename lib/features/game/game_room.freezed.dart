// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameRoom {

/// Firestore document ID
 String? get id;/// Room name/title
 String get name;/// Host user ID (creator of the room)
 String get hostId;/// 6-digit room code for joining
 String? get roomCode;/// Current game status
@GameStatusConverter() GameStatus get status;/// Type of game (call_break, marriage, teen_patti, etc.)
 String get gameType;/// Game configuration (point value, rounds, etc.)
 GameConfig get config;/// List of players in the room
 List<Player> get players;/// Player scores map (playerId -> score)
 Map<String, int> get scores;/// Whether game is finished (legacy, use status instead)
 bool get isFinished;/// Whether room is public (visible in lobby) or private (code-only)
 bool get isPublic;/// When the room was created
 DateTime? get createdAt;/// When the game finished
 DateTime? get finishedAt;// ===== Call Break Game Fields =====
/// Current round number (1-indexed)
 int get currentRound;/// Current phase of the game
@JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson) GamePhase? get gamePhase;/// Player hands (playerId -> cards)
@JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson) Map<String, List<PlayingCard>> get playerHands;/// Player bids for current round
 Map<String, Bid> get bids;/// Current trick in progress
 Trick? get currentTrick;/// History of completed tricks in current round
 List<Trick> get trickHistory;/// Tricks won by each player in current round
 Map<String, int> get tricksWon;/// Round scores (playerId -> list of scores per round)
@JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson) Map<String, List<double>> get roundScores;/// Current turn (player ID whose turn it is)
 String? get currentTurn;
/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameRoomCopyWith<GameRoom> get copyWith => _$GameRoomCopyWithImpl<GameRoom>(this as GameRoom, _$identity);

  /// Serializes this GameRoom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.scores, scores)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.gamePhase, gamePhase) || other.gamePhase == gamePhase)&&const DeepCollectionEquality().equals(other.playerHands, playerHands)&&const DeepCollectionEquality().equals(other.bids, bids)&&(identical(other.currentTrick, currentTrick) || other.currentTrick == currentTrick)&&const DeepCollectionEquality().equals(other.trickHistory, trickHistory)&&const DeepCollectionEquality().equals(other.tricksWon, tricksWon)&&const DeepCollectionEquality().equals(other.roundScores, roundScores)&&(identical(other.currentTurn, currentTurn) || other.currentTurn == currentTurn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,hostId,roomCode,status,gameType,config,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(scores),isFinished,isPublic,createdAt,finishedAt,currentRound,gamePhase,const DeepCollectionEquality().hash(playerHands),const DeepCollectionEquality().hash(bids),currentTrick,const DeepCollectionEquality().hash(trickHistory),const DeepCollectionEquality().hash(tricksWon),const DeepCollectionEquality().hash(roundScores),currentTurn]);

@override
String toString() {
  return 'GameRoom(id: $id, name: $name, hostId: $hostId, roomCode: $roomCode, status: $status, gameType: $gameType, config: $config, players: $players, scores: $scores, isFinished: $isFinished, isPublic: $isPublic, createdAt: $createdAt, finishedAt: $finishedAt, currentRound: $currentRound, gamePhase: $gamePhase, playerHands: $playerHands, bids: $bids, currentTrick: $currentTrick, trickHistory: $trickHistory, tricksWon: $tricksWon, roundScores: $roundScores, currentTurn: $currentTurn)';
}


}

/// @nodoc
abstract mixin class $GameRoomCopyWith<$Res>  {
  factory $GameRoomCopyWith(GameRoom value, $Res Function(GameRoom) _then) = _$GameRoomCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String hostId, String? roomCode,@GameStatusConverter() GameStatus status, String gameType, GameConfig config, List<Player> players, Map<String, int> scores, bool isFinished, bool isPublic, DateTime? createdAt, DateTime? finishedAt, int currentRound,@JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson) GamePhase? gamePhase,@JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson) Map<String, List<PlayingCard>> playerHands, Map<String, Bid> bids, Trick? currentTrick, List<Trick> trickHistory, Map<String, int> tricksWon,@JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson) Map<String, List<double>> roundScores, String? currentTurn
});


$GameConfigCopyWith<$Res> get config;$TrickCopyWith<$Res>? get currentTrick;

}
/// @nodoc
class _$GameRoomCopyWithImpl<$Res>
    implements $GameRoomCopyWith<$Res> {
  _$GameRoomCopyWithImpl(this._self, this._then);

  final GameRoom _self;
  final $Res Function(GameRoom) _then;

/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? hostId = null,Object? roomCode = freezed,Object? status = null,Object? gameType = null,Object? config = null,Object? players = null,Object? scores = null,Object? isFinished = null,Object? isPublic = null,Object? createdAt = freezed,Object? finishedAt = freezed,Object? currentRound = null,Object? gamePhase = freezed,Object? playerHands = null,Object? bids = null,Object? currentTrick = freezed,Object? trickHistory = null,Object? tricksWon = null,Object? roundScores = null,Object? currentTurn = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,roomCode: freezed == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as GameConfig,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,gamePhase: freezed == gamePhase ? _self.gamePhase : gamePhase // ignore: cast_nullable_to_non_nullable
as GamePhase?,playerHands: null == playerHands ? _self.playerHands : playerHands // ignore: cast_nullable_to_non_nullable
as Map<String, List<PlayingCard>>,bids: null == bids ? _self.bids : bids // ignore: cast_nullable_to_non_nullable
as Map<String, Bid>,currentTrick: freezed == currentTrick ? _self.currentTrick : currentTrick // ignore: cast_nullable_to_non_nullable
as Trick?,trickHistory: null == trickHistory ? _self.trickHistory : trickHistory // ignore: cast_nullable_to_non_nullable
as List<Trick>,tricksWon: null == tricksWon ? _self.tricksWon : tricksWon // ignore: cast_nullable_to_non_nullable
as Map<String, int>,roundScores: null == roundScores ? _self.roundScores : roundScores // ignore: cast_nullable_to_non_nullable
as Map<String, List<double>>,currentTurn: freezed == currentTurn ? _self.currentTurn : currentTurn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameConfigCopyWith<$Res> get config {
  
  return $GameConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrickCopyWith<$Res>? get currentTrick {
    if (_self.currentTrick == null) {
    return null;
  }

  return $TrickCopyWith<$Res>(_self.currentTrick!, (value) {
    return _then(_self.copyWith(currentTrick: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameRoom].
extension GameRoomPatterns on GameRoom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameRoom value)  $default,){
final _that = this;
switch (_that) {
case _GameRoom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameRoom value)?  $default,){
final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String hostId,  String? roomCode, @GameStatusConverter()  GameStatus status,  String gameType,  GameConfig config,  List<Player> players,  Map<String, int> scores,  bool isFinished,  bool isPublic,  DateTime? createdAt,  DateTime? finishedAt,  int currentRound, @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)  GamePhase? gamePhase, @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)  Map<String, List<PlayingCard>> playerHands,  Map<String, Bid> bids,  Trick? currentTrick,  List<Trick> trickHistory,  Map<String, int> tricksWon, @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)  Map<String, List<double>> roundScores,  String? currentTurn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
return $default(_that.id,_that.name,_that.hostId,_that.roomCode,_that.status,_that.gameType,_that.config,_that.players,_that.scores,_that.isFinished,_that.isPublic,_that.createdAt,_that.finishedAt,_that.currentRound,_that.gamePhase,_that.playerHands,_that.bids,_that.currentTrick,_that.trickHistory,_that.tricksWon,_that.roundScores,_that.currentTurn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String hostId,  String? roomCode, @GameStatusConverter()  GameStatus status,  String gameType,  GameConfig config,  List<Player> players,  Map<String, int> scores,  bool isFinished,  bool isPublic,  DateTime? createdAt,  DateTime? finishedAt,  int currentRound, @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)  GamePhase? gamePhase, @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)  Map<String, List<PlayingCard>> playerHands,  Map<String, Bid> bids,  Trick? currentTrick,  List<Trick> trickHistory,  Map<String, int> tricksWon, @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)  Map<String, List<double>> roundScores,  String? currentTurn)  $default,) {final _that = this;
switch (_that) {
case _GameRoom():
return $default(_that.id,_that.name,_that.hostId,_that.roomCode,_that.status,_that.gameType,_that.config,_that.players,_that.scores,_that.isFinished,_that.isPublic,_that.createdAt,_that.finishedAt,_that.currentRound,_that.gamePhase,_that.playerHands,_that.bids,_that.currentTrick,_that.trickHistory,_that.tricksWon,_that.roundScores,_that.currentTurn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String hostId,  String? roomCode, @GameStatusConverter()  GameStatus status,  String gameType,  GameConfig config,  List<Player> players,  Map<String, int> scores,  bool isFinished,  bool isPublic,  DateTime? createdAt,  DateTime? finishedAt,  int currentRound, @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)  GamePhase? gamePhase, @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)  Map<String, List<PlayingCard>> playerHands,  Map<String, Bid> bids,  Trick? currentTrick,  List<Trick> trickHistory,  Map<String, int> tricksWon, @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)  Map<String, List<double>> roundScores,  String? currentTurn)?  $default,) {final _that = this;
switch (_that) {
case _GameRoom() when $default != null:
return $default(_that.id,_that.name,_that.hostId,_that.roomCode,_that.status,_that.gameType,_that.config,_that.players,_that.scores,_that.isFinished,_that.isPublic,_that.createdAt,_that.finishedAt,_that.currentRound,_that.gamePhase,_that.playerHands,_that.bids,_that.currentTrick,_that.trickHistory,_that.tricksWon,_that.roundScores,_that.currentTurn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameRoom extends GameRoom {
  const _GameRoom({this.id, required this.name, required this.hostId, this.roomCode, @GameStatusConverter() this.status = GameStatus.waiting, this.gameType = 'call_break', this.config = const GameConfig(), required final  List<Player> players, required final  Map<String, int> scores, this.isFinished = false, this.isPublic = false, this.createdAt, this.finishedAt, this.currentRound = 1, @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson) this.gamePhase, @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson) final  Map<String, List<PlayingCard>> playerHands = const {}, final  Map<String, Bid> bids = const {}, this.currentTrick, final  List<Trick> trickHistory = const [], final  Map<String, int> tricksWon = const {}, @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson) final  Map<String, List<double>> roundScores = const {}, this.currentTurn}): _players = players,_scores = scores,_playerHands = playerHands,_bids = bids,_trickHistory = trickHistory,_tricksWon = tricksWon,_roundScores = roundScores,super._();
  factory _GameRoom.fromJson(Map<String, dynamic> json) => _$GameRoomFromJson(json);

/// Firestore document ID
@override final  String? id;
/// Room name/title
@override final  String name;
/// Host user ID (creator of the room)
@override final  String hostId;
/// 6-digit room code for joining
@override final  String? roomCode;
/// Current game status
@override@JsonKey()@GameStatusConverter() final  GameStatus status;
/// Type of game (call_break, marriage, teen_patti, etc.)
@override@JsonKey() final  String gameType;
/// Game configuration (point value, rounds, etc.)
@override@JsonKey() final  GameConfig config;
/// List of players in the room
 final  List<Player> _players;
/// List of players in the room
@override List<Player> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

/// Player scores map (playerId -> score)
 final  Map<String, int> _scores;
/// Player scores map (playerId -> score)
@override Map<String, int> get scores {
  if (_scores is EqualUnmodifiableMapView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scores);
}

/// Whether game is finished (legacy, use status instead)
@override@JsonKey() final  bool isFinished;
/// Whether room is public (visible in lobby) or private (code-only)
@override@JsonKey() final  bool isPublic;
/// When the room was created
@override final  DateTime? createdAt;
/// When the game finished
@override final  DateTime? finishedAt;
// ===== Call Break Game Fields =====
/// Current round number (1-indexed)
@override@JsonKey() final  int currentRound;
/// Current phase of the game
@override@JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson) final  GamePhase? gamePhase;
/// Player hands (playerId -> cards)
 final  Map<String, List<PlayingCard>> _playerHands;
/// Player hands (playerId -> cards)
@override@JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson) Map<String, List<PlayingCard>> get playerHands {
  if (_playerHands is EqualUnmodifiableMapView) return _playerHands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_playerHands);
}

/// Player bids for current round
 final  Map<String, Bid> _bids;
/// Player bids for current round
@override@JsonKey() Map<String, Bid> get bids {
  if (_bids is EqualUnmodifiableMapView) return _bids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bids);
}

/// Current trick in progress
@override final  Trick? currentTrick;
/// History of completed tricks in current round
 final  List<Trick> _trickHistory;
/// History of completed tricks in current round
@override@JsonKey() List<Trick> get trickHistory {
  if (_trickHistory is EqualUnmodifiableListView) return _trickHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trickHistory);
}

/// Tricks won by each player in current round
 final  Map<String, int> _tricksWon;
/// Tricks won by each player in current round
@override@JsonKey() Map<String, int> get tricksWon {
  if (_tricksWon is EqualUnmodifiableMapView) return _tricksWon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tricksWon);
}

/// Round scores (playerId -> list of scores per round)
 final  Map<String, List<double>> _roundScores;
/// Round scores (playerId -> list of scores per round)
@override@JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson) Map<String, List<double>> get roundScores {
  if (_roundScores is EqualUnmodifiableMapView) return _roundScores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_roundScores);
}

/// Current turn (player ID whose turn it is)
@override final  String? currentTurn;

/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameRoomCopyWith<_GameRoom> get copyWith => __$GameRoomCopyWithImpl<_GameRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.gamePhase, gamePhase) || other.gamePhase == gamePhase)&&const DeepCollectionEquality().equals(other._playerHands, _playerHands)&&const DeepCollectionEquality().equals(other._bids, _bids)&&(identical(other.currentTrick, currentTrick) || other.currentTrick == currentTrick)&&const DeepCollectionEquality().equals(other._trickHistory, _trickHistory)&&const DeepCollectionEquality().equals(other._tricksWon, _tricksWon)&&const DeepCollectionEquality().equals(other._roundScores, _roundScores)&&(identical(other.currentTurn, currentTurn) || other.currentTurn == currentTurn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,hostId,roomCode,status,gameType,config,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_scores),isFinished,isPublic,createdAt,finishedAt,currentRound,gamePhase,const DeepCollectionEquality().hash(_playerHands),const DeepCollectionEquality().hash(_bids),currentTrick,const DeepCollectionEquality().hash(_trickHistory),const DeepCollectionEquality().hash(_tricksWon),const DeepCollectionEquality().hash(_roundScores),currentTurn]);

@override
String toString() {
  return 'GameRoom(id: $id, name: $name, hostId: $hostId, roomCode: $roomCode, status: $status, gameType: $gameType, config: $config, players: $players, scores: $scores, isFinished: $isFinished, isPublic: $isPublic, createdAt: $createdAt, finishedAt: $finishedAt, currentRound: $currentRound, gamePhase: $gamePhase, playerHands: $playerHands, bids: $bids, currentTrick: $currentTrick, trickHistory: $trickHistory, tricksWon: $tricksWon, roundScores: $roundScores, currentTurn: $currentTurn)';
}


}

/// @nodoc
abstract mixin class _$GameRoomCopyWith<$Res> implements $GameRoomCopyWith<$Res> {
  factory _$GameRoomCopyWith(_GameRoom value, $Res Function(_GameRoom) _then) = __$GameRoomCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String hostId, String? roomCode,@GameStatusConverter() GameStatus status, String gameType, GameConfig config, List<Player> players, Map<String, int> scores, bool isFinished, bool isPublic, DateTime? createdAt, DateTime? finishedAt, int currentRound,@JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson) GamePhase? gamePhase,@JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson) Map<String, List<PlayingCard>> playerHands, Map<String, Bid> bids, Trick? currentTrick, List<Trick> trickHistory, Map<String, int> tricksWon,@JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson) Map<String, List<double>> roundScores, String? currentTurn
});


@override $GameConfigCopyWith<$Res> get config;@override $TrickCopyWith<$Res>? get currentTrick;

}
/// @nodoc
class __$GameRoomCopyWithImpl<$Res>
    implements _$GameRoomCopyWith<$Res> {
  __$GameRoomCopyWithImpl(this._self, this._then);

  final _GameRoom _self;
  final $Res Function(_GameRoom) _then;

/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? hostId = null,Object? roomCode = freezed,Object? status = null,Object? gameType = null,Object? config = null,Object? players = null,Object? scores = null,Object? isFinished = null,Object? isPublic = null,Object? createdAt = freezed,Object? finishedAt = freezed,Object? currentRound = null,Object? gamePhase = freezed,Object? playerHands = null,Object? bids = null,Object? currentTrick = freezed,Object? trickHistory = null,Object? tricksWon = null,Object? roundScores = null,Object? currentTurn = freezed,}) {
  return _then(_GameRoom(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,roomCode: freezed == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as GameConfig,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, int>,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,gamePhase: freezed == gamePhase ? _self.gamePhase : gamePhase // ignore: cast_nullable_to_non_nullable
as GamePhase?,playerHands: null == playerHands ? _self._playerHands : playerHands // ignore: cast_nullable_to_non_nullable
as Map<String, List<PlayingCard>>,bids: null == bids ? _self._bids : bids // ignore: cast_nullable_to_non_nullable
as Map<String, Bid>,currentTrick: freezed == currentTrick ? _self.currentTrick : currentTrick // ignore: cast_nullable_to_non_nullable
as Trick?,trickHistory: null == trickHistory ? _self._trickHistory : trickHistory // ignore: cast_nullable_to_non_nullable
as List<Trick>,tricksWon: null == tricksWon ? _self._tricksWon : tricksWon // ignore: cast_nullable_to_non_nullable
as Map<String, int>,roundScores: null == roundScores ? _self._roundScores : roundScores // ignore: cast_nullable_to_non_nullable
as Map<String, List<double>>,currentTurn: freezed == currentTurn ? _self.currentTurn : currentTurn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameConfigCopyWith<$Res> get config {
  
  return $GameConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}/// Create a copy of GameRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrickCopyWith<$Res>? get currentTrick {
    if (_self.currentTrick == null) {
    return null;
  }

  return $TrickCopyWith<$Res>(_self.currentTrick!, (value) {
    return _then(_self.copyWith(currentTrick: value));
  });
}
}


/// @nodoc
mixin _$Player {

 String get id; String get name; UserProfile? get profile; bool get isReady; bool get isBot;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isBot, isBot) || other.isBot == isBot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profile,isReady,isBot);

@override
String toString() {
  return 'Player(id: $id, name: $name, profile: $profile, isReady: $isReady, isBot: $isBot)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String id, String name, UserProfile? profile, bool isReady, bool isBot
});


$UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? profile = freezed,Object? isReady = null,Object? isBot = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  UserProfile? profile,  bool isReady,  bool isBot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.profile,_that.isReady,_that.isBot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  UserProfile? profile,  bool isReady,  bool isBot)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.name,_that.profile,_that.isReady,_that.isBot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  UserProfile? profile,  bool isReady,  bool isBot)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.profile,_that.isReady,_that.isBot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player implements Player {
  const _Player({required this.id, required this.name, this.profile, this.isReady = false, this.isBot = false});
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

@override final  String id;
@override final  String name;
@override final  UserProfile? profile;
@override@JsonKey() final  bool isReady;
@override@JsonKey() final  bool isBot;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.isReady, isReady) || other.isReady == isReady)&&(identical(other.isBot, isBot) || other.isBot == isBot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profile,isReady,isBot);

@override
String toString() {
  return 'Player(id: $id, name: $name, profile: $profile, isReady: $isReady, isBot: $isBot)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, UserProfile? profile, bool isReady, bool isBot
});


@override $UserProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? profile = freezed,Object? isReady = null,Object? isBot = null,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile?,isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on

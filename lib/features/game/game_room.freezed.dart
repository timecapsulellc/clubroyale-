// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GameRoom _$GameRoomFromJson(Map<String, dynamic> json) {
  return _GameRoom.fromJson(json);
}

/// @nodoc
mixin _$GameRoom {
  /// Firestore document ID
  String? get id => throw _privateConstructorUsedError;

  /// Room name/title
  String get name => throw _privateConstructorUsedError;

  /// Host user ID (creator of the room)
  String get hostId => throw _privateConstructorUsedError;

  /// 6-digit room code for joining
  String? get roomCode => throw _privateConstructorUsedError;

  /// Current game status
  @GameStatusConverter()
  GameStatus get status => throw _privateConstructorUsedError;

  /// Game configuration (point value, rounds, etc.)
  GameConfig get config => throw _privateConstructorUsedError;

  /// List of players in the room
  List<Player> get players => throw _privateConstructorUsedError;

  /// Player scores map (playerId -> score)
  Map<String, int> get scores => throw _privateConstructorUsedError;

  /// Whether game is finished (legacy, use status instead)
  bool get isFinished => throw _privateConstructorUsedError;

  /// When the room was created
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the game finished
  DateTime? get finishedAt =>
      throw _privateConstructorUsedError; // ===== Call Break Game Fields =====
  /// Current round number (1-indexed)
  int get currentRound => throw _privateConstructorUsedError;

  /// Current phase of the game
  @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
  GamePhase? get gamePhase => throw _privateConstructorUsedError;

  /// Player hands (playerId -> cards)
  @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
  Map<String, List<PlayingCard>> get playerHands =>
      throw _privateConstructorUsedError;

  /// Player bids for current round
  Map<String, Bid> get bids => throw _privateConstructorUsedError;

  /// Current trick in progress
  Trick? get currentTrick => throw _privateConstructorUsedError;

  /// History of completed tricks in current round
  List<Trick> get trickHistory => throw _privateConstructorUsedError;

  /// Tricks won by each player in current round
  Map<String, int> get tricksWon => throw _privateConstructorUsedError;

  /// Round scores (playerId -> list of scores per round)
  @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
  Map<String, List<double>> get roundScores =>
      throw _privateConstructorUsedError;

  /// Current turn (player ID whose turn it is)
  String? get currentTurn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GameRoomCopyWith<GameRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameRoomCopyWith<$Res> {
  factory $GameRoomCopyWith(GameRoom value, $Res Function(GameRoom) then) =
      _$GameRoomCopyWithImpl<$Res, GameRoom>;
  @useResult
  $Res call(
      {String? id,
      String name,
      String hostId,
      String? roomCode,
      @GameStatusConverter() GameStatus status,
      GameConfig config,
      List<Player> players,
      Map<String, int> scores,
      bool isFinished,
      DateTime? createdAt,
      DateTime? finishedAt,
      int currentRound,
      @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
      GamePhase? gamePhase,
      @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
      Map<String, List<PlayingCard>> playerHands,
      Map<String, Bid> bids,
      Trick? currentTrick,
      List<Trick> trickHistory,
      Map<String, int> tricksWon,
      @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
      Map<String, List<double>> roundScores,
      String? currentTurn});

  $GameConfigCopyWith<$Res> get config;
  $TrickCopyWith<$Res>? get currentTrick;
}

/// @nodoc
class _$GameRoomCopyWithImpl<$Res, $Val extends GameRoom>
    implements $GameRoomCopyWith<$Res> {
  _$GameRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? hostId = null,
    Object? roomCode = freezed,
    Object? status = null,
    Object? config = null,
    Object? players = null,
    Object? scores = null,
    Object? isFinished = null,
    Object? createdAt = freezed,
    Object? finishedAt = freezed,
    Object? currentRound = null,
    Object? gamePhase = freezed,
    Object? playerHands = null,
    Object? bids = null,
    Object? currentTrick = freezed,
    Object? trickHistory = null,
    Object? tricksWon = null,
    Object? roundScores = null,
    Object? currentTurn = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      roomCode: freezed == roomCode
          ? _value.roomCode
          : roomCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStatus,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as GameConfig,
      players: null == players
          ? _value.players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      scores: null == scores
          ? _value.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      isFinished: null == isFinished
          ? _value.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finishedAt: freezed == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentRound: null == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int,
      gamePhase: freezed == gamePhase
          ? _value.gamePhase
          : gamePhase // ignore: cast_nullable_to_non_nullable
              as GamePhase?,
      playerHands: null == playerHands
          ? _value.playerHands
          : playerHands // ignore: cast_nullable_to_non_nullable
              as Map<String, List<PlayingCard>>,
      bids: null == bids
          ? _value.bids
          : bids // ignore: cast_nullable_to_non_nullable
              as Map<String, Bid>,
      currentTrick: freezed == currentTrick
          ? _value.currentTrick
          : currentTrick // ignore: cast_nullable_to_non_nullable
              as Trick?,
      trickHistory: null == trickHistory
          ? _value.trickHistory
          : trickHistory // ignore: cast_nullable_to_non_nullable
              as List<Trick>,
      tricksWon: null == tricksWon
          ? _value.tricksWon
          : tricksWon // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      roundScores: null == roundScores
          ? _value.roundScores
          : roundScores // ignore: cast_nullable_to_non_nullable
              as Map<String, List<double>>,
      currentTurn: freezed == currentTurn
          ? _value.currentTurn
          : currentTurn // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $GameConfigCopyWith<$Res> get config {
    return $GameConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TrickCopyWith<$Res>? get currentTrick {
    if (_value.currentTrick == null) {
      return null;
    }

    return $TrickCopyWith<$Res>(_value.currentTrick!, (value) {
      return _then(_value.copyWith(currentTrick: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameRoomImplCopyWith<$Res>
    implements $GameRoomCopyWith<$Res> {
  factory _$$GameRoomImplCopyWith(
          _$GameRoomImpl value, $Res Function(_$GameRoomImpl) then) =
      __$$GameRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String name,
      String hostId,
      String? roomCode,
      @GameStatusConverter() GameStatus status,
      GameConfig config,
      List<Player> players,
      Map<String, int> scores,
      bool isFinished,
      DateTime? createdAt,
      DateTime? finishedAt,
      int currentRound,
      @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
      GamePhase? gamePhase,
      @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
      Map<String, List<PlayingCard>> playerHands,
      Map<String, Bid> bids,
      Trick? currentTrick,
      List<Trick> trickHistory,
      Map<String, int> tricksWon,
      @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
      Map<String, List<double>> roundScores,
      String? currentTurn});

  @override
  $GameConfigCopyWith<$Res> get config;
  @override
  $TrickCopyWith<$Res>? get currentTrick;
}

/// @nodoc
class __$$GameRoomImplCopyWithImpl<$Res>
    extends _$GameRoomCopyWithImpl<$Res, _$GameRoomImpl>
    implements _$$GameRoomImplCopyWith<$Res> {
  __$$GameRoomImplCopyWithImpl(
      _$GameRoomImpl _value, $Res Function(_$GameRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? hostId = null,
    Object? roomCode = freezed,
    Object? status = null,
    Object? config = null,
    Object? players = null,
    Object? scores = null,
    Object? isFinished = null,
    Object? createdAt = freezed,
    Object? finishedAt = freezed,
    Object? currentRound = null,
    Object? gamePhase = freezed,
    Object? playerHands = null,
    Object? bids = null,
    Object? currentTrick = freezed,
    Object? trickHistory = null,
    Object? tricksWon = null,
    Object? roundScores = null,
    Object? currentTurn = freezed,
  }) {
    return _then(_$GameRoomImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      roomCode: freezed == roomCode
          ? _value.roomCode
          : roomCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GameStatus,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as GameConfig,
      players: null == players
          ? _value._players
          : players // ignore: cast_nullable_to_non_nullable
              as List<Player>,
      scores: null == scores
          ? _value._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      isFinished: null == isFinished
          ? _value.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      finishedAt: freezed == finishedAt
          ? _value.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentRound: null == currentRound
          ? _value.currentRound
          : currentRound // ignore: cast_nullable_to_non_nullable
              as int,
      gamePhase: freezed == gamePhase
          ? _value.gamePhase
          : gamePhase // ignore: cast_nullable_to_non_nullable
              as GamePhase?,
      playerHands: null == playerHands
          ? _value._playerHands
          : playerHands // ignore: cast_nullable_to_non_nullable
              as Map<String, List<PlayingCard>>,
      bids: null == bids
          ? _value._bids
          : bids // ignore: cast_nullable_to_non_nullable
              as Map<String, Bid>,
      currentTrick: freezed == currentTrick
          ? _value.currentTrick
          : currentTrick // ignore: cast_nullable_to_non_nullable
              as Trick?,
      trickHistory: null == trickHistory
          ? _value._trickHistory
          : trickHistory // ignore: cast_nullable_to_non_nullable
              as List<Trick>,
      tricksWon: null == tricksWon
          ? _value._tricksWon
          : tricksWon // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      roundScores: null == roundScores
          ? _value._roundScores
          : roundScores // ignore: cast_nullable_to_non_nullable
              as Map<String, List<double>>,
      currentTurn: freezed == currentTurn
          ? _value.currentTurn
          : currentTurn // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GameRoomImpl extends _GameRoom {
  const _$GameRoomImpl(
      {this.id,
      required this.name,
      required this.hostId,
      this.roomCode,
      @GameStatusConverter() this.status = GameStatus.waiting,
      this.config = const GameConfig(),
      required final List<Player> players,
      required final Map<String, int> scores,
      this.isFinished = false,
      this.createdAt,
      this.finishedAt,
      this.currentRound = 1,
      @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
      this.gamePhase,
      @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
      final Map<String, List<PlayingCard>> playerHands = const {},
      final Map<String, Bid> bids = const {},
      this.currentTrick,
      final List<Trick> trickHistory = const [],
      final Map<String, int> tricksWon = const {},
      @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
      final Map<String, List<double>> roundScores = const {},
      this.currentTurn})
      : _players = players,
        _scores = scores,
        _playerHands = playerHands,
        _bids = bids,
        _trickHistory = trickHistory,
        _tricksWon = tricksWon,
        _roundScores = roundScores,
        super._();

  factory _$GameRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameRoomImplFromJson(json);

  /// Firestore document ID
  @override
  final String? id;

  /// Room name/title
  @override
  final String name;

  /// Host user ID (creator of the room)
  @override
  final String hostId;

  /// 6-digit room code for joining
  @override
  final String? roomCode;

  /// Current game status
  @override
  @JsonKey()
  @GameStatusConverter()
  final GameStatus status;

  /// Game configuration (point value, rounds, etc.)
  @override
  @JsonKey()
  final GameConfig config;

  /// List of players in the room
  final List<Player> _players;

  /// List of players in the room
  @override
  List<Player> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  /// Player scores map (playerId -> score)
  final Map<String, int> _scores;

  /// Player scores map (playerId -> score)
  @override
  Map<String, int> get scores {
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_scores);
  }

  /// Whether game is finished (legacy, use status instead)
  @override
  @JsonKey()
  final bool isFinished;

  /// When the room was created
  @override
  final DateTime? createdAt;

  /// When the game finished
  @override
  final DateTime? finishedAt;
// ===== Call Break Game Fields =====
  /// Current round number (1-indexed)
  @override
  @JsonKey()
  final int currentRound;

  /// Current phase of the game
  @override
  @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
  final GamePhase? gamePhase;

  /// Player hands (playerId -> cards)
  final Map<String, List<PlayingCard>> _playerHands;

  /// Player hands (playerId -> cards)
  @override
  @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
  Map<String, List<PlayingCard>> get playerHands {
    if (_playerHands is EqualUnmodifiableMapView) return _playerHands;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_playerHands);
  }

  /// Player bids for current round
  final Map<String, Bid> _bids;

  /// Player bids for current round
  @override
  @JsonKey()
  Map<String, Bid> get bids {
    if (_bids is EqualUnmodifiableMapView) return _bids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bids);
  }

  /// Current trick in progress
  @override
  final Trick? currentTrick;

  /// History of completed tricks in current round
  final List<Trick> _trickHistory;

  /// History of completed tricks in current round
  @override
  @JsonKey()
  List<Trick> get trickHistory {
    if (_trickHistory is EqualUnmodifiableListView) return _trickHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trickHistory);
  }

  /// Tricks won by each player in current round
  final Map<String, int> _tricksWon;

  /// Tricks won by each player in current round
  @override
  @JsonKey()
  Map<String, int> get tricksWon {
    if (_tricksWon is EqualUnmodifiableMapView) return _tricksWon;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_tricksWon);
  }

  /// Round scores (playerId -> list of scores per round)
  final Map<String, List<double>> _roundScores;

  /// Round scores (playerId -> list of scores per round)
  @override
  @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
  Map<String, List<double>> get roundScores {
    if (_roundScores is EqualUnmodifiableMapView) return _roundScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_roundScores);
  }

  /// Current turn (player ID whose turn it is)
  @override
  final String? currentTurn;

  @override
  String toString() {
    return 'GameRoom(id: $id, name: $name, hostId: $hostId, roomCode: $roomCode, status: $status, config: $config, players: $players, scores: $scores, isFinished: $isFinished, createdAt: $createdAt, finishedAt: $finishedAt, currentRound: $currentRound, gamePhase: $gamePhase, playerHands: $playerHands, bids: $bids, currentTrick: $currentTrick, trickHistory: $trickHistory, tricksWon: $tricksWon, roundScores: $roundScores, currentTurn: $currentTurn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hostId, hostId) || other.hostId == hostId) &&
            (identical(other.roomCode, roomCode) ||
                other.roomCode == roomCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.config, config) || other.config == config) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound) &&
            (identical(other.gamePhase, gamePhase) ||
                other.gamePhase == gamePhase) &&
            const DeepCollectionEquality()
                .equals(other._playerHands, _playerHands) &&
            const DeepCollectionEquality().equals(other._bids, _bids) &&
            (identical(other.currentTrick, currentTrick) ||
                other.currentTrick == currentTrick) &&
            const DeepCollectionEquality()
                .equals(other._trickHistory, _trickHistory) &&
            const DeepCollectionEquality()
                .equals(other._tricksWon, _tricksWon) &&
            const DeepCollectionEquality()
                .equals(other._roundScores, _roundScores) &&
            (identical(other.currentTurn, currentTurn) ||
                other.currentTurn == currentTurn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        hostId,
        roomCode,
        status,
        config,
        const DeepCollectionEquality().hash(_players),
        const DeepCollectionEquality().hash(_scores),
        isFinished,
        createdAt,
        finishedAt,
        currentRound,
        gamePhase,
        const DeepCollectionEquality().hash(_playerHands),
        const DeepCollectionEquality().hash(_bids),
        currentTrick,
        const DeepCollectionEquality().hash(_trickHistory),
        const DeepCollectionEquality().hash(_tricksWon),
        const DeepCollectionEquality().hash(_roundScores),
        currentTurn
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GameRoomImplCopyWith<_$GameRoomImpl> get copyWith =>
      __$$GameRoomImplCopyWithImpl<_$GameRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameRoomImplToJson(
      this,
    );
  }
}

abstract class _GameRoom extends GameRoom {
  const factory _GameRoom(
      {final String? id,
      required final String name,
      required final String hostId,
      final String? roomCode,
      @GameStatusConverter() final GameStatus status,
      final GameConfig config,
      required final List<Player> players,
      required final Map<String, int> scores,
      final bool isFinished,
      final DateTime? createdAt,
      final DateTime? finishedAt,
      final int currentRound,
      @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
      final GamePhase? gamePhase,
      @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
      final Map<String, List<PlayingCard>> playerHands,
      final Map<String, Bid> bids,
      final Trick? currentTrick,
      final List<Trick> trickHistory,
      final Map<String, int> tricksWon,
      @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
      final Map<String, List<double>> roundScores,
      final String? currentTurn}) = _$GameRoomImpl;
  const _GameRoom._() : super._();

  factory _GameRoom.fromJson(Map<String, dynamic> json) =
      _$GameRoomImpl.fromJson;

  @override

  /// Firestore document ID
  String? get id;
  @override

  /// Room name/title
  String get name;
  @override

  /// Host user ID (creator of the room)
  String get hostId;
  @override

  /// 6-digit room code for joining
  String? get roomCode;
  @override

  /// Current game status
  @GameStatusConverter()
  GameStatus get status;
  @override

  /// Game configuration (point value, rounds, etc.)
  GameConfig get config;
  @override

  /// List of players in the room
  List<Player> get players;
  @override

  /// Player scores map (playerId -> score)
  Map<String, int> get scores;
  @override

  /// Whether game is finished (legacy, use status instead)
  bool get isFinished;
  @override

  /// When the room was created
  DateTime? get createdAt;
  @override

  /// When the game finished
  DateTime? get finishedAt;
  @override // ===== Call Break Game Fields =====
  /// Current round number (1-indexed)
  int get currentRound;
  @override

  /// Current phase of the game
  @JsonKey(fromJson: _gamePhaseFromJson, toJson: _gamePhaseToJson)
  GamePhase? get gamePhase;
  @override

  /// Player hands (playerId -> cards)
  @JsonKey(fromJson: _playerHandsFromJson, toJson: _playerHandsToJson)
  Map<String, List<PlayingCard>> get playerHands;
  @override

  /// Player bids for current round
  Map<String, Bid> get bids;
  @override

  /// Current trick in progress
  Trick? get currentTrick;
  @override

  /// History of completed tricks in current round
  List<Trick> get trickHistory;
  @override

  /// Tricks won by each player in current round
  Map<String, int> get tricksWon;
  @override

  /// Round scores (playerId -> list of scores per round)
  @JsonKey(fromJson: _roundScoresFromJson, toJson: _roundScoresToJson)
  Map<String, List<double>> get roundScores;
  @override

  /// Current turn (player ID whose turn it is)
  String? get currentTurn;
  @override
  @JsonKey(ignore: true)
  _$$GameRoomImplCopyWith<_$GameRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return _Player.fromJson(json);
}

/// @nodoc
mixin _$Player {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  UserProfile? get profile => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlayerCopyWith<Player> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerCopyWith<$Res> {
  factory $PlayerCopyWith(Player value, $Res Function(Player) then) =
      _$PlayerCopyWithImpl<$Res, Player>;
  @useResult
  $Res call({String id, String name, UserProfile? profile, bool isReady});

  $UserProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class _$PlayerCopyWithImpl<$Res, $Val extends Player>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profile = freezed,
    Object? isReady = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayerImplCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$$PlayerImplCopyWith(
          _$PlayerImpl value, $Res Function(_$PlayerImpl) then) =
      __$$PlayerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, UserProfile? profile, bool isReady});

  @override
  $UserProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$PlayerImplCopyWithImpl<$Res>
    extends _$PlayerCopyWithImpl<$Res, _$PlayerImpl>
    implements _$$PlayerImplCopyWith<$Res> {
  __$$PlayerImplCopyWithImpl(
      _$PlayerImpl _value, $Res Function(_$PlayerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profile = freezed,
    Object? isReady = null,
  }) {
    return _then(_$PlayerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerImpl implements _Player {
  const _$PlayerImpl(
      {required this.id,
      required this.name,
      this.profile,
      this.isReady = false});

  factory _$PlayerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final UserProfile? profile;
  @override
  @JsonKey()
  final bool isReady;

  @override
  String toString() {
    return 'Player(id: $id, name: $name, profile: $profile, isReady: $isReady)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.isReady, isReady) || other.isReady == isReady));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, profile, isReady);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      __$$PlayerImplCopyWithImpl<_$PlayerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerImplToJson(
      this,
    );
  }
}

abstract class _Player implements Player {
  const factory _Player(
      {required final String id,
      required final String name,
      final UserProfile? profile,
      final bool isReady}) = _$PlayerImpl;

  factory _Player.fromJson(Map<String, dynamic> json) = _$PlayerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  UserProfile? get profile;
  @override
  bool get isReady;
  @override
  @JsonKey(ignore: true)
  _$$PlayerImplCopyWith<_$PlayerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

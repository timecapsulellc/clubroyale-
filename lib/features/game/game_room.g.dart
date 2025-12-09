// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameRoom _$GameRoomFromJson(Map<String, dynamic> json) => _GameRoom(
  id: json['id'] as String?,
  name: json['name'] as String,
  hostId: json['hostId'] as String,
  roomCode: json['roomCode'] as String?,
  status: json['status'] == null
      ? GameStatus.waiting
      : const GameStatusConverter().fromJson(json['status'] as String),
  gameType: json['gameType'] as String? ?? 'call_break',
  config: json['config'] == null
      ? const GameConfig()
      : GameConfig.fromJson(json['config'] as Map<String, dynamic>),
  players: (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  scores: Map<String, int>.from(json['scores'] as Map),
  isFinished: json['isFinished'] as bool? ?? false,
  isPublic: json['isPublic'] as bool? ?? false,
  createdAt: _dateTimeFromJson(json['createdAt']),
  finishedAt: _dateTimeFromJson(json['finishedAt']),
  currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
  gamePhase: _gamePhaseFromJson(json['gamePhase'] as String?),
  playerHands: json['playerHands'] == null
      ? const {}
      : _playerHandsFromJson(json['playerHands'] as Map<String, dynamic>?),
  bids:
      (json['bids'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Bid.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
  currentTrick: json['currentTrick'] == null
      ? null
      : Trick.fromJson(json['currentTrick'] as Map<String, dynamic>),
  trickHistory:
      (json['trickHistory'] as List<dynamic>?)
          ?.map((e) => Trick.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tricksWon:
      (json['tricksWon'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  roundScores: json['roundScores'] == null
      ? const {}
      : _roundScoresFromJson(json['roundScores'] as Map<String, dynamic>?),
  currentTurn: json['currentTurn'] as String?,
);

Map<String, dynamic> _$GameRoomToJson(_GameRoom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'hostId': instance.hostId,
  'roomCode': instance.roomCode,
  'status': const GameStatusConverter().toJson(instance.status),
  'gameType': instance.gameType,
  'config': instance.config,
  'players': instance.players,
  'scores': instance.scores,
  'isFinished': instance.isFinished,
  'isPublic': instance.isPublic,
  'createdAt': _dateTimeToJson(instance.createdAt),
  'finishedAt': _dateTimeToJson(instance.finishedAt),
  'currentRound': instance.currentRound,
  'gamePhase': _gamePhaseToJson(instance.gamePhase),
  'playerHands': _playerHandsToJson(instance.playerHands),
  'bids': instance.bids,
  'currentTrick': instance.currentTrick,
  'trickHistory': instance.trickHistory,
  'tricksWon': instance.tricksWon,
  'roundScores': _roundScoresToJson(instance.roundScores),
  'currentTurn': instance.currentTurn,
};

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  name: json['name'] as String,
  profile: json['profile'] == null
      ? null
      : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
  isReady: json['isReady'] as bool? ?? false,
  isBot: json['isBot'] as bool? ?? false,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'profile': instance.profile,
  'isReady': instance.isReady,
  'isBot': instance.isBot,
};

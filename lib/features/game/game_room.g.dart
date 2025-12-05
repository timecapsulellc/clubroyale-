// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameRoomImpl _$$GameRoomImplFromJson(Map<String, dynamic> json) =>
    _$GameRoomImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      hostId: json['hostId'] as String,
      roomCode: json['roomCode'] as String?,
      status: json['status'] == null
          ? GameStatus.waiting
          : const GameStatusConverter().fromJson(json['status'] as String),
      config: json['config'] == null
          ? const GameConfig()
          : GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      scores: Map<String, int>.from(json['scores'] as Map),
      isFinished: json['isFinished'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      finishedAt: json['finishedAt'] == null
          ? null
          : DateTime.parse(json['finishedAt'] as String),
      currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
      gamePhase: _gamePhaseFromJson(json['gamePhase'] as String?),
      playerHands: json['playerHands'] == null
          ? const {}
          : _playerHandsFromJson(json['playerHands'] as Map<String, dynamic>?),
      bids: (json['bids'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, Bid.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      currentTrick: json['currentTrick'] == null
          ? null
          : Trick.fromJson(json['currentTrick'] as Map<String, dynamic>),
      trickHistory: (json['trickHistory'] as List<dynamic>?)
              ?.map((e) => Trick.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tricksWon: (json['tricksWon'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      roundScores: json['roundScores'] == null
          ? const {}
          : _roundScoresFromJson(json['roundScores'] as Map<String, dynamic>?),
      currentTurn: json['currentTurn'] as String?,
    );

Map<String, dynamic> _$$GameRoomImplToJson(_$GameRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostId': instance.hostId,
      'roomCode': instance.roomCode,
      'status': const GameStatusConverter().toJson(instance.status),
      'config': instance.config,
      'players': instance.players,
      'scores': instance.scores,
      'isFinished': instance.isFinished,
      'createdAt': instance.createdAt?.toIso8601String(),
      'finishedAt': instance.finishedAt?.toIso8601String(),
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

_$PlayerImpl _$$PlayerImplFromJson(Map<String, dynamic> json) => _$PlayerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      profile: json['profile'] == null
          ? null
          : UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      isReady: json['isReady'] as bool? ?? false,
    );

Map<String, dynamic> _$$PlayerImplToJson(_$PlayerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profile': instance.profile,
      'isReady': instance.isReady,
    };

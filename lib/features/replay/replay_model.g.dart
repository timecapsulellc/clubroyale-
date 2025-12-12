// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replay_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReplayEvent _$ReplayEventFromJson(Map<String, dynamic> json) => _ReplayEvent(
  sequenceNumber: (json['sequenceNumber'] as num).toInt(),
  type: $enumDecode(_$ReplayEventTypeEnumMap, json['type']),
  timestamp: (json['timestamp'] as num).toInt(),
  playerId: json['playerId'] as String?,
  playerName: json['playerName'] as String?,
  data: json['data'] as Map<String, dynamic>?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ReplayEventToJson(_ReplayEvent instance) =>
    <String, dynamic>{
      'sequenceNumber': instance.sequenceNumber,
      'type': _$ReplayEventTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp,
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'data': instance.data,
      'description': instance.description,
    };

const _$ReplayEventTypeEnumMap = {
  ReplayEventType.gameStart: 'gameStart',
  ReplayEventType.cardDrawn: 'cardDrawn',
  ReplayEventType.cardPlayed: 'cardPlayed',
  ReplayEventType.meldDeclared: 'meldDeclared',
  ReplayEventType.turnChange: 'turnChange',
  ReplayEventType.scoreUpdate: 'scoreUpdate',
  ReplayEventType.roundEnd: 'roundEnd',
  ReplayEventType.gameEnd: 'gameEnd',
  ReplayEventType.chat: 'chat',
};

_GameReplay _$GameReplayFromJson(Map<String, dynamic> json) => _GameReplay(
  id: json['id'] as String,
  gameType: json['gameType'] as String,
  roomId: json['roomId'] as String,
  playerIds: (json['playerIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  playerNames: (json['playerNames'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  gameDate: DateTime.parse(json['gameDate'] as String),
  durationMs: (json['durationMs'] as num).toInt(),
  winnerId: json['winnerId'] as String?,
  winnerName: json['winnerName'] as String?,
  finalScores: (json['finalScores'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => ReplayEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  savedBy: json['savedBy'] as String?,
  title: json['title'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
  views: (json['views'] as num?)?.toInt() ?? 0,
  likedBy:
      (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$GameReplayToJson(_GameReplay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gameType': instance.gameType,
      'roomId': instance.roomId,
      'playerIds': instance.playerIds,
      'playerNames': instance.playerNames,
      'gameDate': instance.gameDate.toIso8601String(),
      'durationMs': instance.durationMs,
      'winnerId': instance.winnerId,
      'winnerName': instance.winnerName,
      'finalScores': instance.finalScores,
      'events': instance.events,
      'savedBy': instance.savedBy,
      'title': instance.title,
      'isPublic': instance.isPublic,
      'views': instance.views,
      'likedBy': instance.likedBy,
    };

_ReplayBookmark _$ReplayBookmarkFromJson(Map<String, dynamic> json) =>
    _ReplayBookmark(
      id: json['id'] as String,
      replayId: json['replayId'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$ReplayBookmarkToJson(_ReplayBookmark instance) =>
    <String, dynamic>{
      'id': instance.id,
      'replayId': instance.replayId,
      'timestamp': instance.timestamp,
      'title': instance.title,
      'description': instance.description,
      'createdBy': instance.createdBy,
    };

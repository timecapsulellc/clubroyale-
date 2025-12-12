// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tournament _$TournamentFromJson(Map<String, dynamic> json) => _Tournament(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  hostId: json['hostId'] as String,
  hostName: json['hostName'] as String,
  gameType: json['gameType'] as String,
  format: $enumDecode(_$TournamentFormatEnumMap, json['format']),
  status:
      $enumDecodeNullable(_$TournamentStatusEnumMap, json['status']) ??
      TournamentStatus.draft,
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 8,
  minParticipants: (json['minParticipants'] as num?)?.toInt() ?? 2,
  prizePool: (json['prizePool'] as num?)?.toInt(),
  entryFee: (json['entryFee'] as num?)?.toInt(),
  registrationDeadline: json['registrationDeadline'] == null
      ? null
      : DateTime.parse(json['registrationDeadline'] as String),
  startTime: json['startTime'] == null
      ? null
      : DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  brackets:
      (json['brackets'] as List<dynamic>?)
          ?.map((e) => TournamentBracket.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  winnerId: json['winnerId'] as String?,
  winnerName: json['winnerName'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TournamentToJson(_Tournament instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'gameType': instance.gameType,
      'format': _$TournamentFormatEnumMap[instance.format]!,
      'status': _$TournamentStatusEnumMap[instance.status]!,
      'maxParticipants': instance.maxParticipants,
      'minParticipants': instance.minParticipants,
      'prizePool': instance.prizePool,
      'entryFee': instance.entryFee,
      'registrationDeadline': instance.registrationDeadline?.toIso8601String(),
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'participantIds': instance.participantIds,
      'brackets': instance.brackets,
      'winnerId': instance.winnerId,
      'winnerName': instance.winnerName,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$TournamentFormatEnumMap = {
  TournamentFormat.singleElimination: 'singleElimination',
  TournamentFormat.doubleElimination: 'doubleElimination',
  TournamentFormat.roundRobin: 'roundRobin',
};

const _$TournamentStatusEnumMap = {
  TournamentStatus.draft: 'draft',
  TournamentStatus.registration: 'registration',
  TournamentStatus.inProgress: 'inProgress',
  TournamentStatus.completed: 'completed',
  TournamentStatus.cancelled: 'cancelled',
};

_TournamentBracket _$TournamentBracketFromJson(Map<String, dynamic> json) =>
    _TournamentBracket(
      id: json['id'] as String,
      round: (json['round'] as num).toInt(),
      matchNumber: (json['matchNumber'] as num).toInt(),
      player1Id: json['player1Id'] as String,
      player1Name: json['player1Name'] as String,
      player2Id: json['player2Id'] as String?,
      player2Name: json['player2Name'] as String?,
      player1Score: (json['player1Score'] as num?)?.toInt(),
      player2Score: (json['player2Score'] as num?)?.toInt(),
      winnerId: json['winnerId'] as String?,
      gameRoomId: json['gameRoomId'] as String?,
      status:
          $enumDecodeNullable(_$BracketStatusEnumMap, json['status']) ??
          BracketStatus.pending,
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
      completedTime: json['completedTime'] == null
          ? null
          : DateTime.parse(json['completedTime'] as String),
    );

Map<String, dynamic> _$TournamentBracketToJson(_TournamentBracket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'round': instance.round,
      'matchNumber': instance.matchNumber,
      'player1Id': instance.player1Id,
      'player1Name': instance.player1Name,
      'player2Id': instance.player2Id,
      'player2Name': instance.player2Name,
      'player1Score': instance.player1Score,
      'player2Score': instance.player2Score,
      'winnerId': instance.winnerId,
      'gameRoomId': instance.gameRoomId,
      'status': _$BracketStatusEnumMap[instance.status]!,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'completedTime': instance.completedTime?.toIso8601String(),
    };

const _$BracketStatusEnumMap = {
  BracketStatus.pending: 'pending',
  BracketStatus.inProgress: 'inProgress',
  BracketStatus.completed: 'completed',
  BracketStatus.cancelled: 'cancelled',
};

_TournamentParticipant _$TournamentParticipantFromJson(
  Map<String, dynamic> json,
) => _TournamentParticipant(
  oderId: json['oderId'] as String,
  userName: json['userName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  wins: (json['wins'] as num?)?.toInt() ?? 0,
  losses: (json['losses'] as num?)?.toInt() ?? 0,
  pointsScored: (json['pointsScored'] as num?)?.toInt() ?? 0,
  isEliminated: json['isEliminated'] as bool?,
  finalPlacement: (json['finalPlacement'] as num?)?.toInt(),
);

Map<String, dynamic> _$TournamentParticipantToJson(
  _TournamentParticipant instance,
) => <String, dynamic>{
  'oderId': instance.oderId,
  'userName': instance.userName,
  'avatarUrl': instance.avatarUrl,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'wins': instance.wins,
  'losses': instance.losses,
  'pointsScored': instance.pointsScored,
  'isEliminated': instance.isEliminated,
  'finalPlacement': instance.finalPlacement,
};

_TournamentStanding _$TournamentStandingFromJson(Map<String, dynamic> json) =>
    _TournamentStanding(
      rank: (json['rank'] as num).toInt(),
      oderId: json['oderId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      wins: (json['wins'] as num).toInt(),
      losses: (json['losses'] as num).toInt(),
      totalPoints: (json['totalPoints'] as num).toInt(),
      prizeDiamonds: (json['prizeDiamonds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TournamentStandingToJson(_TournamentStanding instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'oderId': instance.oderId,
      'userName': instance.userName,
      'avatarUrl': instance.avatarUrl,
      'wins': instance.wins,
      'losses': instance.losses,
      'totalPoints': instance.totalPoints,
      'prizeDiamonds': instance.prizeDiamonds,
    };

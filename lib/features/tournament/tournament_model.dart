/// Tournament Models
/// 
/// Models for tournament bracket system

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tournament_model.freezed.dart';
part 'tournament_model.g.dart';

/// Tournament status
enum TournamentStatus {
  draft,       // Being created
  registration, // Open for sign-ups
  inProgress,  // Matches being played
  completed,   // All matches finished
  cancelled,   // Cancelled
}

/// Tournament format
enum TournamentFormat {
  singleElimination,  // Lose once, you're out
  doubleElimination,  // Lose twice to be eliminated
  roundRobin,         // Everyone plays everyone
}

/// Main tournament model
@freezed
abstract class Tournament with _$Tournament {
  const Tournament._();

  const factory Tournament({
    required String id,
    required String name,
    required String description,
    required String hostId,
    required String hostName,
    required String gameType,
    required TournamentFormat format,
    @Default(TournamentStatus.draft) TournamentStatus status,
    @Default(8) int maxParticipants,
    @Default(2) int minParticipants,
    int? prizePool,
    int? entryFee,
    DateTime? registrationDeadline,
    DateTime? startTime,
    DateTime? endTime,
    @Default([]) List<String> participantIds,
    @Default([]) List<TournamentBracket> brackets,
    String? winnerId,
    String? winnerName,
    DateTime? createdAt,
  }) = _Tournament;

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);

  /// Check if registration is open
  bool get isRegistrationOpen => 
      status == TournamentStatus.registration &&
      participantIds.length < maxParticipants;

  /// Check if tournament is full
  bool get isFull => participantIds.length >= maxParticipants;

  /// Current round number
  int get currentRound {
    if (brackets.isEmpty) return 0;
    final activeBrackets = brackets.where((b) => b.winnerId == null);
    if (activeBrackets.isEmpty) return brackets.last.round;
    return activeBrackets.first.round;
  }
}

/// Tournament bracket (single match)
@freezed
abstract class TournamentBracket with _$TournamentBracket {
  const TournamentBracket._();

  const factory TournamentBracket({
    required String id,
    required int round,
    required int matchNumber,
    required String player1Id,
    required String player1Name,
    String? player2Id,
    String? player2Name,
    int? player1Score,
    int? player2Score,
    String? winnerId,
    String? gameRoomId,
    @Default(BracketStatus.pending) BracketStatus status,
    DateTime? scheduledTime,
    DateTime? completedTime,
  }) = _TournamentBracket;

  factory TournamentBracket.fromJson(Map<String, dynamic> json) =>
      _$TournamentBracketFromJson(json);

  /// Check if this match is a bye (one player advances automatically)
  bool get isBye => player2Id == null;

  /// Get match display name
  String get displayName => 'Round $round - Match $matchNumber';
}

/// Bracket status
enum BracketStatus {
  pending,     // Waiting to start
  inProgress,  // Currently playing
  completed,   // Match finished
  cancelled,   // Match cancelled
}

/// Tournament participant
@freezed
abstract class TournamentParticipant with _$TournamentParticipant {
  const TournamentParticipant._();

  const factory TournamentParticipant({
    required String oderId,
    required String userName,
    String? avatarUrl,
    required DateTime joinedAt,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int pointsScored,
    bool? isEliminated,
    int? finalPlacement,
  }) = _TournamentParticipant;

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) =>
      _$TournamentParticipantFromJson(json);
}

/// Tournament leaderboard entry
@freezed
abstract class TournamentStanding with _$TournamentStanding {
  const TournamentStanding._();

  const factory TournamentStanding({
    required int rank,
    required String oderId,
    required String userName,
    String? avatarUrl,
    required int wins,
    required int losses,
    required int totalPoints,
    int? prizeDiamonds,
  }) = _TournamentStanding;

  factory TournamentStanding.fromJson(Map<String, dynamic> json) =>
      _$TournamentStandingFromJson(json);
}

/// Replay Models
/// 
/// Models for game replay/playback system
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_model.freezed.dart';
part 'replay_model.g.dart';

/// Replay event type
enum ReplayEventType {
  gameStart,
  cardDrawn,
  cardPlayed,
  meldDeclared,
  turnChange,
  scoreUpdate,
  roundEnd,
  gameEnd,
  chat,
}

/// Single event in a replay
@freezed
abstract class ReplayEvent with _$ReplayEvent {
  const ReplayEvent._();

  const factory ReplayEvent({
    required int sequenceNumber,
    required ReplayEventType type,
    required int timestamp, // Milliseconds from game start
    String? playerId,
    String? playerName,
    Map<String, dynamic>? data,
    String? description,
  }) = _ReplayEvent;

  factory ReplayEvent.fromJson(Map<String, dynamic> json) =>
      _$ReplayEventFromJson(json);
}

/// Complete game replay
@freezed
abstract class GameReplay with _$GameReplay {
  const GameReplay._();

  const factory GameReplay({
    required String id,
    required String gameType,
    required String roomId,
    required List<String> playerIds,
    required List<String> playerNames,
    required DateTime gameDate,
    required int durationMs,
    String? winnerId,
    String? winnerName,
    Map<String, int>? finalScores,
    @Default([]) List<ReplayEvent> events,
    String? savedBy, // User who saved this replay
    String? title,
    @Default(false) bool isPublic,
    @Default(0) int views,
    @Default([]) List<String> likedBy,
  }) = _GameReplay;

  factory GameReplay.fromJson(Map<String, dynamic> json) =>
      _$GameReplayFromJson(json);

  /// Get formatted duration
  String get formattedDuration {
    final seconds = (durationMs / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  /// Get event at specific time
  List<ReplayEvent> getEventsAt(int timestamp) {
    return events.where((e) => e.timestamp <= timestamp).toList();
  }
}

/// Replay bookmark/highlight
@freezed
abstract class ReplayBookmark with _$ReplayBookmark {
  const ReplayBookmark._();

  const factory ReplayBookmark({
    required String id,
    required String replayId,
    required int timestamp,
    required String title,
    String? description,
    String? createdBy,
  }) = _ReplayBookmark;

  factory ReplayBookmark.fromJson(Map<String, dynamic> json) =>
      _$ReplayBookmarkFromJson(json);
}

/// Replay playback state
class ReplayPlaybackState {
  final bool isPlaying;
  final int currentTime; // Milliseconds
  final double playbackSpeed;
  final int totalDuration;
  final int currentEventIndex;

  const ReplayPlaybackState({
    this.isPlaying = false,
    this.currentTime = 0,
    this.playbackSpeed = 1.0,
    this.totalDuration = 0,
    this.currentEventIndex = 0,
  });

  ReplayPlaybackState copyWith({
    bool? isPlaying,
    int? currentTime,
    double? playbackSpeed,
    int? totalDuration,
    int? currentEventIndex,
  }) {
    return ReplayPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTime: currentTime ?? this.currentTime,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      totalDuration: totalDuration ?? this.totalDuration,
      currentEventIndex: currentEventIndex ?? this.currentEventIndex,
    );
  }

  double get progress => totalDuration > 0 ? currentTime / totalDuration : 0;
}

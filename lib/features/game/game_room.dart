import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clubroyale/features/profile/user_profile.dart';
import 'package:clubroyale/features/game/engine/models/card.dart';
import 'package:clubroyale/features/game/engine/models/deck.dart';
import 'game_config.dart';
import 'models/game_state.dart';

part 'game_room.freezed.dart';
part 'game_room.g.dart';

/// Converts GameStatus enum to/from Firestore string
class GameStatusConverter implements JsonConverter<GameStatus, String> {
  const GameStatusConverter();

  @override
  GameStatus fromJson(String json) {
    return GameStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => GameStatus.waiting,
    );
  }

  @override
  String toJson(GameStatus object) => object.name;
}

@freezed
abstract class GameRoom with _$GameRoom {
  const GameRoom._();
  
  const factory GameRoom({
    /// Firestore document ID
    String? id,
    
    /// Room name/title
    @Default('Game Room') String name,
    
    /// Host user ID (creator of the room)
    @Default('') String hostId,
    
    /// 6-digit room code for joining
    String? roomCode,
    
    /// Current game status
    @GameStatusConverter() @Default(GameStatus.waiting) GameStatus status,
    
    /// Type of game (call_break, marriage, teen_patti, etc.)
    @Default('call_break') String gameType,
    
    /// Game configuration (point value, rounds, etc.)
    @Default(GameConfig()) GameConfig config,
    
    /// List of players in the room
    required List<Player> players,
    
    /// Player scores map (playerId -> score)
    required Map<String, int> scores,
    
    /// Whether game is finished (legacy, use status instead)
    @Default(false) bool isFinished,
    
    /// Whether room is public (visible in lobby) or private (code-only)
    @Default(false) bool isPublic,
    
    /// When the room was created
    @JsonKey(
      fromJson: _dateTimeFromJson,
      toJson: _dateTimeToJson,
    )
    DateTime? createdAt,
    
    /// When the game finished
    @JsonKey(
      fromJson: _dateTimeFromJson,
      toJson: _dateTimeToJson,
    )
    DateTime? finishedAt,
    
    // ===== Call Break Game Fields =====
    
    /// Current round number (1-indexed)
    @Default(1) int currentRound,
    
    /// Current phase of the game
    @JsonKey(
      fromJson: _gamePhaseFromJson,
      toJson: _gamePhaseToJson,
    )
    GamePhase? gamePhase,
    
    /// Player hands (playerId -> cards)
    @JsonKey(
      fromJson: _playerHandsFromJson,
      toJson: _playerHandsToJson,
    )
    @Default({}) Map<String, List<PlayingCard>> playerHands,
    
    /// Player bids for current round
    @Default({}) Map<String, Bid> bids,
    
    /// Current trick in progress
    Trick? currentTrick,
    
    /// History of completed tricks in current round
    @Default([]) List<Trick> trickHistory,
    
    /// Tricks won by each player in current round
    @Default({}) Map<String, int> tricksWon,
    
    /// Round scores (playerId -> list of scores per round)
    @JsonKey(
      fromJson: _roundScoresFromJson,
      toJson: _roundScoresToJson,
    )
    @Default({}) Map<String, List<double>> roundScores,
    
    /// Current turn (player ID whose turn it is)
    String? currentTurn,
  }) = _GameRoom;

  factory GameRoom.fromJson(Map<String, dynamic> json) => _$GameRoomFromJson(json);
  
  /// Check if all players in the room are ready
  bool get allPlayersReady => players.isNotEmpty && players.every((p) => p.isReady);
  
  /// Check if game can start (minimum players and all ready)
  bool get canStart => players.length >= 2 && allPlayersReady;
}

@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    @Default('Player') String name, // Default to 'Player' if null from Firestore
    UserProfile? profile,
    @Default(false) bool isReady,
    @Default(false) bool isBot,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

// ===== JSON Converter Helpers =====

/// Convert GamePhase enum from JSON
GamePhase? _gamePhaseFromJson(String? json) {
  if (json == null) return null;
  return GamePhase.values.firstWhere(
    (e) => e.name == json,
    orElse: () => GamePhase.bidding,
  );
}

/// Convert GamePhase enum to JSON
String? _gamePhaseToJson(GamePhase? phase) => phase?.name;

/// Convert player hands from JSON
Map<String, List<PlayingCard>> _playerHandsFromJson(Map<String, dynamic>? json) {
  if (json == null) return {};
  
  final hands = <String, List<PlayingCard>>{};
  json.forEach((playerId, cardsJson) {
    if (cardsJson is List) {
      hands[playerId] = Deck.deserializeHand(cardsJson);
    }
  });
  return hands;
}

/// Convert player hands to JSON
Map<String, dynamic> _playerHandsToJson(Map<String, List<PlayingCard>> hands) {
  final json = <String, dynamic>{};
  hands.forEach((playerId, cards) {
    json[playerId] = Deck.serializeHand(cards);
  });
  return json;
}

/// Convert round scores from JSON
Map<String, List<double>> _roundScoresFromJson(Map<String, dynamic>? json) {
  if (json == null) return {};
  
  final scores = <String, List<double>>{};
  json.forEach((playerId, scoresJson) {
    if (scoresJson is List) {
      scores[playerId] = scoresJson.cast<double>();
    }
  });
  return scores;
}

/// Convert round scores to JSON
Map<String, dynamic> _roundScoresToJson(Map<String, List<double>> scores) {
  final json = <String, dynamic>{};
  scores.forEach((playerId, scoreList) {
    json[playerId] = scoreList;
  });
  return json;
}

/// Convert DateTime from JSON (handles Firestore Timestamp and String)
DateTime? _dateTimeFromJson(dynamic json) {
  if (json == null) return null;
  if (json is Timestamp) return json.toDate();
  if (json is String) return DateTime.tryParse(json);
  return null;
}

/// Convert DateTime to JSON
String? _dateTimeToJson(DateTime? dateTime) => dateTime?.toIso8601String();

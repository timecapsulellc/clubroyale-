import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_config.freezed.dart';
part 'game_config.g.dart';

/// Game configuration set by the host when creating a room
@freezed
abstract class GameConfig with _$GameConfig {
  const factory GameConfig({
    /// Point value in units (user mentally maps to currency)
    /// e.g., 1 point = 10 units
    @Default(10) double pointValue,

    /// Maximum players allowed in the room
    @Default(8) int maxPlayers,

    /// Whether guests see ads (host can pay to disable)
    @Default(true) bool allowAds,

    /// Total rounds in the game
    @Default(5) int totalRounds,

    /// Entry fee in chips/units (optional boot amount)
    @Default(0) int bootAmount,

    /// Game-specific rule variants (e.g. Marriage rules: tunnelPachaunu, kidnap)
    @Default({}) Map<String, dynamic> variants,
  }) = _GameConfig;

  factory GameConfig.fromJson(Map<String, dynamic> json) =>
      _$GameConfigFromJson(json);
}

/// Game status enum for room lifecycle
enum GameStatus {
  waiting, // Waiting for players to join
  playing, // Game in progress
  settled, // Game finished and settlement shown
}

/// Adaptive Difficulty System
///
/// Dynamically adjusts bot difficulty based on player performance.
/// Uses sliding window analysis to detect player skill level.
library;

import 'dart:math';

/// Player skill metrics
class PlayerSkillMetrics {
  final String playerId;
  final List<double> recentWinRates;
  final List<double> recentScores;
  final int gamesPlayed;
  final int wins;
  final DateTime lastUpdated;

  PlayerSkillMetrics({
    required this.playerId,
    this.recentWinRates = const [],
    this.recentScores = const [],
    this.gamesPlayed = 0,
    this.wins = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Calculate skill rating (0.0 - 1.0)
  double get skillRating {
    if (gamesPlayed < 3) return 0.5; // Not enough data

    final winRate = wins / gamesPlayed;
    final recentPerformance = recentWinRates.isNotEmpty
        ? recentWinRates.reduce((a, b) => a + b) / recentWinRates.length
        : 0.5;

    // Weight recent performance more heavily
    return (winRate * 0.4) + (recentPerformance * 0.6);
  }

  /// Get recommended bot difficulty based on skill
  BotDifficultyLevel get recommendedDifficulty {
    if (skillRating < 0.3) return BotDifficultyLevel.easy;
    if (skillRating < 0.5) return BotDifficultyLevel.medium;
    if (skillRating < 0.7) return BotDifficultyLevel.hard;
    return BotDifficultyLevel.expert;
  }

  /// Create updated metrics after a game
  PlayerSkillMetrics recordGame({
    required bool won,
    required double score,
    int windowSize = 10,
  }) {
    final newWinRates = [...recentWinRates, won ? 1.0 : 0.0];
    final newScores = [...recentScores, score];

    // Keep only last N games in window
    if (newWinRates.length > windowSize) {
      newWinRates.removeAt(0);
    }
    if (newScores.length > windowSize) {
      newScores.removeAt(0);
    }

    return PlayerSkillMetrics(
      playerId: playerId,
      recentWinRates: newWinRates,
      recentScores: newScores,
      gamesPlayed: gamesPlayed + 1,
      wins: won ? wins + 1 : wins,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'recentWinRates': recentWinRates,
    'recentScores': recentScores,
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory PlayerSkillMetrics.fromJson(Map<String, dynamic> json) {
    return PlayerSkillMetrics(
      playerId: json['playerId'] as String,
      recentWinRates: (json['recentWinRates'] as List?)?.cast<double>() ?? [],
      recentScores: (json['recentScores'] as List?)?.cast<double>() ?? [],
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}

/// Bot difficulty levels
enum BotDifficultyLevel { easy, medium, hard, expert }

/// Adaptive difficulty configuration per game type
class AdaptiveDifficultyConfig {
  /// How sensitive to difficulty changes (0.0 = stable, 1.0 = very responsive)
  final double sensitivity;

  /// Minimum games before adapting
  final int minGamesForAdaptation;

  /// Allow difficulty to decrease if player is struggling
  final bool allowDecrease;

  /// Maximum difficulty change per session
  final int maxStepsPerSession;

  const AdaptiveDifficultyConfig({
    this.sensitivity = 0.5,
    this.minGamesForAdaptation = 3,
    this.allowDecrease = true,
    this.maxStepsPerSession = 1,
  });

  static const callBreak = AdaptiveDifficultyConfig(
    sensitivity: 0.4,
    minGamesForAdaptation: 2,
  );

  static const marriage = AdaptiveDifficultyConfig(
    sensitivity: 0.3, // More stable for complex game
    minGamesForAdaptation: 3,
  );

  static const teenPatti = AdaptiveDifficultyConfig(
    sensitivity: 0.5, // More variance in luck-based game
    minGamesForAdaptation: 5,
  );

  static const inBetween = AdaptiveDifficultyConfig(
    sensitivity: 0.6, // Quick adaptation for simple game
    minGamesForAdaptation: 3,
  );
}

/// Adaptive Difficulty Manager
class AdaptiveDifficultyManager {
  final Map<String, PlayerSkillMetrics> _playerMetrics = {};
  final Random _random = Random();

  /// Get current difficulty for a player
  BotDifficultyLevel getDifficulty(String playerId, {String? gameType}) {
    final metrics = _playerMetrics[playerId];
    if (metrics == null) return BotDifficultyLevel.medium;

    return metrics.recommendedDifficulty;
  }

  /// Record game result and update difficulty
  void recordGameResult({
    required String playerId,
    required bool playerWon,
    required double playerScore,
    required String gameType,
  }) {
    final existing =
        _playerMetrics[playerId] ?? PlayerSkillMetrics(playerId: playerId);
    _playerMetrics[playerId] = existing.recordGame(
      won: playerWon,
      score: playerScore,
    );
  }

  /// Get bot error rate based on difficulty
  double getBotErrorRate(BotDifficultyLevel difficulty) {
    switch (difficulty) {
      case BotDifficultyLevel.easy:
        return 0.20; // 20% chance of suboptimal play
      case BotDifficultyLevel.medium:
        return 0.10; // 10% chance
      case BotDifficultyLevel.hard:
        return 0.03; // 3% chance
      case BotDifficultyLevel.expert:
        return 0.01; // 1% chance (near-perfect)
    }
  }

  /// Should bot make a mistake at this difficulty?
  bool shouldBotMakeMistake(BotDifficultyLevel difficulty) {
    return _random.nextDouble() < getBotErrorRate(difficulty);
  }

  /// Get thinking delay range (ms) based on difficulty
  ({int min, int max}) getThinkingDelay(BotDifficultyLevel difficulty) {
    switch (difficulty) {
      case BotDifficultyLevel.easy:
        return (min: 2000, max: 4000); // Slower, more human-like
      case BotDifficultyLevel.medium:
        return (min: 1500, max: 3000);
      case BotDifficultyLevel.hard:
        return (min: 1000, max: 2000);
      case BotDifficultyLevel.expert:
        return (min: 500, max: 1500); // Quick decisions
    }
  }

  /// Get metrics for a player
  PlayerSkillMetrics? getPlayerMetrics(String playerId) =>
      _playerMetrics[playerId];

  /// Clear metrics for testing
  void clearMetrics() => _playerMetrics.clear();
}

/// Singleton instance
final adaptiveDifficultyManager = AdaptiveDifficultyManager();

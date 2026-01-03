/// AI Difficulty Service
///
/// Manages AI opponent difficulty levels for all games
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI difficulty levels
enum AIDifficulty {
  easy(
    name: 'Easy',
    description: 'Perfect for learning. AI makes occasional mistakes.',
    thinkDelay: Duration(milliseconds: 1500),
    mistakeRate: 0.3,
  ),
  medium(
    name: 'Medium',
    description: 'Balanced challenge. AI plays smart but fair.',
    thinkDelay: Duration(milliseconds: 1000),
    mistakeRate: 0.15,
  ),
  hard(
    name: 'Hard',
    description: 'Serious challenge. AI plays near-optimally.',
    thinkDelay: Duration(milliseconds: 500),
    mistakeRate: 0.05,
  ),
  expert(
    name: 'Expert',
    description: 'Maximum challenge. AI plays perfectly.',
    thinkDelay: Duration(milliseconds: 300),
    mistakeRate: 0.0,
  );

  final String name;
  final String description;
  final Duration thinkDelay;
  final double mistakeRate;

  const AIDifficulty({
    required this.name,
    required this.description,
    required this.thinkDelay,
    required this.mistakeRate,
  });
}

/// AI behavior configuration for specific games
class AIBehavior {
  final AIDifficulty difficulty;
  final bool bluffEnabled;
  final bool countCards;
  final bool predictOpponents;

  const AIBehavior({
    this.difficulty = AIDifficulty.medium,
    this.bluffEnabled = true,
    this.countCards = false,
    this.predictOpponents = false,
  });

  AIBehavior copyWith({
    AIDifficulty? difficulty,
    bool? bluffEnabled,
    bool? countCards,
    bool? predictOpponents,
  }) {
    return AIBehavior(
      difficulty: difficulty ?? this.difficulty,
      bluffEnabled: bluffEnabled ?? this.bluffEnabled,
      countCards: countCards ?? this.countCards,
      predictOpponents: predictOpponents ?? this.predictOpponents,
    );
  }

  factory AIBehavior.forDifficulty(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return const AIBehavior(
          difficulty: AIDifficulty.easy,
          bluffEnabled: false,
          countCards: false,
          predictOpponents: false,
        );
      case AIDifficulty.medium:
        return const AIBehavior(
          difficulty: AIDifficulty.medium,
          bluffEnabled: true,
          countCards: false,
          predictOpponents: false,
        );
      case AIDifficulty.hard:
        return const AIBehavior(
          difficulty: AIDifficulty.hard,
          bluffEnabled: true,
          countCards: true,
          predictOpponents: false,
        );
      case AIDifficulty.expert:
        return const AIBehavior(
          difficulty: AIDifficulty.expert,
          bluffEnabled: true,
          countCards: true,
          predictOpponents: true,
        );
    }
  }
}

/// Service for managing AI settings
class AIDifficultyService {
  AIBehavior _behavior = const AIBehavior();

  AIBehavior get behavior => _behavior;
  AIDifficulty get difficulty => _behavior.difficulty;

  void setDifficulty(AIDifficulty difficulty) {
    _behavior = AIBehavior.forDifficulty(difficulty);
  }

  void setBehavior(AIBehavior behavior) {
    _behavior = behavior;
  }

  bool shouldMakeMistake() {
    if (_behavior.difficulty.mistakeRate == 0) return false;
    return (DateTime.now().millisecondsSinceEpoch % 100) / 100 <
        _behavior.difficulty.mistakeRate;
  }

  Duration get thinkDelay => _behavior.difficulty.thinkDelay;
}

/// Provider for AI difficulty service
final aiDifficultyServiceProvider = Provider((ref) => AIDifficultyService());

/// Simple provider for AI behavior (using ChangeNotifier instead of StateNotifier)
final aiDifficultyProvider = Provider<AIBehavior>((ref) {
  final service = ref.watch(aiDifficultyServiceProvider);
  return service.behavior;
});

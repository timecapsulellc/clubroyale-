import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PhD Audit Finding #20: Player Progression System
/// Levels, XP, unlocks for long-term retention

/// Player level and XP state
class PlayerProgression {
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final List<String> unlockedThemes;
  final List<String> unlockedBots;
  final ProfileBorder border;
  final int totalGamesPlayed;
  final int totalWins;
  
  const PlayerProgression({
    this.level = 1,
    this.currentXP = 0,
    this.xpForNextLevel = 100,
    this.unlockedThemes = const ['default'],
    this.unlockedBots = const ['random', 'conservative'],
    this.border = ProfileBorder.none,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
  });
  
  PlayerProgression copyWith({
    int? level,
    int? currentXP,
    int? xpForNextLevel,
    List<String>? unlockedThemes,
    List<String>? unlockedBots,
    ProfileBorder? border,
    int? totalGamesPlayed,
    int? totalWins,
  }) {
    return PlayerProgression(
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      unlockedBots: unlockedBots ?? this.unlockedBots,
      border: border ?? this.border,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
    );
  }
  
  double get progressToNextLevel => currentXP / xpForNextLevel;
}

enum ProfileBorder {
  none,
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

/// XP rewards for different actions
class XPRewards {
  static const int gameComplete = 10;
  static const int gameWin = 25;
  static const int maalCollected = 5;
  static const int marriageFormed = 15;
  static const int tunnellaFormed = 10;
  static const int firstBlood = 20; // First win of day
  static const int weeklyChallenge = 50;
}

/// Level unlocks configuration
class LevelUnlocks {
  static const Map<int, List<String>> themeUnlocks = {
    10: ['midnight'],
    25: ['crimson'],
    50: ['emerald'],
    75: ['royal_gold'],
  };
  
  static const Map<int, List<String>> botUnlocks = {
    15: ['aggressive'],
    30: ['expert'],
    50: ['champion'],
  };
  
  static const Map<int, ProfileBorder> borderUnlocks = {
    10: ProfileBorder.bronze,
    25: ProfileBorder.silver,
    50: ProfileBorder.gold,
    75: ProfileBorder.platinum,
    100: ProfileBorder.diamond,
  };
}

/// Progression state manager
class ProgressionNotifier extends StateNotifier<PlayerProgression> {
  ProgressionNotifier() : super(const PlayerProgression()) {
    _loadFromPrefs();
  }
  
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = PlayerProgression(
      level: prefs.getInt('player_level') ?? 1,
      currentXP: prefs.getInt('player_xp') ?? 0,
      xpForNextLevel: _calculateXPForLevel(prefs.getInt('player_level') ?? 1),
      totalGamesPlayed: prefs.getInt('total_games') ?? 0,
      totalWins: prefs.getInt('total_wins') ?? 0,
    );
  }
  
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_level', state.level);
    await prefs.setInt('player_xp', state.currentXP);
    await prefs.setInt('total_games', state.totalGamesPlayed);
    await prefs.setInt('total_wins', state.totalWins);
  }
  
  int _calculateXPForLevel(int level) {
    // Exponential curve: 100 * 1.2^level
    return (100 * (1.0 + (level * 0.2))).round();
  }
  
  /// Add XP and handle level up
  Future<LevelUpResult?> addXP(int amount) async {
    int newXP = state.currentXP + amount;
    int newLevel = state.level;
    int xpNeeded = state.xpForNextLevel;
    List<String> newUnlocks = [];
    
    // Check for level up
    while (newXP >= xpNeeded) {
      newXP -= xpNeeded;
      newLevel++;
      xpNeeded = _calculateXPForLevel(newLevel);
      
      // Check for unlocks
      if (LevelUnlocks.themeUnlocks.containsKey(newLevel)) {
        newUnlocks.addAll(LevelUnlocks.themeUnlocks[newLevel]!);
      }
      if (LevelUnlocks.botUnlocks.containsKey(newLevel)) {
        newUnlocks.addAll(LevelUnlocks.botUnlocks[newLevel]!);
      }
    }
    
    // Get new border if unlocked
    ProfileBorder? newBorder;
    for (final entry in LevelUnlocks.borderUnlocks.entries) {
      if (newLevel >= entry.key && state.level < entry.key) {
        newBorder = entry.value;
      }
    }
    
    state = state.copyWith(
      level: newLevel,
      currentXP: newXP,
      xpForNextLevel: xpNeeded,
      border: newBorder ?? state.border,
    );
    
    await _saveToPrefs();
    
    if (newLevel > state.level || newUnlocks.isNotEmpty) {
      return LevelUpResult(
        oldLevel: state.level,
        newLevel: newLevel,
        unlocks: newUnlocks,
        newBorder: newBorder,
      );
    }
    return null;
  }
  
  /// Record game completion
  Future<LevelUpResult?> recordGameComplete({required bool won}) async {
    state = state.copyWith(
      totalGamesPlayed: state.totalGamesPlayed + 1,
      totalWins: won ? state.totalWins + 1 : state.totalWins,
    );
    
    int xp = XPRewards.gameComplete;
    if (won) xp += XPRewards.gameWin;
    
    return addXP(xp);
  }
}

class LevelUpResult {
  final int oldLevel;
  final int newLevel;
  final List<String> unlocks;
  final ProfileBorder? newBorder;
  
  LevelUpResult({
    required this.oldLevel,
    required this.newLevel,
    required this.unlocks,
    this.newBorder,
  });
  
  bool get didLevelUp => newLevel > oldLevel;
}

/// Provider for progression state
final progressionProvider =
    StateNotifierProvider<ProgressionNotifier, PlayerProgression>(
  (ref) => ProgressionNotifier(),
);

/// Level badge widget
class LevelBadge extends StatelessWidget {
  final int level;
  final double size;
  
  const LevelBadge({super.key, required this.level, this.size = 40});
  
  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor(level);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Color _getLevelColor(int level) {
    if (level >= 100) return Colors.cyan;      // Diamond
    if (level >= 75) return Colors.purple;     // Platinum
    if (level >= 50) return Colors.amber;      // Gold
    if (level >= 25) return Colors.grey;       // Silver
    if (level >= 10) return Colors.brown;      // Bronze
    return Colors.blueGrey;                    // None
  }
}

/// XP progress bar widget
class XPProgressBar extends StatelessWidget {
  final PlayerProgression progression;
  
  const XPProgressBar({super.key, required this.progression});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${progression.level}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${progression.currentXP}/${progression.xpForNextLevel} XP',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progression.progressToNextLevel,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.amber),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

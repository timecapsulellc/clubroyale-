/// Game Score Persistence Service
/// 
/// Saves and loads game scores using SharedPreferences
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting game scores across sessions
class GameScorePersistence {
  static const String _callBreakKey = 'call_break_scores';
  static const String _teenPattiKey = 'teen_patti_stats';
  static const String _inBetweenKey = 'in_between_stats';
  
  static SharedPreferences? _prefs;
  
  /// Initialize the persistence service
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // === Call Break Score Persistence ===
  
  /// Save Call Break scores
  static Future<void> saveCallBreakScores(Map<String, int> scores) async {
    await init();
    final jsonStr = jsonEncode(scores);
    await _prefs!.setString(_callBreakKey, jsonStr);
  }
  
  /// Load Call Break scores
  static Future<Map<String, int>> loadCallBreakScores() async {
    await init();
    final jsonStr = _prefs!.getString(_callBreakKey);
    if (jsonStr == null) return {};
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (e) {
      return {};
    }
  }
  
  /// Clear Call Break scores
  static Future<void> clearCallBreakScores() async {
    await init();
    await _prefs!.remove(_callBreakKey);
  }
  
  // === Teen Patti Stats ===
  
  /// Save Teen Patti stats (wins, losses, biggest pot)
  static Future<void> saveTeenPattiStats({
    required int gamesPlayed,
    required int gamesWon,
    required int biggestPot,
    required int totalWinnings,
  }) async {
    await init();
    final stats = {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'biggestPot': biggestPot,
      'totalWinnings': totalWinnings,
    };
    await _prefs!.setString(_teenPattiKey, jsonEncode(stats));
  }
  
  /// Load Teen Patti stats
  static Future<Map<String, int>> loadTeenPattiStats() async {
    await init();
    final jsonStr = _prefs!.getString(_teenPattiKey);
    if (jsonStr == null) {
      return {
        'gamesPlayed': 0,
        'gamesWon': 0,
        'biggestPot': 0,
        'totalWinnings': 0,
      };
    }
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (e) {
      return {
        'gamesPlayed': 0,
        'gamesWon': 0,
        'biggestPot': 0,
        'totalWinnings': 0,
      };
    }
  }
  
  // === In-Between Stats ===
  
  /// Save In-Between stats
  static Future<void> saveInBetweenStats({
    required int roundsPlayed,
    required int wins,
    required int losses,
    required int posts,
    required int highestChips,
  }) async {
    await init();
    final stats = {
      'roundsPlayed': roundsPlayed,
      'wins': wins,
      'losses': losses,
      'posts': posts,
      'highestChips': highestChips,
    };
    await _prefs!.setString(_inBetweenKey, jsonEncode(stats));
  }
  
  /// Load In-Between stats
  static Future<Map<String, int>> loadInBetweenStats() async {
    await init();
    final jsonStr = _prefs!.getString(_inBetweenKey);
    if (jsonStr == null) {
      return {
        'roundsPlayed': 0,
        'wins': 0,
        'losses': 0,
        'posts': 0,
        'highestChips': 100,
      };
    }
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, v as int));
    } catch (e) {
      return {
        'roundsPlayed': 0,
        'wins': 0,
        'losses': 0,
        'posts': 0,
        'highestChips': 100,
      };
    }
  }
  
  /// Clear all game stats
  static Future<void> clearAllStats() async {
    await init();
    await _prefs!.remove(_callBreakKey);
    await _prefs!.remove(_teenPattiKey);
    await _prefs!.remove(_inBetweenKey);
  }
}

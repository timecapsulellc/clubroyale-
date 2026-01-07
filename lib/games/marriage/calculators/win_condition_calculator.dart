import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Win Condition Calculator
/// Determines game winner based on Nepali Marriage rules
/// 
/// PhD Audit Finding #4: Win condition verification

class WinConditionCalculator {
  final Card? tiplu;
  final MarriageGameConfig config;
  
  WinConditionCalculator({
    this.tiplu,
    this.config = const MarriageGameConfig(),
  });
  
  /// Determine winner between all players
  /// CRITICAL: Highest Maal points wins, NOT first finisher
  WinResult determineWinner({
    required Map<String, PlayerState> players,
    required String? firstFinisherId,
  }) {
    if (players.isEmpty) {
      return WinResult(
        winnerId: null,
        reason: WinReason.noPlayers,
        maalPoints: {},
      );
    }
    
    // Calculate Maal points for all players
    final maalPoints = <String, int>{};
    MarriageMaalCalculator? calculator;
    
    if (tiplu != null) {
      calculator = MarriageMaalCalculator(tiplu: tiplu!, config: config);
    }
    
    for (final entry in players.entries) {
      final playerId = entry.key;
      final state = entry.value;
      
      if (calculator != null) {
        maalPoints[playerId] = calculator.calculateMaalPoints(state.hand);
      } else {
        maalPoints[playerId] = 0;
      }
    }
    
    // Check for 8-Dublee auto-win first
    for (final entry in players.entries) {
      if (calculator != null && calculator.canWinWith8Dublee(entry.value.hand)) {
        return WinResult(
          winnerId: entry.key,
          reason: WinReason.eightDublee,
          maalPoints: maalPoints,
        );
      }
    }
    
    // Find player with highest Maal points
    String? highestPlayer;
    int highestPoints = -1;
    
    for (final entry in maalPoints.entries) {
      if (entry.value > highestPoints) {
        highestPoints = entry.value;
        highestPlayer = entry.key;
      }
    }
    
    // Tie-breaker: If tied Maal points, first finisher wins
    final tiedPlayers = maalPoints.entries
        .where((e) => e.value == highestPoints)
        .map((e) => e.key)
        .toList();
    
    if (tiedPlayers.length > 1 && firstFinisherId != null) {
      if (tiedPlayers.contains(firstFinisherId)) {
        highestPlayer = firstFinisherId;
      }
    }
    
    return WinResult(
      winnerId: highestPlayer,
      reason: highestPoints > 0 ? WinReason.highestMaal : WinReason.firstFinish,
      maalPoints: maalPoints,
      firstFinisherId: firstFinisherId,
    );
  }
  
  /// Check if a player can declare (finish the game)
  bool canDeclare(List<Card> hand, List<dynamic> melds) {
    // Must have all cards in valid melds
    // Must have at least one pure sequence (no wildcards)
    
    // Simplified check: All cards must be melded
    if (hand.isNotEmpty) return false;
    
    // Must have at least one pure sequence
    // (This would be validated by meld validator)
    
    return true;
  }
}

/// Result of win condition calculation
class WinResult {
  final String? winnerId;
  final WinReason reason;
  final Map<String, int> maalPoints;
  final String? firstFinisherId;
  
  WinResult({
    required this.winnerId,
    required this.reason,
    required this.maalPoints,
    this.firstFinisherId,
  });
  
  bool get hasWinner => winnerId != null;
  
  @override
  String toString() {
    if (winnerId == null) return 'No winner yet';
    final points = maalPoints[winnerId] ?? 0;
    return 'Winner: $winnerId with $points Maal points (${reason.name})';
  }
}

/// Reason for winning
enum WinReason {
  highestMaal,    // Most Maal points
  eightDublee,    // 8 pairs auto-win
  firstFinish,    // Finished first (tie-breaker)
  noPlayers,      // No players in game
}

/// Player state for win calculation
class PlayerState {
  final List<Card> hand;
  final bool hasVisited;
  final bool hasFinished;
  
  PlayerState({
    required this.hand,
    this.hasVisited = false,
    this.hasFinished = false,
  });
}

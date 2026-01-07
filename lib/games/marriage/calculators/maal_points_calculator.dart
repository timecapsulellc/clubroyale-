import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';

/// Maal Points Calculator
/// Centralized point calculation for Marriage game
/// 
/// PhD Audit Finding #8: maal_points_calculator.dart

class MaalPointsCalculator {
  final Card tiplu;
  final MarriageGameConfig config;
  late final MarriageMaalCalculator _calculator;
  
  MaalPointsCalculator({
    required this.tiplu,
    this.config = const MarriageGameConfig(),
  }) {
    _calculator = MarriageMaalCalculator(tiplu: tiplu, config: config);
  }
  
  /// Calculate total Maal points in hand
  int calculateTotalMaal(List<Card> hand) {
    return _calculator.calculateMaalPoints(hand);
  }
  
  /// Get Marriage combo bonus (Jhiplu + Tiplu + Poplu)
  int getMarriageBonus(List<Card> hand, {bool isPlayed = false}) {
    return _calculator.getMarriageComboBonus(hand, isPlayed: isPlayed);
  }
  
  /// Get Tunnel display bonus
  int getTunnelBonus(List<Card> hand) {
    return _calculator.getTunnelDisplayBonus(hand);
  }
  
  /// Check 8-Dublee win condition
  bool can8DubleeWin(List<Card> hand) {
    return _calculator.canWinWith8Dublee(hand);
  }
  
  /// Get detailed breakdown of Maal cards
  List<MaalCardInfo> getMaalBreakdown(List<Card> hand) {
    return _calculator.getMaalBreakdown(hand);
  }
  
  /// Get Maal count by type
  Map<MaalType, int> getMaalCounts(List<Card> hand) {
    return _calculator.countMaalByType(hand);
  }
  
  /// Determine winner between players
  /// Returns player ID with highest points
  /// PhD Audit Finding #4: Highest points wins, NOT first finish
  static String determineWinner({
    required Map<String, int> playerMaalPoints,
    required String? firstFinisher,
  }) {
    // Winner is whoever has highest Maal points
    // Finishing first does NOT guarantee win
    
    String winner = playerMaalPoints.keys.first;
    int highestPoints = playerMaalPoints[winner] ?? 0;
    
    for (final entry in playerMaalPoints.entries) {
      if (entry.value > highestPoints) {
        highestPoints = entry.value;
        winner = entry.key;
      }
    }
    
    return winner;
  }
  
  /// Calculate final settlement for all players
  /// PhD Audit: Implements Nepali Marriage scoring rules
  static Map<String, int> calculateSettlement({
    required Map<String, int> playerMaalPoints,
    required String winnerId,
    required int kidneyValue,
    required int murderedPlayerPenalty,
    required Set<String> kidnappedPlayers,
    required Set<String> murderedPlayers,
  }) {
    final settlement = <String, int>{};
    final winnerPoints = playerMaalPoints[winnerId] ?? 0;
    
    for (final entry in playerMaalPoints.entries) {
      final playerId = entry.key;
      final points = entry.value;
      
      if (playerId == winnerId) {
        // Winner gets difference from all other players
        int winnings = 0;
        for (final other in playerMaalPoints.entries) {
          if (other.key != winnerId) {
            winnings += winnerPoints - other.value;
          }
        }
        settlement[playerId] = winnings;
      } else {
        // Losers pay difference to winner
        int loss = points - winnerPoints;
        
        // Apply kidnap penalty
        if (kidnappedPlayers.contains(playerId)) {
          loss -= kidneyValue;
        }
        
        // Apply murder penalty (lose all points)
        if (murderedPlayers.contains(playerId)) {
          loss = -murderedPlayerPenalty;
        }
        
        settlement[playerId] = loss;
      }
    }
    
    return settlement;
  }
}

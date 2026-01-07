import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PhD Audit Finding #3: Scoring Balance Monitoring
/// Track and analyze point distribution for game balance

class ScoringBalanceMonitor {
  static final ScoringBalanceMonitor _instance = ScoringBalanceMonitor._internal();
  factory ScoringBalanceMonitor() => _instance;
  ScoringBalanceMonitor._internal();
  
  // Accumulated statistics
  int _totalGames = 0;
  int _totalAlterPoints = 0;
  int _totalTunnellaPoints = 0;
  int _totalMarriagePoints = 0;
  int _totalMaalPoints = 0;
  int _gamesWithHighWildcards = 0; // 6+ wildcards
  
  /// Record game scoring breakdown
  void recordGameScoring({
    required int alterPoints,
    required int tunnellaPoints,
    required int marriagePoints,
    required int totalMaalPoints,
    required int wildcardCount,
  }) {
    _totalGames++;
    _totalAlterPoints += alterPoints;
    _totalTunnellaPoints += tunnellaPoints;
    _totalMarriagePoints += marriagePoints;
    _totalMaalPoints += totalMaalPoints;
    
    if (wildcardCount >= 6) {
      _gamesWithHighWildcards++;
    }
    
    // Save to prefs periodically
    if (_totalGames % 10 == 0) {
      _saveStats();
    }
  }
  
  /// Get current balance metrics
  ScoringBalanceMetrics getMetrics() {
    final alterPercentage = _totalMaalPoints > 0 
        ? (_totalAlterPoints / _totalMaalPoints * 100) 
        : 0.0;
    
    final tunnellaPercentage = _totalMaalPoints > 0 
        ? (_totalTunnellaPoints / _totalMaalPoints * 100) 
        : 0.0;
    
    final marriagePercentage = _totalMaalPoints > 0 
        ? (_totalMarriagePoints / _totalMaalPoints * 100) 
        : 0.0;
    
    final highWildcardRate = _totalGames > 0 
        ? (_gamesWithHighWildcards / _totalGames * 100) 
        : 0.0;
    
    return ScoringBalanceMetrics(
      totalGamesTracked: _totalGames,
      alterPointPercentage: alterPercentage,
      tunnellaPointPercentage: tunnellaPercentage,
      marriagePointPercentage: marriagePercentage,
      highWildcardGameRate: highWildcardRate,
      isAlterOverpowered: alterPercentage > 40, // Finding #3 threshold
      needsRebalancing: alterPercentage > 40 || highWildcardRate > 10,
    );
  }
  
  /// Check if rebalancing is needed
  BalanceRecommendation getRecommendation() {
    final metrics = getMetrics();
    
    if (metrics.needsRebalancing) {
      if (metrics.isAlterOverpowered) {
        return BalanceRecommendation(
          needed: true,
          type: RebalanceType.reduceAlterPoints,
          message: 'Alter cards account for ${metrics.alterPointPercentage.toStringAsFixed(1)}% '
              'of points. Consider reducing from 5 to 3 points.',
        );
      }
      
      if (metrics.highWildcardGameRate > 10) {
        return BalanceRecommendation(
          needed: true,
          type: RebalanceType.limitWildcards,
          message: '${metrics.highWildcardGameRate.toStringAsFixed(1)}% of games have '
              '6+ wildcards. Consider wildcard cap or re-deal rule.',
        );
      }
    }
    
    return BalanceRecommendation(
      needed: false,
      type: RebalanceType.none,
      message: 'Scoring balance is within acceptable range.',
    );
  }
  
  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('balance_total_games', _totalGames);
    await prefs.setInt('balance_alter_pts', _totalAlterPoints);
    await prefs.setInt('balance_tunnella_pts', _totalTunnellaPoints);
    await prefs.setInt('balance_marriage_pts', _totalMarriagePoints);
    await prefs.setInt('balance_high_wildcard', _gamesWithHighWildcards);
  }
  
  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _totalGames = prefs.getInt('balance_total_games') ?? 0;
    _totalAlterPoints = prefs.getInt('balance_alter_pts') ?? 0;
    _totalTunnellaPoints = prefs.getInt('balance_tunnella_pts') ?? 0;
    _totalMarriagePoints = prefs.getInt('balance_marriage_pts') ?? 0;
    _gamesWithHighWildcards = prefs.getInt('balance_high_wildcard') ?? 0;
  }
  
  void reset() {
    _totalGames = 0;
    _totalAlterPoints = 0;
    _totalTunnellaPoints = 0;
    _totalMarriagePoints = 0;
    _totalMaalPoints = 0;
    _gamesWithHighWildcards = 0;
  }
}

class ScoringBalanceMetrics {
  final int totalGamesTracked;
  final double alterPointPercentage;
  final double tunnellaPointPercentage;
  final double marriagePointPercentage;
  final double highWildcardGameRate;
  final bool isAlterOverpowered;
  final bool needsRebalancing;
  
  const ScoringBalanceMetrics({
    required this.totalGamesTracked,
    required this.alterPointPercentage,
    required this.tunnellaPointPercentage,
    required this.marriagePointPercentage,
    required this.highWildcardGameRate,
    required this.isAlterOverpowered,
    required this.needsRebalancing,
  });
}

class BalanceRecommendation {
  final bool needed;
  final RebalanceType type;
  final String message;
  
  const BalanceRecommendation({
    required this.needed,
    required this.type,
    required this.message,
  });
}

enum RebalanceType {
  none,
  reduceAlterPoints,
  increaseTunnellaPoints,
  limitWildcards,
  adjustMarriageBonus,
}

/// Provider for scoring balance
final scoringBalanceProvider = Provider<ScoringBalanceMonitor>((ref) {
  final monitor = ScoringBalanceMonitor();
  monitor.loadStats();
  return monitor;
});

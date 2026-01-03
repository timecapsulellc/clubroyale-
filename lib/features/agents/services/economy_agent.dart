import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Economy Agent provider
final economyAgentProvider = Provider<EconomyAgent>((ref) {
  return EconomyAgent();
});

/// Economy Agent - Handles fraud detection, rewards optimization, and economy balancing
class EconomyAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== FRAUD DETECTION ====================

  /// Check if a transaction is potentially fraudulent
  Future<FraudCheckResult> checkFraudRisk({
    required String userId,
    required String action,
    required int amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = _functions.httpsCallable('checkFraudRisk');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'action': action,
        'amount': amount,
        'metadata': metadata,
      });

      return FraudCheckResult(
        isRisky: result.data['isRisky'] as bool? ?? false,
        riskScore: result.data['riskScore'] as double? ?? 0.0,
        reasons: List<String>.from(result.data['reasons'] ?? []),
        action: result.data['action'] as String? ?? 'allow',
      );
    } catch (e) {
      // Local fraud check fallback
      return _localFraudCheck(userId, action, amount);
    }
  }

  /// Local fraud detection rules
  Future<FraudCheckResult> _localFraudCheck(
    String userId,
    String action,
    int amount,
  ) async {
    final reasons = <String>[];
    double riskScore = 0.0;

    // Rule 1: Large transaction
    if (amount > 10000) {
      riskScore += 0.3;
      reasons.add('Large transaction amount');
    }

    // Rule 2: Check recent transaction velocity
    final recentTransactions = await _getRecentTransactionCount(userId);
    if (recentTransactions > 20) {
      riskScore += 0.4;
      reasons.add('High transaction velocity');
    }

    // Rule 3: New account check
    final accountAge = await _getAccountAgeInDays(userId);
    if (accountAge < 1 && amount > 1000) {
      riskScore += 0.5;
      reasons.add('New account with large transaction');
    }

    return FraudCheckResult(
      isRisky: riskScore > 0.5,
      riskScore: riskScore.clamp(0.0, 1.0),
      reasons: reasons,
      action: riskScore > 0.7
          ? 'block'
          : (riskScore > 0.5 ? 'review' : 'allow'),
    );
  }

  Future<int> _getRecentTransactionCount(String userId) async {
    try {
      final hourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(hourAgo))
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getAccountAgeInDays(String userId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();
      if (!doc.exists) return 0;
      final createdAt = (doc.data()?['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null) return 365; // Assume old account
      return DateTime.now().difference(createdAt).inDays;
    } catch (e) {
      return 365;
    }
  }

  // ==================== REWARD OPTIMIZATION ====================

  /// Calculate optimized reward based on user engagement
  Future<OptimizedReward> optimizeReward({
    required String userId,
    required int baseReward,
    required String rewardType,
  }) async {
    try {
      final callable = _functions.httpsCallable('optimizeReward');
      final result = await callable.call<Map<String, dynamic>>({
        'userId': userId,
        'baseReward': baseReward,
        'rewardType': rewardType,
      });

      return OptimizedReward(
        amount: result.data['amount'] as int? ?? baseReward,
        multiplier: result.data['multiplier'] as double? ?? 1.0,
        bonusReasons: List<String>.from(result.data['bonusReasons'] ?? []),
      );
    } catch (e) {
      return _localRewardOptimization(userId, baseReward, rewardType);
    }
  }

  /// Local reward optimization
  Future<OptimizedReward> _localRewardOptimization(
    String userId,
    int baseReward,
    String rewardType,
  ) async {
    double multiplier = 1.0;
    final bonusReasons = <String>[];

    // Check streak bonus
    final streak = await _getUserStreak(userId);
    if (streak >= 7) {
      multiplier += 0.5;
      bonusReasons.add('7-day streak bonus (+50%)');
    } else if (streak >= 3) {
      multiplier += 0.2;
      bonusReasons.add('3-day streak bonus (+20%)');
    }

    // Check loyalty bonus
    final accountAge = await _getAccountAgeInDays(userId);
    if (accountAge >= 30) {
      multiplier += 0.1;
      bonusReasons.add('Loyalty bonus (+10%)');
    }

    // Weekend bonus
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      multiplier += 0.15;
      bonusReasons.add('Weekend bonus (+15%)');
    }

    return OptimizedReward(
      amount: (baseReward * multiplier).round(),
      multiplier: multiplier,
      bonusReasons: bonusReasons,
    );
  }

  Future<int> _getUserStreak(String userId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();
      return doc.data()?['currentStreak'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== ECONOMY BALANCING ====================

  /// Check if daily limits are reached
  Future<LimitCheckResult> checkDailyLimit({
    required String userId,
    required String limitType,
    required int requestedAmount,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final doc = await _firestore
          .collection('daily_usage')
          .doc('${userId}_$today')
          .get();

      final currentUsage = doc.data()?[limitType] as int? ?? 0;
      final limit = _getDailyLimit(limitType);

      return LimitCheckResult(
        allowed: currentUsage + requestedAmount <= limit,
        currentUsage: currentUsage,
        limit: limit,
        remaining: (limit - currentUsage).clamp(0, limit),
      );
    } catch (e) {
      return LimitCheckResult(
        allowed: true,
        currentUsage: 0,
        limit: _getDailyLimit(limitType),
        remaining: _getDailyLimit(limitType),
      );
    }
  }

  int _getDailyLimit(String limitType) {
    switch (limitType) {
      case 'gameEarnings':
        return 5000;
      case 'transfers':
        return 10000;
      case 'bonusClaims':
        return 500;
      default:
        return 1000;
    }
  }

  /// Record usage against daily limit
  Future<void> recordUsage({
    required String userId,
    required String limitType,
    required int amount,
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _firestore.collection('daily_usage').doc('${userId}_$today').set({
      limitType: FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

/// Result of fraud check
class FraudCheckResult {
  final bool isRisky;
  final double riskScore;
  final List<String> reasons;
  final String action; // allow, review, block

  FraudCheckResult({
    required this.isRisky,
    required this.riskScore,
    required this.reasons,
    required this.action,
  });

  bool get shouldBlock => action == 'block';
  bool get needsReview => action == 'review';
}

/// Optimized reward result
class OptimizedReward {
  final int amount;
  final double multiplier;
  final List<String> bonusReasons;

  OptimizedReward({
    required this.amount,
    required this.multiplier,
    required this.bonusReasons,
  });

  bool get hasBonus => multiplier > 1.0;
}

/// Daily limit check result
class LimitCheckResult {
  final bool allowed;
  final int currentUsage;
  final int limit;
  final int remaining;

  LimitCheckResult({
    required this.allowed,
    required this.currentUsage,
    required this.limit,
    required this.remaining,
  });

  double get usagePercentage => (currentUsage / limit * 100).clamp(0, 100);
}

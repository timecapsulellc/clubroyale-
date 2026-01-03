import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/config/diamond_config.dart';

/// Provider for diamond rewards service
final diamondRewardsServiceProvider = Provider<DiamondRewardsService>(
  (ref) => DiamondRewardsService(),
);

/// Service for handling free diamond rewards
class DiamondRewardsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Claim signup bonus (100 diamonds - one time only)
  Future<ClaimResult> claimSignupBonus(String userId) async {
    // Check if already claimed
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'signup')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(
        success: false,
        reason: 'Signup bonus already claimed',
      );
    }

    // Grant bonus
    await _grantReward(
      userId: userId,
      type: 'signup',
      amount: DiamondConfig.signupBonus,
      description: 'Welcome signup bonus',
    );

    return ClaimResult(success: true, amount: DiamondConfig.signupBonus);
  }

  /// Claim daily login bonus (10 diamonds per day)
  Future<ClaimResult> claimDailyLogin(String userId) async {
    final today = _getTodayKey();

    // Check if already claimed today
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'daily_login')
        .where('dateKey', isEqualTo: today)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(
        success: false,
        reason: 'Daily login already claimed today',
      );
    }

    await _grantReward(
      userId: userId,
      type: 'daily_login',
      amount: DiamondConfig.dailyLogin,
      description: 'Daily login bonus',
      dateKey: today,
    );

    return ClaimResult(success: true, amount: DiamondConfig.dailyLogin);
  }

  /// Claim ad watch reward (20 diamonds per ad, 6 max per day)
  Future<ClaimResult> claimAdReward(String userId, String adId) async {
    final today = _getTodayKey();

    // Check how many ads watched today
    final todayAds = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'ad_watch')
        .where('dateKey', isEqualTo: today)
        .get();

    if (todayAds.docs.length >= DiamondConfig.maxAdsPerDay) {
      return ClaimResult(
        success: false,
        reason: 'Maximum ads for today reached (${DiamondConfig.maxAdsPerDay})',
      );
    }

    await _grantReward(
      userId: userId,
      type: 'ad_watch',
      amount: DiamondConfig.perAdWatch,
      description: 'Watched ad reward',
      dateKey: today,
      metadata: {'adId': adId},
    );

    return ClaimResult(
      success: true,
      amount: DiamondConfig.perAdWatch,
      remaining: DiamondConfig.maxAdsPerDay - todayAds.docs.length - 1,
    );
  }

  /// Claim game completion reward (5 diamonds per game, 15 max per day)
  Future<ClaimResult> claimGameReward(String userId, String gameId) async {
    final today = _getTodayKey();

    // Check if this game already rewarded
    final gameRewarded = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'game_complete')
        .where('metadata.gameId', isEqualTo: gameId)
        .limit(1)
        .get();

    if (gameRewarded.docs.isNotEmpty) {
      return ClaimResult(success: false, reason: 'Game already rewarded');
    }

    // Check daily limit
    final todayGames = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'game_complete')
        .where('dateKey', isEqualTo: today)
        .get();

    if (todayGames.docs.length >= DiamondConfig.maxGamesPerDay) {
      return ClaimResult(
        success: false,
        reason:
            'Maximum games for today reached (${DiamondConfig.maxGamesPerDay})',
      );
    }

    await _grantReward(
      userId: userId,
      type: 'game_complete',
      amount: DiamondConfig.perGameComplete,
      description: 'Game completion reward',
      dateKey: today,
      metadata: {'gameId': gameId},
    );

    return ClaimResult(
      success: true,
      amount: DiamondConfig.perGameComplete,
      remaining: DiamondConfig.maxGamesPerDay - todayGames.docs.length - 1,
    );
  }

  /// Claim referral bonus (50 diamonds, 20 max per month)
  Future<ClaimResult> claimReferralBonus(
    String referrerId,
    String newUserId,
  ) async {
    final monthKey = _getMonthKey();

    // Check if this referral already rewarded
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: referrerId)
        .where('type', isEqualTo: 'referral')
        .where('metadata.referredUserId', isEqualTo: newUserId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(success: false, reason: 'Referral already rewarded');
    }

    // Check monthly limit
    final monthlyReferrals = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: referrerId)
        .where('type', isEqualTo: 'referral')
        .where('monthKey', isEqualTo: monthKey)
        .get();

    if (monthlyReferrals.docs.length >= DiamondConfig.maxReferralsPerMonth) {
      return ClaimResult(
        success: false,
        reason: 'Maximum referrals for this month reached',
      );
    }

    await _grantReward(
      userId: referrerId,
      type: 'referral',
      amount: DiamondConfig.referralBonus,
      description: 'Referral bonus',
      monthKey: monthKey,
      metadata: {'referredUserId': newUserId},
    );

    return ClaimResult(
      success: true,
      amount: DiamondConfig.referralBonus,
      remaining:
          DiamondConfig.maxReferralsPerMonth - monthlyReferrals.docs.length - 1,
    );
  }

  /// Claim weekly bonus (100 diamonds on Sundays)
  Future<ClaimResult> claimWeeklyBonus(String userId) async {
    final now = DateTime.now();
    if (now.weekday != DateTime.sunday) {
      return ClaimResult(
        success: false,
        reason: 'Weekly bonus is only available on Sundays',
      );
    }

    final weekKey = _getWeekKey();

    // Check if already claimed this week
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'weekly')
        .where('weekKey', isEqualTo: weekKey)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(
        success: false,
        reason: 'Weekly bonus already claimed',
      );
    }

    await _grantReward(
      userId: userId,
      type: 'weekly',
      amount: DiamondConfig.weeklyBonus,
      description: 'Weekly Sunday bonus',
      weekKey: weekKey,
    );

    return ClaimResult(success: true, amount: DiamondConfig.weeklyBonus);
  }

  /// Claim win streak bonus (progressive: 3→10, 5→20, 10→50, etc.)
  Future<ClaimResult> claimWinStreakBonus(
    String userId,
    int streakCount,
  ) async {
    final reward = DiamondConfig.getStreakReward(streakCount);
    if (reward == null) {
      return ClaimResult(
        success: false,
        reason: 'No reward for streak of $streakCount',
      );
    }

    // Check if this streak milestone already claimed
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'win_streak')
        .where('metadata.streakCount', isEqualTo: streakCount)
        .limit(1)
        .get();

    // Allow claiming same milestone again if time passed (new streak)
    if (existing.docs.isNotEmpty) {
      final lastClaim = existing.docs.first.data()['claimedAt'] as Timestamp?;
      if (lastClaim != null) {
        final hoursSinceClaim = DateTime.now()
            .difference(lastClaim.toDate())
            .inHours;
        if (hoursSinceClaim < 24) {
          return ClaimResult(
            success: false,
            reason: 'Streak milestone already claimed recently',
          );
        }
      }
    }

    await _grantReward(
      userId: userId,
      type: 'win_streak',
      amount: reward,
      description: '$streakCount-win streak bonus',
      metadata: {'streakCount': streakCount},
    );

    return ClaimResult(success: true, amount: reward);
  }

  /// Get today's reward status for a user
  Future<DailyRewardStatus> getDailyStatus(String userId) async {
    final today = _getTodayKey();
    final weekKey = _getWeekKey();
    final now = DateTime.now();

    // Check daily login
    final dailyLogin = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'daily_login')
        .where('dateKey', isEqualTo: today)
        .limit(1)
        .get();

    // Check ads today
    final adsToday = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'ad_watch')
        .where('dateKey', isEqualTo: today)
        .get();

    // Check games today
    final gamesToday = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'game_complete')
        .where('dateKey', isEqualTo: today)
        .get();

    // Check weekly bonus
    final weeklyBonus = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'weekly')
        .where('weekKey', isEqualTo: weekKey)
        .limit(1)
        .get();

    return DailyRewardStatus(
      dailyLoginClaimed: dailyLogin.docs.isNotEmpty,
      adsWatchedToday: adsToday.docs.length,
      gamesCompletedToday: gamesToday.docs.length,
      weeklyBonusClaimed: weeklyBonus.docs.isNotEmpty,
      isSunday: now.weekday == DateTime.sunday,
    );
  }

  /// Internal method to grant a reward
  Future<void> _grantReward({
    required String userId,
    required String type,
    required int amount,
    required String description,
    String? dateKey,
    String? weekKey,
    String? monthKey,
    Map<String, dynamic>? metadata,
  }) async {
    final batch = _db.batch();

    // Create reward record
    final rewardRef = _db.collection('diamond_rewards').doc();
    batch.set(rewardRef, {
      'userId': userId,
      'type': type,
      'amount': amount,
      'description': description,
      'dateKey': dateKey,
      'weekKey': weekKey,
      'monthKey': monthKey,
      'metadata': metadata,
      'claimedAt': FieldValue.serverTimestamp(),
    });

    // Update wallet balance
    final walletRef = _db.collection('wallets').doc(userId);
    batch.update(walletRef, {
      'balance': FieldValue.increment(amount),
      'totalEarned': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Record transaction
    final txRef = _db.collection('transactions').doc();
    batch.set(txRef, {
      'userId': userId,
      'amount': amount,
      'type': 'reward',
      'rewardType': type,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('Reward granted: $amount diamonds ($type) to $userId');
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getWeekKey() {
    final now = DateTime.now();
    final weekNumber = ((now.day - now.weekday + 10) / 7).floor();
    return '${now.year}-W$weekNumber';
  }

  String _getMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}

/// Result of a claim attempt
class ClaimResult {
  final bool success;
  final int? amount;
  final String? reason;
  final int? remaining;

  ClaimResult({
    required this.success,
    this.amount,
    this.reason,
    this.remaining,
  });
}

/// Daily reward status for a user
class DailyRewardStatus {
  final bool dailyLoginClaimed;
  final int adsWatchedToday;
  final int gamesCompletedToday;
  final bool weeklyBonusClaimed;
  final bool isSunday;

  DailyRewardStatus({
    required this.dailyLoginClaimed,
    required this.adsWatchedToday,
    required this.gamesCompletedToday,
    required this.weeklyBonusClaimed,
    required this.isSunday,
  });

  int get adsRemaining => DiamondConfig.maxAdsPerDay - adsWatchedToday;
  int get gamesRemaining => DiamondConfig.maxGamesPerDay - gamesCompletedToday;
  bool get canClaimWeeklyBonus => isSunday && !weeklyBonusClaimed;
}

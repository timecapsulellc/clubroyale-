/// Diamond Configuration for Economy System
/// 
/// All diamond amounts, limits, and costs in one place.
library;

class DiamondConfig {
  // ============ EARNING (FREE TIER) ============

  /// One-time signup bonus
  static const int signupBonus = 100;

  /// Daily login reward
  static const int dailyLogin = 10;

  /// Reward per ad watched
  static const int perAdWatch = 20;

  /// Reward per game completed
  static const int perGameComplete = 5;

  /// Referral bonus (referrer gets this)
  static const int referralBonus = 50;

  /// Weekly bonus (available on Sundays)
  static const int weeklyBonus = 100;

  // ============ DAILY LIMITS ============

  /// Maximum ads per day
  static const int maxAdsPerDay = 6; // 120💎 max

  /// Maximum games rewarded per day
  static const int maxGamesPerDay = 15; // 75💎 max

  // ============ MONTHLY LIMITS ============

  /// Maximum referrals per month
  static const int maxReferralsPerMonth = 20; // 1000💎 max

  // ============ WIN STREAK REWARDS (Progressive) ============

  /// Win streak milestone rewards
  static const Map<int, int> streakRewards = {
    3: 10, // 3 wins = 10💎
    5: 20, // 5 wins = 20💎
    7: 30, // 7 wins = 30💎
    10: 50, // 10 wins = 50💎
    15: 100, // 15 wins = 100💎
    20: 200, // 20 wins = 200💎
  };

  // ============ SPENDING COSTS ============

  /// Cost to create a room
  static const int roomCreationCost = 10;

  /// Cost to extend a room duration
  static const int roomExtendCost = 5;

  /// Cost for rematch
  static const int rematchCost = 5;

  // ============ TRANSFERS ============

  /// Transfer expiry in hours
  static const int transferExpiryHours = 48;

  /// Reminder hours before expiry
  static const int transferReminderHours = 24;

  /// Minimum transfer amount
  static const int minTransferAmount = 1;

  /// Maximum transfer amount per transaction
  static const int maxTransferAmount = 100000;

  // ============ CALCULATED VALUES ============

  /// Maximum daily free earnings (excluding streaks)
  static int get maxDailyFreeEarnings =>
      dailyLogin + (maxAdsPerDay * perAdWatch) + (maxGamesPerDay * perGameComplete);
  // = 10 + 120 + 75 = 205💎/day

  /// Maximum monthly free earnings (approximate)
  static int get maxMonthlyFreeEarnings =>
      (maxDailyFreeEarnings * 30) +
      (weeklyBonus * 4) +
      (referralBonus * maxReferralsPerMonth);
  // = 6150 + 400 + 1000 = ~7,550💎/month

  /// Get streak reward for a given win count
  static int? getStreakReward(int winCount) {
    return streakRewards[winCount];
  }

  /// Get next streak milestone after current count
  static int? getNextStreakMilestone(int currentStreak) {
    for (final milestone in streakRewards.keys.toList()..sort()) {
      if (milestone > currentStreak) return milestone;
    }
    return null;
  }
  // ============ AD CONFIGURATION ============

  /// Android Ad Unit ID (Rewarded Video - Test ID)
  /// REPLACE with real ID on release: ca-app-pub-xxxxxxxx/yyyyyyyy
  static const String androidAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  /// iOS Ad Unit ID (Rewarded Video - Test ID)
  /// REPLACE with real ID on release: ca-app-pub-xxxxxxxx/yyyyyyyy
  static const String iosAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
}

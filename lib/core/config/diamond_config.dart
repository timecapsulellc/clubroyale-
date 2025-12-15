/// Diamond Configuration for Economy System
/// 
/// All diamond amounts, limits, and costs in one place.
library;

class DiamondConfig {
  // ============ V5 ECONOMY CONSTANTS ============

  /// Fee to upgrade to Verified Tier (burnt)
  static const int verificationFee = 100;

  /// P2P Transfer Burn Fee (5%)
  static const double transferFeePercent = 0.05;

  // ============ EARNING (FREE TIER) ============

  /// One-time signup bonus
  static const int signupBonus = 100;

  /// Daily login reward (Base)
  static const int dailyLogin = 10;

  /// Reward per ad watched
  static const int perAdWatch = 20;

  /// Reward per game completed
  static const int perGameComplete = 5;

  /// Referral bonus (referrer gets this)
  static const int referralBonus = 50;

  /// Weekly bonus (available on Sundays)
  static const int weeklyBonus = 100;
  
  /// Gameplay Rewards Mapping (Backend mirror)
  static const Map<String, int> gameplayRewards = {
    'callbreak_win': 20,
    'callbreak_second': 5,
    'teenpatti_win': 10,
    'rummy_win': 15,
    'poker_win': 25,
    'marriage_win': 30,
  };

  // ============ DAILY LIMITS ============

  /// Maximum ads per day
  static const int maxAdsPerDay = 6; // 120💎 max

  /// Maximum games rewarded per day
  static const int maxGamesPerDay = 15; // 75💎 max

  // ============ MONTHLY LIMITS ============

  /// Maximum referrals per month
  static const int maxReferralsPerMonth = 20; // 1000💎 max

  // ============ WIN STREAK REWARDS (V5) ============
  
  /// V5 Streak Bonuses (7, 14, 30 days)
  /// Backend source of truth: 7:50, 14:100, 30:500
  static const Map<int, int> streakRewards = {
    7: 50,
    14: 100,
    30: 500,
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
  static const int minTransferAmount = 10; // Bumped for V5 to make sense with fees

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
  static int? getStreakReward(int days) {
    return streakRewards[days];
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

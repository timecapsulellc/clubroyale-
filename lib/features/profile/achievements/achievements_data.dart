/// Achievement and Badge Definitions
/// 
/// Defines all achievements available in ClubRoyale
library;

import 'package:clubroyale/features/profile/user_profile.dart';

/// All available achievements in ClubRoyale
class AchievementsData {
  AchievementsData._();

  /// Get all defined achievements
  static List<Achievement> get allAchievements => [
    // ============ GAME WINS ============
    const Achievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Win your first game',
      iconUrl: 'assets/badges/first_win.png',
      rarity: AchievementRarity.common,
      maxProgress: 1,
    ),
    const Achievement(
      id: 'win_10',
      title: 'Rising Star',
      description: 'Win 10 games',
      iconUrl: 'assets/badges/win_10.png',
      rarity: AchievementRarity.uncommon,
      maxProgress: 10,
    ),
    const Achievement(
      id: 'win_50',
      title: 'Champion',
      description: 'Win 50 games',
      iconUrl: 'assets/badges/win_50.png',
      rarity: AchievementRarity.rare,
      maxProgress: 50,
    ),
    const Achievement(
      id: 'win_100',
      title: 'Legend',
      description: 'Win 100 games',
      iconUrl: 'assets/badges/win_100.png',
      rarity: AchievementRarity.epic,
      maxProgress: 100,
    ),
    const Achievement(
      id: 'win_500',
      title: 'Grandmaster',
      description: 'Win 500 games',
      iconUrl: 'assets/badges/win_500.png',
      rarity: AchievementRarity.legendary,
      maxProgress: 500,
    ),

    // ============ GAME-SPECIFIC ============
    const Achievement(
      id: 'marriage_master',
      title: 'Marriage Master',
      description: 'Win 25 Marriage games',
      iconUrl: 'assets/badges/marriage_master.png',
      rarity: AchievementRarity.rare,
      maxProgress: 25,
    ),
    const Achievement(
      id: 'call_break_ace',
      title: 'Call Break Ace',
      description: 'Win 25 Call Break games',
      iconUrl: 'assets/badges/call_break_ace.png',
      rarity: AchievementRarity.rare,
      maxProgress: 25,
    ),
    const Achievement(
      id: 'teen_patti_king',
      title: 'Teen Patti King',
      description: 'Win 25 Teen Patti games',
      iconUrl: 'assets/badges/teen_patti_king.png',
      rarity: AchievementRarity.rare,
      maxProgress: 25,
    ),
    const Achievement(
      id: 'perfect_declare',
      title: 'Perfect Declare',
      description: 'Win Marriage with all cards in melds (no deadwood)',
      iconUrl: 'assets/badges/perfect_declare.png',
      rarity: AchievementRarity.epic,
      maxProgress: 1,
    ),

    // ============ STREAKS ============
    const Achievement(
      id: 'streak_3',
      title: 'Hot Streak',
      description: 'Win 3 games in a row',
      iconUrl: 'assets/badges/streak_3.png',
      rarity: AchievementRarity.uncommon,
      maxProgress: 3,
    ),
    const Achievement(
      id: 'streak_7',
      title: 'On Fire',
      description: 'Win 7 games in a row',
      iconUrl: 'assets/badges/streak_7.png',
      rarity: AchievementRarity.rare,
      maxProgress: 7,
    ),
    const Achievement(
      id: 'daily_7',
      title: 'Dedicated Player',
      description: 'Play for 7 consecutive days',
      iconUrl: 'assets/badges/daily_7.png',
      rarity: AchievementRarity.uncommon,
      maxProgress: 7,
    ),
    const Achievement(
      id: 'daily_30',
      title: 'Committed',
      description: 'Play for 30 consecutive days',
      iconUrl: 'assets/badges/daily_30.png',
      rarity: AchievementRarity.epic,
      maxProgress: 30,
    ),

    // ============ SOCIAL ============
    const Achievement(
      id: 'first_friend',
      title: 'Friendly',
      description: 'Add your first friend',
      iconUrl: 'assets/badges/first_friend.png',
      rarity: AchievementRarity.common,
      maxProgress: 1,
    ),
    const Achievement(
      id: 'friends_10',
      title: 'Social Butterfly',
      description: 'Have 10 friends',
      iconUrl: 'assets/badges/friends_10.png',
      rarity: AchievementRarity.uncommon,
      maxProgress: 10,
    ),
    const Achievement(
      id: 'friends_50',
      title: 'Popular',
      description: 'Have 50 friends',
      iconUrl: 'assets/badges/friends_50.png',
      rarity: AchievementRarity.rare,
      maxProgress: 50,
    ),
    const Achievement(
      id: 'host_5',
      title: 'Host With the Most',
      description: 'Host 5 game rooms',
      iconUrl: 'assets/badges/host_5.png',
      rarity: AchievementRarity.uncommon,
      maxProgress: 5,
    ),
    const Achievement(
      id: 'host_25',
      title: 'Party Starter',
      description: 'Host 25 game rooms',
      iconUrl: 'assets/badges/host_25.png',
      rarity: AchievementRarity.rare,
      maxProgress: 25,
    ),

    // ============ SPECIAL ============
    const Achievement(
      id: 'beta_tester',
      title: 'Beta Tester',
      description: 'Joined during beta phase',
      iconUrl: 'assets/badges/beta_tester.png',
      rarity: AchievementRarity.legendary,
      maxProgress: 1,
    ),
    const Achievement(
      id: 'tournament_winner',
      title: 'Tournament Champion',
      description: 'Win a tournament',
      iconUrl: 'assets/badges/tournament_winner.png',
      rarity: AchievementRarity.epic,
      maxProgress: 1,
    ),
    const Achievement(
      id: 'diamond_spender',
      title: 'High Roller',
      description: 'Earn 10,000 diamonds',
      iconUrl: 'assets/badges/diamond_spender.png',
      rarity: AchievementRarity.epic,
      maxProgress: 10000,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get achievements by rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return allAchievements.where((a) => a.rarity == rarity).toList();
  }

  /// Get achievement icon color based on rarity
  static String getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return '#9E9E9E'; // Grey
      case AchievementRarity.uncommon:
        return '#4CAF50'; // Green
      case AchievementRarity.rare:
        return '#2196F3'; // Blue
      case AchievementRarity.epic:
        return '#9C27B0'; // Purple
      case AchievementRarity.legendary:
        return '#FF9800'; // Orange/Gold
    }
  }

  /// Get rarity display name
  static String getRarityName(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

/// Profile badges (different from achievements - displayed on profile)
class BadgesData {
  BadgesData._();

  static List<ProfileBadge> get allBadges => [
    // Game badges
    const ProfileBadge(
      id: 'marriage_pro',
      name: 'Marriage Pro',
      iconUrl: 'assets/badges/marriage_pro.png',
      description: 'Mastered the Marriage game',
      type: BadgeType.game,
    ),
    const ProfileBadge(
      id: 'call_break_pro',
      name: 'Call Break Pro',
      iconUrl: 'assets/badges/call_break_pro.png',
      description: 'Mastered the Call Break game',
      type: BadgeType.game,
    ),
    const ProfileBadge(
      id: 'teen_patti_pro',
      name: 'Teen Patti Pro',
      iconUrl: 'assets/badges/teen_patti_pro.png',
      description: 'Mastered Teen Patti',
      type: BadgeType.game,
    ),
    
    // Social badges
    const ProfileBadge(
      id: 'influencer',
      name: 'Influencer',
      iconUrl: 'assets/badges/influencer.png',
      description: '100+ followers',
      type: BadgeType.social,
    ),
    const ProfileBadge(
      id: 'community_leader',
      name: 'Community Leader',
      iconUrl: 'assets/badges/community_leader.png',
      description: 'Active community member',
      type: BadgeType.social,
    ),
    
    // Special badges
    const ProfileBadge(
      id: 'verified',
      name: 'Verified',
      iconUrl: 'assets/badges/verified.png',
      description: 'Verified account',
      type: BadgeType.verified,
    ),
    const ProfileBadge(
      id: 'creator',
      name: 'Creator',
      iconUrl: 'assets/badges/creator.png',
      description: 'Content creator',
      type: BadgeType.creator,
    ),
    const ProfileBadge(
      id: 'early_adopter',
      name: 'Early Adopter',
      iconUrl: 'assets/badges/early_adopter.png',
      description: 'Among the first users',
      type: BadgeType.seasonal,
    ),
  ];

  static ProfileBadge? getById(String id) {
    try {
      return allBadges.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

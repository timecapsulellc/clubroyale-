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
  /// TODO: REDUCE TO 100 BEFORE PUBLIC RELEASE!
  /// Currently set high (10000) for pre-production testing
  static const int signupBonus = 10000;

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

// ============================================================================
// SOCIAL DIAMOND REWARDS (V5 Enhancement)
// ============================================================================

/// Social activity diamond rewards - leveraging new social features
class SocialDiamondRewards {
  // ============ VOICE ROOM HOSTING REWARDS ============
  static const int hostVoiceRoom10Minutes = 10;
  static const int hostVoiceRoom30Minutes = 25;
  static const int voiceRoomRegularHost = 50; // 10+ rooms/month

  // ============ STORY ENGAGEMENT REWARDS ============
  static const int firstStoryPosted = 15;
  static const int storyReached50Views = 10;
  static const int storyReached100Views = 25;
  static const int dailyStoryStreak7 = 50;

  // ============ CHAT ACTIVITY REWARDS ============
  static const int activeChatter = 10; // 50+ messages/day
  static const int helpfulResponder = 15; // Quick response rate
  static const int groupCreator = 25; // Create active group

  // ============ SOCIAL GAMING REWARDS ============
  static const int gameInviteAccepted = 5;
  static const int gameInvite5Players = 25;
  static const int voiceGameCompleted = 10; // Game with voice chat
  static const int videoGameCompleted = 15; // Game with video chat

  // ============ SUPPORT REWARDS ============
  static const int helpedNewPlayerVerified = 25;
  static const int bugReportVerified = 50;
  static const int featureSuggestionImplemented = 100;

  // ============ DAILY CAPS (Prevent Abuse) ============
  static const int voiceRoomHostingDailyCap = 50;
  static const int storyViewsDailyCap = 50;
  static const int chatActivityDailyCap = 30;
  static const int gameInvitesDailyCap = 50;

  /// All rewards as a map for programmatic access
  static const Map<String, int> rewards = {
    'host_voice_room_10_minutes': hostVoiceRoom10Minutes,
    'host_voice_room_30_minutes': hostVoiceRoom30Minutes,
    'voice_room_regular': voiceRoomRegularHost,
    'first_story_posted': firstStoryPosted,
    'story_reached_50_views': storyReached50Views,
    'story_reached_100_views': storyReached100Views,
    'daily_story_streak_7': dailyStoryStreak7,
    'active_chatter': activeChatter,
    'helpful_responder': helpfulResponder,
    'group_creator': groupCreator,
    'game_invite_accepted': gameInviteAccepted,
    'game_invite_5_players': gameInvite5Players,
    'voice_game_completed': voiceGameCompleted,
    'video_game_completed': videoGameCompleted,
    'helped_new_player_verified': helpedNewPlayerVerified,
    'bug_report_verified': bugReportVerified,
    'feature_suggestion_implemented': featureSuggestionImplemented,
  };

  /// Daily caps by category
  static const Map<String, int> dailyCaps = {
    'voice_room_hosting': voiceRoomHostingDailyCap,
    'story_views': storyViewsDailyCap,
    'chat_activity': chatActivityDailyCap,
    'game_invites': gameInvitesDailyCap,
  };
}

// ============================================================================
// VOICE ROOM DIAMOND FEATURES (V5 Enhancement)
// ============================================================================

/// Voice room monetization configuration
class VoiceRoomDiamondConfig {
  // ============ VOICE ROOM CREATION COSTS ============
  static const int createPublicRoom = 0; // FREE (engagement)
  static const int createPrivateRoom = 10;
  static const int extendRoom1Hour = 5;
  static const int premiumAudioQuality = 20;
  static const int roomRecording = 50;
  static const int featuredRoomListing = 100;

  // ============ TIPPING CONFIG ============
  static const int minimumTip = 5;
  static const int tipAnimationThreshold = 50;
  static const int superTipThreshold = 100;
  static const double platformTipFee = 0.05; // 5% burned

  // ============ VOICE ROOM GAMING BONUS ============
  static const int gameStartedFromVoice = 5;
  static const int fullVoiceGame = 10; // Everyone on voice = bonus

  /// All costs as a map
  static const Map<String, int> costs = {
    'create_public_room': createPublicRoom,
    'create_private_room': createPrivateRoom,
    'extend_room_1_hour': extendRoom1Hour,
    'premium_audio_quality': premiumAudioQuality,
    'room_recording': roomRecording,
    'featured_room_listing': featuredRoomListing,
  };
}

// ============================================================================
// STORY DIAMOND FEATURES (V5 Enhancement)
// ============================================================================

/// Story monetization configuration
class StoryDiamondConfig {
  // ============ STORY CREATION COSTS ============
  static const int basicStory = 0; // FREE
  static const int premiumFilters = 10;
  static const int animatedText = 15;
  static const int musicOverlay = 20;
  static const int pollStory = 5;
  static const int quizStory = 10;

  // ============ STORY REACTION COSTS ============
  static const int basicReaction = 0; // FREE
  static const int superReaction = 5;
  static const int diamondRain = 25;
  static const int spotlight = 50; // Feature their story

  // ============ AUTO-GENERATED STORY REWARDS ============
  static const int gameResultStoryShared = 5;
  static const int achievementStoryShared = 10;
  static const int tournamentWinStory = 25;

  /// Creation costs as a map
  static const Map<String, int> creationCosts = {
    'basic_story': basicStory,
    'premium_filters': premiumFilters,
    'animated_text': animatedText,
    'music_overlay': musicOverlay,
    'poll_story': pollStory,
    'quiz_story': quizStory,
  };

  /// Reaction costs as a map
  static const Map<String, int> reactionCosts = {
    'basic_reaction': basicReaction,
    'super_reaction': superReaction,
    'diamond_rain': diamondRain,
    'spotlight': spotlight,
  };
}

// ============================================================================
// ENGAGEMENT TIERS (V5 Enhancement)
// ============================================================================

/// Weekly engagement tier requirements and rewards
class EngagementTierConfig {
  // ============ WEEKLY TIER REWARDS ============
  static const int casualReward = 25;
  static const int regularReward = 75;
  static const int dedicatedReward = 150;
  static const int superUserReward = 300;

  // ============ MONTHLY MILESTONE REWARDS ============
  static const int played100Games = 500;
  static const int hosted20VoiceRooms = 300;
  static const int posted30Stories = 200;
  static const int helped10NewPlayers = 400;
  static const int allAchievementsMonth = 1000;

  /// Weekly tiers with requirements
  static const Map<String, EngagementTier> weeklyTiers = {
    'casual': EngagementTier(
      name: 'Casual Player',
      badge: '🎮',
      reward: casualReward,
      gamesRequired: 5,
      daysRequired: 3,
      messagesRequired: 0,
    ),
    'regular': EngagementTier(
      name: 'Regular Player',
      badge: '⭐',
      reward: regularReward,
      gamesRequired: 15,
      daysRequired: 5,
      messagesRequired: 10,
    ),
    'dedicated': EngagementTier(
      name: 'Dedicated Player',
      badge: '🔥',
      reward: dedicatedReward,
      gamesRequired: 30,
      daysRequired: 7,
      messagesRequired: 0,
      requiresVoiceRoom: true,
    ),
    'super_user': EngagementTier(
      name: 'Super User',
      badge: '👑',
      reward: superUserReward,
      gamesRequired: 50,
      daysRequired: 7,
      messagesRequired: 0,
      requiresVoiceRoom: true,
      requiresStories: true,
      requiresHelping: true,
    ),
  };

  /// Monthly milestones
  static const Map<String, int> monthlyMilestones = {
    'played_100_games': played100Games,
    'hosted_20_voice_rooms': hosted20VoiceRooms,
    'posted_30_stories': posted30Stories,
    'helped_10_new_players': helped10NewPlayers,
    'all_achievements_month': allAchievementsMonth,
  };
}

/// Individual engagement tier definition
class EngagementTier {
  final String name;
  final String badge;
  final int reward;
  final int gamesRequired;
  final int daysRequired;
  final int messagesRequired;
  final bool requiresVoiceRoom;
  final bool requiresStories;
  final bool requiresHelping;

  const EngagementTier({
    required this.name,
    required this.badge,
    required this.reward,
    required this.gamesRequired,
    required this.daysRequired,
    required this.messagesRequired,
    this.requiresVoiceRoom = false,
    this.requiresStories = false,
    this.requiresHelping = false,
  });
}


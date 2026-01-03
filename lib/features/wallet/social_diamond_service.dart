import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/config/diamond_config.dart';

/// Provider for social diamond service
final socialDiamondServiceProvider = Provider<SocialDiamondService>(
  (ref) => SocialDiamondService(),
);

/// Service for handling social activity diamond rewards
///
/// Part of Diamond Revenue Model V5 - Social Enhancements
class SocialDiamondService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================================
  // VOICE ROOM REWARDS
  // ============================================================================

  /// Claim voice room hosting reward
  /// [durationMinutes] - how long the room was active
  Future<ClaimResult> claimVoiceRoomHostingReward({
    required String userId,
    required String roomId,
    required int durationMinutes,
  }) async {
    final today = _getTodayKey();

    // Check daily cap
    final todayRewards = await _getDailyRewardTotal(
      userId: userId,
      category: 'voice_room_hosting',
      dateKey: today,
    );

    if (todayRewards >= SocialDiamondRewards.voiceRoomHostingDailyCap) {
      return ClaimResult(
        success: false,
        reason:
            'Daily voice room hosting cap reached (${SocialDiamondRewards.voiceRoomHostingDailyCap}💎)',
      );
    }

    // Check if this room already rewarded
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'voice_room_hosting')
        .where('metadata.roomId', isEqualTo: roomId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(success: false, reason: 'This room already rewarded');
    }

    // Calculate reward based on duration
    int reward;
    String description;
    if (durationMinutes >= 30) {
      reward = SocialDiamondRewards.hostVoiceRoom30Minutes;
      description = 'Voice room host (30+ minutes)';
    } else if (durationMinutes >= 10) {
      reward = SocialDiamondRewards.hostVoiceRoom10Minutes;
      description = 'Voice room host (10+ minutes)';
    } else {
      return ClaimResult(
        success: false,
        reason: 'Host for at least 10 minutes to earn rewards',
      );
    }

    // Apply cap
    final cappedReward = _applyCap(
      reward,
      todayRewards,
      SocialDiamondRewards.voiceRoomHostingDailyCap,
    );

    await _grantSocialReward(
      userId: userId,
      type: 'voice_room_hosting',
      category: 'voice_room_hosting',
      amount: cappedReward,
      description: description,
      dateKey: today,
      metadata: {'roomId': roomId, 'durationMinutes': durationMinutes},
    );

    return ClaimResult(success: true, amount: cappedReward);
  }

  /// Process a voice room tip (sender to receiver)
  /// Returns the net amount received after platform fee
  Future<TipResult> processVoiceRoomTip({
    required String senderId,
    required String receiverId,
    required int amount,
    String? roomId,
  }) async {
    // Validate minimum
    if (amount < VoiceRoomDiamondConfig.minimumTip) {
      return TipResult(
        success: false,
        reason: 'Minimum tip is ${VoiceRoomDiamondConfig.minimumTip}💎',
      );
    }

    // Check sender balance
    final senderWallet = await _db.collection('wallets').doc(senderId).get();
    final senderBalance = (senderWallet.data()?['balance'] ?? 0) as int;

    if (senderBalance < amount) {
      return TipResult(success: false, reason: 'Insufficient diamond balance');
    }

    // Calculate fee (burned)
    final fee = (amount * VoiceRoomDiamondConfig.platformTipFee).floor();
    final netAmount = amount - fee;

    // Execute transfer
    final batch = _db.batch();

    // Deduct from sender
    batch.update(_db.collection('wallets').doc(senderId), {
      'balance': FieldValue.increment(-amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Credit to receiver (minus fee)
    batch.update(_db.collection('wallets').doc(receiverId), {
      'balance': FieldValue.increment(netAmount),
      'totalEarned': FieldValue.increment(netAmount),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Record transaction
    final txRef = _db.collection('transactions').doc();
    batch.set(txRef, {
      'type': 'voice_room_tip',
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'fee': fee,
      'netAmount': netAmount,
      'roomId': roomId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    debugPrint(
      'Voice room tip: $amount from $senderId to $receiverId (fee: $fee)',
    );

    return TipResult(
      success: true,
      grossAmount: amount,
      fee: fee,
      netAmount: netAmount,
      showAnimation: amount >= VoiceRoomDiamondConfig.tipAnimationThreshold,
      isSuperTip: amount >= VoiceRoomDiamondConfig.superTipThreshold,
    );
  }

  // ============================================================================
  // STORY REWARDS
  // ============================================================================

  /// Claim story view milestone reward
  Future<ClaimResult> claimStoryViewReward({
    required String userId,
    required String storyId,
    required int viewCount,
  }) async {
    final today = _getTodayKey();

    // Check daily cap
    final todayRewards = await _getDailyRewardTotal(
      userId: userId,
      category: 'story_views',
      dateKey: today,
    );

    if (todayRewards >= SocialDiamondRewards.storyViewsDailyCap) {
      return ClaimResult(
        success: false,
        reason: 'Daily story views cap reached',
      );
    }

    // Determine milestone
    int reward;
    String milestone;
    if (viewCount >= 100) {
      milestone = '100_views';
      reward = SocialDiamondRewards.storyReached100Views;
    } else if (viewCount >= 50) {
      milestone = '50_views';
      reward = SocialDiamondRewards.storyReached50Views;
    } else {
      return ClaimResult(
        success: false,
        reason: 'Reach 50 views to earn rewards',
      );
    }

    // Check if this milestone already claimed for this story
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'story_views')
        .where('metadata.storyId', isEqualTo: storyId)
        .where('metadata.milestone', isEqualTo: milestone)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(success: false, reason: 'Milestone already claimed');
    }

    final cappedReward = _applyCap(
      reward,
      todayRewards,
      SocialDiamondRewards.storyViewsDailyCap,
    );

    await _grantSocialReward(
      userId: userId,
      type: 'story_views',
      category: 'story_views',
      amount: cappedReward,
      description: 'Story reached $viewCount views',
      dateKey: today,
      metadata: {
        'storyId': storyId,
        'milestone': milestone,
        'viewCount': viewCount,
      },
    );

    return ClaimResult(success: true, amount: cappedReward);
  }

  /// Claim first story posted bonus
  Future<ClaimResult> claimFirstStoryBonus(String userId) async {
    // Check if ever claimed
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'first_story')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(success: false, reason: 'Already claimed');
    }

    await _grantSocialReward(
      userId: userId,
      type: 'first_story',
      category: 'story_views',
      amount: SocialDiamondRewards.firstStoryPosted,
      description: 'First story bonus!',
    );

    return ClaimResult(
      success: true,
      amount: SocialDiamondRewards.firstStoryPosted,
    );
  }

  // ============================================================================
  // GAME INVITE REWARDS
  // ============================================================================

  /// Claim game invite reward when someone joins
  Future<ClaimResult> claimGameInviteReward({
    required String userId,
    required String inviteeId,
    required String gameId,
  }) async {
    final today = _getTodayKey();

    // Check daily cap
    final todayRewards = await _getDailyRewardTotal(
      userId: userId,
      category: 'game_invites',
      dateKey: today,
    );

    if (todayRewards >= SocialDiamondRewards.gameInvitesDailyCap) {
      return ClaimResult(success: false, reason: 'Daily invite cap reached');
    }

    // Check if this invite already rewarded
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'game_invite')
        .where('metadata.inviteeId', isEqualTo: inviteeId)
        .where('metadata.gameId', isEqualTo: gameId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(success: false, reason: 'Invite already rewarded');
    }

    final reward = SocialDiamondRewards.gameInviteAccepted;
    final cappedReward = _applyCap(
      reward,
      todayRewards,
      SocialDiamondRewards.gameInvitesDailyCap,
    );

    await _grantSocialReward(
      userId: userId,
      type: 'game_invite',
      category: 'game_invites',
      amount: cappedReward,
      description: 'Friend joined your game',
      dateKey: today,
      metadata: {'inviteeId': inviteeId, 'gameId': gameId},
    );

    return ClaimResult(success: true, amount: cappedReward);
  }

  // ============================================================================
  // ENGAGEMENT TIER REWARDS
  // ============================================================================

  /// Claim weekly engagement tier reward
  Future<ClaimResult> claimWeeklyEngagementReward({
    required String userId,
    required String tierKey,
  }) async {
    final weekKey = _getWeekKey();
    final tier = EngagementTierConfig.weeklyTiers[tierKey];

    if (tier == null) {
      return ClaimResult(success: false, reason: 'Invalid tier');
    }

    // Check if already claimed this week
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'weekly_engagement')
        .where('weekKey', isEqualTo: weekKey)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(
        success: false,
        reason: 'Weekly reward already claimed',
      );
    }

    // Verify tier requirements (simplified - full verification done by scheduled function)
    // For now, trust the client claim (will be validated by backend trigger)

    await _grantSocialReward(
      userId: userId,
      type: 'weekly_engagement',
      category: 'engagement',
      amount: tier.reward,
      description: '${tier.name} weekly bonus',
      weekKey: weekKey,
      metadata: {'tier': tierKey, 'badge': tier.badge},
    );

    return ClaimResult(success: true, amount: tier.reward);
  }

  /// Claim monthly milestone reward
  Future<ClaimResult> claimMonthlyMilestone({
    required String userId,
    required String milestoneKey,
  }) async {
    final monthKey = _getMonthKey();
    final reward = EngagementTierConfig.monthlyMilestones[milestoneKey];

    if (reward == null) {
      return ClaimResult(success: false, reason: 'Invalid milestone');
    }

    // Check if already claimed this month
    final existing = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'monthly_milestone')
        .where('monthKey', isEqualTo: monthKey)
        .where('metadata.milestone', isEqualTo: milestoneKey)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return ClaimResult(
        success: false,
        reason: 'Milestone already claimed this month',
      );
    }

    await _grantSocialReward(
      userId: userId,
      type: 'monthly_milestone',
      category: 'engagement',
      amount: reward,
      description: 'Monthly milestone: $milestoneKey',
      monthKey: monthKey,
      metadata: {'milestone': milestoneKey},
    );

    return ClaimResult(success: true, amount: reward);
  }

  // ============================================================================
  // STATUS & HELPERS
  // ============================================================================

  /// Get today's social reward status
  Future<SocialRewardStatus> getDailyStatus(String userId) async {
    final today = _getTodayKey();

    final voiceRoomTotal = await _getDailyRewardTotal(
      userId: userId,
      category: 'voice_room_hosting',
      dateKey: today,
    );

    final storyViewsTotal = await _getDailyRewardTotal(
      userId: userId,
      category: 'story_views',
      dateKey: today,
    );

    final gameInvitesTotal = await _getDailyRewardTotal(
      userId: userId,
      category: 'game_invites',
      dateKey: today,
    );

    return SocialRewardStatus(
      voiceRoomEarned: voiceRoomTotal,
      voiceRoomRemaining:
          SocialDiamondRewards.voiceRoomHostingDailyCap - voiceRoomTotal,
      storyViewsEarned: storyViewsTotal,
      storyViewsRemaining:
          SocialDiamondRewards.storyViewsDailyCap - storyViewsTotal,
      gameInvitesEarned: gameInvitesTotal,
      gameInvitesRemaining:
          SocialDiamondRewards.gameInvitesDailyCap - gameInvitesTotal,
    );
  }

  // ============================================================================
  // INTERNAL HELPERS
  // ============================================================================

  Future<int> _getDailyRewardTotal({
    required String userId,
    required String category,
    required String dateKey,
  }) async {
    final rewards = await _db
        .collection('diamond_rewards')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .where('dateKey', isEqualTo: dateKey)
        .get();

    int total = 0;
    for (final doc in rewards.docs) {
      total += (doc.data()['amount'] ?? 0) as int;
    }
    return total;
  }

  int _applyCap(int reward, int alreadyEarned, int cap) {
    final remaining = cap - alreadyEarned;
    if (remaining <= 0) return 0;
    return reward > remaining ? remaining : reward;
  }

  Future<void> _grantSocialReward({
    required String userId,
    required String type,
    required String category,
    required int amount,
    required String description,
    String? dateKey,
    String? weekKey,
    String? monthKey,
    Map<String, dynamic>? metadata,
  }) async {
    if (amount <= 0) return;

    final batch = _db.batch();

    // Create reward record
    final rewardRef = _db.collection('diamond_rewards').doc();
    batch.set(rewardRef, {
      'userId': userId,
      'type': type,
      'category': category,
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
      'type': 'social_reward',
      'rewardType': type,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('Social reward granted: $amount💎 ($type) to $userId');
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

  ClaimResult({required this.success, this.amount, this.reason});
}

/// Result of a tip transaction
class TipResult {
  final bool success;
  final int? grossAmount;
  final int? fee;
  final int? netAmount;
  final String? reason;
  final bool showAnimation;
  final bool isSuperTip;

  TipResult({
    required this.success,
    this.grossAmount,
    this.fee,
    this.netAmount,
    this.reason,
    this.showAnimation = false,
    this.isSuperTip = false,
  });
}

/// Daily social reward status
class SocialRewardStatus {
  final int voiceRoomEarned;
  final int voiceRoomRemaining;
  final int storyViewsEarned;
  final int storyViewsRemaining;
  final int gameInvitesEarned;
  final int gameInvitesRemaining;

  SocialRewardStatus({
    required this.voiceRoomEarned,
    required this.voiceRoomRemaining,
    required this.storyViewsEarned,
    required this.storyViewsRemaining,
    required this.gameInvitesEarned,
    required this.gameInvitesRemaining,
  });

  int get totalEarnedToday =>
      voiceRoomEarned + storyViewsEarned + gameInvitesEarned;
  int get totalRemainingToday =>
      voiceRoomRemaining + storyViewsRemaining + gameInvitesRemaining;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/core/widgets/legal_disclaimer_widget.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_rewards_service.dart';
import 'package:clubroyale/features/wallet/social_diamond_service.dart';
import 'package:clubroyale/features/store/diamond_service.dart';
import 'package:clubroyale/core/services/ad_service.dart';
import 'package:clubroyale/core/services/share_service.dart';

/// Screen for earning free diamonds - includes Standard and Social rewards
class EarnDiamondsScreen extends ConsumerStatefulWidget {
  const EarnDiamondsScreen({super.key});

  @override
  ConsumerState<EarnDiamondsScreen> createState() => _EarnDiamondsScreenState();
}

class _EarnDiamondsScreenState extends ConsumerState<EarnDiamondsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  DailyRewardStatus? _status;
  SocialRewardStatus? _socialStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatus();
    AdService().initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final rewardsService = ref.read(diamondRewardsServiceProvider);
      final socialService = ref.read(socialDiamondServiceProvider);

      final status = await rewardsService.getDailyStatus(user.uid);
      final socialStatus = await socialService.getDailyStatus(user.uid);

      setState(() {
        _status = status;
        _socialStatus = socialStatus;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _claimDailyLogin() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final rewardsService = ref.read(diamondRewardsServiceProvider);
      final result = await rewardsService.claimDailyLogin(user.uid);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Claimed ${result.amount} diamonds!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.reason ?? 'Already claimed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _watchAd() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final adService = AdService();
    setState(() => _isLoading = true);

    try {
      final rewardEarned = await adService.showRewardedAd();

      if (rewardEarned) {
        final rewardsService = ref.read(diamondRewardsServiceProvider);
        final result = await rewardsService.claimAdReward(
          user.uid,
          'ad_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (mounted) {
          if (result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '🎬 Earned ${result.amount} diamonds! (${result.remaining} ads left today)'),
                backgroundColor: Colors.green,
              ),
            );
            _loadStatus();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.reason ?? 'Failed to claim reward'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad failed to load or was cancelled')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claimWeeklyBonus() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final rewardsService = ref.read(diamondRewardsServiceProvider);
      final result = await rewardsService.claimWeeklyBonus(user.uid);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Claimed ${result.amount} weekly diamonds!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.reason ?? 'Not available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn Diamonds'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.diamond), text: 'Standard'),
            Tab(icon: Icon(Icons.people), text: 'Social'),
          ],
        ),
      ),
      body: _isLoading && _status == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStandardTab(colorScheme, theme),
                _buildSocialTab(colorScheme, theme),
              ],
            ),
    );
  }

  Widget _buildStandardTab(ColorScheme colorScheme, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadStatus,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card with disclaimer
          const LegalDisclaimerBanner(type: DisclaimerType.wallet),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '💎 FREE DIAMONDS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earn up to ${DiamondConfig.maxDailyFreeEarnings}💎 daily!',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TEST MODE - Dev only (grants diamonds for testing)
          if (kDebugMode)
            Card(
              color: Colors.red.shade100,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bug_report, color: Colors.red),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🧪 TEST MODE',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Text(
                            'Grant 10,000 test diamonds',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        final user = ref.read(authServiceProvider).currentUser;
                        if (user == null) return;
                        
                        setState(() => _isLoading = true);
                        try {
                          final diamondService = DiamondService();
                          await diamondService.grantTestDiamonds(user.uid);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Granted 10,000 test diamonds!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Grant'),
                    ),
                  ],
                ),
              ),
            ),

          // Daily Login
          _buildRewardCard(
            icon: Icons.calendar_today,
            title: 'Daily Login',
            subtitle: 'Claim once per day',
            amount: DiamondConfig.dailyLogin,
            isClaimed: _status?.dailyLoginClaimed ?? false,
            onClaim: _claimDailyLogin,
            isLoading: _isLoading,
          ),

          // Watch Ad
          _buildRewardCard(
            icon: Icons.play_circle_outline,
            title: 'Watch Ad',
            subtitle:
                '${_status?.adsWatchedToday ?? 0}/${DiamondConfig.maxAdsPerDay} today',
            amount: DiamondConfig.perAdWatch,
            isClaimed: (_status?.adsRemaining ?? 0) <= 0,
            onClaim: _watchAd,
            isLoading: _isLoading,
            progress:
                (_status?.adsWatchedToday ?? 0) / DiamondConfig.maxAdsPerDay,
          ),

          // Games Completed
          _buildRewardCard(
            icon: Icons.games,
            title: 'Play Games',
            subtitle:
                '${_status?.gamesCompletedToday ?? 0}/${DiamondConfig.maxGamesPerDay} today',
            amount: DiamondConfig.perGameComplete,
            isClaimed: false,
            isPlayGames: true,
            progress: (_status?.gamesCompletedToday ?? 0) /
                DiamondConfig.maxGamesPerDay,
          ),

          // Referral
          _buildRewardCard(
            icon: Icons.people,
            title: 'Invite Friends',
            subtitle: 'Share your invite code',
            amount: DiamondConfig.referralBonus,
            isClaimed: false,
            isReferral: true,
          ),

          // Weekly Bonus
          _buildRewardCard(
            icon: Icons.star,
            title: 'Weekly Bonus',
            subtitle: _status?.isSunday == true
                ? 'Available now!'
                : 'Available on Sundays',
            amount: DiamondConfig.weeklyBonus,
            isClaimed: _status?.weeklyBonusClaimed ?? false,
            onClaim:
                _status?.canClaimWeeklyBonus == true ? _claimWeeklyBonus : null,
            isLoading: _isLoading,
          ),

          // Win Streak
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildSocialTab(ColorScheme colorScheme, ThemeData theme) {
    final socialStatus = _socialStatus;

    return RefreshIndicator(
      onRefresh: _loadStatus,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Social Header
          Card(
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '🎤 SOCIAL REWARDS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Earn ${SocialDiamondRewards.voiceRoomHostingDailyCap + SocialDiamondRewards.storyViewsDailyCap + SocialDiamondRewards.gameInvitesDailyCap}💎+ daily through social activities!',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Today's Social Earnings
          if (socialStatus != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Social Earnings",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildProgressRow(
                      '🎤 Voice Rooms',
                      socialStatus.voiceRoomEarned,
                      SocialDiamondRewards.voiceRoomHostingDailyCap,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressRow(
                      '📸 Story Views',
                      socialStatus.storyViewsEarned,
                      SocialDiamondRewards.storyViewsDailyCap,
                    ),
                    const SizedBox(height: 8),
                    _buildProgressRow(
                      '🎮 Game Invites',
                      socialStatus.gameInvitesEarned,
                      SocialDiamondRewards.gameInvitesDailyCap,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Social Activities
          _buildSocialActivityCard(
            icon: Icons.mic,
            title: 'Host Voice Room',
            subtitle: 'Host for 10+ minutes',
            amounts: {
              '10 min': SocialDiamondRewards.hostVoiceRoom10Minutes,
              '30 min': SocialDiamondRewards.hostVoiceRoom30Minutes,
            },
            color: Colors.purple,
          ),

          _buildSocialActivityCard(
            icon: Icons.camera_alt,
            title: 'Post Stories',
            subtitle: 'Get views on your stories',
            amounts: {
              'First Story': SocialDiamondRewards.firstStoryPosted,
              '50 Views': SocialDiamondRewards.storyReached50Views,
              '100 Views': SocialDiamondRewards.storyReached100Views,
            },
            color: Colors.pink,
          ),

          _buildSocialActivityCard(
            icon: Icons.send,
            title: 'Invite Friends to Games',
            subtitle: 'Earn when they join',
            amounts: {
              'Per Join': SocialDiamondRewards.gameInviteAccepted,
              '5 Players': SocialDiamondRewards.gameInvite5Players,
            },
            color: Colors.blue,
          ),

          const SizedBox(height: 16),

          // Engagement Tiers
          _buildEngagementTierCard(theme),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int earned, int cap) {
    final progress = earned / cap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$earned/$cap 💎',
              style: TextStyle(
                color: earned >= cap ? Colors.green : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            earned >= cap ? Colors.green : Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Map<String, int> amounts,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amounts.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key}: +${entry.value}💎'),
                  backgroundColor: color.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementTierCard(ThemeData theme) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Weekly Engagement Tiers',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...EngagementTierConfig.weeklyTiers.entries.map((entry) {
              final tier = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(tier.badge, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${tier.gamesRequired}+ games, ${tier.daysRequired}+ days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${tier.reward}💎',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int amount,
    required bool isClaimed,
    VoidCallback? onClaim,
    bool isLoading = false,
    bool isPlayGames = false,
    bool isReferral = false,
    double? progress,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isClaimed ? Colors.grey.shade300 : Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isClaimed ? Colors.grey : Colors.amber.shade800,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+$amount 💎',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (isPlayGames)
                  const Text('Auto', style: TextStyle(color: Colors.grey))
                else if (isReferral)
                  TextButton.icon(
                    onPressed: () async {
                      final user = ref.read(authServiceProvider).currentUser;
                      if (user != null) {
                        await ShareService.shareReferralCode(
                          user.uid.substring(0, 8).toUpperCase(),
                          context: context,
                        );
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  )
                else if (isClaimed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Claimed',
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                else if (onClaim != null)
                  ElevatedButton(
                    onPressed: isLoading ? null : onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Claim'),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Locked',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_fire_department,
                      color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Win Streak 🔥',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Win consecutive games for bonus!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Streak milestones
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DiamondConfig.streakRewards.entries.map((entry) {
                return Chip(
                  avatar: Text('${entry.key}🏆'),
                  label: Text('+${entry.value}💎'),
                  backgroundColor: Colors.amber.shade50,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}


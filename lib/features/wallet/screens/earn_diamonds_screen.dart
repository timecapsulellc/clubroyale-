import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/config/diamond_config.dart';
import 'package:taasclub/features/auth/auth_service.dart';
import 'package:taasclub/features/wallet/diamond_rewards_service.dart';
import 'package:taasclub/core/services/ad_service.dart';

/// Screen for earning free diamonds
class EarnDiamondsScreen extends ConsumerStatefulWidget {
  const EarnDiamondsScreen({super.key});

  @override
  ConsumerState<EarnDiamondsScreen> createState() => _EarnDiamondsScreenState();
}

class _EarnDiamondsScreenState extends ConsumerState<EarnDiamondsScreen> {
  bool _isLoading = false;
  DailyRewardStatus? _status;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final rewardsService = ref.read(diamondRewardsServiceProvider);
      final status = await rewardsService.getDailyStatus(user.uid);
      setState(() => _status = status);
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

    final adService = ref.read(adServiceProvider);
    
    // Show loading indicator or toast if needed
    setState(() => _isLoading = true);
    
    try {
      final rewardEarned = await adService.showRewardedAd();
      
      if (rewardEarned) {
        // Grant reward via backend
        final rewardsService = ref.read(diamondRewardsServiceProvider);
        final result = await rewardsService.claimAdReward(user.uid);
        
        if (mounted) {
          if (result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎬 Earned ${result.amount} diamonds! (${result.remaining} ads left today)'),
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
  void initState() {
    super.initState();
    // Initialize ads when screen loads (if not already done)
    ref.read(adServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn Diamonds'),
        centerTitle: true,
      ),
      body: _isLoading && _status == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatus,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header card
                  Card(
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            '💎 FREE DIAMONDS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                    subtitle: '${_status?.adsWatchedToday ?? 0}/${DiamondConfig.maxAdsPerDay} today',
                    amount: DiamondConfig.perAdWatch,
                    isClaimed: (_status?.adsRemaining ?? 0) <= 0,
                    onClaim: _watchAd,
                    isLoading: _isLoading,
                    progress: (_status?.adsWatchedToday ?? 0) / DiamondConfig.maxAdsPerDay,
                  ),

                  // Games Completed
                  _buildRewardCard(
                    icon: Icons.games,
                    title: 'Play Games',
                    subtitle: '${_status?.gamesCompletedToday ?? 0}/${DiamondConfig.maxGamesPerDay} today',
                    amount: DiamondConfig.perGameComplete,
                    isClaimed: false,
                    isPlayGames: true,
                    progress: (_status?.gamesCompletedToday ?? 0) / DiamondConfig.maxGamesPerDay,
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
                    onClaim: _status?.canClaimWeeklyBonus == true ? _claimWeeklyBonus : null,
                    isLoading: _isLoading,
                  ),

                  // Win Streak
                  _buildStreakCard(),

                  const SizedBox(height: 24),

                  // Need more diamonds?
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.chat_bubble_outline, color: Colors.purple),
                      title: const Text('Need More Diamonds?'),
                      subtitle: const Text('Chat with admin to request'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to support chat
                      },
                    ),
                  ),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
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
                  TextButton(
                    onPressed: () {
                      // TODO: Share invite link
                    },
                    child: const Text('Share'),
                  )
                else if (isClaimed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  child: const Icon(Icons.local_fire_department, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Win Streak 🔥',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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

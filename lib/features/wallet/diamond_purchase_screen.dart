import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/config/diamond_config.dart';

/// Diamond Info Screen - ClubRoyale uses FREE diamonds only
/// 
/// Safe Harbor Model: No real money transactions
/// Diamonds are earned for FREE through:
/// - Welcome bonus (100💎)
/// - Daily login (10💎)
/// - Watching ads (20💎 x 6/day)
/// - Completing games (5💎 x 15/day)
/// - Referrals (50💎)
/// - Weekly bonus (100💎 on Sundays)
class DiamondPurchaseScreen extends ConsumerWidget {
  const DiamondPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Get Diamonds')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    final diamondService = ref.watch(diamondServiceProvider);
    final walletStream = diamondService.watchWallet(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Diamonds'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: walletStream,
        builder: (context, snapshot) {
          final currentBalance = snapshot.data?.balance ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current balance card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.diamond, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'Current Balance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currentBalance',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Diamonds',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // FREE APP Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        '100% FREE!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ClubRoyale is completely free!\nDiamonds cannot be purchased - earn them for FREE!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // How to Earn Diamonds
                Text(
                  '✨ Earn Diamonds FREE',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildEarnOption(
                  context,
                  icon: Icons.card_giftcard,
                  title: 'Welcome Bonus',
                  subtitle: 'One-time new user reward',
                  diamonds: DiamondConfig.signupBonus,
                  color: Colors.purple,
                ),
                _buildEarnOption(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Daily Login',
                  subtitle: 'Log in every day',
                  diamonds: DiamondConfig.dailyLogin,
                  color: Colors.blue,
                ),
                _buildEarnOption(
                  context,
                  icon: Icons.play_circle,
                  title: 'Watch Ads',
                  subtitle: 'Up to ${DiamondConfig.maxAdsPerDay} per day',
                  diamonds: DiamondConfig.perAdWatch,
                  color: Colors.orange,
                ),
                _buildEarnOption(
                  context,
                  icon: Icons.games,
                  title: 'Complete Games',
                  subtitle: 'Up to ${DiamondConfig.maxGamesPerDay} per day',
                  diamonds: DiamondConfig.perGameComplete,
                  color: Colors.green,
                ),
                _buildEarnOption(
                  context,
                  icon: Icons.people,
                  title: 'Refer Friends',
                  subtitle: 'Invite friends to join',
                  diamonds: DiamondConfig.referralBonus,
                  color: Colors.pink,
                ),
                _buildEarnOption(
                  context,
                  icon: Icons.weekend,
                  title: 'Weekly Bonus',
                  subtitle: 'Every Sunday',
                  diamonds: DiamondConfig.weeklyBonus,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 24),

                // Maximum earnings info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.diamond, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Max ${DiamondConfig.maxDailyFreeEarnings}💎/day',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '~${DiamondConfig.maxMonthlyFreeEarnings}💎/month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Go to Earn Screen button
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/earn-diamonds');
                  },
                  icon: const Icon(Icons.diamond),
                  label: const Text('Start Earning Now'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Safe Harbor notice
                Text(
                  '⚖️ Safe Harbor Model\nThis app is a score tracking utility only. '
                  'Diamonds have no real-world monetary value and cannot be purchased or redeemed for cash.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarnOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int diamonds,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
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
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '+$diamonds',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/features/wallet/services/user_tier_service.dart';
import 'package:clubroyale/features/wallet/models/user_tier.dart';
import 'package:clubroyale/core/services/ad_service.dart';
import 'package:clubroyale/features/wallet/diamond_rewards_service.dart';

import 'package:google_fonts/google_fonts.dart';

/// Diamond Info Screen - ClubRoyale Vault
///
/// Premium "Vault" aesthetic for managing FREE diamonds.
class DiamondPurchaseScreen extends ConsumerWidget {
  const DiamondPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
    // Note: retaining existing logic, just updating Scaffold/AppBar
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: CasinoColors.deepPurple,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'The Vault',
            style: GoogleFonts.oswald(
              color: CasinoColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text('Please sign in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final diamondService = ref.watch(diamondServiceProvider);
    final walletStream = diamondService.watchWallet(userId);

    return Scaffold(
      backgroundColor: CasinoColors.deepPurple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'The Vault',
          style: GoogleFonts.oswald(
            color: CasinoColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        iconTheme: const IconThemeData(color: CasinoColors.gold),
      ),
      body: ParticleBackground(
        primaryColor: CasinoColors.gold,
        secondaryColor: CasinoColors.richPurple,
        particleCount: 20,
        child: StreamBuilder(
          stream: walletStream,
          builder: (context, snapshot) {
            final currentBalance = snapshot.data?.balance ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                100,
                16,
                20,
              ), // Top padding for extended app bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current balance card
                  _buildBalanceCard(currentBalance).animate().fadeIn().scale(),

                  const SizedBox(height: 24),

                  // Tier Upgrade Card (if Basic)
                  Consumer(
                    builder: (context, ref, child) {
                      final tierAsync = ref.watch(currentUserTierProvider);
                      final tier = tierAsync.value;

                      // Only show upgrade if data is loaded and user is Basic
                      if (tier != UserTier.basic) return const SizedBox();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade900,
                              Colors.blue.shade700,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blueAccent.shade100,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.grey.shade900,
                                  title: const Text(
                                    'Upgrade to Verified?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Unlock P2P Transfers and higher daily limits for 100 Diamonds.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      child: const Text('Upgrade (100 💎)'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  await ref
                                      .read(diamondServiceProvider)
                                      .upgradeToVerified();
                                  if (context.mounted) {
                                    await SoundService.playRoundEnd(); // Level up sound
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '🎉 Congratulations! You are now Verified!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    final friendlyMessage =
                                        _getFriendlyErrorMessage(e.toString());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(friendlyMessage),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unlock P2P Transfers',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Get Verified Status • 100 💎',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().shimmer(
                        delay: 2.seconds,
                        duration: 2.seconds,
                      );
                    },
                  ),

                  // FREE APP Banner
                  _buildFreeBadge()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // How to Earn Diamonds
                  const Text(
                    '✨ Earn Diamonds FREE',
                    style: TextStyle(
                      color: CasinoColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildEarnOption(
                    context,
                    icon: Icons.card_giftcard,
                    title: 'Welcome Bonus',
                    subtitle: 'One-time new user reward',
                    diamonds: DiamondConfig.signupBonus,
                    color: CasinoColors.richPurple,
                    delay: 300,
                  ),
                  _buildEarnOption(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Daily Login',
                    subtitle: 'Log in every day',
                    diamonds: DiamondConfig.dailyLogin,
                    color: CasinoColors.gold,
                    delay: 400,
                  ),
                  _buildEarnOption(
                    context,
                    icon: Icons.play_circle,
                    title: 'Watch Ads',
                    subtitle: 'Up to ${DiamondConfig.maxAdsPerDay} per day',
                    diamonds: DiamondConfig.perAdWatch,
                    color: CasinoColors.neonPink,
                    delay: 500,
                    onTap: () => _handleWatchAd(context, ref, userId),
                  ),

                  // ... (other options)
                  _buildEarnOption(
                    context,
                    icon: Icons.games,
                    title: 'Complete Games',
                    subtitle: 'Up to ${DiamondConfig.maxGamesPerDay} per day',
                    diamonds: DiamondConfig.perGameComplete,
                    color: CasinoColors.feltGreen,
                    delay: 600,
                  ),

                  // ... (rest of build method)
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleWatchAd(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    // Show Loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading Ad...'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }

    try {
      adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');

          // Claim reward in backend
          final result = await ref
              .read(diamondRewardsServiceProvider)
              .claimAdReward(
                userId,
                'admob_reward_${DateTime.now().millisecondsSinceEpoch}',
              );

          if (context.mounted) {
            if (result.success) {
              SoundService.playWinSound(); // Winning sound!
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🎉 Attempted Claim: +${result.amount} Diamonds! (${result.remaining} ads remaining today)',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not claim reward: ${result.reason}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      debugPrint('Ad Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load ad. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBalanceCard(int balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CasinoColors.richPurple, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CasinoColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
              boxShadow: [
                BoxShadow(
                  color: CasinoColors.gold.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.diamond, size: 48, color: CasinoColors.gold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '$balance',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
              fontFamily: 'monospace',
            ),
          ),
          const Text(
            'Diamonds',
            style: TextStyle(color: CasinoColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '100% FREE',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Diamonds cannot be purchased. Earn them by playing!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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
    required int delay,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap();
        } else {
          SoundService.playCardSlide();
          // Default action
        }
      },
      child:
          Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CasinoColors.gold,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: CasinoColors.gold, blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '+',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$diamonds',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.diamond,
                            size: 12,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: delay))
              .slideX(begin: 0.1),
    );
  }

  /// Parse Firebase error codes and return user-friendly messages
  String _getFriendlyErrorMessage(String error) {
    // Common Firebase error patterns
    if (error.contains('failed-precondition')) {
      if (error.contains('Insufficient diamonds')) {
        return '💎 Not enough diamonds! You need 100 diamonds to upgrade.';
      }
      return 'Cannot complete this action right now. Please try again.';
    }
    if (error.contains('unauthenticated')) {
      return 'Please sign in to continue.';
    }
    if (error.contains('permission-denied')) {
      return 'You don\'t have permission for this action.';
    }
    if (error.contains('not-found')) {
      return 'Account data not found. Please try again.';
    }
    if (error.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    if (error.contains('network')) {
      return 'Network error. Check your connection and try again.';
    }
    // Generic fallback - extract just the message part
    final bracketMatch = RegExp(r'\](.*?)(?:\[|$)').firstMatch(error);
    if (bracketMatch != null) {
      return bracketMatch.group(1)?.trim() ??
          'Something went wrong. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

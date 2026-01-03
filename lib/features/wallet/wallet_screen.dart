import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:clubroyale/core/widgets/legal_disclaimer_widget.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';
import 'package:clubroyale/features/wallet/services/user_tier_service.dart';
import 'package:clubroyale/features/governance/governance_service.dart';
import 'package:clubroyale/features/wallet/models/user_tier.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        backgroundColor: CasinoColors.darkPurple,
        body: Center(
          child: Text(
            'Please log in to view wallet',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final diamondService = ref.watch(diamondServiceProvider);
    final userTierAsync = ref.watch(currentUserTierProvider);
    final governanceService = ref.watch(governanceServiceProvider);

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Royal Vault',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [CasinoColors.deepPurple, CasinoColors.darkPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DiamondWallet>(
            stream: diamondService.watchWallet(userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    ErrorHelper.getFriendlyMessage(snapshot.error),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: ContextualLoader(
                    message: 'Loading vault...',
                    icon: Icons.diamond,
                  ),
                );
              }

              final wallet = snapshot.data!;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Compliance disclaimer
                    const LegalDisclaimerBanner(type: DisclaimerType.wallet),
                    const SizedBox(height: 16),
                    // Balance Card
                    _buildPremiumBalanceCard(
                      context,
                      wallet,
                      userTierAsync.value ?? UserTier.basic,
                      governanceService,
                    ),

                    const SizedBox(height: 24),

                    // Daily Limits & Tier Stats
                    _buildDailyLimits(
                      context,
                      wallet,
                      userTierAsync.value ?? UserTier.basic,
                    ),

                    const SizedBox(height: 32),

                    // Main Actions
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.add_card,
                            label: 'Purchase',
                            gradient: const LinearGradient(
                              colors: [ClubRoyaleTheme.gold, Colors.orange],
                            ),
                            onTap: () => context.push('/diamond-store'),
                            textColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.emoji_events,
                            label: 'Rewards',
                            gradient: LinearGradient(
                              colors: [
                                Colors.purpleAccent.shade400,
                                Colors.purple,
                              ],
                            ),
                            onTap: () => context.push('/earn-diamonds'),
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.swap_horiz,
                            label: 'Transfer',
                            gradient:
                                (userTierAsync.value?.canTransfer ?? false)
                                ? LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade700,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade700,
                                      Colors.grey.shade800,
                                    ],
                                  ),
                            onTap: (userTierAsync.value?.canTransfer ?? false)
                                ? () => context.push('/transfer')
                                : () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Transfers require Verified Tier or higher!',
                                      ),
                                    ),
                                  ),
                            textColor: Colors.white,
                            isLocked:
                                !(userTierAsync.value?.canTransfer ?? false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.support_agent,
                            label: 'Support',
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade700,
                                Colors.grey.shade900,
                              ],
                            ),
                            onTap: () {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Support chat coming soon'),
                                ),
                              ); // context.push('/support'),
                            },
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Transaction History Header
                    const Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: ClubRoyaleTheme.gold,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Ledger History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Transaction List
                    FutureBuilder<List<DiamondTransaction>>(
                      future: diamondService.getTransactionHistory(userId),
                      builder: (context, historySnapshot) {
                        if (historySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                              ),
                            ),
                          );
                        }

                        final transactions = historySnapshot.data ?? [];

                        if (transactions.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'The ledger is empty.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (c, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _TransactionTile(tx: transactions[index]);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDailyLimits(
    BuildContext context,
    DiamondWallet wallet,
    UserTier tier,
  ) {
    // Limits
    final transferLimit = tier.dailyTransferLimit;
    final earnLimit = tier.dailyEarningCap;

    // Usage
    final transferred = wallet.dailyTransferred;
    final earned = wallet.dailyEarned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Limits',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (transferLimit > 0 || transferLimit == -1) ...[
            _buildLimitBar(
              'Transfers',
              transferred,
              transferLimit,
              Colors.blueAccent,
            ),
            const SizedBox(height: 8),
          ],

          if (earnLimit > 0 || earnLimit == -1)
            _buildLimitBar(
              'Free Earnings',
              earned,
              earnLimit,
              Colors.greenAccent,
            ),

          if (transferLimit == 0 && earnLimit == 0)
            const Text(
              'Upgrade tier to increase limits',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitBar(String label, int current, int max, Color color) {
    double progress = 0.0;
    String statusText = '';

    if (max == -1) {
      progress = 0.5; // Just show half bar for unlimited
      statusText = '$current / ∞';
    } else if (max > 0) {
      progress = (current / max).clamp(0.0, 1.0);
      statusText = '$current / $max';
    } else {
      statusText = 'Disabled';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: max == -1
              ? null
              : progress, // null for indeterminate if unlimited? No, better show solid line or custom
          backgroundColor: Colors.white10,
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildPremiumBalanceCard(
    BuildContext context,
    DiamondWallet wallet,
    UserTier tier,
    GovernanceService govService,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [ClubRoyaleTheme.royalPurple, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: ClubRoyaleTheme.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: ClubRoyaleTheme.gold.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background shine
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.diamond_outlined,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [ClubRoyaleTheme.gold, Colors.orange],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tier.color.withValues(alpha: 0.2),
                      border: Border.all(color: tier.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tier.displayName.toUpperCase(),
                      style: TextStyle(
                        color: tier.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${wallet.balance}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'diamonds',
                    style: TextStyle(
                      color: ClubRoyaleTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),

              // Voting Power
              FutureBuilder<double>(
                future: govService.getVotingPower(wallet.userId),
                builder: (context, snapshot) {
                  return Row(
                    children: [
                      Icon(
                        Icons.how_to_vote,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Voting Power: ${snapshot.data?.toStringAsFixed(0) ?? "..."}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final Color textColor;
  final bool isLocked;

  const _PremiumActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    required this.textColor,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLocked)
              const Icon(Icons.lock, color: Colors.white54, size: 24)
            else
              Icon(icon, color: textColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final DiamondTransaction tx;

  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.amount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.greenAccent : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? (isCredit ? 'Deposit' : 'Payment'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd().add_jm().format(tx.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : ''}${tx.amount}',
            style: TextStyle(
              color: isCredit ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

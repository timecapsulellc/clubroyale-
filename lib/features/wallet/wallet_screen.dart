import 'package:flutter/material.dart';
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/wallet/diamond_rewards_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;
    
    if (userId == null) {
      return const Scaffold(
        backgroundColor: CasinoColors.darkPurple,
        body: Center(child: Text('Please log in to view wallet', style: TextStyle(color: Colors.white))),
      );
    }

    final diamondService = ref.watch(diamondServiceProvider);
    
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
                 return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: ClubRoyaleTheme.gold));
              }

              final wallet = snapshot.data!;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Balance Card
                    _buildPremiumBalanceCard(context, wallet),
                    
                    const SizedBox(height: 32),
                    
                    // Main Actions
                    Row(
                      children: [
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.add_card,
                            label: 'Purchase',
                            gradient: const LinearGradient(colors: [ClubRoyaleTheme.gold, Colors.orange]),
                            onTap: () => context.push('/diamond-store'),
                            textColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.emoji_events,
                            label: 'Rewards',
                            gradient: LinearGradient(colors: [Colors.purpleAccent.shade400, Colors.purple]),
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
                            label: 'Transfer', // Renamed from Withdraw as Withdraw is N/A
                            gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
                            onTap: () => context.push('/transfer'),
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.support_agent,
                            label: 'Support',
                            gradient: LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade900]),
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support chat coming soon'))), // context.push('/support'),
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Transaction History Header
                    const Row(
                      children: [
                        Icon(Icons.history, color: ClubRoyaleTheme.gold, size: 24),
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
                        if (historySnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: Colors.white54),
                          ));
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
                                Icon(Icons.receipt_long, size: 48, color: Colors.white.withValues(alpha: 0.3)),
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
                          separatorBuilder: (c, i) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                             return _TransactionTile(tx: transactions[index]);
                          },
                        );
                      }
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

  Widget _buildPremiumBalanceCard(BuildContext context, DiamondWallet wallet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
           colors: [
             ClubRoyaleTheme.royalPurple,
             Colors.black87,
           ],
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
            child: Icon(Icons.diamond_outlined, size: 150, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [ClubRoyaleTheme.gold, Colors.orange]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.black, size: 20),
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
                      shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))],
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

  const _PremiumActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    required this.textColor,
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

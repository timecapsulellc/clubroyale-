// Diamond Store - Compliant Entertainment Token Acquisition
//
// NO prices shown in-app. All transactions via admin channels.
// Diamonds are entertainment tokens with no cash value.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';
import 'package:clubroyale/core/widgets/legal_disclaimer_widget.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/wallet/screens/contact_admin_screen.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Diamond Store Screen - Compliant version
/// No prices, no in-app purchases, contact admin only
class DiamondStoreScreen extends ConsumerWidget {
  const DiamondStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final diamondService = ref.watch(diamondServiceProvider);

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      appBar: AppBar(
        title: const Text('Diamond Store'),
        centerTitle: true,
        backgroundColor: CasinoColors.deepPurple,
        actions: [
          // Current balance
          StreamBuilder<DiamondWallet>(
            stream: diamondService.watchWallet(currentUser.uid),
            builder: (context, snapshot) {
              final balance = snapshot.data?.balance ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CasinoColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CasinoColors.gold),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.diamond,
                      size: 18,
                      color: CasinoColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Compliance disclaimer banner
          const LegalDisclaimerBanner(type: DisclaimerType.store),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // What are diamonds?
                  _buildInfoCard(context),

                  const SizedBox(height: 24),

                  // Ways to get diamonds
                  const Text(
                    'Ways to Get Diamonds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Free methods first
                  _buildMethodCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Daily Login',
                    description: 'Earn free diamonds every day',
                    buttonText: 'Claim Now',
                    onTap: () => context.push('/earn-diamonds'),
                    isPrimary: true,
                  ),

                  _buildMethodCard(
                    context,
                    icon: Icons.people,
                    title: 'Refer Friends',
                    description: 'Earn diamonds when friends join',
                    buttonText: 'Invite',
                    onTap: () => context.push('/referral'),
                  ),

                  _buildMethodCard(
                    context,
                    icon: Icons.emoji_events,
                    title: 'Tournaments',
                    description: 'Win diamonds in competitions',
                    buttonText: 'View',
                    onTap: () => context.push('/tournaments'),
                  ),

                  const SizedBox(height: 24),

                  // Contact admin option (no prices!)
                  _buildContactAdminCard(context),

                  const SizedBox(height: 24),

                  // Disclaimer
                  DisclaimerText(text: Disclaimers.diamondsDisclaimer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CasinoColors.deepPurple,
            CasinoColors.richPurple.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.diamond, size: 48, color: CasinoColors.gold),
          const SizedBox(height: 16),
          const Text(
            'What are Diamonds?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Diamonds are virtual entertainment tokens used within ClubRoyale. '
            'Use them to create private rooms, join tournaments, and unlock features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUsageChip(Icons.meeting_room, 'Rooms'),
              const SizedBox(width: 12),
              _buildUsageChip(Icons.emoji_events, 'Tourneys'),
              const SizedBox(width: 12),
              _buildUsageChip(Icons.star, 'Features'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CasinoColors.gold),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? CasinoColors.gold.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? CasinoColors.gold : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary
                  ? CasinoColors.gold.withValues(alpha: 0.3)
                  : Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isPrimary ? CasinoColors.gold : Colors.white70,
            ),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? CasinoColors.gold : Colors.white24,
              foregroundColor: isPrimary ? Colors.black : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAdminCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade800, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Need More Diamonds?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact our admin team for acquisition options',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactAdminScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.amber.shade800,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Contact Admin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

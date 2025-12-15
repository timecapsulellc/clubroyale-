// Diamond Rewards Screen
//
// UI to earn FREE diamonds through:
// - Daily login bonus
// - Referral program
// - Watching optional ads
// - Game completion tracking
//
// NO PURCHASES - Diamonds are free!

// Diamond Rewards Screen
//
// UI to earn FREE diamonds through:
// - Daily login bonus
// - Referral program
// - Watching optional ads
// - Game completion tracking
//
// NO PURCHASES - Diamonds are free!

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/store/diamond_service.dart';
import 'package:clubroyale/core/constants/disclaimers.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Earn Diamonds Screen
class DiamondRewardsScreen extends StatefulWidget {
  final String userId;

  const DiamondRewardsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DiamondRewardsScreen> createState() => _DiamondRewardsScreenState();
}

class _DiamondRewardsScreenState extends State<DiamondRewardsScreen> {
  final DiamondService _diamondService = DiamondService();
  bool _dailyLoginAvailable = false;
  bool _claimingDaily = false;

  @override
  void initState() {
    super.initState();
    _checkDailyLogin();
  }

  Future<void> _checkDailyLogin() async {
    final available = await _diamondService.isDailyLoginAvailable(widget.userId);
    setState(() => _dailyLoginAvailable = available);
  }

  Future<void> _claimDailyLogin() async {
    setState(() => _claimingDaily = true);
    
    final success = await _diamondService.claimDailyLogin(widget.userId);
    
    setState(() {
      _claimingDaily = false;
      _dailyLoginAvailable = !success;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? '🎉 +${DiamondRewards.dailyLogin} Diamonds, Your Highness!'
              : 'Already claimed today!'),
          backgroundColor: success ? ClubRoyaleTheme.gold : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Royal Treasury', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          // Current balance
          StreamBuilder<int>(
            stream: _diamondService.watchBalance(widget.userId),
            builder: (context, snapshot) {
              final balance = snapshot.data ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [ClubRoyaleTheme.gold, Colors.orangeAccent]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: ClubRoyaleTheme.gold.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/diamond_3d.png', width: 20, height: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CasinoColors.deepPurple, CasinoColors.darkPurple],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Free disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: ClubRoyaleTheme.champagne.withValues(alpha: 0.8)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          Disclaimers.diamondsDisclaimer,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // How to earn section
                _SectionHeader(title: 'Earn Royal Rewards'),
                const SizedBox(height: 16),
                
                // Daily Login
                _RewardCard(
                  icon: Icons.calendar_today,
                  iconColor: Colors.blueAccent,
                  title: 'Daily Tribute',
                  description: 'Return daily for your allowance',
                  reward: DiamondRewards.dailyLogin,
                  isPremium: true,
                  action: _dailyLoginAvailable
                      ? ElevatedButton(
                          onPressed: _claimingDaily ? null : _claimDailyLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ClubRoyaleTheme.gold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _claimingDaily
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text('Claim'),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
                              SizedBox(width: 4),
                              Text('Claimed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                ).animate().slideX(duration: 300.ms),
                const SizedBox(height: 12),
                
                // Complete Games
                _RewardCard(
                  icon: Icons.emoji_events,
                  iconColor: ClubRoyaleTheme.gold,
                  title: 'Play & Win',
                  description: 'Complete games to earn rewards',
                  reward: DiamondRewards.gameComplete,
                  action: Text('Automatic', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic, fontSize: 12)),
                ).animate().slideX(duration: 300.ms, delay: 100.ms),
                const SizedBox(height: 12),
                
                // Referral
                _RewardCard(
                  icon: Icons.group_add,
                  iconColor: Colors.purpleAccent,
                  title: 'Invite Subjects',
                  description: 'Bring friends to your court',
                  reward: DiamondRewards.referralBonus,
                  action: IconButton(
                    onPressed: () => _showReferralDialog(context),
                    icon: const Icon(Icons.share, color: ClubRoyaleTheme.gold),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ).animate().slideX(duration: 300.ms, delay: 200.ms),
                const SizedBox(height: 12),
                
                // Weekly Bonus
                _RewardCard(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  title: 'Weekly Jackpot',
                  description: 'Sunday loyalist bonus',
                  reward: DiamondRewards.weeklyBonus,
                  action: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Image.asset('assets/images/vip_crown.png', width: 14, height: 14, color: Colors.amber),
                         const SizedBox(width: 4),
                         const Text('Sunday', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                       ],
                     )
                  ),
                ).animate().slideX(duration: 300.ms, delay: 300.ms),
                
                const SizedBox(height: 32),
                Divider(color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 16),

                // Spending info
                _SectionHeader(title: 'Spend Your Riches'),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      _SpendingInfo(
                        title: 'Create Private Room',
                        cost: DiamondRewards.createRoom,
                        icon: Icons.meeting_room,
                      ),
                      const SizedBox(height: 12),
                      _SpendingInfo(
                        title: 'Extend Room Time',
                        cost: DiamondRewards.extendRoom,
                        icon: Icons.timer,
                      ),
                      const SizedBox(height: 12),
                      _SpendingInfo(
                        title: 'Quick Rematch',
                        cost: DiamondRewards.rematch,
                        icon: Icons.replay,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReferralDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CasinoColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: ClubRoyaleTheme.gold)),
        title: const Row(
          children: [
            Icon(Icons.share, color: ClubRoyaleTheme.gold),
            SizedBox(width: 12),
            Text('Invite Friends', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share your invite link with friends. When they join and play, you both earn diamonds!',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'clubroyale.app/join?ref=${widget.userId.substring(0, 5)}...',
                      style: const TextStyle(fontFamily: 'monospace', color: ClubRoyaleTheme.gold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: ClubRoyaleTheme.gold, foregroundColor: Colors.black),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: ClubRoyaleTheme.gold),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final int reward;
  final Widget action;
  final bool isPremium;

  const _RewardCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.reward,
    required this.action,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPremium ? ClubRoyaleTheme.gold.withValues(alpha: 0.3) : Colors.white10),
        boxShadow: isPremium ? [BoxShadow(color: ClubRoyaleTheme.gold.withValues(alpha: 0.05), blurRadius: 10)] : [],
      ),
      padding: const EdgeInsets.all(16), // Replaces Card padding
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset('assets/images/diamond_3d.png', width: 16, height: 16),
                    const SizedBox(width: 6),
                    Text(
                      '+$reward',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

class _SpendingInfo extends StatelessWidget {
  final String title;
  final int cost;
  final IconData icon;

  const _SpendingInfo({
    required this.title,
    required this.cost,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white70))),
        Row(
          children: [
            Image.asset('assets/images/diamond_3d.png', width: 16, height: 16),
            const SizedBox(width: 6),
            Text(
              '$cost',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}

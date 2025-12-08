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
import 'package:taasclub/features/store/diamond_service.dart';
import 'package:taasclub/core/constants/disclaimers.dart';

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
              ? '🎉 +${DiamondRewards.dailyLogin} Diamonds!'
              : 'Already claimed today!'),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn Diamonds'),
        centerTitle: true,
        actions: [
          // Current balance
          StreamBuilder<int>(
            stream: _diamondService.watchBalance(widget.userId),
            builder: (context, snapshot) {
              final balance = snapshot.data ?? 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$balance',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Free disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Disclaimers.diamondsDisclaimer,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // How to earn section
            const Text(
              'How to Earn Diamonds',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Daily Login
            _RewardCard(
              icon: Icons.calendar_today,
              iconColor: Colors.blue,
              title: 'Daily Login',
              description: 'Log in every day to earn diamonds',
              reward: DiamondRewards.dailyLogin,
              action: _dailyLoginAvailable
                  ? FilledButton(
                      onPressed: _claimingDaily ? null : _claimDailyLogin,
                      child: _claimingDaily
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Claim'),
                    )
                  : const Chip(
                      label: Text('Claimed ✓'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(height: 12),
            
            // Complete Games
            _RewardCard(
              icon: Icons.emoji_events,
              iconColor: Colors.orange,
              title: 'Complete Games',
              description: 'Finish any game to earn diamonds',
              reward: DiamondRewards.gameComplete,
              action: const Chip(
                label: Text('Automatic'),
                backgroundColor: Colors.grey,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            
            // Referral
            _RewardCard(
              icon: Icons.people,
              iconColor: Colors.purple,
              title: 'Invite Friends',
              description: 'When a friend joins via your link',
              reward: DiamondRewards.referralBonus,
              action: OutlinedButton.icon(
                onPressed: () => _showReferralDialog(context),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(height: 12),
            
            // Weekly Bonus
            _RewardCard(
              icon: Icons.star,
              iconColor: Colors.amber,
              title: 'Weekly Bonus',
              description: 'Active players get bonus diamonds',
              reward: DiamondRewards.weeklyBonus,
              action: const Chip(
                label: Text('Every Sunday'),
                backgroundColor: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            
            // Spending info
            const Text(
              'How to Spend Diamonds',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _SpendingInfo(
              title: 'Create Room',
              cost: DiamondRewards.createRoom,
              icon: Icons.meeting_room,
            ),
            _SpendingInfo(
              title: 'Extend Room Time',
              cost: DiamondRewards.extendRoom,
              icon: Icons.timer,
            ),
            _SpendingInfo(
              title: 'Quick Rematch',
              cost: DiamondRewards.rematch,
              icon: Icons.replay,
            ),
          ],
        ),
      ),
    );
  }

  void _showReferralDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.purple),
            SizedBox(width: 12),
            Text('Invite Friends'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share your invite link with friends. When they join and play a game, you both get diamonds!',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://taasclub.app/join?ref=${widget.userId.substring(0, 8)}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard
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
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              // Share via WhatsApp
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
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

  const _RewardCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.reward,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
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
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.diamond, size: 14, color: Colors.cyan),
                      const SizedBox(width: 4),
                      Text(
                        '+$reward',
                        style: const TextStyle(
                          color: Colors.cyan,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Row(
            children: [
              const Icon(Icons.diamond, size: 14, color: Colors.cyan),
              const SizedBox(width: 4),
              Text(
                '$cost',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

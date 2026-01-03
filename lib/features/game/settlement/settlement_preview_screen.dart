/// Settlement Preview Screen
///
/// Displays final game scores and diamond transfers between players
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';

/// Settlement data model
class SettlementData {
  final String gameId;
  final String gameType;
  final List<PlayerResult> results;
  final DateTime endTime;

  SettlementData({
    required this.gameId,
    required this.gameType,
    required this.results,
    required this.endTime,
  });

  /// Total pot size
  int get totalPot => results.fold(0, (sum, r) => sum + r.entryFee.abs());

  /// Get winner
  PlayerResult? get winner => results.isNotEmpty
      ? results.reduce((a, b) => a.finalScore > b.finalScore ? a : b)
      : null;
}

/// Player result in a game
class PlayerResult {
  final String playerId;
  final String playerName;
  final String? avatarUrl;
  final int finalScore;
  final int entryFee;
  final int winnings;
  final int rank;

  PlayerResult({
    required this.playerId,
    required this.playerName,
    this.avatarUrl,
    required this.finalScore,
    required this.entryFee,
    required this.winnings,
    required this.rank,
  });

  /// Net result (positive = won, negative = lost)
  int get netResult => winnings - entryFee;

  bool get isWinner => rank == 1;
}

/// Settlement Preview Screen Widget
class SettlementPreviewScreen extends ConsumerStatefulWidget {
  final SettlementData? settlementData;
  final String? gameId;

  const SettlementPreviewScreen({super.key, this.settlementData, this.gameId});

  @override
  ConsumerState<SettlementPreviewScreen> createState() =>
      _SettlementPreviewScreenState();
}

class _SettlementPreviewScreenState
    extends ConsumerState<SettlementPreviewScreen> {
  bool _isProcessing = false;
  bool _isConfirmed = false;

  SettlementData get _demoData => SettlementData(
    gameId: widget.gameId ?? 'demo_game',
    gameType: 'Call Break',
    endTime: DateTime.now(),
    results: [
      PlayerResult(
        playerId: 'p1',
        playerName: 'You',
        finalScore: 45,
        entryFee: 100,
        winnings: 280,
        rank: 1,
      ),
      PlayerResult(
        playerId: 'p2',
        playerName: 'Player 2',
        finalScore: 32,
        entryFee: 100,
        winnings: 80,
        rank: 2,
      ),
      PlayerResult(
        playerId: 'p3',
        playerName: 'Player 3',
        finalScore: 18,
        entryFee: 100,
        winnings: 40,
        rank: 3,
      ),
      PlayerResult(
        playerId: 'p4',
        playerName: 'Player 4',
        finalScore: 5,
        entryFee: 100,
        winnings: 0,
        rank: 4,
      ),
    ],
  );

  SettlementData get settlementData => widget.settlementData ?? _demoData;

  Future<void> _confirmSettlement() async {
    setState(() => _isProcessing = true);

    try {
      final diamondService = ref.read(diamondServiceProvider);

      // Process each player's winnings
      for (final result in settlementData.results) {
        if (result.netResult != 0) {
          // In production, this would update Firestore
          // For now, just simulate the transfer
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      setState(() {
        _isProcessing = false;
        _isConfirmed = true;
      });

      // Show success and navigate after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go('/lobby');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing settlement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final winner = settlementData.winner;

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      appBar: AppBar(
        title: const Text('Game Results'),
        backgroundColor: CasinoColors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Winner announcement
              if (winner != null)
                _WinnerCard(
                  winner: winner,
                  gameType: settlementData.gameType,
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 24),

              // All players results
              Text(
                'Final Standings',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              ...settlementData.results.asMap().entries.map((entry) {
                final index = entry.key;
                final result = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlayerResultCard(result: result)
                      .animate()
                      .fadeIn(delay: (300 + index * 100).ms)
                      .slideX(begin: index.isEven ? -0.1 : 0.1),
                );
              }),

              const SizedBox(height: 24),

              // Settlement breakdown
              _SettlementBreakdown(
                data: settlementData,
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),

              // Confirm button
              if (!_isConfirmed)
                _ConfirmButton(
                  isProcessing: _isProcessing,
                  onPressed: _confirmSettlement,
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2)
              else
                _SuccessMessage().animate().fadeIn().scale(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Winner announcement card
class _WinnerCard extends StatelessWidget {
  final PlayerResult winner;
  final String gameType;

  const _WinnerCard({required this.winner, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CasinoColors.gold, CasinoColors.bronzeGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: CasinoColors.goldGlow,
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
              .shimmer(duration: 2.seconds),

          const SizedBox(height: 12),

          Text(
            'WINNER!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            winner.playerName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatBadge(label: 'Score', value: '${winner.finalScore}'),
              const SizedBox(width: 16),
              _StatBadge(
                label: 'Won',
                value: '+${winner.winnings}💎',
                isGold: true,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            gameType,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;

  const _StatBadge({
    required this.label,
    required this.value,
    this.isGold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isGold ? Colors.white : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isGold ? CasinoColors.gold : Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isGold ? Colors.grey : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Player result row
class _PlayerResultCard extends StatelessWidget {
  final PlayerResult result;

  const _PlayerResultCard({required this.result});

  Color get _rankColor {
    switch (result.rank) {
      case 1:
        return CasinoColors.gold;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey.shade600;
    }
  }

  String get _rankEmoji {
    switch (result.rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '${result.rank}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = result.netResult >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isWinner
            ? CasinoColors.gold.withValues(alpha: 0.15)
            : CasinoColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isWinner ? CasinoColors.gold : Colors.white12,
          width: result.isWinner ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _rankColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_rankEmoji, style: const TextStyle(fontSize: 20)),
            ),
          ),

          const SizedBox(width: 16),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.playerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: result.isWinner ? CasinoColors.gold : Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Score: ${result.finalScore}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Net result
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPositive ? '+${result.netResult}' : '${result.netResult}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('💎', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settlement breakdown showing transfers
class _SettlementBreakdown extends StatelessWidget {
  final SettlementData data;

  const _SettlementBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    final losers = data.results.where((r) => r.netResult < 0).toList();
    final winners = data.results.where((r) => r.netResult > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CasinoColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_horiz, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Settlement Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),

          // Show transfers
          ...losers.expand((loser) {
            return winners.where((w) => w.netResult > 0).map((winner) {
              // Calculate proportional transfer
              final totalWinnings = winners.fold(0, (s, w) => s + w.netResult);
              final transfer =
                  (loser.netResult.abs() * winner.netResult / totalWinnings)
                      .round();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loser.playerName,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white38,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$transfer 💎',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white38,
                      size: 16,
                    ),
                    Expanded(
                      child: Text(
                        winner.playerName,
                        style: const TextStyle(color: Colors.green),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            });
          }),

          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // Total pot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pot', style: TextStyle(color: Colors.white70)),
              Text(
                '${data.totalPot} 💎',
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Confirm button
class _ConfirmButton extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onPressed;

  const _ConfirmButton({required this.isProcessing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isProcessing ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CasinoColors.gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      child: isProcessing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 24),
                SizedBox(width: 12),
                Text(
                  'Confirm & Exit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}

/// Success message after confirmation
class _SuccessMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 48),
          SizedBox(height: 12),
          Text(
            'Settlement Complete!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Diamonds have been transferred.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

class PrizeDistributionCard extends StatelessWidget {
  final int prizePool;
  final int participantCount;

  const PrizeDistributionCard({
    super.key,
    required this.prizePool,
    required this.participantCount,
  });

  @override
  Widget build(BuildContext context) {
    // Simple distribution logic: 1st (50%), 2nd (30%), 3rd (20%)
    // Adjust based on participant count
    final first = (prizePool * 0.5).round();
    final second = (prizePool * 0.3).round();
    final third = (prizePool * 0.2).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: CasinoColors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Prize Pool Distribution',
                style: TextStyle(
                  color: CasinoColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PrizeRow(
            rank: 1,
            amount: first,
            color: const Color(0xFFFFD700), // Gold
            label: 'Winner',
          ),
          if (participantCount > 2) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Colors.white12),
            ),
            _PrizeRow(
              rank: 2,
              amount: second,
              color: const Color(0xFFC0C0C0), // Silver
              label: 'Runner-up',
            ),
          ],
          if (participantCount > 4) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Colors.white12),
            ),
            _PrizeRow(
              rank: 3,
              amount: third,
              color: const Color(0xFFCD7F32), // Bronze
              label: '3rd Place',
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _PrizeRow extends StatelessWidget {
  final int rank;
  final int amount;
  final Color color;
  final String label;

  const _PrizeRow({
    required this.rank,
    required this.amount,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Text(
            '$rank',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.diamond, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              '$amount',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

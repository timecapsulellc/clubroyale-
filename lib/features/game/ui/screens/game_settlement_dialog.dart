import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

/// Game Settlement Dialog
///
/// A polished overlay shown at the end of a round/game:
/// - Winner announcement with animation
/// - Score breakdown
/// - Maal distribution
/// - "Share to Story" CTA
class GameSettlementDialog extends StatelessWidget {
  final String winnerName;
  final int winAmount;
  final Map<String, int> scores;
  final bool isWinner;
  final VoidCallback onNextRound;
  final VoidCallback onExit;

  const GameSettlementDialog({
    super.key,
    required this.winnerName,
    required this.winAmount,
    required this.scores,
    required this.isWinner,
    required this.onNextRound,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B4D3E), // Dark Green
              const Color(0xFF051A12), // Deep Forest
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Result Header
            _buildResultHeader().animate().scale(
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),

            const SizedBox(height: 24),

            // 2. Winner Amount
            Text(
              isWinner ? '+$winAmount 💎' : '$winAmount 💎',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isWinner ? const Color(0xFFD4AF37) : Colors.redAccent,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 32),

            // 3. Score Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: scores.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key, // Player Name
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${entry.value > 0 ? '+' : ''}${entry.value}',
                          style: TextStyle(
                            color: entry.value > 0
                                ? Colors.greenAccent
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // 4. Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExit,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('LEAVE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNextRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('NEXT ROUND'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 5. Share Button
            TextButton.icon(
              onPressed: () {
                Share.share(
                  'I just won $winAmount 💎 in ClubRoyale Marriage! Can you beat me? #ClubRoyale #MarriageCardGame',
                );
              },
              icon: const Icon(Icons.share, size: 16, color: Colors.white54),
              label: const Text(
                'Share Victory',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        Icon(
          isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
          size: 64,
          color: isWinner ? const Color(0xFFD4AF37) : Colors.white38,
        ),
        const SizedBox(height: 16),
        Text(
          isWinner ? 'VICTORY!' : 'ROUND OVER',
          style: const TextStyle(
            fontFamily: 'Oswald',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        if (isWinner)
          const Text(
            'Spectacular Win!',
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }
}

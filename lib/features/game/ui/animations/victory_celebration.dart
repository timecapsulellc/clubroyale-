import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/services/haptic_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';

/// Victory celebration overlay with confetti, trophy, and score breakdown
class VictoryCelebration extends StatefulWidget {
  final String winnerName;
  final int winnerScore;
  final List<PlayerScore> scores;
  final bool isMe;
  final VoidCallback? onDismiss;

  const VictoryCelebration({
    super.key,
    required this.winnerName,
    required this.winnerScore,
    required this.scores,
    this.isMe = false,
    this.onDismiss,
  });

  @override
  State<VictoryCelebration> createState() => _VictoryCelebrationState();
}

class _VictoryCelebrationState extends State<VictoryCelebration> {
  @override
  void initState() {
    super.initState();
    if (widget.isMe) {
      HapticService.victory();
      SoundService.playRoundEnd();
    } else {
      HapticService.defeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dark overlay
        GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),

        // Confetti (only for winner who is me)
        if (widget.isMe) const ConfettiOverlay(),

        // Main content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              _buildTrophy(),
              const SizedBox(height: 20),

              // Winner announcement
              _buildWinnerBanner(),
              const SizedBox(height: 24),

              // Score breakdown
              _buildScoreCard(),
              const SizedBox(height: 24),

              // Continue button
              _buildContinueButton(),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
        ),
      ],
    );
  }

  Widget _buildTrophy() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: widget.isMe
              ? [CasinoColors.gold, CasinoColors.bronzeGold]
              : [Colors.grey, Colors.grey[700]!],
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isMe ? CasinoColors.gold : Colors.grey)
                .withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(
        widget.isMe ? Icons.emoji_events : Icons.sentiment_dissatisfied,
        size: 50,
        color: Colors.white,
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 1000.ms,
        );
  }

  Widget _buildWinnerBanner() {
    return Column(
      children: [
        Text(
          widget.isMe ? '🎉 YOU WIN! 🎉' : 'Game Over',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: widget.isMe ? CasinoColors.gold : Colors.white,
            letterSpacing: 2,
          ),
        ),
        if (!widget.isMe)
          Text(
            '${widget.winnerName} Wins!',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'FINAL SCORES',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          ...widget.scores.asMap().entries.map((entry) {
            final index = entry.key;
            final score = entry.value;
            return _buildScoreRow(score, index)
                .animate(delay: (100 * index).ms)
                .fadeIn()
                .slideX(begin: -0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _buildScoreRow(PlayerScore score, int rank) {
    final isWinner = rank == 0;
    final isMe = score.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Rank
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWinner
                  ? CasinoColors.gold
                  : Colors.grey.withValues(alpha: 0.3),
            ),
            alignment: Alignment.center,
            child: Text(
              '${rank + 1}',
              style: TextStyle(
                color: isWinner ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              isMe ? 'You' : score.name,
              style: TextStyle(
                color: isMe ? Colors.blue[200] : Colors.white,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // Maal points
          if (score.maalPoints > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${score.maalPoints}M',
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Score
          Text(
            '${score.totalScore > 0 ? '+' : ''}${score.totalScore}',
            style: TextStyle(
              color: score.totalScore > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: widget.onDismiss,
      style: ElevatedButton.styleFrom(
        backgroundColor: CasinoColors.gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: const Text(
        'CONTINUE',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Player score data
class PlayerScore {
  final String name;
  final int maalPoints;
  final int totalScore;
  final bool isMe;
  final bool wasVisited;

  const PlayerScore({
    required this.name,
    required this.maalPoints,
    required this.totalScore,
    this.isMe = false,
    this.wasVisited = false,
  });
}

/// Confetti overlay for victory
class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Random = math.Random();
        return Stack(
          fit: StackFit.expand,
          children: List.generate(50, (index) {
            final startX = Random.nextDouble() * constraints.maxWidth;
            final delay = Random.nextInt(2000);
            final duration = 2000 + Random.nextInt(1500);
            final size = 8.0 + Random.nextDouble() * 8;
            final color = [
              CasinoColors.gold,
              Colors.pink,
              Colors.purple,
              Colors.blue,
              Colors.green,
              Colors.orange,
            ][index % 6];

            return Positioned(
              left: startX,
              top: -20,
              child: Container(
                width: size,
                height: size * 1.5,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
                  .animate(delay: Duration(milliseconds: delay))
                  .fadeIn(duration: 200.ms)
                  .slideY(
                    begin: 0,
                    end: (constraints.maxHeight + 40) / size,
                    duration: Duration(milliseconds: duration),
                    curve: Curves.linear,
                  )
                  .rotate(
                    begin: 0,
                    end: 2 + Random.nextDouble() * 2,
                    duration: Duration(milliseconds: duration),
                  )
                  .then()
                  .fadeOut(),
            );
          }),
        );
      },
    );
  }
}

/// Simple defeat overlay (less celebratory)
class DefeatOverlay extends StatelessWidget {
  final String winnerName;
  final int pointsLost;
  final VoidCallback? onDismiss;

  const DefeatOverlay({
    super.key,
    required this.winnerName,
    required this.pointsLost,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                size: 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '$winnerName Wins',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '-$pointsLost points',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tap to continue',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        ),
      ),
    );
  }
}

import 'package:clubroyale/core/design_system/animations/celebration_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:audioplayers/audioplayers.dart'; // Uncomment when audio is ready

/// Victory Celebration Overlay
/// Shows a premium victory animation sequence:
/// 1. Dark overlay fade in
/// 2. Confetti burst
/// 3. Trophy/Winner animation
/// 4. "You Won!" text with glow
class VictoryCelebration extends StatefulWidget {
  final VoidCallback? onDismiss;
  final int? score;
  final int? reward;
  final bool isWinner;

  const VictoryCelebration({
    super.key,
    this.onDismiss,
    this.score,
    this.reward,
    this.isWinner = true,
  });

  @override
  State<VictoryCelebration> createState() => _VictoryCelebrationState();
}

class _VictoryCelebrationState extends State<VictoryCelebration> {
  @override
  void initState() {
    super.initState();
    if (widget.isWinner) {
      _playVictorySound();
    }
  }

  void _playVictorySound() {
    // TODO: Integrate with AudioService
    // AudioService.play(GameSound.victory);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isWinner) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
            ).animate().fadeIn(duration: 500.ms),
          ),

          // 2. Confetti (Behind trophy)
          const Positioned.fill(
            child: ConfettiAnimation(repeat: true, play: true),
          ),

          // 3. Main Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy / Winner Animation
              const RiveWinnerTrophy(size: 250)
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0, 0),
                  )
                  .then()
                  .shimmer(duration: 1000.ms, delay: 500.ms),

              const SizedBox(height: 24),

              // Victory Text
              Text(
                    'VICTORY!',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        const BoxShadow(
                          color: Color(0xFFD4AF37),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .moveY(
                    begin: 20,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              if (widget.score != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Score: ${widget.score}',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ).animate().fadeIn(delay: 600.ms),
              ],

              if (widget.reward != null) ...[
                const SizedBox(height: 16),
                CoinCelebrationAnimation(
                  amount: widget.reward!,
                  size: 100,
                ).animate().fadeIn(delay: 800.ms).scale(),
              ],

              const SizedBox(height: 48),

              // Dismiss Button
              ElevatedButton(
                onPressed:
                    widget.onDismiss ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('CONTINUE'),
              ).animate().fadeIn(delay: 1500.ms),
            ],
          ),
        ],
      ),
    );
  }
}

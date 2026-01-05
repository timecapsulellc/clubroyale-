import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Marriage HUD Overlay
///
/// Enhances the game table with:
/// - Animated Turn Indicator
/// - Floating Maal Counter
/// - Quick Emote Selector
class MarriageHUDOverlay extends StatelessWidget {
  final String? currentPlayerId;
  final String myPlayerId;
  final int maalPoints;
  final VoidCallback onEmoteTap;

  const MarriageHUDOverlay({
    super.key,
    required this.currentPlayerId,
    required this.myPlayerId,
    required this.maalPoints,
    required this.onEmoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Turn Indicator (Center Table Notification - positioned higher)
        if (currentPlayerId == myPlayerId)
          Positioned(
            top:
                MediaQuery.of(context).size.height *
                0.28, // Higher position to avoid card overlap
            left: 0,
            right: 0,
            child: Center(
              child:
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.amber.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Text(
                          'YOUR TURN',
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            fontSize: 20, // Slightly smaller
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 300.ms)
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
            ),
          ),

        // 2. Enhanced Maal Counter (Bottom Left - Floating Badge)
        Positioned(
          bottom: 120, // Above hand area
          left: 16,
          child: _MaalCounterChip(points: maalPoints),
        ),

        // 3. Quick Emote Button (Left side, above Maal)
        Positioned(
          bottom: 190, 
          left: 16,
          child: FloatingActionButton.small(
            backgroundColor: Colors.black54,
            onPressed: onEmoteTap,
            child: const Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _MaalCounterChip extends StatelessWidget {
  final int points;

  const _MaalCounterChip({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: points > 0 ? Colors.amber : Colors.white24,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (points > 0 ? Colors.amber : Colors.black).withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'YOUR MAAL',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 8,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: points > 0 ? Colors.amber : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$points pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

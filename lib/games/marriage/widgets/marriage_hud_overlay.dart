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
            top: MediaQuery.of(context).size.height * 0.28, // Higher position to avoid card overlap
            left: 0, 
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.amber.withOpacity(0.6), Colors.transparent],
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
                      Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .fadeIn(duration: 300.ms)
               .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          
        // 2. Enhanced Maal Counter (Top Right, below status)
        Positioned(
          top: 70, // Below AppBar
          right: 16,
          child: _MaalCounterChip(points: maalPoints),
        ),
        
        // 3. Quick Emote Button (Left side to avoid hand overlap)
        Positioned(
          bottom: 250, // Higher to clear the action bar and hand
          left: 16, // Moved to left side
          child: FloatingActionButton.small(
            backgroundColor: Colors.black54,
            child: const Icon(Icons.emoji_emotions_outlined, color: Colors.white),
            onPressed: onEmoteTap,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: points > 0 ? Colors.amber : Colors.white24,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (points > 0 ? Colors.amber : Colors.black).withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: points > 0 ? Colors.amber : Colors.grey,
            size: 16,
          ).animate(target: points > 0 ? 1 : 0)
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 200.ms)
           .then().scale(end: const Offset(1, 1)),
          const SizedBox(width: 8),
          Text(
            '$points Maal',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Turn Timer Widget
/// 
/// A reusable circular countdown timer for all card games.
/// Shows remaining time with color-coded urgency levels.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A circular countdown timer widget for game turns
class TurnTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final bool showPulse;
  final double size;

  const TurnTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.showPulse = true,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final color = _getColor(progress);
    final isCritical = remainingSeconds <= 5 && remainingSeconds > 0;
    
    Widget timer = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: isCritical
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress
          SizedBox(
            width: size - 8,
            height: size - 8,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 4,
            ),
          ),
          // Timer text
          Text(
            '$remainingSeconds',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.36,
            ),
          ),
        ],
      ),
    );
    
    // Add pulse animation for critical time
    if (isCritical && showPulse) {
      timer = timer
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 500.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
            duration: 500.ms,
          );
    }
    
    return timer;
  }

  Color _getColor(double progress) {
    if (progress >= 0.5) return Colors.green;
    if (progress >= 0.2) return Colors.orange;
    return Colors.red;
  }
}

/// Compact inline timer for tight spaces
class TurnTimerBadge extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TurnTimerBadge({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final color = _getColor(progress);
    final isCritical = remainingSeconds <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: color.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${remainingSeconds}s',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate(
      onComplete: (controller) => isCritical ? controller.repeat() : null,
    ).shimmer(
      duration: isCritical ? 500.ms : 1000.ms,
      color: isCritical ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
    );
  }

  Color _getColor(double progress) {
    if (progress >= 0.5) return Colors.green;
    if (progress >= 0.2) return Colors.orange;
    return Colors.red;
  }
}

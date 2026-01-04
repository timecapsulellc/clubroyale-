import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/theme/app_theme.dart';
import 'package:clubroyale/features/game/ui/components/casino_button.dart';

/// State of the Visit button
enum VisitButtonState {
  /// Cannot visit yet (requirements not met)
  locked,

  /// Requirements met, ready to click
  ready,

  /// Already visited
  visited,
}

/// A dedicated button for the "Visit" action in Marriage game.
///
/// Shows status (e.g., "2/3 Sequences") and animates when ready.
class VisitButtonWidget extends StatelessWidget {
  final VisitButtonState state;
  final VoidCallback? onPressed;
  final String label;
  final String subLabel;
  final int pureSequenceCount; // For progress display
  final int dubleeCount; // For progress display

  const VisitButtonWidget({
    super.key,
    required this.state,
    this.onPressed,
    this.label = 'VISIT',
    this.subLabel = 'Unlock Maal',
    this.pureSequenceCount = 0,
    this.dubleeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case VisitButtonState.visited:
        return _buildVisitedState();
      case VisitButtonState.ready:
        return _buildReadyState();
      case VisitButtonState.locked:
        return _buildLockedState();
    }
  }

  Widget _buildLockedState() {
    // Determine which path is closer to completion
    final seqProgress = pureSequenceCount / 3; // Need 3 sequences
    final dubProgress = dubleeCount / 7; // Need 7 dublees

    String progressText;
    Color progressColor;

    if (seqProgress >= dubProgress) {
      progressText = '$pureSequenceCount/3 SEQ';
      progressColor = pureSequenceCount >= 2 ? Colors.orange : Colors.grey;
    } else {
      progressText = '$dubleeCount/7 DUB';
      progressColor = dubleeCount >= 5 ? Colors.orange : Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: progressColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              progressText,
              style: TextStyle(
                color: progressColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState() {
    return CasinoButton(
          label: label,
          onPressed: onPressed,
          backgroundColor: AppTheme.gold,
          borderColor: AppTheme.goldDark,
          textColor: Colors.black,
          icon: Icons.lock_open,
          isLarge: true, // Make it prominent
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5))
        .scaleXY(end: 1.05, duration: 1000.ms, curve: Curves.easeInOut);
  }

  Widget _buildVisitedState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VISITED',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const Text(
                'Maal Unlocked',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

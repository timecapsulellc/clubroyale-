import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/services/haptic_service.dart';

/// Turn timeout warning overlay
/// Shows a flashing warning when the player's turn is about to expire
class TurnTimeoutWarning extends StatefulWidget {
  final int remainingSeconds;
  final int warningThreshold; // Start warning at this time
  final int criticalThreshold; // Urgent warning at this time
  final VoidCallback? onTimeout;

  const TurnTimeoutWarning({
    super.key,
    required this.remainingSeconds,
    this.warningThreshold = 15,
    this.criticalThreshold = 5,
    this.onTimeout,
  });

  @override
  State<TurnTimeoutWarning> createState() => _TurnTimeoutWarningState();
}

class _TurnTimeoutWarningState extends State<TurnTimeoutWarning>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  bool _lastTickPlayed = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TurnTimeoutWarning oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Play tick sound and haptic at certain thresholds
    if (widget.remainingSeconds <= widget.criticalThreshold &&
        widget.remainingSeconds != oldWidget.remainingSeconds &&
        widget.remainingSeconds > 0) {
      _playTickFeedback();
    }

    // Timeout reached
    if (widget.remainingSeconds <= 0 && !_lastTickPlayed) {
      _lastTickPlayed = true;
      HapticService.victory();
      widget.onTimeout?.call();
    }
  }

  void _playTickFeedback() {
    HapticService.turnNotification();
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = widget.remainingSeconds <= widget.warningThreshold;
    final isCritical = widget.remainingSeconds <= widget.criticalThreshold;

    if (!isWarning) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _flashController,
          builder: (context, child) {
            final opacity = isCritical
                ? 0.3 + (_flashController.value * 0.4)
                : 0.1 + (_flashController.value * 0.2);

            return Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isCritical ? Colors.red : Colors.orange)
                        .withValues(alpha: opacity),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Compact turn timer badge
/// Shows remaining time with color-coded urgency
class TurnTimerBadge extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TurnTimerBadge({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 30,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / totalSeconds;
    final isWarning = remainingSeconds <= 15;
    final isCritical = remainingSeconds <= 5;

    final color = isCritical
        ? Colors.red
        : isWarning
            ? Colors.orange
            : CasinoColors.gold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress ring
          SizedBox(
            width: 20,
            height: 20,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: color,
                ),
                Center(
                  child: Icon(
                    Icons.timer,
                    size: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Time text
          Text(
            '${remainingSeconds}s',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        .animate(
          target: isCritical ? 1 : 0,
          onPlay: (c) => isCritical ? c.repeat(reverse: true) : null,
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 300.ms,
        );
  }
}

/// Full-screen timeout notification
/// Shown when auto-play triggers due to timeout
class TimeoutNotification extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const TimeoutNotification({
    super.key,
    this.message = 'Time expired! Auto-playing...',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_off,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red[900],
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn()
            .shake(hz: 3, duration: 500.ms),
      ),
    );
  }
}

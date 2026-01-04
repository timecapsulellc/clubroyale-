import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/services/sound_service.dart';

/// Enhanced Game Timer Widget with urgency feedback
class GameTimerWidget extends StatefulWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isMyTurn;

  const GameTimerWidget({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isMyTurn = false,
  });

  @override
  State<GameTimerWidget> createState() => _GameTimerWidgetState();
}

class _GameTimerWidgetState extends State<GameTimerWidget> {
  int _lastTickPlayed = -1;

  @override
  void didUpdateWidget(GameTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Play warning tick in final 5 seconds (only on player's turn)
    if (widget.isMyTurn &&
        widget.remainingSeconds <= 5 &&
        widget.remainingSeconds > 0 &&
        widget.remainingSeconds != _lastTickPlayed) {
      _lastTickPlayed = widget.remainingSeconds;
      SoundService.playCardSlide(); // Quick tick sound
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.remainingSeconds / widget.totalSeconds;

    // Urgency states
    final isWarning = progress < 0.5 && progress >= 0.2;
    final isCritical = progress < 0.2;

    Color color = Colors.green;
    if (isWarning) color = Colors.orange;
    if (isCritical) color = Colors.red;

    Widget timer = Container(
      width: isCritical ? 60 : 50,
      height: isCritical ? 60 : 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: isCritical ? 0.7 : 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: isCritical ? 0.9 : 0.5),
          width: isCritical ? 3 : 2,
        ),
        boxShadow: isCritical
            ? [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: isCritical ? 5 : 4,
          ),
          Text(
            '${widget.remainingSeconds}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isCritical ? 24 : 18,
            ),
          ),
        ],
      ),
    );

    // Add pulse animation for critical state
    if (isCritical && widget.isMyTurn) {
      timer = timer
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 400.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
            duration: 400.ms,
          );
    }

    return timer;
  }
}

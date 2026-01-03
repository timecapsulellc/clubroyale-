// Game Timer Widget with Color Transitions
//
// Timer that changes color as time runs out:
// - Green: > 50% time remaining
// - Yellow: 20-50% remaining
// - Red: < 20% remaining

import 'dart:async';
import 'package:flutter/material.dart';

/// Timer state for game turns
class GameTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isMyTurn;

  GameTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.isMyTurn = false,
  });

  double get progress => remainingSeconds / totalSeconds;

  TimerPhase get phase {
    if (progress > 0.5) return TimerPhase.safe;
    if (progress > 0.2) return TimerPhase.warning;
    return TimerPhase.danger;
  }

  Color get color {
    switch (phase) {
      case TimerPhase.safe:
        return Colors.green;
      case TimerPhase.warning:
        return Colors.orange;
      case TimerPhase.danger:
        return Colors.red;
    }
  }

  GameTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isMyTurn,
  }) {
    return GameTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isMyTurn: isMyTurn ?? this.isMyTurn,
    );
  }
}

enum TimerPhase { safe, warning, danger }

/// Timer controller using ChangeNotifier
class GameTimerController extends ChangeNotifier {
  Timer? _timer;
  final VoidCallback? onTimeUp;
  GameTimerState _state;

  GameTimerController({int totalSeconds = 30, this.onTimeUp})
    : _state = GameTimerState(
        totalSeconds: totalSeconds,
        remainingSeconds: totalSeconds,
      );

  GameTimerState get state => _state;

  /// Start the timer for a player's turn
  void startTurn({required bool isMyTurn, int? seconds}) {
    _timer?.cancel();

    final totalSecs = seconds ?? _state.totalSeconds;
    _state = GameTimerState(
      totalSeconds: totalSecs,
      remainingSeconds: totalSecs,
      isRunning: true,
      isMyTurn: isMyTurn,
    );
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.remainingSeconds > 0) {
        _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
        notifyListeners();
      } else {
        _timer?.cancel();
        _state = _state.copyWith(isRunning: false);
        notifyListeners();
        onTimeUp?.call();
      }
    });
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    _state = _state.copyWith(isRunning: false);
    notifyListeners();
  }

  /// Reset the timer
  void reset({int? seconds}) {
    _timer?.cancel();
    final totalSecs = seconds ?? _state.totalSeconds;
    _state = GameTimerState(
      totalSeconds: totalSecs,
      remainingSeconds: totalSecs,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Timer widget with color transitions
class GameTimerWidget extends StatelessWidget {
  final GameTimerController controller;
  final double size;
  final bool showSeconds;

  const GameTimerWidget({
    super.key,
    required this.controller,
    this.size = 60,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final timerState = controller.state;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: timerState.color.withValues(alpha: 0.2),
            border: Border.all(color: timerState.color, width: 3),
            boxShadow: timerState.phase == TimerPhase.danger
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
                  value: timerState.progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(timerState.color),
                ),
              ),
              // Seconds text
              if (showSeconds)
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    color: timerState.color,
                  ),
                  child: Text('${timerState.remainingSeconds}'),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Inline timer bar (alternative to circular)
class GameTimerBar extends StatelessWidget {
  final GameTimerController controller;
  final double height;

  const GameTimerBar({super.key, required this.controller, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final timerState = controller.state;

        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: timerState.progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: [
                    timerState.color,
                    timerState.color.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

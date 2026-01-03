/// Rate Limiter Utility
///
/// Provides rate limiting for game actions and wallet operations
/// to prevent abuse and spam.
library;

import 'dart:async';

/// Simple rate limiter that limits actions per time window
class RateLimiter {
  final int maxActions;
  final Duration window;
  final List<DateTime> _actions = [];

  RateLimiter({required this.maxActions, required this.window});

  /// Check if action is allowed and record it
  bool tryAction() {
    _cleanup();

    if (_actions.length >= maxActions) {
      return false;
    }

    _actions.add(DateTime.now());
    return true;
  }

  /// Check if action would be allowed (without recording)
  bool canAct() {
    _cleanup();
    return _actions.length < maxActions;
  }

  /// Get remaining actions in current window
  int get remainingActions {
    _cleanup();
    return maxActions - _actions.length;
  }

  /// Get time until next action is allowed
  Duration? get timeUntilNextAction {
    _cleanup();

    if (_actions.length < maxActions) {
      return Duration.zero;
    }

    final oldestAction = _actions.first;
    final expiresAt = oldestAction.add(window);
    final now = DateTime.now();

    if (expiresAt.isAfter(now)) {
      return expiresAt.difference(now);
    }

    return Duration.zero;
  }

  /// Remove expired actions
  void _cleanup() {
    final cutoff = DateTime.now().subtract(window);
    _actions.removeWhere((action) => action.isBefore(cutoff));
  }

  /// Reset the rate limiter
  void reset() {
    _actions.clear();
  }
}

/// Rate limiter with debounce for UI actions
class DebouncedAction {
  final Duration delay;
  Timer? _timer;

  DebouncedAction({this.delay = const Duration(milliseconds: 300)});

  /// Execute action after debounce delay
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttle for actions that should run at most once per interval
class Throttle {
  final Duration interval;
  DateTime? _lastRun;

  Throttle({required this.interval});

  /// Execute action if interval has passed
  bool call(void Function() action) {
    final now = DateTime.now();

    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
      return true;
    }

    return false;
  }

  /// Reset the throttle
  void reset() {
    _lastRun = null;
  }
}

/// Pre-configured rate limiters for common use cases
class GameRateLimiters {
  static final cardPlay = RateLimiter(
    maxActions: 5,
    window: const Duration(seconds: 1),
  );

  static final bid = RateLimiter(
    maxActions: 3,
    window: const Duration(seconds: 2),
  );

  static final chatMessage = RateLimiter(
    maxActions: 10,
    window: const Duration(seconds: 30),
  );

  static final walletTransfer = RateLimiter(
    maxActions: 3,
    window: const Duration(minutes: 1),
  );

  static final roomCreation = RateLimiter(
    maxActions: 2,
    window: const Duration(minutes: 5),
  );
}

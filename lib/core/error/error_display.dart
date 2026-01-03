// Error Resilience - Graceful error handling UI components
//
// These widgets provide beautiful, user-friendly error states
// with retry functionality and helpful messaging.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Generic error widget with retry capability
class ErrorDisplay extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? accentColor;

  const ErrorDisplay({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'We encountered an unexpected error. Please try again.',
    this.onRetry,
    this.icon = Icons.error_outline,
    this.accentColor,
  });

  /// Network error preset
  factory ErrorDisplay.network({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'No Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      accentColor: Colors.orangeAccent,
      onRetry: onRetry,
    );
  }

  /// Server error preset
  factory ErrorDisplay.server({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'Server Error',
      message: 'Our servers are having trouble. Please try again in a moment.',
      icon: Icons.cloud_off_rounded,
      accentColor: Colors.redAccent,
      onRetry: onRetry,
    );
  }

  /// Permission denied preset
  factory ErrorDisplay.permission({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'Access Denied',
      message: 'You don\'t have permission to access this content.',
      icon: Icons.lock_outline,
      accentColor: Colors.amber,
      onRetry: onRetry,
    );
  }

  /// Session expired preset
  factory ErrorDisplay.sessionExpired({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'Session Expired',
      message: 'Please log in again to continue.',
      icon: Icons.timer_off_outlined,
      accentColor: CasinoColors.gold,
      onRetry: onRetry,
    );
  }

  /// Game not found preset
  factory ErrorDisplay.gameNotFound({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'Game Not Found',
      message: 'This game room may have ended or been deleted.',
      icon: Icons.casino_outlined,
      accentColor: Colors.purpleAccent,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.redAccent;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated error icon
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(icon, size: 64, color: color),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 2.seconds,
                ),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              _RetryButton(onPressed: onRetry!, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const _RetryButton({required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Try Again',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}

/// Inline error message for forms
class InlineError extends StatelessWidget {
  final String message;
  final bool visible;

  const InlineError({super.key, required this.message, this.visible = true});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake(hz: 2, rotation: 0.01);
  }
}

/// Toast-style error notification
class ErrorToast {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _AnimatedToast(
            message: message,
            onDismiss: () => entry.remove(),
            duration: duration,
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _AnimatedToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Duration duration;

  const _AnimatedToast({
    required this.message,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onDismiss,
            child: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5);
  }
}

/// Success toast
class SuccessToast {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
  }
}

/// Error boundary widget - catches errors in subtree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  void _retry() {
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }
      return ErrorDisplay(message: _error.toString(), onRetry: _retry);
    }

    return widget.child;
  }
}

/// Loading with error state wrapper
class AsyncStateBuilder<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) builder;
  final Widget? loading;
  final Widget Function(Object error)? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncStateBuilder({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loading,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      if (errorBuilder != null) {
        return errorBuilder!(snapshot.error!);
      }
      return ErrorDisplay(message: snapshot.error.toString(), onRetry: onRetry);
    }

    if (!snapshot.hasData) {
      return loading ?? const Center(child: CircularProgressIndicator());
    }

    return builder(snapshot.data as T);
  }
}

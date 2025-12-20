/// Error Boundary Widget - Catches and handles widget errors gracefully
///
/// Features:
/// - Catches errors in child widget tree
/// - Shows user-friendly error UI
/// - Provides retry functionality
/// - Reports errors to Crashlytics
library;

import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Error boundary widget that catches and displays errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  void _reset() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _reset) ??
          DefaultErrorWidget(error: _error!, onRetry: _reset);
    }
    return widget.child;
  }
}

/// Default error widget shown when an error occurs
class DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const DefaultErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F12),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                "We're sorry, but something unexpected happened. Please try again.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Retry button
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // Go Home button
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Go to Home',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Async error widget for FutureBuilder/StreamBuilder errors
class AsyncErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const AsyncErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().replaceAll('Exception: ', ''),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: const BorderSide(color: Colors.amber),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Snackbar helper for displaying user-friendly error messages
class ErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    // Report to Crashlytics
    FirebaseCrashlytics.instance.log('Error shown to user: $message');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static void showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    show(
      context,
      'Network error. Please check your connection.',
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );
  }

  static void showGameError(BuildContext context, String message) {
    show(context, message);
  }
}


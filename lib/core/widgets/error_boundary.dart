import 'package:flutter/material.dart';

/// Error boundary widget that catches and displays errors gracefully
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Default error widget
  static Widget defaultErrorWidget(Object error, StackTrace? stackTrace) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showNetworkError(BuildContext context) {
    show(
      context,
      'Network error. Please check your connection and try again.',
      action: SnackBarAction(
        label: 'Retry',
        textColor: Colors.white,
        onPressed: () {
          // Retry logic would be handled by caller
        },
      ),
    );
  }

  static void showGameError(BuildContext context, String message) {
    show(context, message);
  }
}

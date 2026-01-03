// Error Boundary Widget
//
// Catches and handles widget errors gracefully.
// Prevents white screens and provides user-friendly error UI.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Error boundary that catches widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({super.key, required this.child, this.onError});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    // Capture Flutter framework errors
    FlutterError.onError = (details) {
      setState(() => _error = details);
      _reportError(details);
    };
  }

  void _reportError(FlutterErrorDetails details) {
    // Log to Crashlytics
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);

    // Also log to console in debug mode
    FlutterError.presentError(details);
  }

  void _retry() {
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.onError?.call(_error!) ??
          ErrorScreen(error: _error!, onRetry: _retry);
    }
    return widget.child;
  }
}

/// Default error screen with retry button
class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const ErrorScreen({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                'We encountered an unexpected error. Please try again.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Retry button
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Go home button
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Global error handler setup
class GlobalErrorHandler {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Catch async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Log non-fatal error
  static void logError(dynamic error, StackTrace? stack, {String? reason}) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason,
      fatal: false,
    );
  }

  /// Set user identifier for crash reports
  static void setUserId(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Log custom key-value for debugging
  static void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
  }

  /// Log breadcrumb message
  static void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }
}

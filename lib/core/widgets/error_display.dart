/// Standardized Error Display Widget
///
/// Use this widget for consistent error messaging across the app.
/// Features premium styling matching the casino theme.
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/core/animations/animation_presets.dart';

class ErrorDisplay extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData icon;
  final bool isFullScreen;

  const ErrorDisplay({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon = Icons.wifi_off_rounded,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Error Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(icon, size: 48, color: Colors.redAccent),
            ).animatePulse(),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animateEntrance(index: 1),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animateEntrance(index: 2),

            if (onRetry != null) ...[
              const SizedBox(height: 48),

              // Retry Button
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37), // Gold
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animateEntrance(index: 3).animatePress(),
            ],
          ],
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1F12), // Deep Green
        body: content,
      );
    }

    return content;
  }
}

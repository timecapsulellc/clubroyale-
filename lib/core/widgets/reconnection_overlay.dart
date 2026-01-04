import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Premium reconnection overlay shown during network disconnection
class ReconnectionOverlay extends StatefulWidget {
  final bool isConnected;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const ReconnectionOverlay({
    super.key,
    required this.isConnected,
    this.onRetry,
    this.errorMessage,
  });

  @override
  State<ReconnectionOverlay> createState() => _ReconnectionOverlayState();
}

class _ReconnectionOverlayState extends State<ReconnectionOverlay> {
  int _retryCount = 0;
  bool _isRetrying = false;
  Timer? _autoRetryTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.isConnected) {
      _startAutoRetry();
    }
  }

  @override
  void didUpdateWidget(ReconnectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isConnected && oldWidget.isConnected) {
      _startAutoRetry();
    } else if (widget.isConnected) {
      _autoRetryTimer?.cancel();
      _retryCount = 0;
    }
  }

  @override
  void dispose() {
    _autoRetryTimer?.cancel();
    super.dispose();
  }

  void _startAutoRetry() {
    _autoRetryTimer?.cancel();
    _autoRetryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!widget.isConnected && _retryCount < 5) {
        _handleRetry();
      }
    });
  }

  void _handleRetry() {
    setState(() {
      _isRetrying = true;
      _retryCount++;
    });

    widget.onRetry?.call();

    // Reset retrying state after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isConnected) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CasinoColors.cardBackground,
                CasinoColors.cardBackground.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: CasinoColors.gold.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated WiFi Icon
              _buildAnimatedIcon(),
              const SizedBox(height: 24),

              // Title
              Text(
                _isRetrying ? 'Reconnecting...' : 'Connection Lost',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                widget.errorMessage ?? 'Please check your internet connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Retry count
              if (_retryCount > 0)
                Text(
                  'Attempt $_retryCount of 5',
                  style: TextStyle(
                    color: CasinoColors.gold.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 24),

              // Retry Button
              _isRetrying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CasinoColors.gold,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _handleRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CasinoColors.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              // Exit option
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Return to Lobby',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing background
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.2),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 1000.ms,
              )
              .fade(begin: 0.5, end: 0.2),

          // Icon
          Icon(
            _isRetrying ? Icons.wifi : Icons.wifi_off,
            size: 48,
            color: _isRetrying ? CasinoColors.gold : Colors.red,
          )
              .animate(
                onPlay: (c) => _isRetrying ? c.repeat() : null,
              )
              .rotate(
                begin: 0,
                end: _isRetrying ? 0.1 : 0,
                duration: 200.ms,
              ),
        ],
      ),
    );
  }
}

/// Mixin for screens that need connection monitoring
mixin ConnectionMonitor<T extends StatefulWidget> on State<T> {
  bool _isConnected = true;
  StreamSubscription? _connectionSubscription;

  bool get isConnected => _isConnected;

  void startConnectionMonitoring(Stream<bool> connectionStream) {
    _connectionSubscription = connectionStream.listen((connected) {
      if (mounted && _isConnected != connected) {
        setState(() => _isConnected = connected);
      }
    });
  }

  void stopConnectionMonitoring() {
    _connectionSubscription?.cancel();
  }

  @override
  void dispose() {
    stopConnectionMonitoring();
    super.dispose();
  }
}

/// Connectivity Service - Monitors network connectivity
///
/// Features:
/// - Real-time connectivity monitoring
/// - Offline banner display
/// - Action queueing when offline
/// - Auto-sync when back online
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider for connectivity state
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

/// Connectivity status
enum ConnectivityStatus {
  online,
  offline,
  checking,
}

/// Extension for easier checks
extension ConnectivityStatusX on ConnectivityStatus {
  bool get isOnline => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;
}

/// Notifier that tracks network connectivity
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final List<Future<void> Function()> _pendingActions = [];

  ConnectivityNotifier() : super(ConnectivityStatus.checking) {
    _init();
  }

  void _init() async {
    // Check initial state
    final result = await Connectivity().checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOffline = state.isOffline;
    
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
      debugPrint('📴 Device went offline');
    } else {
      state = ConnectivityStatus.online;
      debugPrint('📶 Device is online');
      
      // If we just came back online, process pending actions
      if (wasOffline && _pendingActions.isNotEmpty) {
        _processPendingActions();
      }
    }
  }

  /// Queue an action to be executed when online
  void queueAction(Future<void> Function() action) {
    if (state.isOnline) {
      // Execute immediately if online
      action();
    } else {
      // Queue for later
      _pendingActions.add(action);
      debugPrint('📝 Action queued for when online (${_pendingActions.length} pending)');
    }
  }

  Future<void> _processPendingActions() async {
    debugPrint('🔄 Processing ${_pendingActions.length} pending actions...');
    
    final actions = List<Future<void> Function()>.from(_pendingActions);
    _pendingActions.clear();
    
    for (final action in actions) {
      try {
        await action();
      } catch (e) {
        debugPrint('❌ Failed to process pending action: $e');
        // Re-queue failed action
        _pendingActions.add(action);
      }
    }
    
    debugPrint('✅ Finished processing pending actions');
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Banner widget that shows when offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider);

    if (status.isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text(
              'You are offline',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget that shows offline banner at top
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Mixin for widgets that need connectivity awareness
mixin ConnectivityAwareMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool get isOnline => ref.read(connectivityProvider).isOnline;
  bool get isOffline => ref.read(connectivityProvider).isOffline;

  /// Execute action now if online, or queue for later
  void executeWhenOnline(Future<void> Function() action) {
    ref.read(connectivityProvider.notifier).queueAction(action);
  }
}

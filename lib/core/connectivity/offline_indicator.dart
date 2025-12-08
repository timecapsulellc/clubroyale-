// Offline Mode Indicator Widget
//
// Shows connectivity status and queues actions when offline.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity status
enum ConnectionStatus {
  online,
  offline,
  reconnecting,
}

/// Connectivity service
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  
  ConnectionStatus _currentStatus = ConnectionStatus.online;
  StreamSubscription? _subscription;

  ConnectionStatus get currentStatus => _currentStatus;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  bool get isOnline => _currentStatus == ConnectionStatus.online;

  /// Initialize connectivity monitoring
  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => 
        r != ConnectivityResult.none);
    
    final newStatus = hasConnection 
        ? ConnectionStatus.online 
        : ConnectionStatus.offline;
    
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Offline indicator banner
class OfflineIndicator extends StatelessWidget {
  final Widget child;

  const OfflineIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: ConnectivityService().statusStream,
      initialData: ConnectivityService().currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectionStatus.online;
        
        return Column(
          children: [
            // Offline banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: status == ConnectionStatus.offline ? 32 : 0,
              color: Colors.red.shade700,
              child: status == ConnectionStatus.offline
                  ? const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'No internet connection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            
            // Reconnecting banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: status == ConnectionStatus.reconnecting ? 32 : 0,
              color: Colors.orange.shade700,
              child: status == ConnectionStatus.reconnecting
                  ? const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reconnecting...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            
            // Main content
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Offline overlay for critical screens
class OfflineOverlay extends StatelessWidget {
  final Widget child;
  final String message;

  const OfflineOverlay({
    super.key,
    required this.child,
    this.message = 'This feature requires an internet connection',
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: ConnectivityService().statusStream,
      initialData: ConnectivityService().currentStatus,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == ConnectionStatus.offline;
        
        return Stack(
          children: [
            child,
            if (isOffline)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'You\'re Offline',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await ConnectivityService()._checkConnectivity();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Connection status icon for app bar
class ConnectionStatusIcon extends StatelessWidget {
  const ConnectionStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: ConnectivityService().statusStream,
      initialData: ConnectivityService().currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectionStatus.online;
        
        switch (status) {
          case ConnectionStatus.online:
            return const SizedBox.shrink();
          case ConnectionStatus.offline:
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.cloud_off, color: Colors.red, size: 20),
            );
          case ConnectionStatus.reconnecting:
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
        }
      },
    );
  }
}

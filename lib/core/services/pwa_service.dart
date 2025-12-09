// PWA Service
//
// Handles PWA-specific functionality (simplified version)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// PWA installation state
enum PWAInstallState {
  notAvailable,
  available,
  installed,
}

/// PWA Service for web-specific features
class PWAService {
  static final PWAService _instance = PWAService._internal();
  factory PWAService() => _instance;
  PWAService._internal();

  final _installStateController = StreamController<PWAInstallState>.broadcast();
  PWAInstallState _installState = PWAInstallState.notAvailable;

  PWAInstallState get installState => _installState;
  Stream<PWAInstallState> get installStateStream => _installStateController.stream;
  bool get isInstallable => _installState == PWAInstallState.available;
  bool get isInstalled => _installState == PWAInstallState.installed;

  /// Initialize PWA service
  void initialize() {
    if (!kIsWeb) return;

    // Check if already installed
    if (_isPWAInstalled()) {
      _updateInstallState(PWAInstallState.installed);
    }
  }

  void _updateInstallState(PWAInstallState state) {
    _installState = state;
    _installStateController.add(state);
  }

  /// Check if running as installed PWA
  bool _isPWAInstalled() {
    if (!kIsWeb) return false;
    
    // Check display mode
    final mediaQuery = web.window.matchMedia('(display-mode: standalone)');
    return mediaQuery.matches;
  }

  /// Trigger install prompt
  Future<bool> promptInstall() async {
    if (!kIsWeb || _installState != PWAInstallState.available) {
      return false;
    }
    // In web, this would be handled by JavaScript
    // For now, return false and let JS handle it
    return false;
  }

  /// Check if app should show install prompt
  bool shouldShowInstallPrompt() {
    if (!kIsWeb) return false;
    if (_installState != PWAInstallState.available) return false;
    
    // Check if dismissed recently (use localStorage)
    final dismissed = web.window.localStorage.getItem('pwa_install_dismissed') ?? '';
    if (dismissed.isNotEmpty) {
      final dismissedTime = int.tryParse(dismissed) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Don't show for 7 days after dismissal
      if (now - dismissedTime < 7 * 24 * 60 * 60 * 1000) {
        return false;
      }
    }
    
    return true;
  }

  /// Dismiss install prompt temporarily
  void dismissInstallPrompt() {
    if (!kIsWeb) return;
    web.window.localStorage.setItem(
      'pwa_install_dismissed',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Get platform for display (iOS, Android, Desktop)
  String getPlatform() {
    if (!kIsWeb) return 'unknown';
    
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
      return 'ios';
    } else if (userAgent.contains('android')) {
      return 'android';
    } else {
      return 'desktop';
    }
  }

  void dispose() {
    _installStateController.close();
  }
}

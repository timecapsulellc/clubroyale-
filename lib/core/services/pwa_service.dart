// PWA Service
//
// Handles PWA-specific functionality:
// - Install prompt
// - Online/offline detection
// - Service worker communication
// - Wake lock for games

import 'dart:async';
import 'dart:js_interop';
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

    // Listen for install availability from JavaScript
    web.window.addEventListener('pwa-install-available', _onInstallAvailable.toJS);
  }

  void _onInstallAvailable(web.Event event) {
    if (_installState != PWAInstallState.installed) {
      _updateInstallState(PWAInstallState.available);
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

    try {
      // Call JavaScript install function
      final result = _callJSInstallPWA();
      if (result) {
        _updateInstallState(PWAInstallState.installed);
      }
      return result;
    } catch (e) {
      debugPrint('PWA install error: $e');
      return false;
    }
  }

  @JS('installPWA')
  external static bool _callJSInstallPWA();

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

/// Wake Lock Service - Prevent screen sleep during games
class WakeLockService {
  static WakeLockSentinel? _wakeLock;

  /// Request wake lock (keep screen on)
  static Future<bool> requestWakeLock() async {
    if (!kIsWeb) return false;

    try {
      _wakeLock = await web.window.navigator.wakeLock.request('screen');
      return true;
    } catch (e) {
      debugPrint('Wake lock not supported or denied: $e');
      return false;
    }
  }

  /// Release wake lock
  static Future<void> releaseWakeLock() async {
    await _wakeLock?.release();
    _wakeLock = null;
  }
}

// JavaScript interop types
@JS()
@staticInterop
class WakeLockSentinel {}

extension WakeLockSentinelExtension on WakeLockSentinel {
  external JSPromise release();
}

extension NavigatorWakeLock on web.Navigator {
  external WakeLock get wakeLock;
}

@JS()
@staticInterop
class WakeLock {}

extension WakeLockExtension on WakeLock {
  external JSPromise<WakeLockSentinel> request(String type);
}

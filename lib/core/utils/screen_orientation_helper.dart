/// Screen Orientation Helper
///
/// Utility class for controlling screen orientation across game screens.
/// Uses Flutter's SystemChrome to lock/unlock orientation.
library;

import 'package:flutter/services.dart';

/// Helper class for screen orientation management
class ScreenOrientationHelper {
  /// Lock screen to landscape mode (for games)
  static Future<void> lockLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Lock screen to portrait mode (for menus)
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Allow all orientations (default - called when exiting games)
  static Future<void> unlockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Auto-detect if landscape should be used
  /// Always returns true for card games (better UX)
  static bool shouldUseLandscape() {
    return true;
  }
}

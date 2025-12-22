/// Haptic Feedback Helper - Tactile feedback for premium UX
///
/// Provides consistent haptic feedback patterns across the app
library;

import 'package:flutter/services.dart';

class HapticHelper {
  /// Light tap - for button presses, toggles
  static void lightTap() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium tap - for selections, confirmations
  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy tap - for important actions, alerts
  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection change - for pickers, sliders
  static void selection() {
    HapticFeedback.selectionClick();
  }
  
  /// Success pattern - double light tap
  static Future<void> success() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }
  
  /// Error pattern - heavy single
  static void error() {
    HapticFeedback.heavyImpact();
  }
  
  /// Card dealt/moved
  static void cardMove() {
    HapticFeedback.selectionClick();
  }
  
  /// Chip placed (betting)
  static void chipPlace() {
    HapticFeedback.lightImpact();
  }
  
  /// Win celebration pattern
  static Future<void> winCelebration() async {
    for (int i = 0; i < 3; i++) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }
  
  /// Notify (new message, turn)
  static void notify() {
    HapticFeedback.lightImpact();
  }
}

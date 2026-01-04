import 'package:flutter/services.dart';

/// Centralized haptic feedback service for consistent tactile responses
///
/// Usage:
/// ```dart
/// HapticService.cardTap();
/// HapticService.cardDraw();
/// HapticService.victory();
/// ```
class HapticService {
  HapticService._();

  /// Light tap - selecting a card
  static void cardTap() {
    HapticFeedback.selectionClick();
  }

  /// Light impact - drawing a card
  static void cardDraw() {
    HapticFeedback.lightImpact();
  }

  /// Light impact - discarding a card
  static void cardDiscard() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - successful visit
  static void visitSuccess() {
    HapticFeedback.mediumImpact();
  }

  /// Medium impact - meld formed
  static void meldFormed() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - victory/winning
  static void victory() {
    HapticFeedback.heavyImpact();
  }

  /// Heavy impact - defeat
  static void defeat() {
    HapticFeedback.mediumImpact();
  }

  /// Selection click - button press
  static void buttonPress() {
    HapticFeedback.selectionClick();
  }

  /// Light vibrate - turn notification
  static void turnNotification() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - error feedback
  static void error() {
    HapticFeedback.mediumImpact();
  }

  /// Double tap pattern - Marriage combo
  static Future<void> marriageCombo() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Triple tap pattern - 8 Dublee win
  static Future<void> specialWin() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }
}

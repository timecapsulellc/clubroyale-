/// Game Animation Controller helps sequence complex animations
/// like dealing cards one by one, or playing turn animations cleanly
library;

import 'package:flutter/material.dart';

/// Controller for orchestrating game animations
class GameAnimationController {
  /// Deal cards with staggered delay
  /// [onDealCard] is called for each card with its index
  /// [totalCards] total number of cards to deal
  /// [delay] delay between each card deal
  static Future<void> dealCards({
    required int totalCards,
    required Function(int index) onDealCard,
    Duration delay = const Duration(milliseconds: 100),
    VoidCallback? onComplete,
  }) async {
    for (var i = 0; i < totalCards; i++) {
      onDealCard(i);
      await Future.delayed(delay);
    }
    onComplete?.call();
  }

  /// Staggered entry animation for list items
  static Future<void> animateListEntry({
    required int itemCount,
    required Function(int index) onAnimate,
    Duration delay = const Duration(milliseconds: 30),
  }) async {
    for (var i = 0; i < itemCount; i++) {
      onAnimate(i);
      await Future.delayed(delay);
    }
  }
}

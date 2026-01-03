/// Card Animations - Collection of card-related effects
library;

// Export the complex flying animation
export 'package:clubroyale/core/design_system/game/flying_card_animation.dart';
// Export Rive card flip
export 'rive_animations.dart' show RiveCardFlip;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Extension for common card animations using flutter_animate
extension CardAnimationExtensions on Widget {
  /// Standard entrance animation for a card dealing effect
  Widget animateCardDeal({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
    Offset begin = const Offset(0, -1),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .slide(begin: begin, duration: duration, curve: Curves.easeOutCubic);
  }

  /// Animation when a card is selected/touched
  Widget animateCardSelection({bool isSelected = false}) {
    return animate(target: isSelected ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        )
        .elevation(begin: 2, end: 8);
  }

  /// Animation for when a card is played
  Widget animateCardPlay() {
    return animate()
        .moveY(begin: 0, end: -50, duration: 200.ms, curve: Curves.easeOut)
        .fadeOut(delay: 150.ms, duration: 100.ms);
  }
}

/// Premium Card Widget - 3D Playing Card with Effects
/// 
/// Features:
/// - 3D shadows and depth
/// - Flip animation
/// - Selection glow effects
/// - Maal badge overlay
/// - Playable/disabled states
/// - Audio feedback on flip
library;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/card_engine/pile.dart' as engine;
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/core/design_system/game/maal_badge_widget.dart';
import 'package:clubroyale/core/design_system/animations/rive_animations.dart';
import 'package:clubroyale/core/services/game_audio_mixin.dart';

/// Premium 3D card widget with animations and Maal badges
class PremiumCardWidget extends ConsumerStatefulWidget {
  final engine.Card card;
  final bool isSelected;
  final bool isFaceUp;
  final bool isPlayable;
  final bool isHighlighted;
  final MaalType? maalType;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PremiumCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isFaceUp = true,
    this.isPlayable = true,
    this.isHighlighted = false,
    this.maalType,
    this.onTap,
    this.width = 60,
    this.height = 90,
  });

  @override
  ConsumerState<PremiumCardWidget> createState() => _PremiumCardWidgetState();
}

class _PremiumCardWidgetState extends ConsumerState<PremiumCardWidget> with GameAudioMixin {

  @override
  void initState() {
    super.initState();
    // Initialize audio after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAudio(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rive Flip Animation
    Widget cardWidget = GestureDetector(
      onTap: widget.isPlayable ? () {
        HapticFeedback.lightImpact();
        playCardFlip(); // Play card flip sound
        widget.onTap?.call();
      } : null,
      child: RiveCardFlip(
        isFaceUp: widget.isFaceUp,
        width: widget.width,
        height: widget.height,
      ),
    );

    // Selection animation
    if (widget.isSelected) {
      cardWidget = cardWidget
          .animate()
          .moveY(end: -12, duration: 200.ms, curve: Curves.easeOut);
    }

    // Maal shimmer effect (overlaying on top of Rive if needed, 
    // or we can rely on Rive's internal look, but keeping shimmer for now)
    if (widget.maalType != null && widget.maalType != MaalType.none) {
      cardWidget = cardWidget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 2000.ms,
            color: getMaalGlowColor(widget.maalType!).withValues(alpha: 0.3),
          );
    }

    // Maal Badge Overlay (since RiveCardFlip doesn't have it built-in yet)
    if (widget.isFaceUp && widget.maalType != null && widget.maalType != MaalType.none) {
      cardWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          cardWidget,
          Positioned(
            top: 2,
            right: 2,
            child: MaalBadgeWidget(
               type: widget.maalType!,
               size: widget.width * 0.25,
            ),
          ),
        ],
      );
    }

    return cardWidget;
  }

  // Legacy build info removed as Rive handles rendering now


}

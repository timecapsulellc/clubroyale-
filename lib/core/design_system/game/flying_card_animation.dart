/// Flying Card Animation - Moving card visual effect
/// 
/// Used for:
/// - Dealing cards
/// - Draw from Deck/Discard
/// - Discarding
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/core/card_engine/pile.dart' as engine;
import 'package:clubroyale/core/design_system/game/premium_card_widget.dart';

/// Animation of a card flying from source to destination
class FlyingCardAnimation extends StatefulWidget {
  final engine.Card card;
  final Offset startOffset;
  final Offset endOffset;
  final double startScale;
  final double endScale;
  final VoidCallback onComplete;
  final Duration duration;
  final bool isFaceUp;

  const FlyingCardAnimation({
    super.key,
    required this.card,
    required this.startOffset,
    required this.endOffset,
    this.startScale = 0.5,
    this.endScale = 1.0,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 600),
    this.isFaceUp = true,
  });

  @override
  State<FlyingCardAnimation> createState() => _FlyingCardAnimationState();
}

class _FlyingCardAnimationState extends State<FlyingCardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curve = Curves.easeInOutCubic;

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _scaleAnimation = Tween<double>(
      begin: widget.startScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    // Add a spin effect
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // One full rotation
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.2, // Subtle rotation
              child: PremiumCardWidget(
                card: widget.card,
                isFaceUp: widget.isFaceUp,
                width: 70, // Standard width
                height: 100,
                isPlayable: false,
              ),
            ),
          ),
        );
      },
    );
  }
}

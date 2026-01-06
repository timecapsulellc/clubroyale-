/// Marriage Game Animation Service
///
/// Orchestrates all animations in Marriage game
/// Card dealing, turn transitions, victory celebrations
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clubroyale/games/marriage/services/marriage_sound_effects.dart';

/// Animation presets for Marriage game
class MarriageAnimations {
  // Card dealing animation timing
  static const dealCardDuration = Duration(milliseconds: 150);
  static const dealCardStaggerDelay = Duration(milliseconds: 50);
  
  // Card interaction animations
  static const selectDuration = Duration(milliseconds: 200);
  static const liftOffset = Offset(0, -12);
  static const selectScale = 1.05;
  
  // Turn transition
  static const turnTransitionDuration = Duration(milliseconds: 300);
  
  // Victory celebration
  static const trophyEntryDuration = Duration(milliseconds: 600);
  static const confettiDuration = Duration(milliseconds: 3000);
  
  /// Deal cards animation with callbacks
  static Future<void> dealCards({
    required int cardCount,
    required Function(int index) onDealCard,
    VoidCallback? onComplete,
  }) async {
    for (var i = 0; i < cardCount; i++) {
      await MarriageSoundEffects.onDealCards();
      onDealCard(i);
      await Future.delayed(dealCardStaggerDelay);
    }
    onComplete?.call();
  }
  
  /// Draw card from deck animation
  static Widget animateCardDraw({
    required Widget child,
    required bool isAnimating,
    required Offset fromPosition,
    required Offset toPosition,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isAnimating ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final currentPosition = Offset.lerp(fromPosition, toPosition, value)!;
        return Transform.translate(
          offset: currentPosition,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Flying card animation widget
  static Widget flyingCard({
    required Widget card,
    required Offset startPosition,
    required Offset endPosition,
    required AnimationController controller,
    VoidCallback? onComplete,
  }) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete?.call();
      }
    });
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final position = Offset.lerp(
          startPosition, 
          endPosition, 
          Curves.easeOutCubic.transform(controller.value),
        )!;
        
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Transform.scale(
            scale: 1.0 + (0.2 * (1 - controller.value)),
            child: Opacity(
              opacity: 1.0 - (controller.value * 0.3),
              child: card,
            ),
          ),
        );
      },
    );
  }
}

/// Turn transition animation mixin
mixin TurnAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _turnController;
  late Animation<double> _turnGlowAnimation;
  bool _isMyTurn = false;
  
  void initTurnAnimation() {
    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _turnGlowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _turnController,
        curve: Curves.easeInOut,
      ),
    );
    
    _turnController.repeat(reverse: true);
  }
  
  void updateTurnState(bool isMyTurn) {
    if (isMyTurn != _isMyTurn) {
      _isMyTurn = isMyTurn;
      if (isMyTurn) {
        _turnController.repeat(reverse: true);
        MarriageSoundEffects.onYourTurn();
      } else {
        _turnController.stop();
        _turnController.reset();
      }
    }
  }
  
  void disposeTurnAnimation() {
    _turnController.dispose();
  }
  
  double get turnGlowValue => _isMyTurn ? _turnGlowAnimation.value : 0.0;
}

/// Card selection animation widget
class SelectableCard extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const SelectableCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });
  
  @override
  State<SelectableCard> createState() => _SelectableCardState();
}

class _SelectableCardState extends State<SelectableCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _liftAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MarriageAnimations.selectDuration,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0, 
      end: MarriageAnimations.selectScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _liftAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: MarriageAnimations.liftOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(SelectableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
        MarriageSoundEffects.onCardSelect();
      } else {
        _controller.reverse();
        MarriageSoundEffects.onCardDeselect();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _liftAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Meld formation celebration animation
class MeldCelebration extends StatefulWidget {
  final Widget child;
  final bool celebrate;
  
  const MeldCelebration({
    super.key,
    required this.child,
    this.celebrate = false,
  });
  
  @override
  State<MeldCelebration> createState() => _MeldCelebrationState();
}

class _MeldCelebrationState extends State<MeldCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.8), weight: 1),
    ]).animate(_controller);
  }
  
  @override
  void didUpdateWidget(MeldCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate) {
      _controller.forward(from: 0.0);
      MarriageSoundEffects.onMeldFormed();
    }
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
        return Container(
          decoration: BoxDecoration(
            boxShadow: _glowAnimation.value > 0
                ? [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: _glowAnimation.value * 0.6),
                      blurRadius: _glowAnimation.value * 20,
                      spreadRadius: _glowAnimation.value * 4,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Visit celebration animation
class VisitCelebration extends StatefulWidget {
  final bool show;
  final VoidCallback? onComplete;
  
  const VisitCelebration({
    super.key,
    this.show = false,
    this.onComplete,
  });
  
  @override
  State<VisitCelebration> createState() => _VisitCelebrationState();
}

class _VisitCelebrationState extends State<VisitCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }
  
  @override
  void didUpdateWidget(VisitCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0.0);
      MarriageSoundEffects.onVisit();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.show && _controller.value == 0) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = Curves.easeOut.transform(
          (_controller.value < 0.8)
              ? _controller.value / 0.8
              : 1.0 - ((_controller.value - 0.8) / 0.2),
        );
        
        final scale = 0.5 + (0.5 * Curves.elasticOut.transform(
          (_controller.value < 0.4) ? _controller.value / 0.4 : 1.0,
        ));
        
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade700,
                    Colors.purple.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.visibility, color: Colors.amber, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'VISITED!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MAAL Revealed',
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

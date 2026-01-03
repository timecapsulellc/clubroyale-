import 'package:flutter/material.dart';

/// Card animation utilities for Call Break game
class CardAnimations {
  /// Duration for card play animation
  static const Duration cardPlayDuration = Duration(milliseconds: 400);

  /// Duration for trick collection animation
  static const Duration trickCollectDuration = Duration(milliseconds: 600);

  /// Duration for card deal animation
  static const Duration cardDealDuration = Duration(milliseconds: 300);

  /// Curve for card movement
  static const Curve cardMoveCurve = Curves.easeOutCubic;

  /// Curve for card flip
  static const Curve cardFlipCurve = Curves.easeInOutBack;
}

/// Animated wrapper for card play animations
class AnimatedCardPlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final Offset targetOffset;
  final VoidCallback? onAnimationComplete;

  const AnimatedCardPlay({
    super.key,
    required this.child,
    this.isPlaying = false,
    this.targetOffset = Offset.zero,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedCardPlay> createState() => _AnimatedCardPlayState();
}

class _AnimatedCardPlayState extends State<AnimatedCardPlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CardAnimations.cardPlayDuration,
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: widget.targetOffset).animate(
          CurvedAnimation(
            parent: _controller,
            curve: CardAnimations.cardMoveCurve,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: CardAnimations.cardMoveCurve),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedCardPlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.forward(from: 0);
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
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Animation for trick collection (all cards move to winner)
class TrickCollectionAnimation extends StatefulWidget {
  final List<Widget> cards;
  final int winnerIndex;
  final VoidCallback? onComplete;

  const TrickCollectionAnimation({
    super.key,
    required this.cards,
    required this.winnerIndex,
    this.onComplete,
  });

  @override
  State<TrickCollectionAnimation> createState() =>
      _TrickCollectionAnimationState();
}

class _TrickCollectionAnimationState extends State<TrickCollectionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CardAnimations.trickCollectDuration,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInBack);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: widget.cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;

            // Calculate offset toward winner position
            final radius = 60.0 * (1 - _animation.value);
            final targetRadius = index == widget.winnerIndex
                ? 0
                : 100 * _animation.value;

            return Transform.translate(
              offset: Offset(
                radius *
                    (index == widget.winnerIndex
                        ? 0
                        : (index < widget.winnerIndex ? -1 : 1) * targetRadius),
                radius * (index % 2 == 0 ? -1 : 1) * (1 - _animation.value),
              ),
              child: Opacity(opacity: 1 - _animation.value * 0.8, child: card),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Card selection animation (lift card up)
class CardSelectionAnimation extends StatelessWidget {
  final Widget child;
  final bool isSelected;

  const CardSelectionAnimation({
    super.key,
    required this.child,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isSelected ? 1 : 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -20 * value),
          child: Transform.scale(scale: 1.0 + 0.05 * value, child: child),
        );
      },
      child: child,
    );
  }
}

/// Card flip animation
class CardFlipAnimation extends StatelessWidget {
  final Widget front;
  final Widget back;
  final bool showFront;

  const CardFlipAnimation({
    super.key,
    required this.front,
    required this.back,
    this.showFront = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: showFront ? 0 : 3.14159),
      duration: CardAnimations.cardDealDuration,
      curve: CardAnimations.cardFlipCurve,
      builder: (context, value, _) {
        final isShowingFront = value < 3.14159 / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value),
          child: isShowingFront ? front : back,
        );
      },
    );
  }
}

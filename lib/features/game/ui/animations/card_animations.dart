import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/core/services/haptic_service.dart';

/// Animated card flying from source to destination
/// Used for draw/discard animations
class FlyingCardAnimation extends StatefulWidget {
  final PlayingCard card;
  final Offset startPosition;
  final Offset endPosition;
  final bool showFace;
  final Duration duration;
  final VoidCallback? onComplete;

  const FlyingCardAnimation({
    super.key,
    required this.card,
    required this.startPosition,
    required this.endPosition,
    this.showFace = false,
    this.duration = const Duration(milliseconds: 400),
    this.onComplete,
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

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 70),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05, // Slight rotation for natural feel
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });

    // Haptic at midpoint
    Future.delayed(widget.duration ~/ 2, () {
      HapticService.cardDraw();
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
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: CardWidget(
                card: widget.card,
                isFaceUp: widget.showFace,
                width: 70,
                height: 100,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Controller to manage flying card animations
class CardAnimationController extends ChangeNotifier {
  final List<FlyingCardAnimation> _activeAnimations = [];

  List<FlyingCardAnimation> get activeAnimations =>
      List.unmodifiable(_activeAnimations);

  /// Animate card from deck to hand
  void animateDrawFromDeck({
    required PlayingCard card,
    required Offset deckPosition,
    required Offset handPosition,
    VoidCallback? onComplete,
  }) {
    final animation = FlyingCardAnimation(
      card: card,
      startPosition: deckPosition,
      endPosition: handPosition,
      showFace: true,
      duration: const Duration(milliseconds: 350),
      onComplete: () {
        _removeAnimation(card);
        onComplete?.call();
      },
    );
    _activeAnimations.add(animation);
    notifyListeners();
  }

  /// Animate card from hand to discard
  void animateDiscard({
    required PlayingCard card,
    required Offset cardPosition,
    required Offset discardPosition,
    VoidCallback? onComplete,
  }) {
    final animation = FlyingCardAnimation(
      card: card,
      startPosition: cardPosition,
      endPosition: discardPosition,
      showFace: true,
      duration: const Duration(milliseconds: 300),
      onComplete: () {
        _removeAnimation(card);
        onComplete?.call();
      },
    );
    _activeAnimations.add(animation);
    notifyListeners();
  }

  void _removeAnimation(PlayingCard card) {
    _activeAnimations.removeWhere((a) => a.card.id == card.id);
    notifyListeners();
  }

  void clearAll() {
    _activeAnimations.clear();
    notifyListeners();
  }
}

/// Overlay that displays all active card animations
class CardAnimationOverlay extends StatelessWidget {
  final CardAnimationController controller;

  const CardAnimationOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.activeAnimations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Stack(children: controller.activeAnimations);
      },
    );
  }
}

/// Simple card deal animation for game start
class DealingAnimation extends StatelessWidget {
  final int cardCount;
  final int playerIndex; // 0-7 for table position
  final Duration staggerDelay;

  const DealingAnimation({
    super.key,
    required this.cardCount,
    required this.playerIndex,
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(cardCount, (index) {
        return Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF2a1f4e),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10),
              ),
            )
            .animate(delay: staggerDelay * index)
            .fadeIn(duration: 150.ms)
            .slide(
              begin: const Offset(0, -2),
              end: Offset.zero,
              duration: 200.ms,
              curve: Curves.easeOutCubic,
            );
      }),
    );
  }
}

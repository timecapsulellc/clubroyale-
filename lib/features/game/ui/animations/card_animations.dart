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
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 6.28, // Full rotation for visual flair
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
        final t = _controller.value;
        // Quadratic Bezier Curve: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
        final p0 = widget.startPosition;
        final p2 = widget.endPosition;
        
        // Calculate Control Point P1 (Midpoint + Offset for Arc)
        // Offset direction depends on start/end to avoid off-screen
        final mid = (p0 + p2) / 2;
        final dist = (p0 - p2).distance;
        // Add random slight variation or fixed curve
        final p1 = Offset(mid.dx, mid.dy - (dist * 0.2)); // Arc upwards

        final x = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
        final y = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;

        // Apply custom curve to time for speed variation
        // Using EaseInOutCubic manually on 't' if needed, but Controller is linear by default
        // Let's use the eased value from a CurvedAnimation if we wanted, 
        // but simple linear 't' with Bezier path looks physically reasonably natural for cards.
        
        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * (t * 0.5), // Rotate slightly during flight
              child: CardWidget(
                card: widget.card,
                isFaceUp: widget.showFace,
                width: 70,
                height: 100,
                // Add shadow for depth during flight
                glowColor: Colors.black.withValues(alpha: 0.3),
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
    _activeAnimations.add(animation);
    notifyListeners();
  }

  /// Optimize dealing for multiple players (Phase 5)
  /// Uses "Packet Dealing" to avoid animating 168+ cards individually
  void dealCards({
    required int playerCount,
    required int myPlayerIndex,
    required Offset deckPosition,
    required List<Offset> playerPositions,
    VoidCallback? onComplete,
  }) async {
    // Deal in 3 rounds (packets of 7 cards)
    const packets = 3;
    const cardsPerPacket = 7;
    const packetDelay = Duration(milliseconds: 600);
    const flightDuration = Duration(milliseconds: 500);

    for (int packet = 0; packet < packets; packet++) {
      // Stagger each packet round
      await Future.delayed(packetDelay * packet);
      
      for (int i = 0; i < playerCount; i++) {
        // Skip invalid positions
        if (i >= playerPositions.length) continue;

        final isMe = i == myPlayerIndex;
        final targetPos = playerPositions[i];
        
        // For ME: Animate a stream of individual cards (looks premium)
        // For OTHERS: Animate a single "Packet" stack (saves performance)
        
        if (isMe) {
             _animateStreamToMe(
               count: cardsPerPacket,
               start: deckPosition,
               end: targetPos,
               delayOffset: packet * 100, // Vary delay slightly
             );
        } else {
             _animatePacketToOpponent(
               start: deckPosition,
               end: targetPos,
               duration: flightDuration,
             );
        }
      }
    }
    
    // Cleanup after all animations roughly done
    Future.delayed(packetDelay * packets + const Duration(seconds: 1), () {
      _activeAnimations.clear();
      notifyListeners();
      onComplete?.call();
    });
  }

  void _animateStreamToMe({
    required int count,
    required Offset start,
    required Offset end,
    required int delayOffset,
  }) {
    for (int c = 0; c < count; c++) {
      Future.delayed(Duration(milliseconds: c * 50), () {
        final animation = FlyingCardAnimation(
          card: PlayingCard(suit: CardSuit.spades, rank: CardRank.ace), // Dummy back
          startPosition: start,
          endPosition: end,
          showFace: false, // Face down deal
          duration: const Duration(milliseconds: 400),
          onComplete: () => _activeAnimations.removeWhere((a) => a.startPosition == start), // Cleanup handled by clearAll mostly
        );
        _activeAnimations.add(animation);
        notifyListeners();
      });
    }
  }

  void _animatePacketToOpponent({
    required Offset start,
    required Offset end,
    required Duration duration,
  }) {
    // A packet looks just like a card but represents many
    // We could add a "Stack" visual if we had a widget for it, 
    // but a single card back flying represents the packet well enough for optimization.
    final animation = FlyingCardAnimation(
      card: PlayingCard(suit: CardSuit.spades, rank: CardRank.ace), // Dummy back
      startPosition: start,
      endPosition: end,
      showFace: false,
      duration: duration,
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

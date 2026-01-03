// Animation Presets - Consistent micro-interactions across the app
//
// These extension methods on Widget make it easy to add
// premium animations with one-liners.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animation presets for consistent micro-interactions
extension PremiumAnimations on Widget {
  /// Entrance animation for cards and containers
  Widget animateEntrance({int index = 0}) {
    return animate()
        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  /// Scale pop for buttons when pressed
  Widget animatePress() {
    return animate(onPlay: (c) => c.forward())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
          duration: 100.ms,
        )
        .then()
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 100.ms,
        );
  }

  /// Subtle pulse for attention-grabbing elements
  Widget animatePulse() {
    return animate(onPlay: (c) => c.repeat(reverse: true)).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 1500.ms,
      curve: Curves.easeInOut,
    );
  }

  /// Shimmer effect for loading states
  Widget animateShimmer() {
    return animate(
      onPlay: (c) => c.repeat(),
    ).shimmer(duration: 1500.ms, color: Colors.white24);
  }

  /// Bounce for success feedback
  Widget animateBounce() {
    return animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.1, 1.1),
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: 150.ms,
          curve: Curves.easeIn,
        );
  }

  /// Slide in from left
  Widget animateSlideLeft({int index = 0}) {
    return animate()
        .fadeIn(delay: (30 * index).ms)
        .slideX(begin: -0.2, curve: Curves.easeOutCubic);
  }

  /// Slide in from right
  Widget animateSlideRight({int index = 0}) {
    return animate()
        .fadeIn(delay: (30 * index).ms)
        .slideX(begin: 0.2, curve: Curves.easeOutCubic);
  }

  /// Flip animation for cards
  Widget animateFlip() {
    return animate().flipH(
      begin: 0.5,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  /// Stagger entrance for list items
  Widget animateStagger(int index) {
    return animate()
        .fadeIn(delay: (80 * index).ms, duration: 300.ms)
        .slideY(begin: 0.15, delay: (80 * index).ms);
  }

  /// Success glow animation
  Widget animateGlow({Color color = Colors.green}) {
    return animate(onPlay: (c) => c.forward()).custom(
      duration: 600.ms,
      builder: (context, value, child) => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5 * (1 - value)),
              blurRadius: 20 * (1 - value),
              spreadRadius: 10 * (1 - value),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  /// Error shake animation
  Widget animateShake() {
    return animate().shake(hz: 4, rotation: 0.02, duration: 400.ms);
  }

  /// Attention grabbing wiggle
  Widget animateWiggle() {
    return animate(
      onPlay: (c) => c.repeat(reverse: true),
    ).rotate(begin: -0.02, end: 0.02, duration: 300.ms);
  }

  // ============ GAME-SPECIFIC ANIMATIONS ============

  /// Card deal animation - fly from deck to hand
  /// Duration: 300ms, Curve: easeOutCubic
  Widget animateCardDeal({int index = 0, Offset? from}) {
    return animate()
        .fadeIn(delay: (100 * index).ms, duration: 300.ms)
        .slideY(begin: -0.5, curve: Curves.easeOutCubic, duration: 300.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: (100 * index).ms,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Card play animation - slide to center pile
  /// Duration: 200ms, Curve: easeInOut
  Widget animateCardPlay() {
    return animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 100.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: 100.ms,
          curve: Curves.easeInOut,
        );
  }

  /// Trick win animation - glow and collect to winner
  /// Duration: 500ms, Curve: bounceOut
  Widget animateTrickWin({Color glowColor = Colors.amber}) {
    return animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.15, 1.15),
          duration: 250.ms,
          curve: Curves.easeOut,
        )
        .then()
        .scale(
          begin: const Offset(1.15, 1.15),
          end: const Offset(0.5, 0.5),
          duration: 250.ms,
          curve: Curves.bounceOut,
        )
        .fadeOut(delay: 400.ms, duration: 100.ms)
        .custom(
          duration: 500.ms,
          builder: (context, value, child) => Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.6 * (1 - value)),
                  blurRadius: 20 * (1 - value),
                  spreadRadius: 8 * (1 - value),
                ),
              ],
            ),
            child: child,
          ),
        );
  }

  /// Marriage flip animation - flip with sparkle
  /// Duration: 400ms, Curve: elasticOut
  Widget animateMarriageFlip() {
    return animate()
        .flipH(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.elasticOut)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 200.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.elasticOut,
        );
  }

  /// Maal declaration animation - pulse with gold glow
  Widget animateMaalDeclaration() {
    return animate(onPlay: (c) => c.repeat(reverse: true, count: 3))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          duration: 300.ms,
        )
        .custom(
          duration: 300.ms,
          builder: (context, value, child) => Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5 * value),
                  blurRadius: 15 * value,
                  spreadRadius: 5 * value,
                ),
              ],
            ),
            child: child,
          ),
        );
  }
}

/// Animated button wrapper with built-in press feedback
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleDown;

  const AnimatedPressButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleDown = 0.95,
  });

  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// Page transition - smooth slide and fade
class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  PremiumPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.05, 0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

/// Animated counter for score displays
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

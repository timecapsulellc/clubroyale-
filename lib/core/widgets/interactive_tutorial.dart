import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Animated Hand Pointer Widget for Tutorial Guidance
/// Shows a pointing hand with tap/swipe animations
class TutorialHandPointer extends StatelessWidget {
  final Offset position;
  final TutorialGestureType gestureType;
  final double size;

  const TutorialHandPointer({
    super.key,
    required this.position,
    this.gestureType = TutorialGestureType.tap,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - size / 2,
      top: position.dy - size / 2,
      child: _buildAnimatedHand(),
    );
  }

  Widget _buildAnimatedHand() {
    Widget hand = Icon(
      Icons.touch_app,
      size: size,
      color: CasinoColors.gold,
      shadows: const [
        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2)),
      ],
    );

    switch (gestureType) {
      case TutorialGestureType.tap:
        // Tap animation: scale down and up
        return hand
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(0.85, 0.85),
              duration: 400.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeInOut,
            )
            .then(delay: 500.ms);

      case TutorialGestureType.swipeRight:
        // Swipe right animation
        return hand
            .animate(onPlay: (controller) => controller.repeat())
            .moveX(begin: 0, end: 40, duration: 600.ms, curve: Curves.easeInOut)
            .fadeOut(delay: 400.ms, duration: 200.ms)
            .then(delay: 300.ms);

      case TutorialGestureType.swipeLeft:
        // Swipe left animation
        return hand
            .animate(onPlay: (controller) => controller.repeat())
            .moveX(
              begin: 0,
              end: -40,
              duration: 600.ms,
              curve: Curves.easeInOut,
            )
            .fadeOut(delay: 400.ms, duration: 200.ms)
            .then(delay: 300.ms);

      case TutorialGestureType.swipeUp:
        // Swipe up animation (for playing a card)
        return hand
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(begin: 0, end: -50, duration: 600.ms, curve: Curves.easeOut)
            .fadeOut(delay: 400.ms, duration: 200.ms)
            .then(delay: 300.ms);

      case TutorialGestureType.dragDrop:
        // Drag and drop animation
        return hand
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(0.9, 0.9),
              duration: 200.ms,
            )
            .then()
            .moveX(begin: 0, end: 60, duration: 500.ms, curve: Curves.easeInOut)
            .moveY(
              begin: 0,
              end: -30,
              duration: 500.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 200.ms,
            )
            .fadeOut(delay: 100.ms, duration: 200.ms)
            .then(delay: 400.ms);

      case TutorialGestureType.hold:
        // Long press / hold animation
        return hand
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(0.9, 0.9),
              duration: 300.ms,
            )
            .then(delay: 800.ms) // Hold for 800ms
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 300.ms,
            )
            .then(delay: 500.ms);
    }
  }
}

/// Types of gestures the tutorial hand can demonstrate
enum TutorialGestureType { tap, swipeRight, swipeLeft, swipeUp, dragDrop, hold }

/// Interactive Tutorial Step with action requirement
class InteractiveTutorialStep {
  final String title;
  final String instruction;
  final GlobalKey? targetKey;
  final TutorialGestureType gestureType;
  final Offset? handOffset; // Offset from target center
  final bool Function()?
  actionValidator; // Returns true when action is complete
  final String? highlightCardId; // Specific card to highlight
  final bool waitForAction; // If true, waits for user action before proceeding

  InteractiveTutorialStep({
    required this.title,
    required this.instruction,
    this.targetKey,
    this.gestureType = TutorialGestureType.tap,
    this.handOffset,
    this.actionValidator,
    this.highlightCardId,
    this.waitForAction = false,
  });
}

/// Interactive Tutorial Controller
/// Manages step progression and action validation
class InteractiveTutorialController extends ChangeNotifier {
  final List<InteractiveTutorialStep> steps;
  int _currentIndex = 0;
  bool _isActive = true;

  InteractiveTutorialController({required this.steps});

  int get currentIndex => _currentIndex;
  bool get isActive => _isActive;
  bool get isComplete => _currentIndex >= steps.length;
  InteractiveTutorialStep? get currentStep =>
      isComplete ? null : steps[_currentIndex];

  void nextStep() {
    if (_currentIndex < steps.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      complete();
    }
  }

  void previousStep() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToStep(int index) {
    if (index >= 0 && index < steps.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void complete() {
    _isActive = false;
    notifyListeners();
  }

  void skip() {
    complete();
  }

  void reset() {
    _currentIndex = 0;
    _isActive = true;
    notifyListeners();
  }

  /// Call this when user performs the expected action
  void validateAction() {
    final step = currentStep;
    if (step == null) return;

    if (step.actionValidator?.call() ?? true) {
      nextStep();
    }
  }
}

/// Widget that shows the interactive tutorial overlay with hand pointer
class InteractiveTutorialOverlay extends StatelessWidget {
  final InteractiveTutorialController controller;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const InteractiveTutorialOverlay({
    super.key,
    required this.controller,
    required this.onComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isActive || controller.isComplete) {
          return const SizedBox.shrink();
        }

        final step = controller.currentStep!;
        final screenSize = MediaQuery.of(context).size;

        // Find target position
        Rect? targetRect;
        if (step.targetKey?.currentContext != null) {
          final renderBox =
              step.targetKey!.currentContext!.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            targetRect = Rect.fromLTWH(
              position.dx,
              position.dy,
              renderBox.size.width,
              renderBox.size.height,
            );
          }
        }

          // Calculate hole punch rectangles (Top, Bottom, Left, Right)
          final hole = targetRect ?? Rect.zero;

          // Define the 4 blocking rectangles around the hole
          final topRect = Rect.fromLTRB(0, 0, screenSize.width, hole.top);
          final bottomRect = Rect.fromLTRB(0, hole.bottom, screenSize.width, screenSize.height);
          final leftRect = Rect.fromLTRB(0, hole.top, hole.left, hole.bottom);
          final rightRect = Rect.fromLTRB(hole.right, hole.top, screenSize.width, hole.bottom);

          return Stack(
            children: [
              // 1. Blocking Overlays (The "Hole Punch")
              // Only block touches if we have a target. If no target (text only), standard overlay
              if (targetRect == null)
                GestureDetector(
                   onTap: controller.nextStep,
                   child: Container(color: Colors.black54),
                )
              else ...[
                _buildBlocker(topRect, controller, step),
                _buildBlocker(bottomRect, controller, step),
                _buildBlocker(leftRect, controller, step),
                _buildBlocker(rightRect, controller, step),
              ],

              // 2. Highlight punch-out for target (Visual Ring)
              if (targetRect != null) _buildHighlight(targetRect),

              // 3. Animated Hand Pointer
              if (targetRect != null)
                TutorialHandPointer(
                  position: Offset(
                    targetRect.center.dx + (step.handOffset?.dx ?? 0),
                    targetRect.center.dy + (step.handOffset?.dy ?? 0),
                  ),
                  gestureType: step.gestureType,
                ),

              // 4. Instruction Card
              _buildInstructionCard(context, step, targetRect, screenSize),

              // 5. Progress dots
              _buildProgressDots(),
            ],
          );
      },
    );
  }

  Widget _buildBlocker(Rect rect, InteractiveTutorialController controller, InteractiveTutorialStep step) {
    return Positioned.fromRect(
      rect: rect,
      child: GestureDetector(
        // If waitForAction is TRUE, we swallow taps (acting as a barrier).
        // If FALSE (text only step), we advance to next step.
        // Actually for target steps, usually tapping OUTSIDE the target shouldn't advance if we expect them to look at it?
        // Let's say: Tapping outside ALWAYS advances UNLESS waitForAction is true.
        onTap: step.waitForAction ? () {} : controller.nextStep,
        behavior: HitTestBehavior.opaque, // Catch all touches in this rect
        child: Container(color: Colors.black54),
      ),
    );
  }

  Widget _buildHighlight(Rect targetRect) {
    return Positioned(
      left: targetRect.left - 8,
      top: targetRect.top - 8,
      width: targetRect.width + 16,
      height: targetRect.height + 16,
      child:
          Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CasinoColors.gold, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.03, 1.03),
                duration: 600.ms,
              ),
    );
  }

  Widget _buildInstructionCard(
    BuildContext context,
    InteractiveTutorialStep step,
    Rect? targetRect,
    Size screenSize,
  ) {
    // Position card away from target
    final isTopHalf = targetRect != null
        ? targetRect.center.dy < screenSize.height / 2
        : false;

    return Positioned(
      left: 24,
      right: 24,
      top: isTopHalf ? null : 60,
      bottom: isTopHalf ? 60 : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CasinoColors.cardBackground.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CasinoColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              Text(
                'Step ${controller.currentIndex + 1} of ${controller.steps.length}',
                style: TextStyle(
                  color: CasinoColors.gold.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                step.title,
                style: const TextStyle(
                  color: CasinoColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Instruction
              Text(
                step.instruction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      onSkip?.call();
                      controller.skip();
                      onComplete();
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: [
                      if (controller.currentIndex > 0)
                        TextButton(
                          onPressed: controller.previousStep,
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (!step.waitForAction)
                        ElevatedButton(
                          onPressed: () {
                            if (controller.currentIndex ==
                                controller.steps.length - 1) {
                              controller.complete();
                              onComplete();
                            } else {
                              controller.nextStep();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CasinoColors.gold,
                            foregroundColor: Colors.black,
                          ),
                          child: Text(
                            controller.currentIndex ==
                                    controller.steps.length - 1
                                ? 'Start Playing!'
                                : 'Next',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          controller.steps.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == controller.currentIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == controller.currentIndex
                  ? CasinoColors.gold
                  : CasinoColors.gold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

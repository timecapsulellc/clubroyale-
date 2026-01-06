import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Definition for a single step in the tutorial
class TutorialStep {
  final GlobalKey? targetKey; // The widget to highlight
  final String title;
  final String description;
  final Alignment tooltipAlignment; // Where to show tooltip relative to target

  TutorialStep({
    this.targetKey, // If null, shows as a general modal
    required this.title,
    required this.description,
    this.tooltipAlignment = Alignment.bottomCenter,
  });
}

/// Interactive Tutorial Overlay (Coach Marks)
class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentIndex = 0;

  void _nextStep() {
    if (_currentIndex < widget.steps.length - 1) {
      setState(() => _currentIndex++);
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onSkip?.call();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final step = widget.steps[_currentIndex];

    // Find target render box
    Rect? targetRect;
    if (step.targetKey != null && step.targetKey!.currentContext != null) {
      final renderBox =
          step.targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        targetRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        );
      }
    }

    return Stack(
      children: [
        // 1. Dimmed Background with Hole (Punch-out)
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.8),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              if (targetRect != null)
                Positioned(
                  left: targetRect.left - 8,
                  top: targetRect.top - 8,
                  width: targetRect.width + 16,
                  height: targetRect.height + 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 2. Pulse Animation on Target
        if (targetRect != null)
          Positioned(
            left: targetRect.left - 12,
            top: targetRect.top - 12,
            width: targetRect.width + 24,
            height: targetRect.height + 24,
            child:
                Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CasinoColors.gold, width: 2),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 800.ms,
                    )
                    .boxShadow(
                      begin: BoxShadow(
                        color: CasinoColors.gold.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                      end: BoxShadow(
                        color: CasinoColors.gold.withValues(alpha: 0.0),
                        blurRadius: 20,
                      ),
                    ),
          ),

        // 3. Tooltip / Instruction Card
        _buildTooltip(step, targetRect, MediaQuery.of(context).size),
      ],
    );
  }

  Widget _buildTooltip(TutorialStep step, Rect? targetRect, Size screenSize) {
    // Determine position based on target
    double? top, bottom, left, right;

    // Default centering
    if (targetRect == null) {
      left = 40;
      right = 40;
      top = screenSize.height * 0.4;
    } else {
      // Smart positioning logic
      final isTopHalf = targetRect.center.dy < screenSize.height / 2;

      if (isTopHalf) {
        top = targetRect.bottom + 30; // Show below
        left = 40;
        right = 40;
      } else {
        bottom = screenSize.height - targetRect.top + 30; // Show above
        left = 40;
        right = 40;
      }
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Material(
        // Material required for buttons
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CasinoColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CasinoColors.gold),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: CasinoColors.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _skip,
                            child: const Text(
                              'Skip Tutorial',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CasinoColors.gold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              _currentIndex == widget.steps.length - 1
                                  ? 'Finish'
                                  : 'Next',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms),
        ),
      ),
    );
  }
}

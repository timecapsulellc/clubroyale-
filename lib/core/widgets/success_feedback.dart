/// Success Feedback Widget - Animations for positive outcomes
///
/// Provides celebratory animations for wins, achievements, successful actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptic_helper.dart';

/// Premium success checkmark animation
class SuccessCheck extends StatelessWidget {
  final Color? color;
  final double size;
  
  const SuccessCheck({super.key, this.color, this.size = 64});
  
  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.green;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: effectiveColor,
        size: size * 0.5,
      ),
    ).animate().scale(delay: 100.ms, curve: Curves.elasticOut).fadeIn();
  }
}

/// Celebration overlay for wins
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool showCelebration;
  
  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.showCelebration,
  });
  
  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCelebration && !oldWidget.showCelebration) {
      HapticHelper.winCelebration();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showCelebration)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amber,
                      ).animate()
                        .scale(delay: 200.ms, curve: Curves.elasticOut)
                        .shake(delay: 600.ms, hz: 2),
                      const SizedBox(height: 16),
                      const Text(
                        'You Win!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Subtle success toast - non-intrusive feedback
class SuccessToast extends StatelessWidget {
  final String message;
  final IconData icon;
  
  const SuccessToast({
    super.key,
    required this.message,
    this.icon = Icons.check_circle,
  });
  
  static void show(BuildContext context, String message, {IconData? icon}) {
    HapticHelper.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Premium button with built-in loading state and haptic feedback
class PremiumButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final String? disabledReason;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.disabledReason,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final disabled = isDisabled || isLoading;
    
    return Tooltip(
      message: disabledReason ?? '',
      child: FilledButton(
        onPressed: disabled ? null : () {
          HapticHelper.lightTap();
          onPressed?.call();
        },
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(label),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

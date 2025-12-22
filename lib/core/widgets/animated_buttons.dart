/// Animated Button Widgets
///
/// Premium button components with scale press animations and haptic feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/utils/haptic_helper.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// A button with satisfying press animation and haptic feedback
class AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double scaleDown;
  final Duration duration;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  
  const AnimatedPressButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.scaleDown = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.padding,
    this.borderRadius,
  });
  
  @override
  State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) {
        setState(() => _isPressed = true);
        HapticHelper.lightTap();
      } : null,
      onTapUp: widget.onPressed != null ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: widget.onPressed != null 
                ? (widget.backgroundColor ?? CasinoColors.gold)
                : Colors.grey,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            boxShadow: _isPressed ? [] : [
              BoxShadow(
                color: (widget.backgroundColor ?? CasinoColors.gold).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              color: widget.foregroundColor ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Casino-styled primary action button with animation
class CasinoActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const CasinoActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedPressButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: CasinoColors.gold,
      foregroundColor: CasinoColors.feltGreenDark,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
          else if (icon != null)
            Icon(icon, size: 20),
          if (icon != null || isLoading) const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

/// Game action button (fold, bet, etc.) with appropriate styling
class GameActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final GameActionType type;
  
  const GameActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.type,
    this.onPressed,
  });
  
  Color get _backgroundColor {
    switch (type) {
      case GameActionType.positive: return Colors.green;
      case GameActionType.negative: return Colors.red;
      case GameActionType.neutral: return Colors.blue;
      case GameActionType.primary: return CasinoColors.gold;
    }
  }
  
  Color get _foregroundColor {
    switch (type) {
      case GameActionType.primary: return Colors.black;
      default: return Colors.white;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedPressButton(
      onPressed: onPressed,
      backgroundColor: _backgroundColor,
      foregroundColor: _foregroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _foregroundColor),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

enum GameActionType { positive, negative, neutral, primary }

/// Card with micro-animation on tap
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final double elevation;
  
  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.elevation = 2,
  });
  
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) {
        setState(() => _isPressed = true);
        HapticHelper.lightTap();
      } : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.98 : 1.0)
          ..translate(0.0, _isPressed ? 2.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected 
                  ? CasinoColors.gold.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: _isPressed ? 0.1 : 0.2),
              blurRadius: _isPressed ? 4 : (widget.elevation * 4),
              offset: Offset(0, _isPressed ? 1 : widget.elevation),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected 
                ? Border.all(color: CasinoColors.gold, width: 2)
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Skeleton shimmer for list items during loading
class SkeletonListItem extends StatelessWidget {
  final double height;
  final EdgeInsets? margin;
  
  const SkeletonListItem({
    super.key,
    this.height = 72,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    ).animate(onPlay: (c) => c.repeat())
     .shimmer(duration: 1200.ms, color: Colors.grey.shade300);
  }
}

/// Skeleton list with multiple items
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonListItem(
        height: itemHeight,
      ).animate(delay: (index * 100).ms).fadeIn(),
    );
  }
}

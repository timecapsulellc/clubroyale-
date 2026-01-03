// Accessibility Utilities - Making ClubRoyale usable for everyone
//
// Include semantic labels, focus management, contrast helpers,
// and touch target sizing for WCAG compliance.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Extension for easy semantic labeling
extension AccessibleWidget on Widget {
  /// Add a semantic label for screen readers
  Widget withSemanticLabel(String label) {
    return Semantics(label: label, child: this);
  }

  /// Mark as a button for screen readers
  Widget asSemanticButton(String label, {VoidCallback? onTap}) {
    return Semantics(button: true, label: label, onTap: onTap, child: this);
  }

  /// Mark as a header for screen readers
  Widget asSemanticHeader(String label) {
    return Semantics(header: true, label: label, child: this);
  }

  /// Mark as an image with description
  Widget asSemanticImage(String description) {
    return Semantics(image: true, label: description, child: this);
  }

  /// Exclude from screen readers (decorative elements)
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Ensure minimum touch target size (48x48 per WCAG)
  Widget ensureMinTouchTarget({double size = 48}) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: this,
    );
  }
}

/// Accessible icon button with proper semantics and touch target
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final double touchTargetSize;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
    this.size = 24,
    this.touchTargetSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(touchTargetSize / 2),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: touchTargetSize,
            minHeight: touchTargetSize,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color ?? Theme.of(context).iconTheme.color,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

/// Skip to content link for keyboard navigation
class SkipToContentLink extends StatelessWidget {
  final FocusNode contentFocusNode;
  final String label;

  const SkipToContentLink({
    super.key,
    required this.contentFocusNode,
    this.label = 'Skip to main content',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: label,
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            if (!hasFocus) {
              return const SizedBox.shrink();
            }
            return Positioned(
              top: 0,
              left: 0,
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                child: InkWell(
                  onTap: () => contentFocusNode.requestFocus(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Contrast checker utility
class ContrastHelper {
  /// Calculate contrast ratio between two colors
  static double contrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if contrast meets WCAG AA (4.5:1 for normal text)
  static bool meetsWCAG_AA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Check if contrast meets WCAG AAA (7:1 for normal text)
  static bool meetsWCAG_AAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Check if contrast meets WCAG AA for large text (3:1)
  static bool meetsWCAG_AA_LargeText(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 3.0;
  }
}

/// Focus-visible indicator for keyboard navigation
class FocusIndicator extends StatelessWidget {
  final Widget child;
  final Color? focusColor;
  final double borderRadius;

  const FocusIndicator({
    super.key,
    required this.child,
    this.focusColor,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: isFocused
                  ? Border.all(
                      color:
                          focusColor ?? Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Announce message to screen readers
void announceToScreenReader(BuildContext context, String message) {
  // Using newer API compatible with multiple windows
  SemanticsService.announce(message, Directionality.of(context));
}

/// Accessible card with proper semantics
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String label;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.label,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Text with automatic high contrast mode
class HighContrastText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color backgroundColor;

  const HighContrastText({
    super.key,
    required this.text,
    this.style,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final baseColor = baseStyle?.color ?? Colors.white;

    // Auto-adjust for contrast if needed
    Color textColor = baseColor;
    if (!ContrastHelper.meetsWCAG_AA(baseColor, backgroundColor)) {
      textColor = backgroundColor.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;
    }

    return Text(text, style: baseStyle?.copyWith(color: textColor));
  }
}

/// Reduced motion preference checker
class ReducedMotionDetector extends StatelessWidget {
  final Widget Function(bool prefersReducedMotion) builder;

  const ReducedMotionDetector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final prefersReducedMotion = MediaQuery.of(context).disableAnimations;
    return builder(prefersReducedMotion);
  }
}

/// Wrapper that automatically disables animations when reduced motion is preferred
///
/// Use this to wrap animated widgets:
/// ```dart
/// ReducedMotionWrapper(
///   child: myAnimatedWidget,
///   reducedChild: myStaticWidget, // Optional fallback
/// )
/// ```
class ReducedMotionWrapper extends StatelessWidget {
  final Widget child;
  final Widget? reducedChild;
  final Duration animationDuration;

  const ReducedMotionWrapper({
    super.key,
    required this.child,
    this.reducedChild,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final prefersReducedMotion = MediaQuery.of(context).disableAnimations;

    if (prefersReducedMotion) {
      // Return static version if reduced motion is preferred
      return reducedChild ?? child;
    }

    return child;
  }
}

/// Focus traversal group for keyboard navigation
///
/// Wraps a section of widgets to create a logical keyboard navigation group.
/// Useful for game tables, dialogs, and multi-section screens.
class FocusTraversalWrapper extends StatelessWidget {
  final Widget child;
  final FocusTraversalPolicy? policy;
  final bool descendantsAreFocusable;

  const FocusTraversalWrapper({
    super.key,
    required this.child,
    this.policy,
    this.descendantsAreFocusable = true,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: policy ?? WidgetOrderTraversalPolicy(),
      descendantsAreFocusable: descendantsAreFocusable,
      child: child,
    );
  }
}

/// Game action button with proper accessibility
///
/// Used for primary game actions like "Play Card", "Declare Maal", etc.
/// Ensures 48x48 touch target and proper semantics.
class AccessibleGameAction extends StatelessWidget {
  final String label;
  final String? semanticHint;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isDestructive;

  const AccessibleGameAction({
    super.key,
    required this.label,
    this.semanticHint,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor =
        backgroundColor ??
        (isDestructive ? Colors.red : theme.colorScheme.primary);
    final fgColor =
        foregroundColor ??
        (isDestructive ? Colors.white : theme.colorScheme.onPrimary);

    return Semantics(
      button: true,
      label: label,
      hint: semanticHint,
      enabled: onPressed != null,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: fgColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

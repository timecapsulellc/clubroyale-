/// Accessibility Utilities
/// 
/// Helpers for adding semantic labels and accessibility features.
library;

import 'package:flutter/material.dart';

/// Wrapper for adding semantics to interactive elements
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onTap;
  final bool isButton;
  
  const AccessibleButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onTap,
    this.isButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Wrapper for card display with semantic description
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String cardDescription;
  final bool isSelected;
  final bool isPlayable;
  
  const AccessibleCard({
    super.key,
    required this.child,
    required this.cardDescription,
    this.isSelected = false,
    this.isPlayable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: cardDescription,
      selected: isSelected,
      enabled: isPlayable,
      hint: isPlayable ? 'Double tap to play' : null,
      child: child,
    );
  }
}

/// Extension for adding accessibility to any widget
extension AccessibilityExtension on Widget {
  /// Add semantic label to widget
  Widget withSemantics({
    required String label,
    String? hint,
    bool? button,
    bool? selected,
    bool? enabled,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      selected: selected,
      enabled: enabled,
      child: this,
    );
  }
  
  /// Exclude from accessibility tree (for decorative elements)
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }
  
  /// Merge semantics with descendants
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}

/// Semantic labels for common game elements
class GameSemantics {
  static String card(String rank, String suit) => '$rank of $suit';
  
  static String chipAmount(int amount) => '$amount chips';
  
  static String diamondAmount(int amount) => '$amount diamonds';
  
  static String playerTurn(String playerName) => "$playerName's turn";
  
  static String bidAmount(int amount) => 'Bid $amount';
  
  static String score(String playerName, int score) => '$playerName has $score points';
  
  static String timer(int seconds) => '$seconds seconds remaining';
  
  static String meld(String type, int points) => '$type meld worth $points points';
}

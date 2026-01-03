/// Simple Game Action Buttons
///
/// Large, easy-to-tap action buttons for card games.
/// Designed for simple, intuitive gameplay UX.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Primary action button with prominent styling
class GameActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLarge;
  final bool isPulsing;

  const GameActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor = Colors.green,
    this.foregroundColor = Colors.white,
    this.isLarge = false,
    this.isPulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton();

    if (isPulsing && onPressed != null) {
      button = button
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 600.ms,
          );
    }

    return button;
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.3),
        disabledForegroundColor: foregroundColor.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 32 : 20,
          vertical: isLarge ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: onPressed != null ? 4 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isLarge ? 24 : 20),
            SizedBox(width: isLarge ? 10 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of simple action buttons for game screens
class SimpleActionBar extends StatelessWidget {
  final bool isMyTurn;
  final List<SimpleAction> actions;
  final Color backgroundColor;

  const SimpleActionBar({
    super.key,
    required this.isMyTurn,
    required this.actions,
    this.backgroundColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions.map((action) {
            final enabled = isMyTurn && action.enabled;
            return Expanded(
              flex: action.isPrimary ? 2 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GameActionButton(
                  label: action.label,
                  icon: action.icon,
                  onPressed: enabled ? action.onPressed : null,
                  backgroundColor: action.color,
                  foregroundColor: action.textColor,
                  isLarge: action.isPrimary,
                  isPulsing: action.isPrimary && enabled,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// An action for the SimpleActionBar
class SimpleAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool enabled;
  final bool isPrimary;

  const SimpleAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.color = Colors.grey,
    this.textColor = Colors.white,
    this.enabled = true,
    this.isPrimary = false,
  });

  /// Common actions
  static SimpleAction fold({VoidCallback? onPressed, bool enabled = true}) =>
      SimpleAction(
        label: 'Fold',
        icon: Icons.close,
        onPressed: onPressed,
        color: Colors.red.shade700,
        enabled: enabled,
      );

  static SimpleAction call({
    required int amount,
    VoidCallback? onPressed,
    bool enabled = true,
  }) => SimpleAction(
    label: 'Call ${amount > 0 ? amount : ''}',
    icon: Icons.check,
    onPressed: onPressed,
    color: Colors.blue.shade600,
    enabled: enabled,
    isPrimary: true,
  );

  static SimpleAction raise({
    required int amount,
    VoidCallback? onPressed,
    bool enabled = true,
  }) => SimpleAction(
    label: 'Raise $amount',
    icon: Icons.arrow_upward,
    onPressed: onPressed,
    color: Colors.amber.shade700,
    textColor: Colors.black,
    enabled: enabled,
    isPrimary: true,
  );

  static SimpleAction bet({
    required int amount,
    VoidCallback? onPressed,
    bool enabled = true,
  }) => SimpleAction(
    label: 'Bet $amount',
    icon: Icons.monetization_on,
    onPressed: onPressed,
    color: Colors.green.shade600,
    enabled: enabled,
    isPrimary: true,
  );

  static SimpleAction pass({VoidCallback? onPressed, bool enabled = true}) =>
      SimpleAction(
        label: 'Pass',
        icon: Icons.skip_next,
        onPressed: onPressed,
        color: Colors.grey.shade600,
        enabled: enabled,
      );

  static SimpleAction reveal({VoidCallback? onPressed, bool enabled = true}) =>
      SimpleAction(
        label: 'Reveal',
        icon: Icons.visibility,
        onPressed: onPressed,
        color: Colors.purple.shade600,
        enabled: enabled,
        isPrimary: true,
      );

  static SimpleAction see({VoidCallback? onPressed, bool enabled = true}) =>
      SimpleAction(
        label: 'See Cards',
        icon: Icons.remove_red_eye,
        onPressed: onPressed,
        color: Colors.orange.shade600,
        enabled: enabled,
      );

  static SimpleAction showdown({
    VoidCallback? onPressed,
    bool enabled = true,
  }) => SimpleAction(
    label: 'Show',
    icon: Icons.emoji_events,
    onPressed: onPressed,
    color: Colors.green.shade700,
    enabled: enabled,
    isPrimary: true,
  );
}

/// Quick amount selector for betting (simplified)
class QuickBetSelector extends StatelessWidget {
  final int currentBet;
  final int minBet;
  final int maxBet;
  final ValueChanged<int> onBetChanged;

  const QuickBetSelector({
    super.key,
    required this.currentBet,
    required this.minBet,
    required this.maxBet,
    required this.onBetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final presets = _calculatePresets();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current bet display
          Text(
            'Bet: $currentBet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Quick select buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: presets
                .map((amount) => _buildPresetButton(amount))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<int> _calculatePresets() {
    if (maxBet <= minBet) return [minBet];

    return [
      minBet,
      ((minBet + maxBet) / 4).round(),
      ((minBet + maxBet) / 2).round(),
      maxBet,
    ].where((v) => v >= minBet && v <= maxBet).toSet().toList()..sort();
  }

  Widget _buildPresetButton(int amount) {
    final isSelected = amount == currentBet;
    final label = amount == minBet
        ? 'Min'
        : (amount == maxBet ? 'Max' : '$amount');

    return GestureDetector(
      onTap: () => onBetChanged(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber.shade300 : Colors.grey.shade600,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

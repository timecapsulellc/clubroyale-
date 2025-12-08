// Keyboard Shortcuts Service
//
// Provides keyboard shortcuts for power users on web/desktop.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut definitions
class GameShortcuts {
  // Card selection (1-9 for card positions)
  static const card1 = SingleActivator(LogicalKeyboardKey.digit1);
  static const card2 = SingleActivator(LogicalKeyboardKey.digit2);
  static const card3 = SingleActivator(LogicalKeyboardKey.digit3);
  static const card4 = SingleActivator(LogicalKeyboardKey.digit4);
  static const card5 = SingleActivator(LogicalKeyboardKey.digit5);
  static const card6 = SingleActivator(LogicalKeyboardKey.digit6);
  static const card7 = SingleActivator(LogicalKeyboardKey.digit7);
  static const card8 = SingleActivator(LogicalKeyboardKey.digit8);
  static const card9 = SingleActivator(LogicalKeyboardKey.digit9);

  // Actions
  static const playCard = SingleActivator(LogicalKeyboardKey.enter);
  static const playCardAlt = SingleActivator(LogicalKeyboardKey.space);
  static const sortHand = SingleActivator(LogicalKeyboardKey.keyS);
  static const sortBySuit = SingleActivator(LogicalKeyboardKey.keyS, shift: true);
  
  // Navigation
  static const nextCard = SingleActivator(LogicalKeyboardKey.arrowRight);
  static const prevCard = SingleActivator(LogicalKeyboardKey.arrowLeft);
  static const selectCard = SingleActivator(LogicalKeyboardKey.arrowUp);
  static const deselectCard = SingleActivator(LogicalKeyboardKey.arrowDown);
  
  // UI
  static const toggleScores = SingleActivator(LogicalKeyboardKey.tab);
  static const toggleChat = SingleActivator(LogicalKeyboardKey.keyC);
  static const toggleMute = SingleActivator(LogicalKeyboardKey.keyM);
  static const showHelp = SingleActivator(LogicalKeyboardKey.f1);
  static const escape = SingleActivator(LogicalKeyboardKey.escape);
  
  // Quick actions
  static const quickBid1 = SingleActivator(LogicalKeyboardKey.digit1, control: true);
  static const quickBid2 = SingleActivator(LogicalKeyboardKey.digit2, control: true);
  static const quickBid3 = SingleActivator(LogicalKeyboardKey.digit3, control: true);
  
  // Bidding
  static const bidUp = SingleActivator(LogicalKeyboardKey.arrowUp, shift: true);
  static const bidDown = SingleActivator(LogicalKeyboardKey.arrowDown, shift: true);
  static const confirmBid = SingleActivator(LogicalKeyboardKey.enter, shift: true);
}

/// Keyboard shortcuts wrapper widget
class KeyboardShortcutsWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPlayCard;
  final VoidCallback? onSortHand;
  final VoidCallback? onToggleScores;
  final VoidCallback? onToggleChat;
  final VoidCallback? onToggleMute;
  final VoidCallback? onShowHelp;
  final VoidCallback? onEscape;
  final void Function(int index)? onSelectCard;
  final VoidCallback? onNextCard;
  final VoidCallback? onPrevCard;

  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.onPlayCard,
    this.onSortHand,
    this.onToggleScores,
    this.onToggleChat,
    this.onToggleMute,
    this.onShowHelp,
    this.onEscape,
    this.onSelectCard,
    this.onNextCard,
    this.onPrevCard,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Play card
        if (onPlayCard != null) ...<ShortcutActivator, VoidCallback>{
          GameShortcuts.playCard: onPlayCard!,
          GameShortcuts.playCardAlt: onPlayCard!,
        },
        
        // Sort
        if (onSortHand != null) GameShortcuts.sortHand: onSortHand!,
        
        // UI toggles
        if (onToggleScores != null) GameShortcuts.toggleScores: onToggleScores!,
        if (onToggleChat != null) GameShortcuts.toggleChat: onToggleChat!,
        if (onToggleMute != null) GameShortcuts.toggleMute: onToggleMute!,
        if (onShowHelp != null) GameShortcuts.showHelp: onShowHelp!,
        if (onEscape != null) GameShortcuts.escape: onEscape!,
        
        // Navigation
        if (onNextCard != null) GameShortcuts.nextCard: onNextCard!,
        if (onPrevCard != null) GameShortcuts.prevCard: onPrevCard!,
        
        // Card selection by number
        if (onSelectCard != null) ...<ShortcutActivator, VoidCallback>{
          GameShortcuts.card1: () => onSelectCard!(0),
          GameShortcuts.card2: () => onSelectCard!(1),
          GameShortcuts.card3: () => onSelectCard!(2),
          GameShortcuts.card4: () => onSelectCard!(3),
          GameShortcuts.card5: () => onSelectCard!(4),
          GameShortcuts.card6: () => onSelectCard!(5),
          GameShortcuts.card7: () => onSelectCard!(6),
          GameShortcuts.card8: () => onSelectCard!(7),
          GameShortcuts.card9: () => onSelectCard!(8),
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}

/// Keyboard shortcuts help dialog
class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard),
          SizedBox(width: 12),
          Text('Keyboard Shortcuts'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Card Selection', [
              _shortcut('1-9', 'Select card by position'),
              _shortcut('← / →', 'Navigate cards'),
              _shortcut('↑', 'Select highlighted card'),
              _shortcut('Enter / Space', 'Play selected card'),
            ]),
            const Divider(),
            _buildSection('Actions', [
              _shortcut('S', 'Sort hand by rank'),
              _shortcut('Shift + S', 'Sort hand by suit'),
              _shortcut('Tab', 'Toggle scoreboard'),
              _shortcut('C', 'Toggle chat'),
              _shortcut('M', 'Toggle mute'),
            ]),
            const Divider(),
            _buildSection('Bidding', [
              _shortcut('Ctrl + 1-8', 'Quick bid'),
              _shortcut('Shift + ↑/↓', 'Adjust bid'),
              _shortcut('Shift + Enter', 'Confirm bid'),
            ]),
            const Divider(),
            _buildSection('General', [
              _shortcut('F1', 'Show this help'),
              _shortcut('Esc', 'Close dialogs / Cancel'),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        ...shortcuts,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _shortcut(String keys, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(description),
        ],
      ),
    );
  }
}

/// AI Hint Service for Marriage Game
///
/// Provides intelligent suggestions to players based on bot strategy logic.
/// Helps beginners learn optimal moves while remaining fully optional.
library;

import 'package:flutter/material.dart' hide Card;
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_bot.dart';



/// Type of hint that can be shown to the player
enum HintType {
  drawSource,     // Whether to draw from deck or discard
  discardChoice,  // Which card to discard
  visitReady,     // When player can visit
  declareReady,   // When player can declare/finish
  meldSuggestion, // Cards that form potential melds
}

/// A single hint suggestion for the player
class GameHint {
  final HintType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? highlightCardIds; // Cards to highlight
  final String? actionLabel; // e.g., "Tap Deck" or "Discard This"

  const GameHint({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.highlightCardIds,
    this.actionLabel,
  });
}

/// AI Hint Service - Provides intelligent gameplay suggestions
class MarriageHintService {
  final MarriageBotStrategy _strategy;
  
  MarriageHintService({
    MarriageBotDifficulty difficulty = MarriageBotDifficulty.hard,
  }) : _strategy = MarriageBotStrategy(difficulty: difficulty);

  /// Get all available hints for the current game state
  List<GameHint> getHints({
    required List<Card> hand,
    required Card? topDiscard,
    required Card? tiplu,
    required bool hasVisited,
    required bool isDrawPhase,
    required bool isDiscardPhase,
    required bool canPickFromDiscard,
    required int deckCount,
  }) {
    final hints = <GameHint>[];

    // Draw Phase Hints
    if (isDrawPhase) {
      hints.add(_getDrawHint(
        hand: hand,
        topDiscard: topDiscard,
        tiplu: tiplu,
        hasVisited: hasVisited,
        canPickFromDiscard: canPickFromDiscard,
        deckCount: deckCount,
      ));
    }

    // Discard Phase Hints
    if (isDiscardPhase) {
      hints.add(_getDiscardHint(
        hand: hand,
        tiplu: tiplu,
      ));
    }

    // Visit Suggestion (if eligible)
    final visitHint = _getVisitHint(
      hand: hand,
      tiplu: tiplu,
      hasVisited: hasVisited,
    );
    if (visitHint != null) hints.add(visitHint);

    // Declare Suggestion (if can win)
    final declareHint = _getDeclareHint(
      hand: hand,
      tiplu: tiplu,
      hasVisited: hasVisited,
    );
    if (declareHint != null) hints.add(declareHint);

    // Meld Suggestions (always show what melds are forming)
    hints.addAll(_getMeldHints(hand: hand, tiplu: tiplu));

    return hints;
  }

  /// Get the primary hint (most important action to take now)
  GameHint? getPrimaryHint({
    required List<Card> hand,
    required Card? topDiscard,
    required Card? tiplu,
    required bool hasVisited,
    required bool isDrawPhase,
    required bool isDiscardPhase,
    required bool canPickFromDiscard,
    required int deckCount,
  }) {
    // Priority: Declare > Visit > Draw/Discard
    
    // Can we win?
    if (_strategy.shouldDeclare(
      hand: hand,
      tiplu: tiplu,
      hasVisited: hasVisited,
    )) {
      return _getDeclareHint(
        hand: hand,
        tiplu: tiplu,
        hasVisited: hasVisited,
      );
    }

    // Can we visit?
    if (!hasVisited && _strategy.shouldAttemptVisit(
      hand: hand,
      tiplu: tiplu,
      requiredSequences: 3,
    )) {
      return _getVisitHint(
        hand: hand,
        tiplu: tiplu,
        hasVisited: hasVisited,
      );
    }

    // Normal turn actions
    if (isDrawPhase) {
      return _getDrawHint(
        hand: hand,
        topDiscard: topDiscard,
        tiplu: tiplu,
        hasVisited: hasVisited,
        canPickFromDiscard: canPickFromDiscard,
        deckCount: deckCount,
      );
    }

    if (isDiscardPhase) {
      return _getDiscardHint(
        hand: hand,
        tiplu: tiplu,
      );
    }

    return null;
  }

  /// Generate draw phase hint
  GameHint _getDrawHint({
    required List<Card> hand,
    required Card? topDiscard,
    required Card? tiplu,
    required bool hasVisited,
    required bool canPickFromDiscard,
    required int deckCount,
  }) {
    final shouldUseDeck = _strategy.shouldDrawFromDeck(
      hand: hand,
      topDiscard: topDiscard,
      tiplu: tiplu,
      hasVisited: hasVisited,
      canPickFromDiscard: canPickFromDiscard,
    );

    if (shouldUseDeck || !canPickFromDiscard) {
      return GameHint(
        type: HintType.drawSource,
        title: '🃏 Draw from Deck',
        description: deckCount > 10 
            ? 'Plenty of cards in deck. Draw fresh!'
            : 'Tap the face-down deck to draw a new card.',
        icon: Icons.layers,
        color: Colors.blue,
        actionLabel: 'Tap Deck',
      );
    } else {
      final discardName = topDiscard != null 
          ? '${topDiscard.rank.symbol} of ${topDiscard.suit.symbol}'
          : 'Card';
      return GameHint(
        type: HintType.drawSource,
        title: '✨ Pick $discardName',
        description: 'This card helps form a meld! Tap the discard pile.',
        icon: Icons.auto_awesome,
        color: Colors.amber,
        highlightCardIds: topDiscard != null ? [topDiscard.id] : null,
        actionLabel: 'Tap Discard',
      );
    }
  }

  /// Generate discard phase hint
  GameHint _getDiscardHint({
    required List<Card> hand,
    required Card? tiplu,
  }) {
    final toDiscard = _strategy.chooseDiscard(
      hand: hand,
      tiplu: tiplu,
      lastDrawnCard: null, // We don't track this for hints
    );

    final cardName = '${toDiscard.rank.symbol}${toDiscard.suit.symbol}';
    
    return GameHint(
      type: HintType.discardChoice,
      title: '🗑️ Discard $cardName',
      description: 'This card doesn\'t help your melds. Safe to discard!',
      icon: Icons.remove_circle_outline,
      color: Colors.orange,
      highlightCardIds: [toDiscard.id],
      actionLabel: 'Tap to Discard',
    );
  }

  /// Generate visit hint (if eligible)
  GameHint? _getVisitHint({
    required List<Card> hand,
    required Card? tiplu,
    required bool hasVisited,
  }) {
    if (hasVisited) return null;

    if (_strategy.shouldAttemptVisit(
      hand: hand,
      tiplu: tiplu,
      requiredSequences: 3,
    )) {
      return const GameHint(
        type: HintType.visitReady,
        title: '🎉 You Can Visit!',
        description: 'You have 3 pure sequences! Tap VISIT to unlock Maal scoring.',
        icon: Icons.verified,
        color: Colors.green,
        actionLabel: 'Tap VISIT',
      );
    }

    return null;
  }

  /// Generate declare hint (if can win)
  GameHint? _getDeclareHint({
    required List<Card> hand,
    required Card? tiplu,
    required bool hasVisited,
  }) {
    if (_strategy.shouldDeclare(
      hand: hand,
      tiplu: tiplu,
      hasVisited: hasVisited,
    )) {
      return const GameHint(
        type: HintType.declareReady,
        title: '🏆 You Can Win!',
        description: 'All your cards form valid melds! Tap FINISH to declare.',
        icon: Icons.emoji_events,
        color: Colors.purple,
        actionLabel: 'Tap FINISH',
      );
    }

    return null;
  }

  /// Get meld formation hints
  List<GameHint> _getMeldHints({
    required List<Card> hand,
    required Card? tiplu,
  }) {
    final hints = <GameHint>[];
    final melds = MeldDetector.findAllMelds(hand, tiplu: tiplu);

    if (melds.isEmpty) {
      hints.add(const GameHint(
        type: HintType.meldSuggestion,
        title: '📝 Build Melds',
        description: 'Collect 3+ cards of same suit in sequence (Run) or same rank (Tunnel).',
        icon: Icons.lightbulb_outline,
        color: Colors.cyan,
      ));
    } else {
      // Show how many melds they have
      final pureCount = melds.where((m) => 
        m.type == MeldType.run || m.type == MeldType.tunnel
      ).length;

      hints.add(GameHint(
        type: HintType.meldSuggestion,
        title: '✅ ${melds.length} Melds Found',
        description: '$pureCount sequences detected. Need 3 pure sequences to visit!',
        icon: Icons.check_circle,
        color: Colors.teal,
        highlightCardIds: melds.expand((m) => m.cards.map((c) => c.id)).toList(),
      ));
    }

    return hints;
  }
}

/// Widget to display a game hint as a floating tooltip
class HintTooltip extends StatelessWidget {
  final GameHint hint;
  final VoidCallback? onDismiss;

  const HintTooltip({
    super.key,
    required this.hint,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hint.color.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: hint.color.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hint.icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hint.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  if (hint.actionLabel != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hint.actionLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Floating hint button that shows/hides hints
class HintButton extends StatefulWidget {
  final GameHint? currentHint;
  final bool hintsEnabled;
  final VoidCallback onToggle;

  const HintButton({
    super.key,
    this.currentHint,
    required this.hintsEnabled,
    required this.onToggle,
  });

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.currentHint != null ? _pulse.value : 1.0,
          child: FloatingActionButton.small(
            heroTag: 'hint_button',
            backgroundColor: widget.hintsEnabled 
                ? Colors.amber 
                : Colors.grey.shade600,
            onPressed: widget.onToggle,
            child: Icon(
              widget.hintsEnabled ? Icons.lightbulb : Icons.lightbulb_outline,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/core/localization/marriage_strings.dart';

/// An overlay widget that displays an enlarged card preview.
/// Shown on long-press of a card for better visibility.
class CardPreviewOverlay extends StatelessWidget {
  final PlayingCard card;
  final VoidCallback onDismiss;

  const CardPreviewOverlay({
    super.key,
    required this.card,
    required this.onDismiss,
  });

  /// Shows the card preview overlay using an OverlayEntry.
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, PlayingCard card) {
    dismiss(); // Dismiss any existing overlay first

    _currentOverlay = OverlayEntry(
      builder: (ctx) => CardPreviewOverlay(
        card: card,
        onDismiss: dismiss,
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Card preview: ${card.rank.name} of ${card.suit.name}. ${LocalizedStrings.tapToClose}',
      child: GestureDetector(
        onTap: onDismiss,
        onPanStart: (_) => onDismiss(),
        child: Material(
          color: Colors.black.withValues(alpha: 0.75),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card Info Header
                Text(
                  '${card.rank.name.toUpperCase()} of ${card.suit.name.toUpperCase()}',
                  style: const TextStyle(
                    color: CasinoColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                // Large Card Preview
                Hero(
                  tag: 'card_preview_${card.id}',
                  child: CardWidget(
                    card: card,
                    isFaceUp: true,
                    width: 180,
                    height: 260,
                  ),
                ),
                const SizedBox(height: 24),

                // Dismiss hint
                Text(
                  LocalizedStrings.tapToClose,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to easily add long-press preview capability to any card widget.
/// Wrap your CardWidget with this to enable long-press preview.
class CardWithPreview extends StatelessWidget {
  final PlayingCard card;
  final Widget child;

  const CardWithPreview({
    super.key,
    required this.card,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${card.rank.name} of ${card.suit.name}. Long press to enlarge.',
      child: GestureDetector(
        onLongPress: () => CardPreviewOverlay.show(context, card),
        onLongPressUp: () => CardPreviewOverlay.dismiss(),
        child: child,
      ),
    );
  }
}

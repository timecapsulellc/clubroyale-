import 'package:flutter/material.dart';
import 'package:myapp/features/game/engine/models/card.dart';
import 'package:myapp/features/game/engine/widgets/playing_card_widget.dart';

/// Widget to display a player's hand of cards in a fanned layout
class CardHandWidget extends StatelessWidget {
  final List<PlayingCard> cards;
  final List<PlayingCard> playableCards;
  final PlayingCard? selectedCard;
  final Function(PlayingCard) onCardTap;
  final bool isCompact;

  const CardHandWidget({
    super.key,
    required this.cards,
    this.playableCards = const [],
    this.selectedCard,
    required this.onCardTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(
        child: Text('No cards'),
      );
    }

    final cardWidth = isCompact ? 50.0 : 60.0;
    final cardHeight = isCompact ? 75.0 : 90.0;
    final overlap = cardWidth * 0.6;

    return SizedBox(
      height: cardHeight + 20, // Extra space for elevation when selected
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              cards.length,
              (index) {
                final card = cards[index];
                final isPlayable = playableCards.isEmpty ||
                    playableCards.any((c) => c.id == card.id);
                final isSelected = selectedCard?.id == card.id;

                return Container(
                  margin: EdgeInsets.only(
                    right: index < cards.length - 1 ? -overlap : 0,
                    top: isSelected ? 0 : 10,
                    bottom: isSelected ? 10 : 0,
                  ),
                  child: PlayingCardWidget(
                    card: card,
                    width: cardWidth,
                    height: cardHeight,
                    isPlayable: isPlayable,
                    isSelected: isSelected,
                    onTap: () => onCardTap(card),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for opponent's hidden cards
class OpponentHandWidget extends StatelessWidget {
  final int cardCount;
  final String playerName;

  const OpponentHandWidget({
    super.key,
    required this.cardCount,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerName,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              cardCount.clamp(0, 5), // Show max 5 cards
              (index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < cardCount - 1 ? -20 : 0,
                  ),
                  child: const PlayingCardWidget(
                    width: 40,
                    height: 60,
                    isFaceDown: true,
                  ),
                );
              },
            ),
          ),
        ),
        if (cardCount > 0)
          Text(
            '$cardCount cards',
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}

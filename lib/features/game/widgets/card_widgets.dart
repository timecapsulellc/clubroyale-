import 'package:flutter/material.dart';
import 'package:taasclub/features/game/engine/models/card.dart';

/// Helper to get asset path
String _getCardAssetPath(PlayingCard card) {
  String rankStr;
  switch (card.rank) {
    case CardRank.ace:
      rankStr = 'ace';
      break;
    case CardRank.jack:
      rankStr = 'jack';
      break;
    case CardRank.queen:
      rankStr = 'queen';
      break;
    case CardRank.king:
      rankStr = 'king';
      break;
    default:
      rankStr = card.rank.value.toString();
  }
  return 'assets/cards/png/${rankStr}_of_${card.suit.name}.png';
}

/// Widget to display a single playing card
class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
    this.width = 60,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        transform: isSelected
            ? (Matrix4.identity()..translate(0.0, -12.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: isSelected ? 12 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Opacity(
          opacity: isPlayable ? 1.0 : 0.6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _getCardAssetPath(card),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to basic rendering
                return _BasicCard(card: card, isSelected: isSelected, isPlayable: isPlayable);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BasicCard extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isPlayable;

  const _BasicCard({
    required this.card,
    required this.isSelected,
    required this.isPlayable,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRed = card.suit.isRed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : isPlayable
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.rank.displayString,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
          Text(
            card.suit.symbol,
            style: TextStyle(
              fontSize: 20,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display a back of card (face down)
class CardBackWidget extends StatelessWidget {
  final double width;
  final double height;

  const CardBackWidget({
    super.key,
    this.width = 60,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/cards/png/back.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Icon(
                  Icons.diamond,
                  color: Colors.white.withOpacity(0.5),
                  size: width * 0.4,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Widget to display player's hand of cards
class PlayerHandWidget extends StatelessWidget {
  final List<PlayingCard> cards;
  final PlayingCard? selectedCard;
  final CardSuit? requiredSuit;
  final ValueChanged<PlayingCard>? onCardSelected;
  final bool isMyTurn;

  const PlayerHandWidget({
    super.key,
    required this.cards,
    this.selectedCard,
    this.requiredSuit,
    this.onCardSelected,
    this.isMyTurn = false,
  });

  bool _canPlayCard(PlayingCard card) {
    if (!isMyTurn) return false;
    if (requiredSuit == null) return true;
    
    // Check if player has cards of required suit
    final hasRequiredSuit = cards.any((c) => c.suit == requiredSuit);
    if (hasRequiredSuit) {
      return card.suit == requiredSuit;
    }
    return true; // Can play any card if doesn't have required suit
  }

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards'));
    }

    // Group cards by suit for better display
    final sortedCards = List<PlayingCard>.from(cards);
    sortedCards.sort((a, b) {
      final suitCompare = a.suit.index.compareTo(b.suit.index);
      if (suitCompare != 0) return suitCompare;
      return b.rank.value.compareTo(a.rank.value);
    });

    // Calculate overlap based on number of cards
    final cardWidth = 60.0;
    final maxWidth = MediaQuery.of(context).size.width - 32;
    final totalWidth = cardWidth * sortedCards.length;
    final overlap = totalWidth > maxWidth
        ? (totalWidth - maxWidth) / (sortedCards.length - 1)
        : 0.0;

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedCards.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final card = sortedCards[index];
          final canPlay = _canPlayCard(card);
          
          return Transform.translate(
            offset: Offset(-overlap * index, 0),
            child: PlayingCardWidget(
              card: card,
              isSelected: selectedCard == card,
              isPlayable: canPlay,
              onTap: canPlay
                  ? () => onCardSelected?.call(card)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Mini card display for tricks
class MiniCardWidget extends StatelessWidget {
  final PlayingCard card;
  final String? playerName;

  const MiniCardWidget({
    super.key,
    required this.card,
    this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 70, // Standardize height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              _getCardAssetPath(card),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _BasicCard(
                     card: card, 
                     isSelected: false, 
                     isPlayable: true
                );
              },
            ),
          ),
        ),
        if (playerName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              playerName!,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

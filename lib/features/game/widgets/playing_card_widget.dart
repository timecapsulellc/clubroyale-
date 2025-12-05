import 'package:flutter/material.dart';
import 'package:myapp/features/game/models/card.dart';

/// Widget to display a single playing card
class PlayingCardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool isFaceDown;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.isFaceDown = false,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
    this.width = 60,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isPlayable && !isFaceDown ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isFaceDown ? Colors.blue.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade400,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isFaceDown
            ? _buildCardBack(theme)
            : card != null
                ? _buildCardFace(card!, theme)
                : _buildEmptyCard(theme),
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.casino,
        color: Colors.white,
        size: width * 0.4,
      ),
    );
  }

  Widget _buildCardFace(PlayingCard card, ThemeData theme) {
    final color = card.suit.isRed ? Colors.red.shade700 : Colors.black87;
    final isDisabled = !isPlayable;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top rank and suit
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.rank.displayString,
                    style: TextStyle(
                      fontSize: width * 0.25,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      fontSize: width * 0.25,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            // Center suit symbol
            Text(
              card.suit.symbol,
              style: TextStyle(
                fontSize: width * 0.5,
                color: color.withOpacity(0.3),
              ),
            ),
            // Bottom rank and suit (rotated)
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.rank.displayString,
                      style: TextStyle(
                        fontSize: width * 0.25,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      card.suit.symbol,
                      style: TextStyle(
                        fontSize: width * 0.25,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.crop_portrait,
        color: Colors.grey.shade300,
        size: width * 0.4,
      ),
    );
  }
}

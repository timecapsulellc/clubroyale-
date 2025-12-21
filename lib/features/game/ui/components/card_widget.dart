import 'package:flutter/material.dart';
import 'package:clubroyale/core/theme/app_theme.dart';
// content for card engine import might vary, assuming Card is imported from core/card_engine/pile.dart but `Card` name conflicts with Flutter Material Card.
// The game screen logic used `import 'package:flutter/material.dart' hide Card;`
import 'package:clubroyale/core/models/playing_card.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isFaceUp;
  final bool isSelectable;
  final double? width;
  final double? height;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isFaceUp = true,
    this.isSelectable = true,
    this.width,
    this.height,
    this.glowColor,
    this.cornerBadge,
  });

  final Color? glowColor;
  final Widget? cornerBadge;

  @override
  Widget build(BuildContext context) {
    // Default sizes
    final w = width ?? 60.0;
    final h = height ?? 85.0;
    final isLarge = w > 65;

    if (!isFaceUp) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
          gradient: const LinearGradient(
            colors: [AppTheme.teal, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(Icons.style, color: AppTheme.gold.withValues(alpha: 0.5), size: isLarge ? 32 : 24),
        ),
      );
    }

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: glowColor ?? (isSelected ? AppTheme.gold : Colors.grey.shade300),
          width: (isSelected || glowColor != null) ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor?.withValues(alpha: 0.6) ?? 
                   (isSelected ? AppTheme.gold.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.2)),
            blurRadius: (isSelected || glowColor != null) ? 8 : 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.rank.symbol,
                  style: TextStyle(
                    color: card.suit.isRed ? Colors.red : Colors.black,
                    fontSize: isLarge ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  card.suit.symbol,
                  style: TextStyle(
                    color: card.suit.isRed ? Colors.red : Colors.black,
                    fontSize: isLarge ? 20 : 16,
                  ),
                ),
              ],
            ),
          ),
          if (cornerBadge != null)
            Positioned(
              top: 2,
              right: 2,
              child: cornerBadge!,
            ),
        ],
      ),
    );
  }
}

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
    // Default sizes - increased for better mobile visibility
    final w = width ?? 75.0;
    final h = height ?? 110.0;
    final isLarge = w > 80;

    if (!isFaceUp) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
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
          child: Icon(
            Icons.style,
            color: AppTheme.gold.withValues(alpha: 0.5),
            size: isLarge ? 36 : 28,
          ),
        ),
      );
    }

    // Enhanced selection styling
    final effectiveGlow = glowColor ?? (isSelected ? AppTheme.gold : null);
    final hasSomeGlow = effectiveGlow != null;

    Widget cardContent = Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: effectiveGlow ?? Colors.grey.shade300,
          width: hasSomeGlow ? 3 : 1,
        ),
        boxShadow: [
          // Base shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
          // Glow effect for selected/maal cards
          if (hasSomeGlow)
            BoxShadow(
              color: effectiveGlow.withValues(alpha: 0.6),
              blurRadius: isSelected ? 16 : 10,
              spreadRadius: isSelected ? 2 : 1,
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
                    fontSize: isLarge ? 32 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  card.suit.symbol,
                  style: TextStyle(
                    color: card.suit.isRed ? Colors.red : Colors.black,
                    fontSize: isLarge ? 26 : 20,
                  ),
                ),
              ],
            ),
          ),
          // Corner badge (Maal indicator)
          if (cornerBadge != null)
            Positioned(top: 2, right: 2, child: cornerBadge!),
          // Selected badge
          if (isSelected)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Add lift effect for selected cards
    if (isSelected) {
      cardContent = Transform.translate(
        offset: const Offset(0, -8),
        child: Transform.scale(scale: 1.05, child: cardContent),
      );
    }

    return cardContent;
  }
}

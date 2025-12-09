import 'package:flutter/material.dart';
import 'package:taasclub/core/theme/app_theme.dart';
// content for card engine import might vary, assuming Card is imported from core/card_engine/pile.dart but `Card` name conflicts with Flutter Material Card.
// The game screen logic used `import 'package:flutter/material.dart' hide Card;`
import 'package:taasclub/core/card_engine/pile.dart' as game;

class CardWidget extends StatelessWidget {
  final game.Card card;
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
  });

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
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
          child: Icon(Icons.style, color: AppTheme.gold.withOpacity(0.5), size: isLarge ? 32 : 24),
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
          color: isSelected ? AppTheme.gold : Colors.grey.shade300,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? AppTheme.gold.withOpacity(0.5) 
                : Colors.black.withOpacity(0.2),
            blurRadius: isSelected ? 8 : 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
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
    );
  }
}

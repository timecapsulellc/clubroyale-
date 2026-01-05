import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

class MaalIndicatorHUD extends StatelessWidget {
  final PlayingCard? tiplu;
  final GlobalKey? tipluKey;
  final VoidCallback? onTap;

  const MaalIndicatorHUD({
    super.key,
    this.tiplu,
    this.tipluKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card widget to show: Face Down or Tiplu Face Up
    final Widget cardWidget;
    if (tiplu != null) {
      cardWidget = CardWidget(
        key: const ValueKey('maal_revealed'),
        card: tiplu!,
        isFaceUp: true,
        width: 50,
        height: 75, // Slightly larger for HUD
        glowColor: CasinoColors.gold,
      );
    } else {
      cardWidget = CardWidget(
        key: const ValueKey('maal_hidden'),
        card: PlayingCard(rank: CardRank.ace, suit: CardSuit.spades), // Dummy
        isFaceUp: false, // Force Face Down styling
        width: 50,
        height: 75,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: CasinoColors.gold,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CasinoColors.gold.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, size: 12, color: Colors.black87),
                const SizedBox(width: 4),
                Text(
                  'MAAL',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Card with Flip Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Flip Effect
              final rotateAnim = Tween(begin: 3.14, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotateAnim,
                child: child,
                builder: (context, child) {
                  final isUnder = (ValueKey(tiplu != null) != child?.key);
                  var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                  tilt *= isUnder ? -1.0 : 1.0;
                  final value = isUnder
                      ? math.min(rotateAnim.value, 3.14 / 2)
                      : rotateAnim.value;
                  return Transform(
                    transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              );
            },
            layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
            switchInCurve: Curves.easeInBack,
            switchOutCurve: Curves.easeOutBack,
            child: Container(
              key: tipluKey,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: cardWidget,
            ),
          ),
        ],
      ),
    );
  }
}

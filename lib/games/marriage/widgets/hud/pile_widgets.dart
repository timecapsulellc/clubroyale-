import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Enhanced deck pile with draw phase indication
class DrawPileWidget extends StatelessWidget {
  final int cardCount;
  final bool canDraw;
  final bool isDrawPhase;
  final VoidCallback? onTap;

  const DrawPileWidget({
    super.key,
    required this.cardCount,
    this.canDraw = false,
    this.isDrawPhase = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget pile = GestureDetector(
      onTap: canDraw ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tap to draw label (only when it's draw phase and can draw)
          if (isDrawPhase && canDraw)
            Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CasinoColors.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TAP TO DRAW',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                ),

          // Deck stack
          Stack(
            children: [
              // Shadow cards for depth
              for (int i = 2; i >= 0; i--)
                Transform.translate(
                  offset: Offset(i * 2.0, i * 2.0),
                  child: Container(
                    width: 70,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                      border: Border.all(color: Colors.white10),
                    ),
                  ),
                ),
              // Top card
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      CasinoColors.tableGreenDark,
                      CasinoColors.feltGreenDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: canDraw ? CasinoColors.gold : Colors.white24,
                    width: canDraw ? 2 : 1,
                  ),
                  boxShadow: canDraw
                      ? [
                          BoxShadow(
                            color: CasinoColors.gold.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.style,
                        color: CasinoColors.gold.withValues(alpha: 0.7),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$cardCount',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Add pulse animation when can draw and it's draw phase
    if (isDrawPhase && canDraw) {
      pile = pile
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: 800.ms,
          );
    }

    return pile;
  }
}

/// Enhanced discard pile with pickup indication
class DiscardPileWidget extends StatelessWidget {
  final Widget? topCard;
  final int cardCount;
  final bool canPickup;
  final bool isBlocked; // Joker block
  final VoidCallback? onTap;

  const DiscardPileWidget({
    super.key,
    this.topCard,
    required this.cardCount,
    this.canPickup = false,
    this.isBlocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canPickup && !isBlocked ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status label
          if (isBlocked)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'BLOCKED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else if (canPickup)
            Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'OR TAP HERE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                ),

          // Discard pile
          Container(
            width: 75,
            height: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black26,
              border: Border.all(
                color: isBlocked
                    ? Colors.red.withValues(alpha: 0.5)
                    : (canPickup ? Colors.blue : Colors.white24),
                width: canPickup ? 2 : 1,
                style: BorderStyle.solid,
              ),
            ),
            child: topCard != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: topCard!,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.layers,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 24,
                        ),
                        Text(
                          '$cardCount',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/games/marriage/widgets/hud/discard_pile_viewer.dart';

/// Professional center table area with deck, discard, and tiplu display
class CenterTableArea extends StatelessWidget {
  final int deckCount;
  final PlayingCard? topDiscard;
  final List<PlayingCard>? discardPile; // Full list for viewer
  final PlayingCard? tiplu;
  final int discardCount;
  final bool canDrawFromDeck;
  final bool canDrawFromDiscard;
  final bool isDiscardBlocked; // Joker block
  final bool isMyTurn;
  final String turnPhase; // 'drawing' or 'discarding'
  final VoidCallback? onDeckTap;
  final VoidCallback? onDiscardTap;

  const CenterTableArea({
    super.key,
    required this.deckCount,
    this.topDiscard,
    this.discardPile,
    this.tiplu,
    required this.discardCount,
    this.canDrawFromDeck = false,
    this.canDrawFromDiscard = false,
    this.isDiscardBlocked = false,
    this.isMyTurn = false,
    this.turnPhase = 'drawing',
    this.onDeckTap,
    this.onDiscardTap,
    this.deckKey,
    this.discardKey,
    this.tipluKey,
    this.showTiplu = true,
  });

  final bool showTiplu;

  final GlobalKey? deckKey;
  final GlobalKey? discardKey;
  final GlobalKey? tipluKey;

  @override
  Widget build(BuildContext context) {
    final isDrawPhase = turnPhase == 'drawing';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CasinoColors.gold.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Deck and Discard row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Deck
              _buildDeckPile(isDrawPhase),
              const SizedBox(width: 24),
              // Discard
              _buildDiscardPile(context, isDrawPhase),
            ],
          ),

          // Tiplu indicator (Conditionally shown)
          if (showTiplu) ...[
            const SizedBox(height: 12),
            _buildTipluIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildDeckPile(bool isDrawPhase) {
    final canDraw = canDrawFromDeck && isMyTurn && isDrawPhase;

    Widget deck = GestureDetector(
      onTap: canDraw ? onDeckTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: canDraw ? CasinoColors.gold : Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'DECK',
              style: TextStyle(
                color: canDraw ? Colors.black : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          // Card stack
          Stack(
            children: [
              // Shadow cards
              for (int i = 2; i >= 0; i--)
                Transform.translate(
                  offset: Offset(i * 1.5, i * 1.5),
                  child: Container(
                    width: 60,
                    height: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF2a1f4e),
                      border: Border.all(color: Colors.white10),
                    ),
                  ),
                ),
              // Top card
              Container(
                width: 60,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3b2066), Color(0xFF2a1f4e)],
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
                          ),
                        ]
                      : null,
                ),
                key: deckKey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.style,
                        color: CasinoColors.gold.withValues(alpha: 0.7),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$deckCount',
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

          // Tap instruction
          if (canDraw)
            Container(
                  margin: const EdgeInsets.only(top: 6),
                  child: const Text(
                    'TAP',
                    style: TextStyle(
                      color: CasinoColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                ),
        ],
      ),
    );

    if (canDraw) {
      deck = deck
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.02, 1.02),
            duration: 800.ms,
          );
    }

    return deck;
  }

  Widget _buildDiscardPile(BuildContext context, bool isDrawPhase) {
    final canDraw =
        canDrawFromDiscard && isMyTurn && isDrawPhase && !isDiscardBlocked;

    return GestureDetector(
      onTap: canDraw ? onDiscardTap : null,
      onLongPress: () {
        if (discardPile != null && discardPile!.isNotEmpty) {
          DiscardPileViewer.show(context, discardPile!);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with status
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDiscardBlocked
                  ? Colors.red[900]
                  : (canDraw ? Colors.blue : Colors.grey[800]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isDiscardBlocked) ...[
                  const Icon(Icons.block, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                ],
                Text(
                  isDiscardBlocked ? 'BLOCKED' : 'DISCARD',
                  style: TextStyle(
                    color: isDiscardBlocked
                        ? Colors.white
                        : (canDraw ? Colors.white : Colors.white60),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Discard pile - Fanned display for realism
          SizedBox(
            width: 100, // Wider to accommodate fanned cards
            height: 95,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Base container
                Container(
                  width: 70,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black.withValues(alpha: 0.2),
                    border: Border.all(
                      color: isDiscardBlocked
                          ? Colors.red.withValues(alpha: 0.5)
                          : (canDraw ? Colors.blue : Colors.white12),
                      width: 1,
                    ),
                  ),
                ),
                // Fanned cards (last 5)
                if (discardPile != null && discardPile!.isNotEmpty)
                  ..._buildFannedDiscardCards(canDraw)
                else if (topDiscard != null)
                  // Fallback to single card if no pile data
                  Container(
                    key: discardKey,
                    child: CardWidget(
                      card: topDiscard!,
                      isFaceUp: true,
                      width: 55,
                      height: 80,
                    ),
                  )
                else
                  // Empty pile placeholder
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.layers,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 20,
                      ),
                      Text(
                        '$discardCount',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Tap instruction
          if (canDraw)
            Container(
              margin: const EdgeInsets.only(top: 6),
              child: const Text(
                'OR TAP',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipluIndicator() {
    // Determine card widget to show: Face Down or Tiplu Face Up
    // Note: tiplu parameter is null if not revealed/visited
    final Widget cardWidget;
    if (tiplu != null) {
      cardWidget = CardWidget(
        key: const ValueKey('tiplu_revealed'),
        card: tiplu!,
        isFaceUp: true,
        width: 45,
        height: 65,
        glowColor: CasinoColors.gold,
      );
    } else {
      cardWidget = CardWidget(
        key: const ValueKey('tiplu_hidden'),
        card: PlayingCard(rank: CardRank.ace, suit: CardSuit.spades), // Dummy
        isFaceUp: false, // Force Face Down styling
        width: 45,
        height: 65,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          child: cardWidget,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tiplu != null ? 'TIPLU' : 'HIDDEN',
            style: const TextStyle(
              color: CasinoColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds fanned discard pile cards (last 5) with rotation and offset
  List<Widget> _buildFannedDiscardCards(bool canDraw) {
    final pile = discardPile!;
    final count = pile.length;
    final displayCount = count > 5 ? 5 : count;
    final startIndex = count - displayCount;
    
    return List.generate(displayCount, (i) {
      final actualIndex = startIndex + i;
      final card = pile[actualIndex];
      final isTopCard = i == displayCount - 1;
      
      // Rotation: slight random-looking angles centered around 0
      final rotationAngles = [-0.08, -0.04, 0.02, -0.03, 0.0];
      final angle = displayCount > i ? rotationAngles[i % 5] : 0.0;
      
      // Offset: fan out horizontally
      final xOffset = (i - (displayCount - 1) / 2) * 8.0;
      final yOffset = i * 1.0; // Slight vertical stacking
      
      // Opacity: older cards more faded
      final opacity = 0.5 + (i * 0.1);
      
      return Positioned(
        left: 20 + xOffset,
        top: 5 + yOffset,
        child: Transform.rotate(
          angle: angle,
          child: Opacity(
            opacity: isTopCard ? 1.0 : opacity,
            child: Container(
              key: isTopCard ? discardKey : null,
              decoration: isTopCard && canDraw
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    )
                  : null,
              child: CardWidget(
                card: card,
                isFaceUp: true,
                width: 50,
                height: 72,
              ),
            ),
          ),
        ),
      );
    });
  }
}

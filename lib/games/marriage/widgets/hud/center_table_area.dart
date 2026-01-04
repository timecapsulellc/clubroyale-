import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

/// Professional center table area with deck, discard, and tiplu display
class CenterTableArea extends StatelessWidget {
  final int deckCount;
  final PlayingCard? topDiscard;
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
  });

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
              _buildDiscardPile(isDrawPhase),
            ],
          ),

          // Tiplu indicator (if revealed)
          if (tiplu != null) ...[
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

  Widget _buildDiscardPile(bool isDrawPhase) {
    final canDraw =
        canDrawFromDiscard && isMyTurn && isDrawPhase && !isDiscardBlocked;

    return GestureDetector(
      onTap: canDraw ? onDiscardTap : null,
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

          // Discard pile
          Container(
            width: 60,
            height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(
                color: isDiscardBlocked
                    ? Colors.red.withValues(alpha: 0.5)
                    : (canDraw ? Colors.blue : Colors.white24),
                width: canDraw ? 2 : 1,
              ),
            ),
            child: Container(
              key: discardKey,
              child: topDiscard != null
                  ? Center(
                      child: CardWidget(
                        card: topDiscard!,
                        isFaceUp: true,
                        width: 55,
                        height: 80,
                      ),
                    )
                  : Center(
                      child: Column(
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
                    ),
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
    return Container(
      key: tipluKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'TIPLU: ',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${tiplu!.rank.symbol}${tiplu!.suit.symbol}',
              style: TextStyle(
                color: tiplu!.suit.isRed ? Colors.red : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '(3 pts)',
            style: TextStyle(color: Colors.amber, fontSize: 9),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}


import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

class DiscardPileViewer extends StatelessWidget {
  final List<PlayingCard> discardedCards;

  const DiscardPileViewer({
    super.key,
    required this.discardedCards,
  });

  static Future<void> show(BuildContext context, List<PlayingCard> cards) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DiscardPileViewer(discardedCards: cards),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: CasinoColors.tableGreenDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.history, color: CasinoColors.gold),
                const SizedBox(width: 8),
                Text(
                  'Discard Pile (${discardedCards.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10),

          // Cards List
          Expanded(
            child: discardedCards.isEmpty
                ? Center(
                    child: Text(
                      'No cards discarded yet',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // 5 cards per row
                      childAspectRatio: 0.7, // Card ratio
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: discardedCards.length,
                    itemBuilder: (context, index) {
                      // Show latest cards last (bottom)
                      final card = discardedCards[index];
                      // Highlight the most recent discard (last in list)
                      final isLast = index == discardedCards.length - 1;
                      
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CardWidget(
                            card: card,
                            width: double.infinity,
                            isFaceUp: true,
                            glowColor: isLast ? CasinoColors.gold : null,
                          ),
                          if (isLast)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: CasinoColors.gold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

/// Modal dialog showing a player's declared sets in a zoomed view.
class PlayerSetsZoomModal extends StatelessWidget {
  final String playerName;
  final List<List<PlayingCard>> declaredSets;
  final int? maalPoints;

  const PlayerSetsZoomModal({
    super.key,
    required this.playerName,
    required this.declaredSets,
    this.maalPoints,
  });

  static void show(
    BuildContext context, {
    required String playerName,
    required List<List<PlayingCard>> declaredSets,
    int? maalPoints,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => PlayerSetsZoomModal(
        playerName: playerName,
        declaredSets: declaredSets,
        maalPoints: maalPoints,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Player sets modal for $playerName. ${declaredSets.length} sets declared.',
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        decoration: BoxDecoration(
          color: CasinoColors.feltGreenDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CasinoColors.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: CasinoColors.gold.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: CasinoColors.gold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      playerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (maalPoints != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Maal: $maalPoints',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Sets Display
            Flexible(
              child: declaredSets.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No sets declared yet',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: declaredSets.asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final cards = entry.value;
                          return _buildSetGroup(setIndex + 1, cards);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSetGroup(int setNumber, List<PlayingCard> cards) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set $setNumber',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: cards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              return Transform.translate(
                offset: Offset(index * -15.0, 0), // Overlap
                child: CardWidget(
                  card: card,
                  isFaceUp: true,
                  width: 50,
                  height: 70,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

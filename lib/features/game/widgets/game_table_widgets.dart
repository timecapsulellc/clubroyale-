import 'package:flutter/material.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/animations/card_animations.dart';
import 'card_widgets.dart';

/// Widget to display the current trick (cards played in center)
class TrickAreaWidget extends StatelessWidget {
  final Trick? currentTrick;
  final Map<String, String> playerNames;
  final String? winnerId;

  const TrickAreaWidget({
    super.key,
    this.currentTrick,
    required this.playerNames,
    this.winnerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (currentTrick == null || currentTrick!.cards.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              Text(
                'Play a card',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Position cards around the center
    final cards = currentTrick!.cards;
    final positions = _getCardPositions(cards.length);

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.green.shade800.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
          
          // Trump indicator
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('♠', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 4),
                  Text(
                    'TRUMP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Played cards
          ...cards.asMap().entries.map((entry) {
            final index = entry.key;
            final playedCard = entry.value;
            final position = positions[index];
            final isWinner = winnerId == playedCard.playerId;
            
            // Calculate entry offset based on position (slide in from edge)
            final entryOffset = Offset(
              position.dx > 110 ? 50.0 : (position.dx < 110 ? -50.0 : 0.0),
              position.dy > 110 ? 50.0 : (position.dy < 110 ? -50.0 : 0.0),
            );

            return Positioned(
              left: position.dx,
              top: position.dy,
              child: AnimatedCardPlay(
                isPlaying: true,
                targetOffset: Offset.zero, // Already positioned by Stack
                child: Container(
                  decoration: isWinner
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                      : null,
                  child: MiniCardWidget(
                    card: playedCard.card,
                    playerName: playerNames[playedCard.playerId],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Offset> _getCardPositions(int count) {
    // Position cards based on number played
    const centerX = 85.0; // (220 - 50) / 2
    const centerY = 75.0;
    const radius = 60.0;

    switch (count) {
      case 1:
        return [Offset(centerX, centerY)];
      case 2:
        return [
          Offset(centerX - 30, centerY),
          Offset(centerX + 30, centerY),
        ];
      case 3:
        return [
          Offset(centerX, centerY - 35),
          Offset(centerX - 40, centerY + 20),
          Offset(centerX + 40, centerY + 20),
        ];
      case 4:
        return [
          Offset(centerX, centerY - 40), // Top
          Offset(centerX + 50, centerY), // Right
          Offset(centerX, centerY + 40), // Bottom
          Offset(centerX - 50, centerY), // Left
        ];
      default:
        return [];
    }
  }
}

/// Widget showing player's bid and tricks won
class PlayerBidStatus extends StatelessWidget {
  final String playerName;
  final int? bid;
  final int tricksWon;
  final bool isCurrentTurn;
  final bool isWinning;

  const PlayerBidStatus({
    super.key,
    required this.playerName,
    this.bid,
    required this.tricksWon,
    this.isCurrentTurn = false,
    this.isWinning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final madeBid = bid != null && tricksWon >= bid!;
    final failedBid = bid != null && (13 - tricksWon) < (bid! - tricksWon);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(color: colorScheme.primary, width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: isCurrentTurn ? colorScheme.primary : Colors.grey,
            child: Text(
              playerName[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          
          // Name and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playerName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (bid != null)
                Text(
                  '$tricksWon / $bid tricks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: madeBid
                        ? Colors.green
                        : failedBid
                            ? Colors.red
                            : colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Text(
                  'Bidding...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          
          // Status indicator
          if (isWinning) ...[
            const SizedBox(width: 8),
            Icon(Icons.star, size: 16, color: Colors.amber.shade600),
          ],
        ],
      ),
    );
  }
}

/// Widget showing round scores
class RoundScoreCard extends StatelessWidget {
  final int roundNumber;
  final Map<String, int> bids;
  final Map<String, int> tricksWon;
  final Map<String, double> scores;
  final Map<String, String> playerNames;

  const RoundScoreCard({
    super.key,
    required this.roundNumber,
    required this.bids,
    required this.tricksWon,
    required this.scores,
    required this.playerNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Round $roundNumber Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            
            // Header row
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Player')),
                const Expanded(child: Text('Bid', textAlign: TextAlign.center)),
                const Expanded(child: Text('Won', textAlign: TextAlign.center)),
                const Expanded(child: Text('Score', textAlign: TextAlign.center)),
              ],
            ),
            const SizedBox(height: 8),
            
            // Player rows
            ...playerNames.entries.map((entry) {
              final playerId = entry.key;
              final name = entry.value;
              final bid = bids[playerId] ?? 0;
              final won = tricksWon[playerId] ?? 0;
              final score = scores[playerId] ?? 0.0;
              final made = won >= bid;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(name, style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        '$bid',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$won',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: made ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${score >= 0 ? '+' : ''}${score.toStringAsFixed(1)}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: score >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

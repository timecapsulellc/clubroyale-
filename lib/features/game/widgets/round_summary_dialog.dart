import 'package:flutter/material.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/models/game_state.dart';

/// Dialog showing round results
class RoundSummaryDialog extends StatelessWidget {
  final int roundNumber;
  final int totalRounds;
  final List<Player> players;
  final Map<String, Bid> bids;
  final Map<String, int> tricksWon;
  final Map<String, int> cumulativeScores;
  final VoidCallback onNextRound;
  final VoidCallback? onEndGame;
  final bool isFinalRound;

  const RoundSummaryDialog({
    super.key,
    required this.roundNumber,
    required this.totalRounds,
    required this.players,
    required this.bids,
    required this.tricksWon,
    required this.cumulativeScores,
    required this.onNextRound,
    this.onEndGame,
    this.isFinalRound = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate round scores for each player
    final roundScores = <String, double>{};
    for (final player in players) {
      final bid = bids[player.id];
      final tricks = tricksWon[player.id] ?? 0;
      if (bid != null) {
        if (tricks >= bid.amount) {
          roundScores[player.id] = bid.amount + (0.1 * (tricks - bid.amount));
        } else {
          roundScores[player.id] = -bid.amount.toDouble();
        }
      }
    }

    // Sort players by cumulative score
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => (cumulativeScores[b.id] ?? 0)
          .compareTo(cumulativeScores[a.id] ?? 0));

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Icon(
              isFinalRound ? Icons.emoji_events : Icons.scoreboard,
              size: 48,
              color: isFinalRound ? Colors.amber : theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isFinalRound ? 'Game Complete!' : 'Round $roundNumber Complete',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isFinalRound)
              Text(
                '$roundNumber of $totalRounds rounds',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 24),

            // Player scores table
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header row
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Expanded(flex: 2, child: Text('Player')),
                        Expanded(
                          child: Text(
                            'Bid',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Won',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Round',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Total',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Player rows
                  ...sortedPlayers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final bid = bids[player.id];
                    final tricks = tricksWon[player.id] ?? 0;
                    final roundScore = roundScores[player.id] ?? 0;
                    final totalScore = cumulativeScores[player.id] ?? 0;
                    final madeBid = bid != null && tricks >= bid.amount;

                    return Container(
                      color: index == 0 && isFinalRound
                          ? Colors.amber.withOpacity(0.2)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Player name with position indicator
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                if (index == 0 && isFinalRound) ...[
                                  const Icon(Icons.emoji_events,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    player.profile?.displayName ?? player.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: index == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bid
                          Expanded(
                            child: Text(
                              bid?.amount.toString() ?? '-',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Tricks won
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('$tricks'),
                                const SizedBox(width: 4),
                                Icon(
                                  madeBid
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 14,
                                  color: madeBid ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                          ),
                          // Round score
                          Expanded(
                            child: Text(
                              roundScore >= 0
                                  ? '+${roundScore.toStringAsFixed(1)}'
                                  : roundScore.toStringAsFixed(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    roundScore >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Total score
                          Expanded(
                            child: Text(
                              totalScore.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isFinalRound && onEndGame != null)
                  TextButton(
                    onPressed: onEndGame,
                    child: const Text('End Game Early'),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: isFinalRound ? onEndGame : onNextRound,
                  icon: Icon(
                      isFinalRound ? Icons.emoji_events : Icons.arrow_forward),
                  label: Text(isFinalRound ? 'View Results' : 'Next Round'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

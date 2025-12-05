import 'package:flutter/material.dart';
import 'package:myapp/features/game/engine/models/card.dart';
import 'package:myapp/features/game/models/game_state.dart';
import 'package:myapp/features/game/game_room.dart';

/// Heads-up display showing game information
class GameHUDWidget extends StatelessWidget {
  final int currentRound;
  final int totalRounds;
  final GamePhase? gamePhase;
  final Map<String, Bid> bids;
  final Map<String, int> tricksWon;
  final List<Player> players;
  final String? currentTurnPlayerId;
  final String currentUserId;

  const GameHUDWidget({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    this.gamePhase,
    required this.bids,
    required this.tricksWon,
    required this.players,
    this.currentTurnPlayerId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Round indicator
          Expanded(
            child: _buildInfoChip(
              context,
              icon: Icons.replay,
              label: 'Round',
              value: '$currentRound/$totalRounds',
            ),
          ),
          const SizedBox(width: 8),
          
          // Trump suit indicator
          Expanded(
            child: _buildInfoChip(
              context,
              icon: Icons.workspace_premium,
              label: 'Trump',
              value: trumpSuit.symbol,
              valueColor: trumpSuit.isRed ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          
          // Phase indicator
          if (gamePhase != null)
            Expanded(
              child: _buildInfoChip(
                context,
                icon: _getPhaseIcon(gamePhase!),
                label: 'Phase',
                value: _getPhaseLabel(gamePhase!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(GamePhase phase) {
    switch (phase) {
      case GamePhase.bidding:
        return Icons.gavel;
      case GamePhase.playing:
        return Icons.casino;
      case GamePhase.roundEnd:
        return Icons.scoreboard;
      case GamePhase.gameFinished:
        return Icons.emoji_events;
    }
  }

  String _getPhaseLabel(GamePhase phase) {
    switch (phase) {
      case GamePhase.bidding:
        return 'Bidding';
      case GamePhase.playing:
        return 'Playing';
      case GamePhase.roundEnd:
        return 'Round End';
      case GamePhase.gameFinished:
        return 'Finished';
    }
  }
}

/// Widget showing player scores and bids during gameplay
class PlayerScoresWidget extends StatelessWidget {
  final List<Player> players;
  final Map<String, Bid> bids;
  final Map<String, int> tricksWon;
  final Map<String, int> scores;
  final String currentUserId;
  final String? currentTurnPlayerId;

  const PlayerScoresWidget({
    super.key,
    required this.players,
    required this.bids,
    required this.tricksWon,
    required this.scores,
    required this.currentUserId,
    this.currentTurnPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scores',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...players.map((player) {
              final bid = bids[player.id];
              final tricks = tricksWon[player.id] ?? 0;
              final score = scores[player.id] ?? 0;
              final isCurrentTurn = currentTurnPlayerId == player.id;
              final isCurrentUser = player.id == currentUserId;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentTurn
                      ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrentUser
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    if (isCurrentTurn)
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isCurrentUser ? 'You' : player.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (bid != null)
                      Text(
                        'Bid: ${bid.amount}',
                        style: theme.textTheme.bodySmall,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      'Tricks: $tricks',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Score: $score',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: score >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

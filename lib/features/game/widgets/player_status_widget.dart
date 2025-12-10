import 'package:flutter/material.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/models/game_state.dart';

/// Widget showing player status around the game table
class PlayerStatusWidget extends StatelessWidget {
  final Player player;
  final int? bid;
  final int tricksWon;
  final int cardCount;
  final bool isCurrentTurn;
  final bool isCurrentUser;
  final int score;
  final TablePosition position;

  const PlayerStatusWidget({
    super.key,
    required this.player,
    this.bid,
    this.tricksWon = 0,
    this.cardCount = 13,
    this.isCurrentTurn = false,
    this.isCurrentUser = false,
    this.score = 0,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar and name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Turn indicator
              if (isCurrentTurn)
                Icon(
                  Icons.arrow_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: player.profile?.avatarUrl != null
                    ? NetworkImage(player.profile!.avatarUrl!)
                    : null,
                child: player.profile?.avatarUrl == null
                    ? Text(
                        player.name[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCurrentUser
                        ? 'You'
                        : (player.profile?.displayName ?? player.name),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrentTurn
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cardCount > 0)
                    Text(
                      '$cardCount cards',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stats row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bid != null) ...[
                _StatChip(
                  label: 'Bid',
                  value: '$bid',
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
              ],
              _StatChip(
                label: 'Won',
                value: '$tricksWon',
                color: tricksWon > 0 ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 6),
              _StatChip(
                label: 'Score',
                value: '$score',
                color: score >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// Position of a player around the table
enum TablePosition { bottom, left, top, right }

/// Helper to get player positions based on current user index
class PlayerPositionHelper {
  static Map<String, TablePosition> getPositions(
    List<Player> players,
    String currentUserId,
  ) {
    final positions = <String, TablePosition>{};
    final currentUserIndex = players.indexWhere((p) => p.id == currentUserId);

    if (currentUserIndex == -1) return positions;

    final positionOrder = [
      TablePosition.bottom, // Current user
      TablePosition.left,
      TablePosition.top,
      TablePosition.right,
    ];

    for (int i = 0; i < players.length && i < 4; i++) {
      final playerIndex = (currentUserIndex + i) % players.length;
      positions[players[playerIndex].id] = positionOrder[i];
    }

    return positions;
  }
}

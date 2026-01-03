import 'package:flutter/material.dart';
import 'package:clubroyale/features/game/game_room.dart';

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
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
        boxShadow: isCurrentTurn
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
        color: color.withValues(alpha: 0.2),
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

/// Position of a player around the table (supports up to 8 players)
enum TablePosition {
  bottom, // Position 0 - Current user (always at bottom)
  bottomLeft, // Position 1
  left, // Position 2
  topLeft, // Position 3
  top, // Position 4
  topRight, // Position 5
  right, // Position 6
  bottomRight, // Position 7
}

/// Helper to get player positions based on current user index
/// Dynamically distributes players around the table for 2-8 players
class PlayerPositionHelper {
  /// Returns position mapping for each player ID
  static Map<String, TablePosition> getPositions(
    List<Player> players,
    String currentUserId,
  ) {
    final positions = <String, TablePosition>{};
    final currentUserIndex = players.indexWhere((p) => p.id == currentUserId);

    if (currentUserIndex == -1) return positions;

    // Get the appropriate position order based on player count
    final positionOrder = _getPositionOrderForCount(players.length);

    for (int i = 0; i < players.length && i < positionOrder.length; i++) {
      final playerIndex = (currentUserIndex + i) % players.length;
      positions[players[playerIndex].id] = positionOrder[i];
    }

    return positions;
  }

  /// Get optimal position distribution based on player count
  static List<TablePosition> _getPositionOrderForCount(int count) {
    switch (count) {
      case 2:
        return [TablePosition.bottom, TablePosition.top];
      case 3:
        return [
          TablePosition.bottom,
          TablePosition.topLeft,
          TablePosition.topRight,
        ];
      case 4:
        return [
          TablePosition.bottom,
          TablePosition.left,
          TablePosition.top,
          TablePosition.right,
        ];
      case 5:
        return [
          TablePosition.bottom,
          TablePosition.bottomLeft,
          TablePosition.topLeft,
          TablePosition.topRight,
          TablePosition.bottomRight,
        ];
      case 6:
        return [
          TablePosition.bottom,
          TablePosition.bottomLeft,
          TablePosition.left,
          TablePosition.top,
          TablePosition.right,
          TablePosition.bottomRight,
        ];
      case 7:
        return [
          TablePosition.bottom,
          TablePosition.bottomLeft,
          TablePosition.left,
          TablePosition.topLeft,
          TablePosition.topRight,
          TablePosition.right,
          TablePosition.bottomRight,
        ];
      case 8:
        return [
          TablePosition.bottom,
          TablePosition.bottomLeft,
          TablePosition.left,
          TablePosition.topLeft,
          TablePosition.top,
          TablePosition.topRight,
          TablePosition.right,
          TablePosition.bottomRight,
        ];
      default:
        // Fallback for any count - distribute evenly
        return TablePosition.values.take(count.clamp(1, 8)).toList();
    }
  }

  /// Get the angle in radians for a table position (useful for UI layout)
  static double getAngleForPosition(TablePosition position) {
    switch (position) {
      case TablePosition.bottom:
        return 3.14159 / 2; // 90° (bottom)
      case TablePosition.bottomLeft:
        return 3.14159 * 0.75; // 135°
      case TablePosition.left:
        return 3.14159; // 180° (left)
      case TablePosition.topLeft:
        return 3.14159 * 1.25; // 225°
      case TablePosition.top:
        return 3.14159 * 1.5; // 270° (top)
      case TablePosition.topRight:
        return 3.14159 * 1.75; // 315°
      case TablePosition.right:
        return 0; // 0° (right)
      case TablePosition.bottomRight:
        return 3.14159 * 0.25; // 45°
    }
  }

  /// Get normalized x,y coordinates (0-1 range) for a table position
  static ({double x, double y}) getCoordinatesForPosition(
    TablePosition position,
  ) {
    switch (position) {
      case TablePosition.bottom:
        return (x: 0.5, y: 0.95);
      case TablePosition.bottomLeft:
        return (x: 0.15, y: 0.80);
      case TablePosition.left:
        return (x: 0.05, y: 0.50);
      case TablePosition.topLeft:
        return (x: 0.15, y: 0.20);
      case TablePosition.top:
        return (x: 0.5, y: 0.05);
      case TablePosition.topRight:
        return (x: 0.85, y: 0.20);
      case TablePosition.right:
        return (x: 0.95, y: 0.50);
      case TablePosition.bottomRight:
        return (x: 0.85, y: 0.80);
    }
  }
}

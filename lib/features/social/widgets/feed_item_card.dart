/// Feed Item Card Widget
/// 
/// Displays a single activity feed item

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/social/activity_feed.dart';

/// Card widget for displaying a feed item
class FeedItemCard extends ConsumerWidget {
  final FeedItem item;
  final String currentUserId;

  const FeedItemCard({
    super.key,
    required this.item,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and name
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: item.userAvatarUrl != null
                      ? NetworkImage(item.userAvatarUrl!)
                      : null,
                  child: item.userAvatarUrl == null
                      ? Text(item.userName.isNotEmpty ? item.userName[0].toUpperCase() : '?')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.userName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _TypeBadge(type: item.type),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            // Game scores if available
            if (item.gameScores != null && item.gameScores!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _GameScoresCard(scores: item.gameScores!),
            ],
            const SizedBox(height: 12),
            // Actions row
            Row(
              children: [
                // Like button
                _LikeButton(
                  isLiked: item.isLikedBy(currentUserId),
                  likesCount: item.likesCount,
                  onTap: () {
                    ref.read(activityFeedServiceProvider).toggleLike(
                      item.id,
                      currentUserId,
                    );
                  },
                ),
                const SizedBox(width: 16),
                // Comments count
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.commentsCount}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const Spacer(),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {
                    // TODO: Implement share functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

/// Type badge for feed items
class _TypeBadge extends StatelessWidget {
  final FeedItemType type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _getTypeInfo();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _getTypeInfo() {
    switch (type) {
      case FeedItemType.gameResult:
        return (Icons.style, Colors.blue, 'Game');
      case FeedItemType.achievement:
        return (Icons.emoji_events, Colors.amber, 'Badge');
      case FeedItemType.friendJoined:
        return (Icons.person_add, Colors.green, 'Friend');
      case FeedItemType.storyPost:
        return (Icons.auto_stories, Colors.purple, 'Story');
      case FeedItemType.clubJoined:
        return (Icons.groups, Colors.orange, 'Club');
      case FeedItemType.tournamentWin:
        return (Icons.military_tech, Colors.red, 'Tournament');
    }
  }
}

/// Like button with animation
class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback onTap;

  const _LikeButton({
    required this.isLiked,
    required this.likesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: isLiked ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '$likesCount',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isLiked ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Game scores display card
class _GameScoresCard extends StatelessWidget {
  final Map<String, int> scores;

  const _GameScoresCard({required this.scores});

  @override
  Widget build(BuildContext context) {
    final sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sortedScores.length && i < 4; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    _getMedal(i),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sortedScores[i].key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: i == 0 ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  Text(
                    '${sortedScores[i].value} pts',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getMedal(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '  ';
    }
  }
}

// Activity Feed Screen
//
// Displays the main activity feed with friends' activities

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/features/social/activity_feed.dart';
import 'package:clubroyale/features/social/widgets/feed_item_card.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';

/// Main activity feed screen
class ActivityFeedScreen extends ConsumerWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view activity'),
        ),
      );
    }

    final feedAsync = ref.watch(activityFeedProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: feedAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyFeedState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activityFeedProvider(currentUser.uid));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return FeedItemCard(
                  item: items[index],
                  currentUserId: currentUser.uid,
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SkeletonLeaderboard(itemCount: 6),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(ErrorHelper.getFriendlyMessage(error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(activityFeedProvider(currentUser.uid));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _FilterSheet(),
    );
  }
}

/// Empty state for feed
class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dynamic_feed_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Activity Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Play games and add friends to see their activity here!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.go('/clubs');
              },
              icon: const Icon(Icons.groups),
              label: const Text('Join a Club'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter options sheet
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final Set<FeedItemType> _selectedTypes = FeedItemType.values.toSet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Activity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FeedItemType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                label: Text(_getTypeName(type)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Apply filter
              },
              child: const Text('Apply Filter'),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(FeedItemType type) {
    switch (type) {
      case FeedItemType.gameResult:
        return 'Games';
      case FeedItemType.achievement:
        return 'Achievements';
      case FeedItemType.friendJoined:
        return 'Friends';
      case FeedItemType.storyPost:
        return 'Stories';
      case FeedItemType.clubJoined:
        return 'Clubs';
      case FeedItemType.tournamentWin:
        return 'Tournaments';
    }
  }
}

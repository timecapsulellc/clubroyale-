/// Replay List Screen
///
/// Shows user's saved replays and public replays
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/utils/haptic_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/replay/replay_model.dart';
import 'package:clubroyale/features/replay/replay_service.dart';
import 'package:clubroyale/features/replay/screens/replay_player_screen.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class ReplayListScreen extends ConsumerWidget {
  const ReplayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final userId = auth.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Replays'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Replays'),
              Tab(text: 'Popular'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Replays
            userId != null
                ? _MyReplaysTab(userId: userId)
                : const Center(child: Text('Please sign in')),
            // Popular Replays
            const _PopularReplaysTab(),
          ],
        ),
      ),
    );
  }
}

class _MyReplaysTab extends ConsumerWidget {
  final String userId;

  const _MyReplaysTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replaysAsync = ref.watch(userReplaysProvider(userId));

    return replaysAsync.when(
      data: (replays) {
        if (replays.isEmpty) {
          return const _EmptyState(
            icon: Icons.video_library_outlined,
            title: 'No Replays Yet',
            subtitle: 'Your saved game replays will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticHelper.lightTap();
            ref.invalidate(userReplaysProvider(userId));
            await ref.read(userReplaysProvider(userId).future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: replays.length,
            itemBuilder: (context, index) =>
                _ReplayCard(replay: replays[index]),
          ),
        );
      },
      loading: () => const ContextualLoader(
        message: 'Loading replays...',
        icon: Icons.video_library,
      ),
      error: (e, _) => Center(child: Text(ErrorHelper.getFriendlyMessage(e))),
    );
  }
}

class _PopularReplaysTab extends ConsumerWidget {
  const _PopularReplaysTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final replaysAsync = ref.watch(publicReplaysProvider);

    return replaysAsync.when(
      data: (replays) {
        if (replays.isEmpty) {
          return const _EmptyState(
            icon: Icons.trending_up,
            title: 'No Popular Replays',
            subtitle: 'Popular game replays will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticHelper.lightTap();
            ref.invalidate(publicReplaysProvider);
            await ref.read(publicReplaysProvider.future);
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: replays.length,
            itemBuilder: (context, index) =>
                _ReplayCard(replay: replays[index], showViews: true),
          ),
        );
      },
      loading: () => const ContextualLoader(
        message: 'Loading replays...',
        icon: Icons.trending_up,
      ),
      error: (e, _) => Center(child: Text(ErrorHelper.getFriendlyMessage(e))),
    );
  }
}

class _ReplayCard extends StatelessWidget {
  final GameReplay replay;
  final bool showViews;

  const _ReplayCard({required this.replay, this.showViews = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReplayPlayerScreen(replayId: replay.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getGameColor(
                        replay.gameType,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: _getGameColor(replay.gameType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replay.title ?? _getGameName(replay.gameType),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          replay.playerNames.join(", "),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(icon: Icons.timer, label: replay.formattedDuration),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.people,
                    label: '${replay.playerNames.length} players',
                  ),
                  if (showViews) ...[
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.visibility, label: '${replay.views}'),
                  ],
                  const Spacer(),
                  if (replay.winnerId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            replay.winnerName ?? 'Winner',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGameColor(String type) {
    switch (type) {
      case 'marriage':
        return Colors.pink;
      case 'call_break':
        return Colors.blue;
      case 'teen_patti':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _getGameName(String type) {
    switch (type) {
      case 'marriage':
        return 'Marriage Game';
      case 'call_break':
        return 'Call Break';
      case 'teen_patti':
        return 'Teen Patti';
      default:
        return type;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

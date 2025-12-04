
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/game_service.dart';

/// Provider for leaderboard data - aggregates scores across all finished games
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final gameService = ref.watch(gameServiceProvider);
  return gameService.getLeaderboard();
});

class LeaderboardEntry {
  final String odayerId;
  final String playerName;
  final String? avatarUrl;
  final int totalScore;
  final int gamesPlayed;
  final int gamesWon;

  LeaderboardEntry({
    required this.odayerId,
    required this.playerName,
    this.avatarUrl,
    required this.totalScore,
    required this.gamesPlayed,
    required this.gamesWon,
  });

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0;
  double get averageScore => gamesPlayed > 0 ? totalScore / gamesPlayed : 0;
}

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: leaderboardAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No rankings yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Play some games to appear on the leaderboard!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => context.go('/lobby'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Playing'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Top 3 Podium
              SliverToBoxAdapter(
                child: _TopThreePodium(entries: entries.take(3).toList()),
              ),

              // Rest of the leaderboard
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Skip first 3 since they're in podium
                      final actualIndex = index + 3;
                      if (actualIndex >= entries.length) return null;
                      final entry = entries[actualIndex];
                      return _LeaderboardTile(
                        entry: entry,
                        rank: actualIndex + 1,
                      );
                    },
                    childCount: entries.length > 3 ? entries.length - 3 : 0,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading leaderboard...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading leaderboard',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('$error', style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.invalidate(leaderboardProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _TopThreePodium({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            '🏆 Top Players',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place (left)
              if (entries.length > 1)
                _PodiumPlayer(
                  entry: entries[1],
                  rank: 2,
                  height: 100,
                  color: Colors.grey.shade400,
                )
              else
                const SizedBox(width: 100),

              const SizedBox(width: 8),

              // 1st place (center)
              if (entries.isNotEmpty)
                _PodiumPlayer(
                  entry: entries[0],
                  rank: 1,
                  height: 130,
                  color: Colors.amber,
                )
              else
                const SizedBox(width: 110),

              const SizedBox(width: 8),

              // 3rd place (right)
              if (entries.length > 2)
                _PodiumPlayer(
                  entry: entries[2],
                  rank: 3,
                  height: 80,
                  color: Colors.brown.shade300,
                )
              else
                const SizedBox(width: 100),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumPlayer extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final Color color;

  const _PodiumPlayer({
    required this.entry,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (rank == 1)
          const Text('👑', style: TextStyle(fontSize: 24))
        else
          const SizedBox(height: 24),

        const SizedBox(height: 8),

        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 40 : 32,
                backgroundImage: entry.avatarUrl != null
                    ? NetworkImage(entry.avatarUrl!)
                    : null,
                backgroundColor: colorScheme.primaryContainer,
                child: entry.avatarUrl == null
                    ? Text(
                        entry.playerName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: rank == 1 ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Name
        SizedBox(
          width: rank == 1 ? 110 : 100,
          child: Text(
            entry.playerName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Score
        Text(
          '${entry.totalScore} pts',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Podium stand
        Container(
          width: rank == 1 ? 110 : 100,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${entry.gamesWon}W',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${entry.gamesPlayed} games',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _LeaderboardTile({
    required this.entry,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            CircleAvatar(
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              backgroundColor: colorScheme.primaryContainer,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.playerName[0].toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        title: Text(
          entry.playerName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${entry.gamesPlayed} games • ${entry.gamesWon} wins',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalScore}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              'points',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

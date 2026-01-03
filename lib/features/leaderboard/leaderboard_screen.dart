import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/game/game_service.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';
import 'package:clubroyale/core/error/error_display.dart';

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

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.amber.shade700,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => context.go('/'),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
                onPressed: () => ref.invalidate(leaderboardProvider),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.shade500,
                      Colors.orange.shade600,
                      Colors.deepOrange.shade700,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,
                              ),
                          itemCount: 64,
                          itemBuilder: (context, index) {
                            return Icon(
                              index % 3 == 0 ? Icons.emoji_events : Icons.star,
                              color: Colors.white,
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),
                    // Trophy icon
                    Center(
                      child:
                          Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.emoji_events_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                duration: 1500.ms,
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1.05, 1.05),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          leaderboardAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return SliverFillRemaining(child: _EmptyState());
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Top 3 Podium
                  _PremiumPodium(entries: entries.take(3).toList()),

                  // Rest of the list
                  if (entries.length > 3)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Other Rankings',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ),

                  ...entries.skip(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          _EnhancedLeaderboardTile(
                                entry: player,
                                rank: index + 4,
                              )
                              .animate(delay: (100 * index).ms)
                              .fadeIn()
                              .slideX(begin: 0.1),
                    );
                  }),

                  const SizedBox(height: 32),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SkeletonLeaderboard(itemCount: 8),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: ErrorDisplay(
                title: 'Leaderboard Error',
                message: error.toString(),
                onRetry: () => ref.invalidate(leaderboardProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Premium podium design
class _PremiumPodium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _PremiumPodium({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.amber.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🏆 Champions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place (left)
              if (entries.length > 1)
                _PodiumPlayer(
                  entry: entries[1],
                  rank: 2,
                  podiumHeight: 90,
                  avatarSize: 50,
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3)
              else
                const SizedBox(width: 100),

              const SizedBox(width: 12),

              // 1st place (center)
              if (entries.isNotEmpty)
                _PodiumPlayer(
                  entry: entries[0],
                  rank: 1,
                  podiumHeight: 120,
                  avatarSize: 64,
                  colors: [Colors.amber.shade400, Colors.amber.shade700],
                  showCrown: true,
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3)
              else
                const SizedBox(width: 110),

              const SizedBox(width: 12),

              // 3rd place (right)
              if (entries.length > 2)
                _PodiumPlayer(
                  entry: entries[2],
                  rank: 3,
                  podiumHeight: 70,
                  avatarSize: 44,
                  colors: [Colors.brown.shade300, Colors.brown.shade500],
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3)
              else
                const SizedBox(width: 100),
            ],
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

class _PodiumPlayer extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double podiumHeight;
  final double avatarSize;
  final List<Color> colors;
  final bool showCrown;

  const _PodiumPlayer({
    required this.entry,
    required this.rank,
    required this.podiumHeight,
    required this.avatarSize,
    required this.colors,
    this.showCrown = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st place
        if (showCrown)
          const Text('👑', style: TextStyle(fontSize: 32))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: 1000.ms,
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
              )
        else
          const SizedBox(height: 32),

        const SizedBox(height: 8),

        // Avatar with gradient border
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: avatarSize / 2 - 3,
              backgroundColor: colors[0].withValues(alpha: 0.2),
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.playerName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: avatarSize * 0.4,
                        fontWeight: FontWeight.bold,
                        color: colors[1],
                      ),
                    )
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Name
        SizedBox(
          width: avatarSize * 2,
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

        // Score badge
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${entry.totalScore} pts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Podium stand
        Container(
          width: avatarSize * 2,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors[0].withValues(alpha: 0.3),
                colors[1].withValues(alpha: 0.5),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: colors[0], width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors[1],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${entry.gamesWon}W / ${entry.gamesPlayed}G',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors[1],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Enhanced leaderboard tile for ranks 4+
class _EnhancedLeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _EnhancedLeaderboardTile({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.amber.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.amber.shade50.withValues(alpha: 0.3)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.amber.shade100,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.playerName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.playerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MiniStat(
                        icon: Icons.games,
                        value: '${entry.gamesPlayed}',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _MiniStat(
                        icon: Icons.emoji_events,
                        value: '${entry.gamesWon}',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${entry.totalScore}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade100, Colors.orange.shade50],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: Colors.amber.shade600,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'No Rankings Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'Be the first to climb the leaderboard!\nPlay games to earn your spot.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/lobby'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Playing'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

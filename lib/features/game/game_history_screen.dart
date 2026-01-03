import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_service.dart';

final gameHistoryProvider = StreamProvider<List<GameRoom>>((ref) {
  final gameService = ref.watch(gameServiceProvider);
  return gameService.getFinishedGames();
});

class GameHistoryScreen extends ConsumerWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsyncValue = ref.watch(gameHistoryProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.indigo,
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
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Game History',
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
                      Colors.indigo.shade400,
                      Colors.indigo.shade700,
                      Colors.purple.shade800,
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
                              index % 3 == 0
                                  ? Icons.history
                                  : Icons.access_time,
                              color: Colors.white,
                              size: 20,
                            );
                          },
                        ),
                      ),
                    ),
                    // Centered icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Bar
          SliverToBoxAdapter(
            child: historyAsyncValue.when(
              data: (games) => _StatsBar(gameCount: games.length, games: games),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Content
          historyAsyncValue.when(
            data: (games) {
              if (games.isEmpty) {
                return SliverFillRemaining(child: _EmptyState());
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final game = games[index];
                    return _EnhancedGameCard(
                          game: game,
                          onTap: () => context.go('/ledger/${game.id}'),
                        )
                        .animate(delay: (100 * index).ms)
                        .fadeIn()
                        .slideX(begin: -0.1);
                  }, childCount: games.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading history...'),
                  ],
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: _ErrorState(error: error.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

// Stats bar showing summary
class _StatsBar extends StatelessWidget {
  final int gameCount;
  final List<GameRoom> games;

  const _StatsBar({required this.gameCount, required this.games});

  @override
  Widget build(BuildContext context) {
    // Calculate wins (where current user had highest score - simplified for now)
    int totalWins = 0;
    int totalPoints = 0;

    for (final game in games) {
      for (final entry in game.scores.entries) {
        totalPoints += entry.value;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade50, Colors.white]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.games_rounded,
            value: '$gameCount',
            label: 'Games',
            color: Colors.indigo,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.indigo.withValues(alpha: 0.2),
          ),
          _StatItem(
            icon: Icons.emoji_events_rounded,
            value: '$totalWins',
            label: 'Wins',
            color: Colors.amber.shade700,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.indigo.withValues(alpha: 0.2),
          ),
          _StatItem(
            icon: Icons.star_rounded,
            value: '$totalPoints',
            label: 'Points',
            color: Colors.green.shade600,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// Enhanced game history card
class _EnhancedGameCard extends StatelessWidget {
  final GameRoom game;
  final VoidCallback onTap;

  const _EnhancedGameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Find the winner
    String? winnerId;
    int highestScore = 0;
    game.scores.forEach((playerId, score) {
      if (score > highestScore) {
        highestScore = score;
        winnerId = playerId;
      }
    });

    final winner = game.players.where((p) => p.id == winnerId).firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.indigo.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.indigo.shade50.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sports_esports,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (game.createdAt != null)
                            Text(
                              _formatDate(game.createdAt!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${game.players.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Winner banner
              if (winner != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade100, Colors.amber.shade50],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Winner',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.amber.shade800,
                              ),
                            ),
                            Text(
                              winner.profile?.displayName ?? winner.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$highestScore pts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Player scores
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: game.players.map((player) {
                    final score = game.scores[player.id] ?? 0;
                    final isWinner = player.id == winnerId;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isWinner
                            ? Colors.amber.withValues(alpha: 0.15)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: isWinner
                            ? Border.all(
                                color: Colors.amber.shade400,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isWinner
                                ? Colors.amber
                                : Colors.indigo.shade100,
                            child: Text(
                              player.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isWinner ? Colors.white : Colors.indigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            player.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isWinner ? FontWeight.bold : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: score > 0
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : score < 0
                                  ? Colors.red.withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${score > 0 ? '+' : ''}$score',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: score > 0
                                    ? Colors.green.shade700
                                    : score < 0
                                    ? Colors.red.shade700
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // View details button
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Settlement',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
                  colors: [Colors.indigo.shade100, Colors.purple.shade50],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 64,
                color: Colors.indigo.shade400,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'No Games Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'Your completed games will appear here.\nStart playing to build your history!',
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
                backgroundColor: Colors.indigo,
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

// Error state
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

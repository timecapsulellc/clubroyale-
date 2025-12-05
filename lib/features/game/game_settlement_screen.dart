import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/providers/game_state_provider.dart';

class GameSettlementScreen extends ConsumerWidget {
  final String gameId;

  const GameSettlementScreen({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(currentGameProvider(gameId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found'));
          }

          // Sort players by score (descending)
          final sortedPlayers = List<Player>.from(game.players);
          sortedPlayers.sort((a, b) {
            final scoreA = game.scores[a.id] ?? 0;
            final scoreB = game.scores[b.id] ?? 0;
            return scoreB.compareTo(scoreA); // Descending
          });

          final winner = sortedPlayers.first;
          final winnerScore = game.scores[winner.id] ?? 0;

          return Container(
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
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Trophy Icon
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 80,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(height: 16),
                  
                  // Winner Announcement
                  Text(
                    'Winner!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winner.name,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$winnerScore pts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Leaderboard
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: sortedPlayers.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final player = sortedPlayers[index];
                          final score = game.scores[player.id] ?? 0;
                          final isWinner = index == 0;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isWinner 
                                  ? Colors.amber.shade100 
                                  : colorScheme.surfaceContainerHighest,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isWinner 
                                      ? Colors.amber.shade800 
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              player.name,
                              style: TextStyle(
                                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: Text(
                              '$score',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isWinner ? colorScheme.primary : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Back to Lobby Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: FilledButton.icon(
                      onPressed: () => context.go('/lobby'),
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Lobby'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/providers/game_state_provider.dart';
import 'package:myapp/features/ledger/services/settlement_service.dart';

class GameSettlementScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameSettlementScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameSettlementScreen> createState() => _GameSettlementScreenState();
}

class _GameSettlementScreenState extends ConsumerState<GameSettlementScreen> {
  @override
  void initState() {
    super.initState();
    // Play win sound on entry
    ref.read(soundServiceProvider).playGameWin();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(currentGameProvider(widget.gameId));
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

                  // Settlement Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settlements',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettlementList(context, ref, game.scores, game.players),
                      ],
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

  Widget _buildSettlementList(
    BuildContext context,
    WidgetRef ref,
    Map<String, int> scores,
    List<Player> players,
  ) {
    final settlementService = ref.read(settlementServiceProvider);
    final transactions = settlementService.calculateSettlements(scores);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('All settled up!'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: transactions.map((tx) {
        final fromPlayer = players.firstWhere(
          (p) => p.id == tx.fromPlayerId,
          orElse: () => Player(id: 'unknown', name: 'Unknown'),
        );
        final toPlayer = players.firstWhere(
          (p) => p.id == tx.toPlayerId,
          orElse: () => Player(id: 'unknown', name: 'Unknown'),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  colorScheme.surfaceContainer,
                  colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Debtor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.red.shade100,
                            child: Icon(Icons.arrow_upward, size: 14, color: Colors.red),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            fromPlayer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 32, top: 4),
                        child: Text(
                          'Pays',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.diamond, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${tx.amount}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Creditor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            toPlayer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.arrow_downward, size: 14, color: Colors.green),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 32, top: 4),
                        child: Text(
                          'Receives',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

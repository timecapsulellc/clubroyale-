
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/ledger/ledger_service.dart';
import 'package:share_plus/share_plus.dart';

final ledgerProvider = FutureProvider.family<GameRoom?, String>((ref, gameId) {
  final ledgerService = ref.watch(ledgerServiceProvider);
  return ledgerService.getGame(gameId);
});

class LedgerScreen extends ConsumerWidget {
  final String gameId;

  const LedgerScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsyncValue = ref.watch(ledgerProvider(gameId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Ledger'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ledgerAsyncValue.whenData((game) {
                if (game != null) {
                  final scores = game.players
                      .map((p) => '${p.name}: ${game.scores[p.id] ?? 0}')
                      .join('\n');
                  Share.share(
                    'Check out the results of our game!\n\nGame: ${game.name}\n\n$scores',
                    subject: 'Game Results: ${game.name}',
                  );
                }
              });
            },
          ),
        ],
      ),
      body: ledgerAsyncValue.when(
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Game: ${game.name}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Text('Final Scores:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      final score = game.scores[player.id] ?? 0;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: player.profile?.avatarUrl != null
                                ? NetworkImage(player.profile!.avatarUrl!)
                                : null,
                            child: player.profile?.avatarUrl == null ? Text(player.name[0]) : null,
                          ),
                          title: Text(player.profile?.displayName ?? player.name),
                          trailing: Text(
                            '$score',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

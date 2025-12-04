
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'game_service.dart';
import 'game_room.dart';

final gameProvider = StreamProvider.family<GameRoom?, String>((ref, gameId) {
  final gameService = ref.watch(gameServiceProvider);
  return gameService.getGameStream(gameId);
});

class GameScreen extends ConsumerWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsyncValue = ref.watch(gameProvider(gameId));
    final gameService = ref.watch(gameServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Game Room: $gameId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: gameAsyncValue.when(
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Game: ${game.name}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: player.profile?.avatarUrl != null
                              ? NetworkImage(player.profile!.avatarUrl!)
                              : null,
                          child: player.profile?.avatarUrl == null
                              ? Text(player.name[0])
                              : null,
                        ),
                        title: Text(player.profile?.displayName ?? player.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => gameService.updatePlayerScore(
                                  gameId, player.id, -1),
                            ),
                            Text('Score: ${game.scores[player.id] ?? 0}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => gameService.updatePlayerScore(
                                  gameId, player.id, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await gameService.finishGame(gameId);
                    if (context.mounted) {
                      context.go('/ledger/$gameId');
                    }
                  },
                  child: const Text('Finish Game'),
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

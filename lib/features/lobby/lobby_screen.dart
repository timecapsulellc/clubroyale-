
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/lobby/lobby_service.dart';
import 'dart:math';

import '../auth/auth_service.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyService = ref.watch(lobbyServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final gamesStream = lobbyService.getGames();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<GameRoom>>(
        stream: gamesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final games = snapshot.data ?? [];

          if (games.isEmpty) {
            return const Center(
              child: Text(
                'No games available. Create one!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(game.players.length.toString()),
                  ),
                  title: Text(game.name),
                  subtitle: Text('Players: ${game.players.map((p) => p.name).join(', ')}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.go('/game/${game.id}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final user = authService.currentUser;
          if (user == null) return;

          final newGameRoom = GameRoom(
            name: 'Game Room #${Random().nextInt(1000)}',
            players: [
              Player(id: user.uid, name: user.displayName ?? 'Player 1'),
            ],
            scores: {user.uid: 0},
            createdAt: DateTime.now(),
          );
          final newGameId = await lobbyService.createGame(newGameRoom);
          if (context.mounted) {
            context.go('/game/$newGameId');
          }
        },
        label: const Text('Create Game'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

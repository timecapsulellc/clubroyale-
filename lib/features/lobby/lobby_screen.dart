
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<List<GameRoom>>(
        stream: gamesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading games...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final games = snapshot.data ?? [];

          if (games.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sports_esports_outlined,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No games yet!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new game to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => _createGame(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Game'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger a refresh
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final isFinished = game.isFinished;
                final currentUser = authService.currentUser;
                final isInGame = game.players.any((p) => p.id == currentUser?.uid);

                return _GameCard(
                  game: game,
                  isFinished: isFinished,
                  isInGame: isInGame,
                  onTap: () {
                    if (isFinished) {
                      context.go('/ledger/${game.id}');
                    } else {
                      context.go('/game/${game.id}');
                    }
                  },
                  onJoin: isInGame
                      ? null
                      : () => _joinGame(context, ref, game),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createGame(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Game'),
        elevation: 4,
      ),
    );
  }

  Future<void> _createGame(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
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
  }

  Future<void> _joinGame(BuildContext context, WidgetRef ref, GameRoom game) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null || game.id == null) return;

    await lobbyService.joinGame(
      game.id!,
      Player(id: user.uid, name: user.displayName ?? 'Player'),
    );

    if (context.mounted) {
      context.go('/game/${game.id}');
    }
  }
}

class _GameCard extends StatelessWidget {
  final GameRoom game;
  final bool isFinished;
  final bool isInGame;
  final VoidCallback onTap;
  final VoidCallback? onJoin;

  const _GameCard({
    required this.game,
    required this.isFinished,
    required this.isInGame,
    required this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFinished
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isFinished ? Icons.check_circle : Icons.sports_esports,
                      color: isFinished
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${game.players.length} players',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (isInGame) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'You\'re in',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isFinished)
                    Chip(
                      label: const Text('Finished'),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      labelStyle: theme.textTheme.labelSmall,
                    )
                  else if (!isInGame && onJoin != null)
                    FilledButton.tonal(
                      onPressed: onJoin,
                      child: const Text('Join'),
                    )
                  else
                    const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: game.players
                    .take(5)
                    .map((p) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          label: Text(p.name),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

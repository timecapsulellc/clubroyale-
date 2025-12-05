
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/game_config.dart';
import 'package:myapp/features/lobby/lobby_service.dart';
import 'package:myapp/features/wallet/diamond_service.dart';
import 'package:myapp/features/wallet/diamond_balance_widget.dart';
import 'package:share_plus/share_plus.dart';
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
          // Diamond balance
          DiamondBalanceBadge(),
          // Join by Code button
          IconButton(
            icon: const Icon(Icons.pin_outlined),
            onPressed: () => _showJoinByCodeDialog(context, ref),
            tooltip: 'Join by Code',
          ),
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
                    'Create a new game or join with a code',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _showCreateGameDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Game'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showJoinByCodeDialog(context, ref),
                        icon: const Icon(Icons.pin),
                        label: const Text('Join by Code'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final isFinished = game.isFinished || game.status == GameStatus.settled;
                final currentUser = authService.currentUser;
                final isInGame = game.players.any((p) => p.id == currentUser?.uid);
                final isHost = game.hostId == currentUser?.uid;

                return _GameCard(
                  game: game,
                  isFinished: isFinished,
                  isInGame: isInGame,
                  isHost: isHost,
                  onTap: () {
                    if (isFinished) {
                      context.go('/ledger/${game.id}');
                    } else if (game.status == GameStatus.waiting) {
                      context.go('/lobby/${game.id}');
                    } else {
                      context.go('/game/${game.id}/play');
                    }
                  },
                  onJoin: isInGame
                      ? null
                      : () => _joinGame(context, ref, game),
                  onShareCode: game.roomCode != null
                      ? () => _shareRoomCode(context, game)
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGameDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Game'),
        elevation: 4,
      ),
    );
  }

  /// Shows dialog to join a game by 6-digit code
  Future<void> _showJoinByCodeDialog(BuildContext context, WidgetRef ref) async {
    final codeController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.pin, size: 48),
        title: const Text('Join by Room Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit code shared by the host'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (codeController.text.length == 6) {
                Navigator.pop(context, codeController.text);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      await _joinByCode(context, ref, result);
    }
  }

  /// Shows dialog to create a game with configuration
  Future<void> _showCreateGameDialog(BuildContext context, WidgetRef ref) async {
    double pointValue = 10;
    int totalRounds = 5;
    
    final result = await showDialog<GameConfig>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          icon: const Icon(Icons.settings, size: 48),
          title: const Text('Room Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Point Value
              Text('Point Value (Units per point)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1')),
                  ButtonSegment(value: 5, label: Text('5')),
                  ButtonSegment(value: 10, label: Text('10')),
                  ButtonSegment(value: 20, label: Text('20')),
                ],
                selected: {pointValue},
                onSelectionChanged: (values) {
                  setState(() => pointValue = values.first);
                },
              ),
              const SizedBox(height: 20),
              
              // Rounds
              Text('Number of Rounds',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 3, label: Text('3')),
                  ButtonSegment(value: 5, label: Text('5')),
                  ButtonSegment(value: 10, label: Text('10')),
                ],
                selected: {totalRounds},
                onSelectionChanged: (values) {
                  setState(() => totalRounds = values.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  GameConfig(
                    pointValue: pointValue,
                    totalRounds: totalRounds,
                  ),
                );
              },
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      await _createGame(context, ref, result);
    }
  }

  Future<void> _createGame(BuildContext context, WidgetRef ref, GameConfig config) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final diamondService = ref.read(diamondServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    // Check diamond balance
    final hasEnough = await diamondService.hasEnoughDiamonds(
      user.uid,
      DiamondService.roomCreationCost,
    );

    if (!hasEnough && context.mounted) {
      // Show insufficient balance dialog
      final shouldBuy = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.diamond, size: 48, color: Colors.amber),
          title: const Text('Insufficient Diamonds'),
          content: Text(
            'You need ${DiamondService.roomCreationCost} diamonds to create a room.\n\n'
            'Would you like to get more diamonds?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Get Diamonds'),
            ),
          ],
        ),
      );

      if (shouldBuy == true && context.mounted) {
        // TODO: Navigate to diamond purchase screen
        // context.push('/diamonds/purchase');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diamond purchase screen coming soon!'),
          ),
        );
      }
      return;
    }

    final newGameRoom = GameRoom(
      name: 'Game Room #${Random().nextInt(1000)}',
      hostId: user.uid,
      config: config,
      players: [
        Player(id: user.uid, name: user.displayName ?? 'Player 1'),
      ],
      scores: {user.uid: 0},
      createdAt: DateTime.now(),
    );

    final newGameId = await lobbyService.createGame(newGameRoom);

    // Deduct diamonds after successful room creation
    await diamondService.processRoomCreation(user.uid, newGameId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room created! ${DiamondService.roomCreationCost} diamonds deducted.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/lobby/$newGameId');
    }
  }

  Future<void> _joinByCode(BuildContext context, WidgetRef ref, String code) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    try {
      final gameId = await lobbyService.joinByCode(
        code,
        Player(id: user.uid, name: user.displayName ?? 'Player'),
      );

      if (gameId != null && context.mounted) {
        context.go('/lobby/$gameId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
      context.go('/lobby/${game.id}');
    }
  }

  void _shareRoomCode(BuildContext context, GameRoom game) {
    if (game.roomCode == null) return;
    
    Share.share(
      'Join my TaasClub game!\n\nRoom Code: ${game.roomCode}\n\nOpen the app and enter this code to join.',
      subject: 'Join my game: ${game.name}',
    );
  }
}


class _GameCard extends StatelessWidget {
  final GameRoom game;
  final bool isFinished;
  final bool isInGame;
  final bool isHost;
  final VoidCallback onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onShareCode;

  const _GameCard({
    required this.game,
    required this.isFinished,
    required this.isInGame,
    required this.isHost,
    required this.onTap,
    this.onJoin,
    this.onShareCode,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                game.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isHost)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Host',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.amber.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
                              '${game.players.length}/${game.config.maxPlayers}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (game.roomCode != null) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.pin,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                game.roomCode!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              if (onShareCode != null)
                                IconButton(
                                  icon: Icon(Icons.share, size: 16, color: colorScheme.primary),
                                  onPressed: onShareCode,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
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
              // Point value info
              if (!isFinished)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, size: 14, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${game.config.pointValue.toInt()} units/point',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.repeat, size: 14, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${game.config.totalRounds} rounds',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
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

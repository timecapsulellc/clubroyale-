
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'game_service.dart';
import 'game_room.dart';
import '../auth/auth_service.dart';
import '../lobby/lobby_service.dart';

final gameProvider = StreamProvider.family<GameRoom?, String>((ref, gameId) {
  final gameService = ref.watch(gameServiceProvider);
  return gameService.getGameStream(gameId);
});

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  final Map<String, AnimationController> _scoreAnimations = {};

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    for (final controller in _scoreAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _animateScore(String playerId) {
    if (!_scoreAnimations.containsKey(playerId)) {
      _scoreAnimations[playerId] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
    _scoreAnimations[playerId]!.forward(from: 0);
  }

  Future<void> _showCustomScoreDialog(
      BuildContext context, String playerId, String playerName) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Score for $playerName'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Score',
            hintText: 'Enter points (can be negative)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result != 0) {
      final gameService = ref.read(gameServiceProvider);
      await gameService.updatePlayerScore(widget.gameId, playerId, result);
      _animateScore(playerId);
    }
  }

  Future<void> _confirmRemovePlayer(
      BuildContext context, Player player, GameRoom game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Player'),
        content: Text('Are you sure you want to remove ${player.name} from this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final lobbyService = ref.read(lobbyServiceProvider);
      await lobbyService.leaveGame(widget.gameId, player.id);
    }
  }

  Future<void> _confirmFinishGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.flag, size: 48),
        title: const Text('Finish Game?'),
        content: const Text(
            'This will end the game and save the final scores to the ledger.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Playing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finish Game'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final gameService = ref.read(gameServiceProvider);
      await gameService.finishGame(widget.gameId);
      if (context.mounted) {
        context.go('/ledger/${widget.gameId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsyncValue = ref.watch(gameProvider(widget.gameId));
    final authService = ref.watch(authServiceProvider);
    final currentUserId = authService.currentUser?.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Room'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/lobby'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () {
              // Show player management bottom sheet
              gameAsyncValue.whenData((game) {
                if (game != null) {
                  _showPlayerManagement(context, game, currentUserId);
                }
              });
            },
            tooltip: 'Manage Players',
          ),
        ],
      ),
      body: gameAsyncValue.when(
        data: (game) {
          if (game == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Game not found',
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/lobby'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Lobby'),
                  ),
                ],
              ),
            );
          }

          // Sort players by score
          final sortedPlayers = List<Player>.from(game.players)
            ..sort((a, b) =>
                (game.scores[b.id] ?? 0).compareTo(game.scores[a.id] ?? 0));

          return Column(
            children: [
              // Game Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primaryContainer, colorScheme.surface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      game.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${game.players.length} players',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Scoreboard
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = sortedPlayers[index];
                    final score = game.scores[player.id] ?? 0;
                    final isCurrentUser = player.id == currentUserId;
                    final isLeader = index == 0 && score > 0;

                    return AnimatedBuilder(
                      animation: _scoreAnimations[player.id] ??
                          const AlwaysStoppedAnimation(0),
                      builder: (context, child) {
                        final scale = 1.0 +
                            (_scoreAnimations[player.id]?.value ?? 0) * 0.05;
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: _PlayerScoreCard(
                        player: player,
                        score: score,
                        rank: index + 1,
                        isCurrentUser: isCurrentUser,
                        isLeader: isLeader,
                        onIncrement: () {
                          ref
                              .read(gameServiceProvider)
                              .updatePlayerScore(widget.gameId, player.id, 1);
                          _animateScore(player.id);
                          HapticFeedback.lightImpact();
                        },
                        onDecrement: () {
                          ref
                              .read(gameServiceProvider)
                              .updatePlayerScore(widget.gameId, player.id, -1);
                          _animateScore(player.id);
                        },
                        onCustomScore: () => _showCustomScoreDialog(
                          context,
                          player.id,
                          player.profile?.displayName ?? player.name,
                        ),
                      ),
                    );
                  },
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
              Text('Loading game...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading game', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('$error', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _confirmFinishGame(context),
          backgroundColor: colorScheme.primary,
          icon: const Icon(Icons.flag),
          label: const Text('Finish Game'),
        ),
      ),
    );
  }

  void _showPlayerManagement(
      BuildContext context, GameRoom game, String? currentUserId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Players',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...game.players.map((player) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: player.profile?.avatarUrl != null
                        ? NetworkImage(player.profile!.avatarUrl!)
                        : null,
                    child: player.profile?.avatarUrl == null
                        ? Text(player.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(player.profile?.displayName ?? player.name),
                  subtitle: Text('Score: ${game.scores[player.id] ?? 0}'),
                  trailing: player.id != currentUserId
                      ? IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: Theme.of(context).colorScheme.error),
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmRemovePlayer(context, player, game);
                          },
                        )
                      : Chip(
                          label: const Text('You'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PlayerScoreCard extends StatelessWidget {
  final Player player;
  final int score;
  final int rank;
  final bool isCurrentUser;
  final bool isLeader;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onCustomScore;

  const _PlayerScoreCard({
    required this.player,
    required this.score,
    required this.rank,
    required this.isCurrentUser,
    required this.isLeader,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCustomScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLeader ? 4 : 1,
      color: isCurrentUser
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getRankColor(rank, colorScheme),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: rank <= 3 ? Colors.white : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: player.profile?.avatarUrl != null
                      ? NetworkImage(player.profile!.avatarUrl!)
                      : null,
                  backgroundColor: colorScheme.primaryContainer,
                  child: player.profile?.avatarUrl == null
                      ? Text(
                          player.name[0].toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (isLeader)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.profile?.displayName ?? player.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCurrentUser)
                    Text(
                      'You',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),

            // Score controls
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrement
                Material(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onDecrement,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.remove,
                          color: colorScheme.onErrorContainer, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Score (tap for custom)
                GestureDetector(
                  onTap: onCustomScore,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$score',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: score > 0
                            ? colorScheme.primary
                            : score < 0
                                ? colorScheme.error
                                : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Increment
                Material(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onIncrement,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.add,
                          color: colorScheme.onPrimaryContainer, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }
}


/// Spectator Screen
/// 
/// Displays a read-only view of an ongoing game

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/game/spectator/spectator_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';

/// Spectator mode screen for watching live games
class SpectatorScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String gameType;

  const SpectatorScreen({
    super.key,
    required this.roomId,
    required this.gameType,
  });

  @override
  ConsumerState<SpectatorScreen> createState() => _SpectatorScreenState();
}

class _SpectatorScreenState extends ConsumerState<SpectatorScreen> {
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    _joinAsSpectator();
  }

  @override
  void dispose() {
    _leaveSpectating();
    super.dispose();
  }

  Future<void> _joinAsSpectator() async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await ref.read(spectatorServiceProvider.notifier).joinAsSpectator(
      roomId: widget.roomId,
      userId: user.uid,
      userName: user.displayName ?? 'Spectator',
    );
  }

  Future<void> _leaveSpectating() async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await ref.read(spectatorServiceProvider.notifier).leaveSpectating(
      userId: user.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spectatorState = ref.watch(spectatorServiceProvider);
    final gameStateAsync = ref.watch(spectatorGameStateProvider(widget.roomId));
    final spectatorCountAsync = ref.watch(spectatorCountProvider(widget.roomId));

    final user = ref.read(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.visibility, size: 20),
            const SizedBox(width: 8),
            Text(_getGameDisplayName(widget.gameType)),
          ],
        ),
        actions: [
          // Spectator count badge
          spectatorCountAsync.when(
            data: (count) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: const Icon(Icons.visibility, size: 16),
                label: Text('$count'),
                visualDensity: VisualDensity.compact,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: Icon(_showChat ? Icons.chat : Icons.chat_bubble_outline),
            onPressed: () {
              setState(() {
                _showChat = !_showChat;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main game view
          _buildGameView(spectatorState, gameStateAsync),
          // Chat overlay
          if (_showChat && user != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 300,
              child: ChatOverlay(
                roomId: widget.roomId,
                userId: user.uid,
                userName: user.displayName ?? 'Spectator',
                isExpanded: true, // Always expanded in side panel mode
                onToggle: () => setState(() => _showChat = false),
              ),
            ),
          // Spectator badge
          Positioned(
            top: 16,
            left: 16,
            child: _SpectatorBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(
    SpectatorState state,
    AsyncValue<Map<String, dynamic>?> gameStateAsync,
  ) {
    if (state.status == SpectatorStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error ?? 'Failed to join as spectator',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    if (state.status == SpectatorStatus.joining) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Joining as spectator...'),
          ],
        ),
      );
    }

    return gameStateAsync.when(
      data: (gameData) {
        if (gameData == null) {
          return const Center(
            child: Text('Game not found'),
          );
        }

        final status = gameData['status'] as String?;
        if (status != 'playing') {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_esports, size: 64),
                const SizedBox(height: 16),
                Text(
                  status == 'finished' ? 'Game Finished' : 'Game not in progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (status == 'finished') ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('View Results'),
                  ),
                ],
              ],
            ),
          );
        }

        // Display game state (simplified view)
        return _GameSpectatorView(
          gameType: widget.gameType,
          gameData: gameData,
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  String _getGameDisplayName(String type) {
    switch (type) {
      case 'marriage':
        return 'Marriage';
      case 'call_break':
        return 'Call Break';
      case 'teen_patti':
        return 'Teen Patti';
      case 'in_between':
        return 'In-Between';
      default:
        return type;
    }
  }
}

/// Spectator badge indicator
class _SpectatorBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            'SPECTATING',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game spectator view (read-only game display)
class _GameSpectatorView extends StatelessWidget {
  final String gameType;
  final Map<String, dynamic> gameData;

  const _GameSpectatorView({
    required this.gameType,
    required this.gameData,
  });

  @override
  Widget build(BuildContext context) {
    final players = gameData['players'] as List<dynamic>? ?? [];
    final currentPlayer = gameData['currentPlayerId'] as String?;
    final round = gameData['currentRound'] as int? ?? 1;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Round indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Round $round',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Players grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final playerId = player['id'] as String?;
                final playerName = player['name'] as String? ?? 'Player ${index + 1}';
                final score = player['score'] as int? ?? 0;
                final isCurrentTurn = playerId == currentPlayer;

                return _PlayerCard(
                  name: playerName,
                  score: score,
                  isCurrentTurn: isCurrentTurn,
                );
              },
            ),
          ),
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are watching this game in spectator mode. Card details are hidden to prevent cheating.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Player card in spectator view
class _PlayerCard extends StatelessWidget {
  final String name;
  final int score;
  final bool isCurrentTurn;

  const _PlayerCard({
    required this.name,
    required this.score,
    required this.isCurrentTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentTurn
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCurrentTurn) ...[
                Icon(
                  Icons.play_circle_filled,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$score pts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (isCurrentTurn)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "THEIR TURN",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

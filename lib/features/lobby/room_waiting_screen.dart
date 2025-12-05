import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/auth_service.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/game_config.dart';
import 'package:myapp/features/lobby/lobby_service.dart';
import 'package:share_plus/share_plus.dart';

class RoomWaitingScreen extends ConsumerStatefulWidget {
  final String roomId;

  const RoomWaitingScreen({
    required this.roomId,
    super.key,
  });

  @override
  ConsumerState<RoomWaitingScreen> createState() => _RoomWaitingScreenState();
}

class _RoomWaitingScreenState extends ConsumerState<RoomWaitingScreen> {
  bool _isTogglingReady = false;
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final lobbyService = ref.watch(lobbyServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Room')),
        body: const Center(child: Text('Please sign in to continue')),
      );
    }

    return StreamBuilder<GameRoom?>(
      stream: lobbyService.watchRoom(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
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
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/lobby'),
                    child: const Text('Back to Lobby'),
                  ),
                ],
              ),
            ),
          );
        }

        final room = snapshot.data;
        if (room == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Room Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Room not found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('The room may have been deleted or the game already started.'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/lobby'),
                    child: const Text('Back to Lobby'),
                  ),
                ],
              ),
            ),
          );
        }

        // Navigate to game screen if game has started
        if (room.status == GameStatus.playing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/game/${widget.roomId}/play');
            }
          });
        }

        final isHost = room.hostId == currentUser.uid;
        final currentPlayer = room.players.where((p) => p.id == currentUser.uid).firstOrNull;
        final isReady = currentPlayer?.isReady ?? false;
        final canStart = lobbyService.canStartGame(room, currentUser.uid);

        return Scaffold(
          appBar: AppBar(
            title: Text(room.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _showLeaveDialog(context, room, currentUser.uid),
            ),
            actions: [
              if (room.roomCode != null)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareRoomCode(room),
                  tooltip: 'Share Room Code',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Room Code Card
                if (room.roomCode != null)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Room Code',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                room.roomCode!,
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  letterSpacing: 8,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton.filled(
                                onPressed: () => _copyRoomCode(context, room.roomCode!),
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy Code',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code with friends to join',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Game Settings
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Game Settings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.monetization_on, 
                              size: 20, 
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${room.config.pointValue.toInt()} units per point',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Icon(Icons.repeat, 
                              size: 20, 
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${room.config.totalRounds} rounds',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Players Section
                Text(
                  'Players (${room.players.length}/${room.config.maxPlayers})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Player List
                ...room.players.map((player) {
                  final isCurrentPlayer = player.id == currentUser.uid;
                  final isPlayerHost = player.id == room.hostId;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isCurrentPlayer ? 2 : 1,
                    color: isCurrentPlayer 
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: player.isReady 
                          ? colorScheme.primary 
                          : colorScheme.surfaceContainerHighest,
                        child: player.profile?.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                player.profile!.avatarUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  color: player.isReady 
                                    ? colorScheme.onPrimary 
                                    : colorScheme.onSurface,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: player.isReady 
                                ? colorScheme.onPrimary 
                                : colorScheme.onSurface,
                            ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.name + (isCurrentPlayer ? ' (You)' : ''),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isCurrentPlayer 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isPlayerHost) ...[
                            const SizedBox(width: 8),
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
                        ],
                      ),
                      trailing: player.isReady
                        ? Chip(
                            avatar: Icon(
                              Icons.check_circle,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            label: const Text('Ready'),
                            backgroundColor: colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Chip(
                            avatar: Icon(
                              Icons.schedule,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            label: const Text('Not Ready'),
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Ready Status Message
                if (!room.allPlayersReady)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Waiting for all players to be ready...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isHost 
                              ? 'All players ready! You can start the game.'
                              : 'All players ready! Waiting for host to start...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Action Buttons - Ready Toggle (available for all players including host)
                FilledButton.icon(
                  onPressed: _isTogglingReady 
                    ? null 
                    : () => _toggleReady(
                        context,
                        lobbyService,
                        room,
                        currentUser.uid,
                        isReady,
                      ),
                  icon: _isTogglingReady
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isReady ? Icons.close : Icons.check),
                  label: Text(isReady ? 'Not Ready' : 'Ready'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isReady
                      ? colorScheme.error
                      : colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                // Start Game Button (host only)
                if (isHost) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: (!canStart || _isStarting)
                            ? null
                            : () => _startGame(context, lobbyService, room),
                          icon: _isStarting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                          label: const Text('Start Game'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      if (room.players.length < 4) ...[
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: () => _addBot(context, lobbyService),
                          icon: const Icon(Icons.smart_toy),
                          tooltip: 'Add Bot Player',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Leave Room Button
                OutlinedButton.icon(
                  onPressed: () => _showLeaveDialog(context, room, currentUser.uid),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Leave Room'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleReady(
    BuildContext context,
    LobbyService lobbyService,
    GameRoom room,
    String userId,
    bool currentReadyStatus,
  ) async {
    setState(() => _isTogglingReady = true);

    try {
      await lobbyService.setPlayerReady(
        widget.roomId,
        userId,
        !currentReadyStatus,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating ready status: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingReady = false);
      }
    }
  }

  Future<void> _startGame(
    BuildContext context,
    LobbyService lobbyService,
    GameRoom room,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.play_arrow, size: 48),
        title: const Text('Start Game'),
        content: Text(
          'Start the game with ${room.players.length} players?\n\n'
          'All players are ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isStarting = true);

    try {
      await lobbyService.startGame(widget.roomId);
      // Navigation will happen automatically via the stream
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting game: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _isStarting = false);
      }
    }
  }

  void _copyRoomCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareRoomCode(GameRoom room) {
    if (room.roomCode == null) return;
    
    Share.share(
      'Join my TaasClub game!\n\nRoom Code: ${room.roomCode}\n\nOpen the app and enter this code to join.',
      subject: 'Join my game: ${room.name}',
    );
  }

  Future<void> _showLeaveDialog(
    BuildContext context,
    GameRoom room,
    String userId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.exit_to_app, size: 48),
        title: const Text('Leave Room'),
        content: Text(
          room.hostId == userId
            ? 'You are the host. If you leave, the room will be reassigned to another player.'
            : 'Are you sure you want to leave this room?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final lobbyService = ref.read(lobbyServiceProvider);
      await lobbyService.leaveGame(widget.roomId, userId);
      if (mounted) {
        context.go('/lobby');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error leaving room: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _addBot(BuildContext context, LobbyService lobbyService) async {
    try {
      await lobbyService.addBot(widget.roomId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding bot: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

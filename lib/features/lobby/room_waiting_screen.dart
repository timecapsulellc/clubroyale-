import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/features/auth/auth_service.dart';
import 'package:taasclub/features/game/game_room.dart';
import 'package:taasclub/features/game/game_config.dart';
import 'package:taasclub/features/lobby/lobby_service.dart';
import 'package:taasclub/games/marriage/marriage_service.dart';
import 'package:taasclub/games/teen_patti/teen_patti_service.dart';
import 'package:taasclub/games/in_between/in_between_service.dart';
import 'package:taasclub/features/chat/widgets/chat_overlay.dart';
import 'package:taasclub/features/rtc/widgets/audio_controls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taasclub/core/services/share_service.dart';

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
  bool _isChatExpanded = false;

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
              // Route to correct game based on gameType
              if (room.gameType == 'marriage') {
                context.go('/marriage/${widget.roomId}');
              } else if (room.gameType == 'teen_patti') {
                context.go('/teen_patti/${widget.roomId}');
              } else if (room.gameType == 'in_between') {
                context.go('/in_between/${widget.roomId}');
              } else {
                context.go('/game/${widget.roomId}/play');
              }
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
                  tooltip: 'Share Room Code',
                  onPressed: () async {
                    await ShareService.shareGameRoomCode(
                      room.roomCode!,
                      room.gameType.toUpperCase(),
                      context: context,
                    );
                  },
                ),
            ],
          ),
          body: Stack(
            children: [
              // Main Content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Audio Controls Card at top
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.headset_mic, color: Colors.deepPurple),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Voice Chat',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            AudioFloatingButton(
                              roomId: widget.roomId,
                              userId: currentUser.uid,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Room Code Card - Premium Design
                if (room.roomCode != null)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade800,
                          Colors.purple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.vpn_key_rounded,
                                color: Colors.amber.shade200,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ROOM CODE',
                                style: TextStyle(
                                  color: Colors.amber.shade200,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [Colors.amber, Colors.orange, Colors.amber],
                                  ).createShader(bounds),
                                  child: Text(
                                    room.roomCode!,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      letterSpacing: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    onPressed: () => _copyRoomCode(context, room.roomCode!),
                                    icon: const Icon(Icons.copy_rounded),
                                    color: Colors.deepPurple.shade900,
                                    tooltip: 'Copy Code',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withOpacity(0.6),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Share this code with friends to join',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                        Row(
                          children: [
                            Text(
                              'Game Settings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            // Game type badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: room.gameType == 'marriage' 
                                    ? Colors.pink.withOpacity(0.2)
                                    : Colors.deepPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: room.gameType == 'marriage' 
                                      ? Colors.pink 
                                      : Colors.deepPurple,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    room.gameType == 'marriage' 
                                        ? Icons.layers_rounded 
                                        : Icons.style_rounded,
                                    size: 14,
                                    color: room.gameType == 'marriage' 
                                        ? Colors.pink 
                                        : Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    room.gameType == 'marriage' ? 'Marriage' : 'Call Break',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: room.gameType == 'marriage' 
                                          ? Colors.pink 
                                          : Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: player.isReady
                          ? LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.15),
                                Colors.teal.withOpacity(0.05),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: player.isReady 
                            ? Colors.green.withOpacity(0.5)
                            : colorScheme.outline.withOpacity(0.2),
                        width: player.isReady ? 2 : 1,
                      ),
                      boxShadow: player.isReady ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Avatar with glow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: player.isReady ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: player.isReady 
                                  ? Colors.green
                                  : colorScheme.surfaceContainerHighest,
                              child: player.profile?.avatarUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        player.profile!.avatarUrl!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.person,
                                          size: 24,
                                          color: player.isReady 
                                              ? Colors.white
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      player.isBot == true 
                                          ? Icons.smart_toy_rounded 
                                          : Icons.person,
                                      size: 24,
                                      color: player.isReady 
                                          ? Colors.white
                                          : colorScheme.onSurface,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Name and badges
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        player.name + (isCurrentPlayer ? ' (You)' : ''),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: player.isReady ? Colors.green.shade800 : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isPlayerHost) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.amber.shade300, Colors.orange.shade400],
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.3),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, size: 12, color: Colors.white),
                                            SizedBox(width: 2),
                                            Text(
                                              'Host',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (player.isBot == true)
                                  Text(
                                    '🤖 AI Player',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple.shade400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Ready indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: player.isReady
                                  ? LinearGradient(
                                      colors: [Colors.green.shade400, Colors.teal.shade500],
                                    )
                                  : null,
                              color: player.isReady ? null : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: player.isReady ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 6,
                                ),
                              ] : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  player.isReady ? Icons.check_circle : Icons.schedule,
                                  size: 16,
                                  color: player.isReady ? Colors.white : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  player.isReady ? 'Ready!' : 'Waiting',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: player.isReady ? Colors.white : colorScheme.onSurfaceVariant,
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
          
          // Chat Overlay (floating)
          Positioned(
            bottom: 24,
            left: 24,
            child: ChatOverlay(
              roomId: widget.roomId,
              userId: currentUser.uid,
              userName: currentUser.displayName ?? 'Player',
              isExpanded: _isChatExpanded,
              onToggle: () => setState(() => _isChatExpanded = !_isChatExpanded),
            ),
          ),
        ],
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
    final gameTypeName = room.gameType == 'marriage' ? 'Marriage' : 'Call Break';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          room.gameType == 'marriage' ? Icons.layers_rounded : Icons.style_rounded,
          size: 48,
          color: room.gameType == 'marriage' ? Colors.pink : Colors.deepPurple,
        ),
        title: Text('Start $gameTypeName'),
        content: Text(
          'Start $gameTypeName with ${room.players.length} players?\n\n'
          'All players are ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: room.gameType == 'marriage' ? Colors.pink : Colors.deepPurple,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isStarting = true);

    try {
      // Start the appropriate game based on type
      if (room.gameType == 'marriage') {
        final marriageService = ref.read(marriageServiceProvider);
        await marriageService.startGame(
          widget.roomId,
          room.players.map((p) => p.id).toList(),
        );
      } else if (room.gameType == 'teen_patti') {
        final teenPattiService = ref.read(teenPattiServiceProvider);
        await teenPattiService.startGame(
          widget.roomId,
          room.players.map((p) => p.id).toList(),
        );
      } else if (room.gameType == 'in_between') {
        final inBetweenService = ref.read(inBetweenServiceProvider);
        await inBetweenService.startGame(
          widget.roomId,
          room.players.map((p) => p.id).toList(),
        );
      }
      
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

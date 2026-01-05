import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_service.dart';
import 'package:clubroyale/games/in_between/in_between_service.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clubroyale/core/services/share_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_tutorial_steps.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';

class RoomWaitingScreen extends ConsumerStatefulWidget {
  final String roomId;

  const RoomWaitingScreen({required this.roomId, super.key});

  @override
  ConsumerState<RoomWaitingScreen> createState() => _RoomWaitingScreenState();
}

class _RoomWaitingScreenState extends ConsumerState<RoomWaitingScreen> {
  bool _isTogglingReady = false;
  bool _isStarting = false;
  bool _isChatExpanded = false;
  bool _isVideoEnabled = false;

  StreamSubscription<GameRoom?>? _gameSubscription;
  Set<String>? _knownPlayerIds;

  @override
  void initState() {
    super.initState();
    // Listen for game updates to show notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lobbyService = ref.read(lobbyServiceProvider);
      _gameSubscription = lobbyService.watchRoom(widget.roomId).listen((room) {
        if (room != null && mounted) {
          _checkPlayerUpdates(room);
        }
      });
    });
  }

  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }

  void _checkPlayerUpdates(GameRoom room) {
    final currentIds = room.players.map((p) => p.id).toSet();

    // Initialize if first load
    if (_knownPlayerIds == null) {
      _knownPlayerIds = currentIds;
      return;
    }

    // Check for new players
    final newIds = currentIds.difference(_knownPlayerIds!);
    for (final id in newIds) {
      final player = room.players.firstWhere((p) => p.id == id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${player.name} joined the room!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Check for players leaving
    final leftIds = _knownPlayerIds!.difference(currentIds);
    if (leftIds.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${leftIds.length} player(s) left'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    _knownPlayerIds = currentIds;
  }

  Future<void> _checkPermissions() async {
    if (kIsWeb) return;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera]?.isDenied == true ||
        statuses[Permission.microphone]?.isDenied == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions required for video chat')),
        );
      }
    }
  }

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
            appBar: AppBar(title: const Text('Connecting...')),
            body: const ContextualLoader(
              message: 'Connecting to room...',
              icon: Icons.wifi,
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
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Room Not Found',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This room may have been deleted, the game already started, or the code is incorrect.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Retry Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // Force refresh by re-navigating
                          context.go('/room/${widget.roomId}');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Back to Lobby
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/lobby'),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Back to Lobby'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Create New Room
                    TextButton(
                      onPressed: () => context.go('/lobby'),
                      child: Text(
                        'Create a New Room →',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
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
        final currentPlayer = room.players
            .where((p) => p.id == currentUser.uid)
            .firstOrNull;
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
                    // Media Controls Card
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.headset_mic,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Voice Chat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                AudioFloatingButton(
                                  roomId: widget.roomId,
                                  userId: currentUser.uid,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.videocam,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Video Chat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _isVideoEnabled,
                                  onChanged: (value) async {
                                    if (value) {
                                      await _checkPermissions();
                                    }
                                    setState(() => _isVideoEnabled = value);
                                  },
                                  activeThumbColor: Colors.deepPurple,
                                ),
                              ],
                            ),
                          ),
                          if (_isVideoEnabled)
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              child: VideoGridWidget(
                                roomId: widget.roomId,
                                userId: currentUser.uid,
                                userName: currentUser.displayName ?? 'Player',
                              ),
                            ),
                        ],
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
                              color: Colors.deepPurple.withValues(alpha: 0.4),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              Colors.amber,
                                              Colors.orange,
                                              Colors.amber,
                                            ],
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
                                        onPressed: () => _copyRoomCode(
                                          context,
                                          room.roomCode!,
                                        ),
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
                                    color: Colors.white.withValues(alpha: 0.6),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Share this code with friends to join',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Share buttons row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // WhatsApp Button
                                  _ShareButton(
                                    icon: Icons.message_rounded,
                                    label: 'WhatsApp',
                                    color: const Color(0xFF25D366),
                                    onTap: () =>
                                        _shareToWhatsApp(context, room),
                                  ),
                                  const SizedBox(width: 12),
                                  // Copy Link Button
                                  _ShareButton(
                                    icon: Icons.link_rounded,
                                    label: 'Copy Link',
                                    color: Colors.amber,
                                    onTap: () => _copyInviteLink(context, room),
                                  ),
                                  const SizedBox(width: 12),
                                  // More Share Options
                                  _ShareButton(
                                    icon: Icons.share_rounded,
                                    label: 'More',
                                    color: Colors.deepPurple.shade300,
                                    onTap: () async {
                                      await ShareService.shareGameRoomCode(
                                        room.roomCode!,
                                        room.gameType.toUpperCase(),
                                        context: context,
                                      );
                                    },
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: room.gameType == 'marriage'
                                        ? Colors.pink.withValues(alpha: 0.2)
                                        : Colors.deepPurple.withValues(
                                            alpha: 0.2,
                                          ),
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
                                        room.gameType == 'marriage'
                                            ? 'Marriage'
                                            : 'Call Break',
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
                                Icon(
                                  Icons.monetization_on,
                                  size: 20,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${room.config.pointValue.toInt()} units per point',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.repeat,
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

                    // How to Play Guide (Marriage Only)
                    if (room.gameType == 'marriage')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Card(
                          color: Colors.blue.shade50,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => MarriageTutorial(
                                  onComplete: () => Navigator.pop(context),
                                  onSkip: () => Navigator.pop(context),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'New to Nepali Marriage?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Learn about Maal, Tunnels, and Scoring',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

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
                                    Colors.green.withValues(alpha: 0.15),
                                    Colors.teal.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: player.isReady
                                ? Colors.green.withValues(alpha: 0.5)
                                : colorScheme.outline.withValues(alpha: 0.2),
                            width: player.isReady ? 2 : 1,
                          ),
                          boxShadow: player.isReady
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar with glow
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: player.isReady
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
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
                                            player.name +
                                                (isCurrentPlayer
                                                    ? ' (You)'
                                                    : ''),
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: player.isReady
                                                      ? Colors.green.shade800
                                                      : null,
                                                ),
                                            overflow: TextOverflow.ellipsis,
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
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.amber.shade300,
                                                  Colors.orange.shade400,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: player.isReady
                                      ? LinearGradient(
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.teal.shade500,
                                          ],
                                        )
                                      : null,
                                  color: player.isReady
                                      ? null
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: player.isReady
                                      ? [
                                          BoxShadow(
                                            color: Colors.green.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      player.isReady
                                          ? Icons.check_circle
                                          : Icons.schedule,
                                      size: 16,
                                      color: player.isReady
                                          ? Colors.white
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      player.isReady ? 'Ready!' : 'Waiting',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: player.isReady
                                            ? Colors.white
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Ready Status Message
                    if (!room.allPlayersReady)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.secondary.withValues(alpha: 0.3),
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
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
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
                                  : () =>
                                        _startGame(context, lobbyService, room),
                              icon: _isStarting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow),
                              label: const Text('Start Game'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          if (room.players.length < room.config.maxPlayers) ...[
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
                      onPressed: () =>
                          _showLeaveDialog(context, room, currentUser.uid),
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
                  onToggle: () =>
                      setState(() => _isChatExpanded = !_isChatExpanded),
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
            content: Text(ErrorHelper.getFriendlyMessage(e)),
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
    final gameTypeName = room.gameType == 'marriage'
        ? 'Marriage'
        : 'Call Break';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          room.gameType == 'marriage'
              ? Icons.layers_rounded
              : Icons.style_rounded,
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
              backgroundColor: room.gameType == 'marriage'
                  ? Colors.pink
                  : Colors.deepPurple,
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

        // Create config from room variants
        final variants = room.config.variants;
        final marriageConfig = MarriageGameConfig(
          tunnelPachaunu: variants['tunnelPachaunu'] as bool? ?? false,
          enableKidnap: variants['enableKidnap'] as bool? ?? true,
          enableMurder: variants['enableMurder'] as bool? ?? false,
          // Preserve other defaults or map more fields if needed
        );

        await marriageService.startGame(
          widget.roomId,
          room.players.map((p) => p.id).toList(),
          config: marriageConfig,
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
            content: Text(ErrorHelper.getFriendlyMessage(e)),
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
      'Join my ClubRoyale game!\n\nRoom Code: ${room.roomCode}\n\nOpen the app and enter this code to join.',
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
            content: Text(ErrorHelper.getFriendlyMessage(e)),
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
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Share to WhatsApp directly using wa.me URL
  void _shareToWhatsApp(BuildContext context, GameRoom room) async {
    if (room.roomCode == null) return;

    final gameTypeName = room.gameType == 'marriage'
        ? 'Marriage'
        : 'Call Break';
    final message = Uri.encodeComponent(
      '🎮 Join my $gameTypeName game on ClubRoyale!\n\n'
      '🔢 Room Code: ${room.roomCode}\n\n'
      '👉 Open ClubRoyale app and enter this code to join!\n\n'
      '📱 Download: https://clubroyale-app.web.app',
    );

    final whatsappUrl = Uri.parse('https://wa.me/?text=$message');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: copy to clipboard
        await Clipboard.setData(ClipboardData(text: message));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'WhatsApp not available. Link copied to clipboard!',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Copy invite link to clipboard
  void _copyInviteLink(BuildContext context, GameRoom room) async {
    if (room.roomCode == null) return;

    final gameTypeName = room.gameType == 'marriage'
        ? 'Marriage'
        : 'Call Break';
    final inviteText =
        '🎮 Join my $gameTypeName game!\n'
        '🔢 Room Code: ${room.roomCode}\n'
        '📱 https://clubroyale-app.web.app';

    await Clipboard.setData(ClipboardData(text: inviteText));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Invite link copied! Paste it anywhere'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Stylish share button widget
class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/social/voice_rooms/models/voice_room.dart';
import 'package:clubroyale/features/social/voice_rooms/services/voice_room_service.dart';
import 'package:clubroyale/features/social/services/voice_room_service.dart'
    as LK;
import 'package:clubroyale/features/social/services/social_service.dart';
import 'package:clubroyale/features/social/invite_service.dart';
import 'package:clubroyale/features/social/services/friend_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/rtc/audio_service.dart';
import 'package:clubroyale/features/rtc/signaling_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Voice room screen displaying participants and controls
/// Now with real WebRTC audio integration
class VoiceRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const VoiceRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends ConsumerState<VoiceRoomScreen> {
  AudioService? _audioService;
  bool _isAudioConnected = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Audio connection will be initialized after we have user info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAudio();
      _listenForUnmuteRequests();
    });
  }

  void _listenForUnmuteRequests() {
    final service = ref.read(LK.liveKitRoomServiceProvider(widget.roomId));
    service.onUnmuteRequested.listen((_) {
      if (!mounted) return;
      _showUnmuteRequestDialog();
    });
  }

  Future<void> _showUnmuteRequestDialog() async {
    final doUnmute = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Host Request'),
        content: const Text(
          'The host would like you to speak. Unmute your microphone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay Muted'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unmute'),
          ),
        ],
      ),
    );

    if (doUnmute == true) {
      // Enable local mic
      // For LiveKit we need to get the service corresponding to this room
      await ref
          .read(LK.liveKitRoomServiceProvider(widget.roomId))
          .enableMicrophone();
      // Also toggle WebRTC if used separately
      _audioService?.toggleMute();
    }
  }

  Future<void> _initAudio() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isConnecting = true);

    try {
      final params = SignalingParams(
        roomId: widget.roomId,
        localUserId: user.uid,
      );

      _audioService = ref.read(audioServiceProvider(params));
      await _audioService!.joinAudioRoom();

      if (mounted) {
        setState(() {
          _isAudioConnected = true;
          _isConnecting = false;
        });
      }
    } catch (e) {
      debugPrint('Error joining audio room: $e');
      if (mounted) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Audio connection failed: $e')));
      }
    }
  }

  Future<void> _leaveAudio() async {
    await _audioService?.leaveAudioRoom();
    setState(() => _isAudioConnected = false);
  }

  @override
  void dispose() {
    _audioService?.leaveAudioRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomStreamProvider = StreamProvider<VoiceRoom?>((ref) {
      return ref.watch(voiceRoomServiceProvider).getRoomStream(widget.roomId);
    });

    final roomAsync = ref.watch(roomStreamProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: roomAsync.when(
          data: (room) => Text(room?.name ?? 'Voice Room'),
          loading: () => const Text('Connecting...'),
          error: (_, __) => const Text('Voice Room'),
        ),
        actions: [
          roomAsync.when(
            data: (room) => room != null
                ? Row(
                    children: [
                      if (ref.watch(authServiceProvider).currentUser?.uid ==
                          room.hostId)
                        IconButton(
                          icon: const Icon(Icons.volume_off),
                          tooltip: 'Mute All',
                          onPressed: () =>
                              _confirmMuteAll(context, ref, room.id),
                        ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => _showRoomSettings(context, ref, room),
                      ),
                    ],
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: roomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load room: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (room) {
          if (room == null || !room.isActive) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.voice_over_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('This voice room has ended'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final participants = room.participants.values.toList();

          return Column(
            children: [
              // Audio connection status
              if (_isConnecting)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.amber.shade800,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Connecting audio...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              if (_isAudioConnected)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.green.shade700,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Audio connected',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              // Room info
              Container(
                padding: const EdgeInsets.all(16),
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (room.description != null)
                            Text(
                              room.description!,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${participants.length}/${room.maxParticipants}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Participants grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    final isHost = participant.id == room.hostId;

                    return _ParticipantTile(
                      participant: participant,
                      isHost: isHost,
                      amIHost:
                          ref.watch(authServiceProvider).currentUser?.uid ==
                          room.hostId,
                      isMe:
                          participant.id ==
                          ref.watch(authServiceProvider).currentUser?.uid,
                      onToggleMute: (muted) {
                        ref
                            .read(LK.liveKitRoomServiceProvider(room.id))
                            .muteRemoteParticipant(participant.id, muted);
                      },
                      onRequestUnmute: () {
                        ref
                            .read(LK.liveKitRoomServiceProvider(room.id))
                            .requestUnmute(participant.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unmute request sent to ${participant.name}',
                            ),
                          ),
                        );
                      },
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: index * 50),
                    );
                  },
                ),
              ),

              // Controls
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button - controls both Firestore state AND actual WebRTC audio
                    Builder(
                      builder: (context) {
                        final userId = ref
                            .watch(authServiceProvider)
                            .currentUser
                            ?.uid;
                        final me = userId != null
                            ? room.participants[userId]
                            : null;
                        final isMuted = me?.isMuted ?? false;

                        return _ControlButton(
                          icon: Icons.mic_off,
                          activeIcon: Icons.mic,
                          label: isMuted ? 'Unmute' : 'Mute',
                          isActive: !isMuted,
                          onTap: () {
                            // Update Firestore state
                            ref
                                .read(voiceRoomServiceProvider)
                                .toggleMute(widget.roomId);
                            // Toggle actual WebRTC audio
                            _audioService?.toggleMute();
                          },
                        );
                      },
                    ),
                    // Deafen button
                    Builder(
                      builder: (context) {
                        final userId = ref
                            .watch(authServiceProvider)
                            .currentUser
                            ?.uid;
                        final me = userId != null
                            ? room.participants[userId]
                            : null;
                        final isDeafened = me?.isDeafened ?? false;

                        return _ControlButton(
                          icon: Icons.headset_off,
                          activeIcon: Icons.headset,
                          label: isDeafened ? 'Undeafen' : 'Deafen',
                          isActive: !isDeafened,
                          onTap: () {
                            ref
                                .read(voiceRoomServiceProvider)
                                .toggleDeafen(widget.roomId);
                            // Note: Deafen affects incoming audio - would need to mute all remote peers
                          },
                        );
                      },
                    ),
                    // Leave button - disconnects audio AND updates Firestore
                    _ControlButton(
                      icon: Icons.call_end,
                      activeIcon: Icons.call_end,
                      label: 'Leave',
                      isActive: true,
                      activeColor: Colors.red,
                      onTap: () async {
                        // Disconnect WebRTC audio first
                        await _leaveAudio();
                        // Then leave room in Firestore
                        await ref
                            .read(voiceRoomServiceProvider)
                            .leaveCurrentRoom();
                        if (context.mounted) context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRoomSettings(BuildContext context, WidgetRef ref, VoiceRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite Friends'),
              onTap: () {
                Navigator.pop(context);
                _showInviteSheet(context, ref, room);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Room Link'),
              onTap: () {
                Navigator.pop(context);
                _shareRoom(context, ref, room);
              },
            ),
            if (ref.read(authServiceProvider).currentUser?.uid == room.hostId)
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Room Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Settings implementation would go here (e.g., change name, privacy)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room settings coming soon')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context, WidgetRef ref, VoiceRoom room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final friendIdsStream = ref
                .watch(friendServiceProvider)
                .watchMyFriendIds();

            return Column(
              children: [
                AppBar(
                  title: const Text('Invite Friends'),
                  leading: const SizedBox(),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<List<String>>(
                    stream: friendIdsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final friendIds = snapshot.data ?? [];
                      if (friendIds.isEmpty) {
                        return const Center(
                          child: Text('No friends found to invite.'),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: friendIds.length,
                        itemBuilder: (context, index) {
                          final friendId = friendIds[index];

                          // Check if already in room
                          final isInRoom = room.participants.containsKey(
                            friendId,
                          );

                          return Consumer(
                            builder: (context, ref, child) {
                              final userFuture = ref
                                  .watch(socialServiceProvider)
                                  .getUserProfile(friendId);

                              return FutureBuilder(
                                future: userFuture,
                                builder: (context, userSnapshot) {
                                  final user = userSnapshot.data;
                                  if (user == null) return const SizedBox();

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user.avatarUrl != null
                                          ? NetworkImage(user.avatarUrl!)
                                          : null,
                                      child: user.avatarUrl == null
                                          ? Text(
                                              user.displayName.isNotEmpty
                                                  ? user.displayName[0]
                                                        .toUpperCase()
                                                  : '?',
                                            )
                                          : null,
                                    ),
                                    title: Text(user.displayName),
                                    subtitle: Text(
                                      isInRoom
                                          ? 'Already in room'
                                          : 'Tap to invite',
                                    ),
                                    trailing: isInRoom
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.send),
                                            onPressed: () async {
                                              // Send invite
                                              final success = await ref
                                                  .read(inviteServiceProvider)
                                                  .sendInvite(
                                                    toUserId: friendId,
                                                    roomId: room.id,
                                                    roomCode:
                                                        null, // Voice rooms might not have codes
                                                    gameType: 'voice_room',
                                                  );

                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      success
                                                          ? 'Invite sent to ${user.displayName}'
                                                          : 'Invite already sent',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmMuteAll(
    BuildContext context,
    WidgetRef ref,
    String roomId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute All Participants?'),
        content: const Text(
          'This will mute everyone in the room except you. Participants can unmute themselves later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mute All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(LK.liveKitRoomServiceProvider(roomId))
            .muteAllRemoteParticipants();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All participants muted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to mute all: $e')));
        }
      }
    }
  }

  Future<void> _shareRoom(
    BuildContext context,
    WidgetRef ref,
    VoiceRoom room,
  ) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final inviteLink = await ref
          .read(inviteServiceProvider)
          .generateInviteLink(
            roomId: room.id,
            roomCode: '', // Voice rooms don't use codes primarily
            hostId: user.uid,
            hostName: user.displayName ?? 'Host',
            gameType: 'voice_room',
          );

      await ref.read(inviteServiceProvider).shareInviteLink(inviteLink);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share room: $e')));
      }
    }
  }
}

/// Single participant tile
class _ParticipantTile extends StatelessWidget {
  final VoiceParticipant participant;
  final bool isHost;
  final bool amIHost;
  final bool isMe;
  final Function(bool) onToggleMute;
  final VoidCallback onRequestUnmute;

  const _ParticipantTile({
    required this.participant,
    this.isHost = false,
    this.amIHost = false,
    this.isMe = false,
    required this.onToggleMute,
    required this.onRequestUnmute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canModerate = amIHost && !isMe;

    return GestureDetector(
      onLongPress: canModerate ? () => _showModerationMenu(context) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Avatar with speaking ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: participant.isSpeaking
                        ? colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: participant.photoUrl != null
                      ? NetworkImage(participant.photoUrl!)
                      : null,
                  child: participant.photoUrl == null
                      ? Text(
                          participant.name.isNotEmpty
                              ? participant.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              // Muted indicator
              if (participant.isMuted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Host badge
              if (isHost)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            participant.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isHost ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showModerationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Manage ${participant.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(),
            if (!participant.isMuted)
              ListTile(
                leading: const Icon(Icons.mic_off, color: Colors.red),
                title: const Text('Mute Player'),
                onTap: () {
                  onToggleMute(true);
                  Navigator.pop(context);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.green),
                title: const Text('Ask to Unmute'),
                subtitle: const Text('Sends a request to the user'),
                onTap: () {
                  onRequestUnmute();
                  Navigator.pop(context);
                },
              ),
            // We can add "Kick User" here later
          ],
        ),
      ),
    );
  }
}

/// Control button for voice room
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = activeColor ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? color : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : colorScheme.onSurface,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// Voice room card for display in lists
class VoiceRoomCard extends StatelessWidget {
  final VoiceRoom room;
  final VoidCallback onTap;

  const VoiceRoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final participantCount = room.participants.length;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Voice icon with pulse animation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic, color: colorScheme.primary),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (room.isPrivate)
                          const Icon(Icons.lock, size: 16, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hosted by ${room.hostName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Participant avatars
                    Row(
                      children: [
                        ...room.participants.values
                            .take(4)
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundImage: p.photoUrl != null
                                      ? NetworkImage(p.photoUrl!)
                                      : null,
                                  child: p.photoUrl == null
                                      ? Text(
                                          p.name.isNotEmpty ? p.name[0] : '?',
                                          style: const TextStyle(fontSize: 10),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                        if (participantCount > 4)
                          Text(
                            '+${participantCount - 4}',
                            style: theme.textTheme.bodySmall,
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$participantCount/${room.maxParticipants}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

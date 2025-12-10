import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/features/social/voice_rooms/models/voice_room.dart';
import 'package:taasclub/features/social/voice_rooms/services/voice_room_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Voice room screen displaying participants and controls
class VoiceRoomScreen extends ConsumerWidget {
  final String roomId;

  const VoiceRoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomStreamProvider = StreamProvider<VoiceRoom?>((ref) {
      return ref.watch(voiceRoomServiceProvider).getRoomStream(roomId);
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showRoomSettings(context, ref),
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
                  const Icon(Icons.voice_over_off, size: 64, color: Colors.grey),
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
              // Room info
              Container(
                padding: const EdgeInsets.all(16),
                color: colorScheme.primaryContainer.withOpacity(0.3),
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
                        color: colorScheme.primary.withOpacity(0.2),
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
                    ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button
                    _ControlButton(
                      icon: Icons.mic_off,
                      activeIcon: Icons.mic,
                      label: 'Mute',
                      isActive: false, // TODO: Get from participant state
                      onTap: () {
                        ref.read(voiceRoomServiceProvider).toggleMute(roomId);
                      },
                    ),
                    // Deafen button
                    _ControlButton(
                      icon: Icons.headset_off,
                      activeIcon: Icons.headset,
                      label: 'Deafen',
                      isActive: false, // TODO: Get from participant state
                      onTap: () {
                        ref.read(voiceRoomServiceProvider).toggleDeafen(roomId);
                      },
                    ),
                    // Leave button
                    _ControlButton(
                      icon: Icons.call_end,
                      activeIcon: Icons.call_end,
                      label: 'Leave',
                      isActive: true,
                      activeColor: Colors.red,
                      onTap: () async {
                        await ref.read(voiceRoomServiceProvider).leaveCurrentRoom();
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

  void _showRoomSettings(BuildContext context, WidgetRef ref) {
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
                // TODO: Implement friend invite
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Room Link'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Room Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement settings
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Single participant tile
class _ParticipantTile extends StatelessWidget {
  final VoiceParticipant participant;
  final bool isHost;

  const _ParticipantTile({
    required this.participant,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
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
          Text(
            label,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Voice room card for display in lists
class VoiceRoomCard extends StatelessWidget {
  final VoiceRoom room;
  final VoidCallback onTap;

  const VoiceRoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

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
                child: Icon(
                  Icons.mic,
                  color: colorScheme.primary,
                ),
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
                        ...room.participants.values.take(4).map((p) => Padding(
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
                            )),
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
                            color: colorScheme.primary.withOpacity(0.1),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio_service.dart';
import '../signaling_service.dart';

/// Widget for voice chat controls during gameplay
class AudioControlWidget extends ConsumerWidget {
  final String roomId;
  final String userId;

  const AudioControlWidget({
    super.key,
    required this.roomId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = SignalingParams(roomId: roomId, localUserId: userId);
    final audioService = ref.watch(audioServiceProvider(params));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connection status indicator
            _buildStatusIndicator(audioService.state, theme),
            const SizedBox(width: 8),

            // Join/Leave button
            if (!audioService.isEnabled)
              FilledButton.tonal(
                onPressed: () => audioService.joinAudioRoom(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, size: 18),
                    SizedBox(width: 4),
                    Text('Join Voice'),
                  ],
                ),
              )
            else ...[
              // Mute button
              IconButton(
                onPressed: () => audioService.toggleMute(),
                icon: Icon(
                  audioService.isMuted ? Icons.mic_off : Icons.mic,
                  color: audioService.isMuted ? theme.colorScheme.error : null,
                ),
                tooltip: audioService.isMuted ? 'Unmute' : 'Mute',
              ),

              // Leave button
              IconButton(
                onPressed: () => audioService.leaveAudioRoom(),
                icon: Icon(
                  Icons.call_end,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Leave Voice Chat',
              ),

              // Connected peers count
              if (audioService.connectedPeers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Chip(
                    avatar: const Icon(Icons.people, size: 16),
                    label: Text('${audioService.connectedPeers.length}'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(AudioConnectionState state, ThemeData theme) {
    Color color;
    String tooltip;

    switch (state) {
      case AudioConnectionState.connected:
        color = Colors.green;
        tooltip = 'Connected';
        break;
      case AudioConnectionState.connecting:
        color = Colors.orange;
        tooltip = 'Connecting...';
        break;
      case AudioConnectionState.failed:
        color = Colors.red;
        tooltip = 'Connection Failed';
        break;
      case AudioConnectionState.disconnected:
        color = Colors.grey;
        tooltip = 'Not Connected';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Floating action button for quick audio toggle
class AudioFloatingButton extends ConsumerWidget {
  final String roomId;
  final String userId;

  const AudioFloatingButton({
    super.key,
    required this.roomId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = SignalingParams(roomId: roomId, localUserId: userId);
    final audioService = ref.watch(audioServiceProvider(params));
    final theme = Theme.of(context);

    if (!audioService.isEnabled) {
      return FloatingActionButton.small(
        onPressed: () => audioService.joinAudioRoom(),
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: const Icon(Icons.mic_none),
      );
    }

    return FloatingActionButton.small(
      onPressed: () => audioService.toggleMute(),
      backgroundColor: audioService.isMuted
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.primaryContainer,
      child: Icon(
        audioService.isMuted ? Icons.mic_off : Icons.mic,
        color: audioService.isMuted
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}

/// Panel showing all connected peers with individual mute controls
class AudioPeersPanel extends ConsumerWidget {
  final String roomId;
  final String userId;
  final Map<String, String>? peerNames; // Map of peerId -> display name

  const AudioPeersPanel({
    super.key,
    required this.roomId,
    required this.userId,
    this.peerNames,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = SignalingParams(roomId: roomId, localUserId: userId);
    final audioService = ref.watch(audioServiceProvider(params));
    final theme = Theme.of(context);

    if (!audioService.isEnabled || audioService.connectedPeers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.headset_mic, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Voice Chat',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const Divider(),
            // Local user
            _buildPeerTile(
              context,
              audioService,
              userId,
              'You',
              isLocal: true,
            ),
            // Remote peers
            ...audioService.connectedPeers.map((peerId) {
              final name = peerNames?[peerId] ?? 'Player';
              return _buildPeerTile(context, audioService, peerId, name);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerTile(
    BuildContext context,
    AudioService audioService,
    String peerId,
    String name, {
    bool isLocal = false,
  }) {
    final theme = Theme.of(context);
    final isMuted = isLocal ? audioService.isMuted : audioService.isPeerMuted(peerId);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        child: Text(name[0].toUpperCase()),
      ),
      title: Text(name),
      trailing: IconButton(
        icon: Icon(
          isMuted ? Icons.volume_off : Icons.volume_up,
          size: 20,
          color: isMuted ? theme.colorScheme.error : null,
        ),
        onPressed: () {
          if (isLocal) {
            audioService.toggleMute();
          } else {
            audioService.togglePeerMute(peerId);
          }
        },
      ),
    );
  }
}

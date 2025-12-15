import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../video_service.dart';

/// 2x2 Video grid for displaying player videos
class VideoGridWidget extends ConsumerWidget {
  final String roomId;
  final String userId;
  final String userName;

  const VideoGridWidget({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = VideoServiceParams(
      roomId: roomId,
      userId: userId,
      userName: userName,
    );
    final videoService = ref.watch(videoServiceProvider(params));

    if (!videoService.isConnected) {
      return _buildJoinPrompt(context, videoService);
    }

    final allParticipants = [
      if (videoService.localParticipant != null)
        _ParticipantInfo(
          participant: videoService.localParticipant!,
          isLocal: true,
        ),
      ...videoService.remoteParticipants.map((p) => _ParticipantInfo(
            participant: p,
            isLocal: false,
          )),
    ];

    return Column(
      children: [
        Expanded(
          child: _buildVideoGrid(context, allParticipants),
        ),
        _buildControlBar(context, videoService),
      ],
    );
  }

  Widget _buildJoinPrompt(BuildContext context, VideoService service) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Join Video Chat',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'See and hear other players in real-time',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: () => service.joinRoom(),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Join as Player'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => service.joinRoom(asSpectator: true),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Watch Only'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGrid(BuildContext context, List<_ParticipantInfo> participants) {
    if (participants.isEmpty) {
      return const Center(child: Text('Waiting for participants...'));
    }

    // Calculate grid layout based on participant count
    final int columns = participants.length <= 2 ? participants.length : 2;
    final int rows = (participants.length / columns).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 4 / 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return _buildParticipantTile(context, participants[index]);
      },
    );
  }

  Widget _buildParticipantTile(BuildContext context, _ParticipantInfo info) {
    final theme = Theme.of(context);
    final participant = info.participant;
    
    // Get video track
    VideoTrack? videoTrack;
    if (participant is LocalParticipant) {
      videoTrack = participant.videoTrackPublications.firstOrNull?.track as VideoTrack?;
    } else if (participant is RemoteParticipant) {
      videoTrack = participant.videoTrackPublications.firstOrNull?.track as VideoTrack?;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: info.isLocal
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or placeholder
          if (videoTrack != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: VideoTrackRenderer(
                videoTrack,
                fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            )
          else
            Center(
              child: CircleAvatar(
                radius: 30,
                child: Text(
                  (participant.name ?? 'U')[0].toUpperCase(),
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),

          // Name overlay
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (info.isLocal)
                    const Icon(Icons.person, size: 14, color: Colors.white),
                  if (info.isLocal) const SizedBox(width: 4),
                  Text(
                    info.isLocal ? 'You' : (participant.name ?? 'Player'),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Mute indicator
          Positioned(
            right: 8,
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isMicEnabled(participant))
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_off, size: 14, color: Colors.white),
                  ),
                const SizedBox(width: 4),
                if (!_isCameraEnabled(participant))
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam_off, size: 14, color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isMicEnabled(Participant participant) {
    return participant.audioTrackPublications.isNotEmpty &&
        participant.audioTrackPublications.first.muted == false;
  }

  bool _isCameraEnabled(Participant participant) {
    return participant.videoTrackPublications.isNotEmpty &&
        participant.videoTrackPublications.first.muted == false;
  }

  Widget _buildControlBar(BuildContext context, VideoService service) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mic toggle
          _buildControlButton(
            context,
            icon: service.isMicEnabled ? Icons.mic : Icons.mic_off,
            isActive: service.isMicEnabled,
            onPressed: service.localRole != ParticipantRole.spectator
                ? () => service.toggleMicrophone()
                : null,
            tooltip: service.isMicEnabled ? 'Mute' : 'Unmute',
          ),
          const SizedBox(width: 16),

          // Camera toggle
          _buildControlButton(
            context,
            icon: service.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            isActive: service.isCameraEnabled,
            onPressed: service.localRole != ParticipantRole.spectator
                ? () => service.toggleCamera()
                : null,
            tooltip: service.isCameraEnabled ? 'Turn off camera' : 'Turn on camera',
          ),
          const SizedBox(width: 16),

          // Switch camera
          _buildControlButton(
            context,
            icon: Icons.flip_camera_ios,
            isActive: true,
            onPressed: service.isCameraEnabled ? () => service.switchCamera() : null,
            tooltip: 'Switch camera',
          ),
          const SizedBox(width: 16),

          // Leave call
          _buildControlButton(
            context,
            icon: Icons.call_end,
            isActive: false,
            isDestructive: true,
            onPressed: () => service.leaveRoom(),
            tooltip: 'Leave call',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    VoidCallback? onPressed,
    String? tooltip,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color iconColor;
    
    if (isDestructive) {
      backgroundColor = theme.colorScheme.errorContainer;
      iconColor = theme.colorScheme.onErrorContainer;
    } else if (isActive) {
      backgroundColor = theme.colorScheme.primaryContainer;
      iconColor = theme.colorScheme.onPrimaryContainer;
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      iconColor = theme.colorScheme.onSurfaceVariant;
    }

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// Helper class for participant info
class _ParticipantInfo {
  final Participant participant;
  final bool isLocal;

  _ParticipantInfo({required this.participant, required this.isLocal});
}

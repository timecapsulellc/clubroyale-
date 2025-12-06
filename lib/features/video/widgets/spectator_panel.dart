import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../video_service.dart';

/// Widget for host to manage spectator approval requests
class SpectatorApprovalPanel extends ConsumerWidget {
  final String roomId;
  final bool isHost;

  const SpectatorApprovalPanel({
    super.key,
    required this.roomId,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isHost) return const SizedBox.shrink();

    final approvalService = ref.watch(spectatorApprovalProvider(roomId));

    return StreamBuilder<List<SpectatorRequest>>(
      stream: approvalService.pendingApprovals,
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        
        if (requests.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Spectator Requests (${requests.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildRequestTile(context, approvalService, request);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestTile(
    BuildContext context,
    SpectatorApprovalService service,
    SpectatorRequest request,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18,
        child: Text(request.displayName[0].toUpperCase()),
      ),
      title: Text(request.displayName),
      subtitle: request.requestedAt != null
          ? Text(
              'Requested ${_formatTime(request.requestedAt!)}',
              style: theme.textTheme.bodySmall,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => service.approveRequest(request.userId),
            tooltip: 'Approve',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => service.rejectRequest(request.userId),
            tooltip: 'Reject',
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

/// Widget for spectators waiting for approval
class SpectatorWaitingWidget extends StatelessWidget {
  final VoidCallback onCancel;

  const SpectatorWaitingWidget({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Waiting for Host Approval',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The host will approve your request to watch the game.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating video pip (Picture-in-Picture) widget for minimized view
class VideoMiniWidget extends ConsumerWidget {
  final String roomId;
  final String userId;
  final String userName;
  final VoidCallback onExpand;

  const VideoMiniWidget({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = VideoServiceParams(
      roomId: roomId,
      userId: userId,
      userName: userName,
    );
    final videoService = ref.watch(videoServiceProvider(params));
    final theme = Theme.of(context);

    if (!videoService.isConnected) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onExpand,
      child: Container(
        width: 120,
        height: 90,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Participant count
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, color: theme.colorScheme.primary),
                  Text(
                    '${videoService.remoteParticipants.length + 1}',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            // Expand button
            Positioned(
              right: 4,
              top: 4,
              child: Icon(
                Icons.open_in_full,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            // Controls
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMiniButton(
                    icon: videoService.isMicEnabled ? Icons.mic : Icons.mic_off,
                    isActive: videoService.isMicEnabled,
                    onPressed: () => videoService.toggleMicrophone(),
                  ),
                  const SizedBox(width: 8),
                  _buildMiniButton(
                    icon: videoService.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                    isActive: videoService.isCameraEnabled,
                    onPressed: () => videoService.toggleCamera(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

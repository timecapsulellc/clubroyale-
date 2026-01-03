import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/share_service.dart';
import '../services/spectator_service.dart';

/// Badge showing spectator count on game screen
class SpectatorBadge extends ConsumerWidget {
  final String gameId;
  final VoidCallback? onTap;

  const SpectatorBadge({super.key, required this.gameId, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spectatorCount = ref.watch(spectatorCountProvider(gameId));

    return GestureDetector(
      onTap: onTap ?? () => _showSpectatorList(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            spectatorCount.when(
              data: (count) => Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white54,
                ),
              ),
              error: (_, __) => const Text(
                '0',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpectatorList(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SpectatorListSheet(gameId: gameId),
    );
  }
}

/// Bottom sheet showing list of spectators
class SpectatorListSheet extends ConsumerWidget {
  final String gameId;

  const SpectatorListSheet({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spectators = ref.watch(spectatorListProvider(gameId));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.visibility, color: Colors.white70),
                const SizedBox(width: 8),
                const Text(
                  'Spectators',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                spectators.when(
                  data: (list) => Text(
                    '${list.length} watching',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Spectator list
          spectators.when(
            data: (list) {
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.visibility_off,
                        color: Colors.white24,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No one is watching yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Share this game to invite friends!',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox(
                height: 300,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final spectator = list[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: spectator.photoUrl != null
                            ? NetworkImage(spectator.photoUrl!)
                            : null,
                        child: spectator.photoUrl == null
                            ? Text(spectator.name[0].toUpperCase())
                            : null,
                      ),
                      title: Text(
                        spectator.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Watching since ${_formatTime(spectator.joinedAt)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Error loading spectators',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
          // Share button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Share game spectator link
                  ShareService.shareAppDownload(
                    context: context,
                    customMessage:
                        '👀 Watch this game live on ClubRoyale! 🃏\n\nJoin as a spectator: https://clubroyale-app.web.app/spectate/$gameId',
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Game Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

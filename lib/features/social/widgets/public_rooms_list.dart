/// Public Rooms List
/// 
/// Shows list of public game rooms that users can join.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/config/game_terminology.dart';

/// Provider for public rooms
final publicRoomsProvider = StreamProvider<List<GameRoom>>((ref) {
  final lobbyService = ref.watch(lobbyServiceProvider);
  return lobbyService.watchPublicRooms();
});

class PublicRoomsList extends ConsumerWidget {
  const PublicRoomsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicRoomsAsync = ref.watch(publicRoomsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.orange.shade600],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Public Rooms',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                publicRoomsAsync.when(
                  data: (rooms) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${rooms.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Room List
          Expanded(
            child: publicRoomsAsync.when(
              data: (rooms) {
                if (rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text(
                          'No public rooms',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create one!',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _PublicRoomTile(room: room)
                        .animate(delay: Duration(milliseconds: index * 50))
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e', style: TextStyle(color: Colors.red.shade300)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicRoomTile extends ConsumerWidget {
  final GameRoom room;

  const _PublicRoomTile({required this.room});

  String _getGameEmoji(String gameType) {
    switch (gameType) {
      case 'marriage':
        return '👰';
      case 'call_break':
        return '♠️';
      case 'teen_patti':
        return '🃏';
      case 'in_between':
        return '🎴';
      default:
        return '🎮';
    }
  }

  String _getGameName(String gameType) {
    switch (gameType) {
      case 'marriage':
        return 'Marriage';
      case 'call_break':
        return 'Call Break';
      case 'teen_patti':
        return 'Teen Patti';
      case 'in_between':
        return GameTerminology.inBetweenGame;
      default:
        return gameType;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerCount = room.players.length;
    final maxPlayers = room.gameType == 'marriage' ? 8 : 4;
    final isFull = playerCount >= maxPlayers;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade800.withOpacity(0.5),
            Colors.purple.shade600.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFull ? Colors.red.withOpacity(0.3) : Colors.deepPurple.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isFull ? null : () => _joinRoom(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Game type icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getGameEmoji(room.gameType),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Room info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _getGameName(room.gameType),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.people,
                            size: 14,
                            color: isFull ? Colors.red : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$playerCount/$maxPlayers',
                            style: TextStyle(
                              color: isFull ? Colors.red : Colors.grey.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Join button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFull 
                        ? Colors.grey.shade700 
                        : Colors.green.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFull ? 'Full' : 'Join',
                    style: TextStyle(
                      color: isFull ? Colors.grey.shade400 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinRoom(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null || room.id == null) return;

    try {
      final player = Player(
        id: user.uid,
        name: user.displayName ?? 'Player',
      );

      await lobbyService.joinRoom(room.id!, player);
      
      if (context.mounted) {
        context.go('/lobby/${room.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

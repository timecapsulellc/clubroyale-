import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'package:clubroyale/features/social/voice_rooms/models/voice_room.dart';
import 'package:clubroyale/features/game/game_room.dart';

/// Nanobanana-style Live Activity Section
/// Shows Voice Room (purple) and Game Match (green) cards
class LiveActivitySection extends ConsumerWidget {
  const LiveActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVoiceRoomsAsync = ref.watch(activeVoiceRoomsProvider);
    final ongoingGamesAsync = ref.watch(spectatorGamesProvider);

    final activeVoiceRooms = activeVoiceRoomsAsync.value ?? [];
    final ongoingGames = ongoingGamesAsync.value ?? [];
    
    // Show section even if empty (with placeholder)
    final hasContent = activeVoiceRooms.isNotEmpty || ongoingGames.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Live Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        SizedBox(
          height: 130,
          child: hasContent
              ? ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Voice Room Cards (Purple)
                    ...activeVoiceRooms.take(3).map((room) => 
                      _VoiceRoomCard(room: room)
                    ),
                    
                    // Game Match Cards (Green)
                    ...ongoingGames.take(3).map((game) => 
                      _GameMatchCard(game: game)
                    ),
                  ],
                )
              : _EmptyActivityPlaceholder(),
        ),
      ],
    );
  }
}

/// Voice Room Card - Purple Gradient (Nanobanana style)
class _VoiceRoomCard extends StatelessWidget {
  final VoiceRoom room;
  
  const _VoiceRoomCard({required this.room});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7c3aed), Color(0xFF5b21b6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7c3aed).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/voice-room/${room.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon + LIVE badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFef4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Title
                const Text(
                  'VOICE\nROOM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                // Host
                Text(
                  'Host: ${room.hostName}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, duration: 300.ms);
  }
}

/// Game Match Card - Green Gradient (Nanobanana style)
class _GameMatchCard extends StatelessWidget {
  final GameRoom game;
  
  const _GameMatchCard({required this.game});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10b981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10b981).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/spectate/${game.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon + WATCH badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sports_esports, color: Colors.white, size: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'WATCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Title
                const Text(
                  'GAME\nMATCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                // Game type
                Text(
                  'Playing: ${game.gameType}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, duration: 300.ms);
  }
}

/// Empty placeholder when no live activity
class _EmptyActivityPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radio_button_checked, color: Colors.white.withOpacity(0.3), size: 20),
          const SizedBox(width: 12),
          Text(
            'No live activity right now',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

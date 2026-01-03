import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'package:clubroyale/features/social/voice_rooms/models/voice_room.dart';
import 'package:clubroyale/features/game/game_room.dart';

/// Nanobanana-style Live Activity Section
/// Shows Voice Room (purple) and Game Match (blue) cards with rich visual design
class LiveActivitySection extends ConsumerWidget {
  const LiveActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicit types to enforce import usage and type safety
    // Explicit types to enforce import usage and type safety
    final List<VoiceRoom> activeVoiceRoomsAsync =
        ref.watch(activeVoiceRoomsProvider).value ?? [];
    final List<GameRoom> ongoingGamesAsync =
        ref.watch(spectatorGamesProvider).value ?? [];

    // Use Real Data Only (User requested backend alignment)
    final List<VoiceRoom> activeVoiceRooms = activeVoiceRoomsAsync;
    final List<GameRoom> ongoingGames = ongoingGamesAsync;

    // Display nothing if no activity (or use a placeholder)
    if (activeVoiceRooms.isEmpty && ongoingGames.isEmpty) {
      return const SizedBox.shrink(); // Hide section entirely if empty
    }

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
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // Voice Room Cards with Varied Styles
              ...activeVoiceRooms.asMap().entries.map((entry) {
                final index = entry.key;
                final room = entry.value;

                // Determine layout based on index/data
                String title = 'VOICE\nROOM';
                IconData icon = Icons.mic_rounded;
                String status = 'LIVE';
                Color statusColor = const Color(0xFFef4444); // Red
                LinearGradient gradient = const LinearGradient(
                  colors: [Color(0xFF7c3aed), Color(0xFFa855f7)], // Purple
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                );

                // Use index or actual count (demo_2 has 50)
                if (index == 1 || room.participants.length >= 50) {
                  title = 'TRENDING\nROOM';
                  icon = Icons.local_fire_department_rounded;
                  status = 'HOT';
                  statusColor = const Color(0xFFf97316); // Orange
                  gradient = const LinearGradient(
                    colors: [Color(0xFFbe123c), Color(0xFFfb7185)], // Pink/Red
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  );
                } else if (index == 2 || room.name.contains('Karaoke')) {
                  title = 'MUSIC\nPARTY';
                  icon = Icons.music_note_rounded;
                  status = 'LISTEN';
                  statusColor = const Color(0xFF06b6d4); // Cyan
                  gradient = const LinearGradient(
                    colors: [
                      Color(0xFF4c1d95),
                      Color(0xFF8b5cf6),
                    ], // Deep Purple
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  );
                }

                return _ProLiveCard(
                  type: _CardType.voice,
                  title: title,
                  subtitle: 'Host: ${room.hostName}',
                  status: status,
                  statusColor: statusColor,
                  icon: icon,
                  gradient: gradient,
                  onTap: () => context.push('/voice-room/${room.id}'),
                );
              }),

              if (activeVoiceRooms.isNotEmpty) const SizedBox(width: 12),

              // Game Match Cards with Varied Styles
              ...ongoingGames.map((game) {
                // Default Styles
                String title = 'GAME\nMATCH';
                IconData icon = Icons.gamepad_rounded;
                String status = 'WATCH';
                Color statusColor = const Color(0xFF10b981); // Green
                LinearGradient gradient = const LinearGradient(
                  colors: [Color(0xFF1e40af), Color(0xFF3b82f6)], // Blue
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                );

                // Specific Styling based on Game Type
                final gameTypeLower = game.gameType.toLowerCase();

                if (gameTypeLower.contains('teen') ||
                    gameTypeLower.contains('patti')) {
                  title = 'TEEN\nPATTI';
                  icon = Icons.style; // Cards
                  status = 'BLIND';
                  statusColor = const Color(0xFF9333ea); // Purple
                  gradient = const LinearGradient(
                    colors: [
                      Color(0xFF4c1d95),
                      Color(0xFF7c3aed),
                    ], // Deep Purple
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );
                } else if (gameTypeLower.contains('marriage') ||
                    gameTypeLower.contains('royal')) {
                  title = 'ROYAL\nMELD'; // Marriage
                  icon = Icons.diamond_outlined;
                  status = 'MAAL'; // Feature specific
                  statusColor = const Color(0xFFeab308); // Gold
                  gradient = const LinearGradient(
                    colors: [
                      Color(0xFF065f46),
                      Color(0xFF059669),
                    ], // Emerald Green
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );
                } else if (gameTypeLower.contains('call') ||
                    gameTypeLower.contains('break')) {
                  title = 'CALL\nBREAK';
                  icon = Icons.filter_vintage_rounded; // Spades
                  status = 'BIDDING'; // Feature specific
                  statusColor = const Color(0xFF0ea5e9); // Sky Blue
                  gradient = const LinearGradient(
                    colors: [
                      Color(0xFF0f172a),
                      Color(0xFF334155),
                    ], // Slate/Dark
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );
                } else if (game.config.bootAmount > 1000) {
                  // High Stakes Fallback
                  title = 'HIGH\nSTAKES';
                  status = 'VIP';
                }

                return _ProLiveCard(
                  type: _CardType.game,
                  title: title,
                  // Safe ID Display
                  subtitle:
                      'Table: ${(game.id ?? "Unknown").length > 4 ? (game.id ?? "Unknown").substring(0, 4) : (game.id ?? "Unknown")}...', // Show Table ID snippet
                  status: status,
                  statusColor: statusColor,
                  icon: icon,
                  gradient: gradient,
                  onTap: () => context.push('/game/${game.id}'),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

enum _CardType { voice, game }

/// Pro-style Live Activity Card
class _ProLiveCard extends StatelessWidget {
  final _CardType type;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ProLiveCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Wider for bold look
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Pattern (subtle circles)
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Icon + Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: Colors.white, size: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (type == _CardType.voice) ...[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                status,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bottom Row: Title + Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

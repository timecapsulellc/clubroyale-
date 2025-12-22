import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_service.dart';
import 'package:clubroyale/games/in_between/in_between_service.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';
import 'package:clubroyale/core/widgets/animated_card_cover.dart';
import 'package:clubroyale/core/widgets/game_card_graphic.dart';

class GameModesSection extends ConsumerWidget {
  const GameModesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GAME MODES',
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _ModeCard(
              title: 'SOLO',
              subtitle: 'Practice vs AI',
              icon: Icons.person,
              accentColor: const Color(0xFFD4AF37), // Gold
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _showGameSelector(context, ref),
            ),
            _ModeCard(
              title: 'PUBLIC',
              subtitle: 'Ranked Match',
              icon: Icons.public,
              accentColor: const Color(0xFF22C55E), // Green
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isFeatured: true, // Gold glow
              onTap: () => context.go('/lobby'),
            ),
            _ModeCard(
              title: 'PRIVATE',
              subtitle: 'Table Code',
              icon: Icons.lock,
              accentColor: const Color(0xFFA855F7), // Purple
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => _showJoinPrivateDialog(context),
            ),
            _ModeCard(
              title: 'LOCAL',
              subtitle: 'WiFi Host',
              icon: Icons.wifi,
              accentColor: const Color(0xFF3B82F6), // Blue
              bgGradient: LinearGradient(
                colors: [const Color(0xFF2d1b4e), const Color(0xFF1a0a2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local Multiplayer coming in v1.3!'),
                    backgroundColor: Color(0xFF1a0a2e),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showGameSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1a0a2e),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Game (Practice)',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Visual Card Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _GameCardTile(
                  gameType: 'marriage',
                  name: 'Marriage',
                  accentColor: const Color(0xFFE74C3C),
                  onTap: () => _startPracticeGame(context, ref, 'marriage'),
                ),
                _GameCardTile(
                  gameType: 'call_break',
                  name: 'Call Break',
                  accentColor: const Color(0xFFD4AF37),
                  onTap: () => _startPracticeGame(context, ref, 'call_break'),
                ),
                _GameCardTile(
                  gameType: 'teen_patti',
                  name: 'Teen Patti',
                  accentColor: const Color(0xFFE91E63),
                  onTap: () => _startPracticeGame(context, ref, 'teen_patti'),
                ),
                _GameCardTile(
                  gameType: 'in_between',
                  name: 'In-Between',
                  accentColor: const Color(0xFF9B59B6),
                  onTap: () => _startPracticeGame(context, ref, 'in_between'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _startPracticeGame(BuildContext context, WidgetRef ref, String gameType) async {
    Navigator.pop(context); // Close sheet
    
    // Store navigator before async gaps
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      debugPrint('🎮 [Practice] Starting $gameType practice game...');
      final lobbyService = ref.read(lobbyServiceProvider);
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId == null) throw Exception('User not logged in');
      debugPrint('🎮 [Practice] User: $userId');

      // 1. Create Game Room
      debugPrint('🎮 [Practice] Step 1: Creating game room...');
      final room = GameRoom(
        hostId: userId,
        name: 'Practice Match',
        gameType: gameType,
        players: [
          Player(id: userId, name: 'You', isReady: true),
        ],
        scores: {userId: 0},
        config: const GameConfig(
          maxPlayers: 4,
        ),
      );

      final roomId = await lobbyService.createGame(room);
      debugPrint('🎮 [Practice] Room created: $roomId');

      // 2. Add Bots based on Game Type
      debugPrint('🎮 [Practice] Step 2: Adding bots...');
      int requiredBots = 0;
      if (gameType == 'marriage') requiredBots = 2; // Total 3
      if (gameType == 'call_break') requiredBots = 3; // Total 4
      if (gameType == 'teen_patti') requiredBots = 2; // Total 3
      if (gameType == 'in_between') requiredBots = 1; // Total 2

      for (int i = 0; i < requiredBots; i++) {
        debugPrint('🎮 [Practice] Adding bot ${i + 1}/$requiredBots...');
        await lobbyService.addBot(roomId);
      }
      debugPrint('🎮 [Practice] All bots added');

      // 3. Initialize Game Engine
      debugPrint('🎮 [Practice] Step 3: Initializing game engine...');
      final fullRoom = await lobbyService.getGame(roomId);
      if (fullRoom == null) throw Exception('Failed to fetch game room');
      
      final playerIds = fullRoom.players.map((p) => p.id).toList();
      debugPrint('🎮 [Practice] Players: ${playerIds.join(', ')}');

      if (gameType == 'marriage') {
        debugPrint('🎮 [Practice] Starting Marriage engine...');
        await ref.read(marriageServiceProvider).startGame(roomId, playerIds);
      } else if (gameType == 'teen_patti') {
        debugPrint('🎮 [Practice] Starting Teen Patti engine...');
        await ref.read(teenPattiServiceProvider).startGame(roomId, playerIds);
      } else if (gameType == 'in_between') {
        debugPrint('🎮 [Practice] Starting In-Between engine...');
        await ref.read(inBetweenServiceProvider).startGame(roomId, playerIds);
      } else if (gameType == 'call_break') {
        debugPrint('🎮 [Practice] Call Break engine will init in lobbyService.startGame');
      }
      debugPrint('🎮 [Practice] Game engine initialized');

      // 4. Start Game (update status)
      debugPrint('🎮 [Practice] Step 4: Starting game...');
      await lobbyService.startGame(roomId);
      debugPrint('🎮 [Practice] Game started!');

      // 5. Navigate (use stored references)
      debugPrint('🎮 [Practice] Step 5: Navigating to game screen...');
      navigator.pop(); // Close loading dialog
      
      if (gameType == 'marriage') {
        router.push('/marriage/$roomId');
      } else if (gameType == 'teen_patti') {
        router.push('/teen_patti/$roomId');
      } else if (gameType == 'in_between') {
        router.push('/in_between/$roomId');
      } else {
        router.push('/game/$roomId/play');
      }
      debugPrint('🎮 [Practice] Navigation complete!');

    } catch (e, stackTrace) {
      debugPrint('❌ [Practice] Error starting practice game: $e');
      debugPrint('❌ [Practice] Stack trace: $stackTrace');
      try {
        navigator.pop(); // Close loading
      } catch (_) {}
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting practice game: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showJoinPrivateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a2e),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1)
        ),
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text('Join Private Table', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the code shared by your friend to join their table.',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'CODE',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: const Color(0xFF2d1b4e),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37))
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                 Navigator.pop(context);
                 context.push('/lobby/${controller.text}');
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
            ),
            child: const Text('Join Table', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// Visual game card tile with card graphics
class _GameCardTile extends StatelessWidget {
  final String gameType;
  final String name;
  final Color accentColor;
  final VoidCallback onTap;

  const _GameCardTile({
    required this.gameType,
    required this.name,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2d1b4e).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                GameCardGraphic(
                  gameType: gameType,
                  size: 55, // Reduced from 80 to fix overflow
                  animate: true,
                ),
              const SizedBox(height: 12),
              // Game name label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Gradient bgGradient;
  final VoidCallback onTap;
  final bool isFeatured;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgGradient,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isFeatured ? const Color(0xFFD4AF37) : Colors.white.withValues(alpha: 0.1),
              width: isFeatured ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (isFeatured)
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative Background Icon (Watermark)
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: -0.2, // Tilted
                  child: Icon(
                    icon, // Uses the mode icon as the watermark
                    size: 100, // Large
                    color: accentColor.withValues(alpha: 0.1), // Subtle
                  ),
                ),
              ),
              
              // Main Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Icon(icon, color: accentColor, size: 22),
                        ),
                        if (isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('LIVE', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds, delay: 1.seconds),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isFeatured ? const Color(0xFFD4AF37) : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Animated Shimmer Overlay (Glass Effect)
              AnimatedCardCover(
                borderRadius: BorderRadius.circular(24),
                // Randomize intervals slightly or use standard? 
                // Using different intervals makes them feel independent and organic.
                // We can't easily randomize purely inside stateless, but we can base it on title length or hashcode.
                interval: Duration(milliseconds: 3000 + (title.hashCode % 3000)),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}

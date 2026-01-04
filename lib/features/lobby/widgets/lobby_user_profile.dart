import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/auth/auth_service.dart';


class LobbyUserProfile extends ConsumerWidget {
  const LobbyUserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    // Assuming user has displayName, photoUrl, etc.

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar (Hero Size)
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CasinoColors.gold, width: 3),
              image: DecorationImage(
                image: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : const AssetImage('assets/images/avatars/default_avatar.png')
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info Stats Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                Text(
                  user?.displayName ?? 'Guest Player',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Oswald
                    color: Colors.white,
                    height: 1.0,
                    shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Stats (Coins, Games, Level)
                _buildStatRow(context, "Coins", "0", CasinoColors.gold), // Real data would plug here
                _buildStatRow(context, "Games Played", "0", Colors.white70),
                _buildStatRow(context, "Player Level", "0", Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium, // Roboto
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(color: CasinoColors.tableGreenMid, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

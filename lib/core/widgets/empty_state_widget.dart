// Empty State Widget - Premium styled component for empty data screens
//
// Use this across the app when:
// - No games found
// - No friends
// - No diamonds
// - No tournaments
// - etc.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
  });

  // Pre-built factory constructors for common cases
  factory EmptyStateWidget.noGames({VoidCallback? onCreateGame}) {
    return EmptyStateWidget(
      icon: Icons.casino_outlined,
      title: 'No Active Games',
      subtitle: 'Create a new room or join a friend\'s game',
      actionLabel: 'Create Game',
      onAction: onCreateGame,
      accentColor: CasinoColors.gold,
    );
  }

  factory EmptyStateWidget.noFriends({VoidCallback? onAddFriend}) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No Friends Yet',
      subtitle: 'Add friends to play together and climb the leaderboards',
      actionLabel: 'Add Friends',
      onAction: onAddFriend,
      accentColor: Colors.pinkAccent,
    );
  }

  factory EmptyStateWidget.noDiamonds({VoidCallback? onEarnDiamonds}) {
    return EmptyStateWidget(
      icon: Icons.diamond_outlined,
      title: 'Diamond Vault Empty',
      subtitle: 'Earn diamonds by playing games and completing challenges',
      actionLabel: 'Earn Diamonds',
      onAction: onEarnDiamonds,
      accentColor: Colors.cyan,
    );
  }

  factory EmptyStateWidget.noTournaments({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.emoji_events_outlined,
      title: 'No Tournaments',
      subtitle: 'Check back later for exciting tournaments!',
      actionLabel: 'Browse Lobby',
      onAction: onBrowse,
      accentColor: CasinoColors.gold,
    );
  }

  factory EmptyStateWidget.noHistory() {
    return const EmptyStateWidget(
      icon: Icons.history_outlined,
      title: 'No Game History',
      subtitle: 'Your completed games will appear here',
    );
  }

  factory EmptyStateWidget.noClubs({VoidCallback? onCreateClub}) {
    return EmptyStateWidget(
      icon: Icons.groups_outlined,
      title: 'No Clubs Joined',
      subtitle: 'Create or join a club to find regular gaming partners',
      actionLabel: 'Explore Clubs',
      onAction: onCreateClub,
      accentColor: Colors.purpleAccent,
    );
  }

  factory EmptyStateWidget.noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none_outlined,
      title: 'All Caught Up!',
      subtitle: 'No new notifications at the moment',
      accentColor: Colors.greenAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? CasinoColors.gold;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with glow
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 64, color: color),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 2.seconds,
                ),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}

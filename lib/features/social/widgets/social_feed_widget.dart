import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:clubroyale/features/social/models/social_activity.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'dart:ui';

/// Compact activity feed widget for the social dashboard
class SocialFeedWidget extends ConsumerWidget {
  final int maxItems;
  
  const SocialFeedWidget({
    super.key,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;
    
    if (userId == null) {
      return const SizedBox.shrink();
    }

    // Watch activity feed provider
    final activitiesAsync = ref.watch(activityFeedProvider(maxItems));

    return activitiesAsync.when(
      loading: () => _LoadingState(),
      error: (err, stack) => _EmptyFeedState(), // Treat error as empty for now or show error
      data: (activities) {
        if (activities.isEmpty) {
          return _EmptyFeedState();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4), // Slightly darker for legibility
                borderRadius: BorderRadius.circular(20), // Kept for border alignment
                border: Border.all(
                  color: CasinoColors.gold.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.dynamic_feed_rounded,
                          color: CasinoColors.gold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.go('/activity'),
                          child: Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: CasinoColors.gold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: CasinoColors.gold,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Activity List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _ActivityTile(
                        activity: activity,
                      ).animate(delay: (50 * index).ms)
                          .fadeIn()
                          .slideX(begin: -0.1);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final SocialActivity activity;
  
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForType(activity.type);
    final iconColor = _getColorForType(activity.type);
    
    return InkWell(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(
                          text: activity.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${activity.content}'),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(activity.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'game_won':
        return Icons.emoji_events_rounded;
      case 'game_lost':
        return Icons.sports_esports_rounded;
      case 'club_joined':
        return Icons.groups_rounded;
      case 'friend_added':
        return Icons.person_add_rounded;
      case 'message':
        return Icons.chat_bubble_rounded;
      case 'invite':
        return Icons.mail_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
  
  Color _getColorForType(String type) {
    switch (type) {
      case 'game_won':
        return Colors.amber;
      case 'game_lost':
        return Colors.red;
      case 'club_joined':
        return Colors.purple;
      case 'friend_added':
        return Colors.green;
      case 'message':
        return Colors.blue;
      case 'invite':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  void _handleTap(BuildContext context) {
    switch (activity.type) {
      case 'game_won':
      case 'game_lost':
        final gameId = activity.metadata?['gameId'];
        if (gameId != null) {
          context.go('/history');
        }
        break;
      case 'club_joined':
        context.go('/clubs');
        break;
      case 'friend_added':
        context.go('/user/${activity.userId}');
        break;
      case 'message':
      case 'invite':
        context.go('/chats');
        break;
      default:
        context.go('/activity');
    }
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: CasinoColors.gold,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CasinoColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.dynamic_feed_rounded,
            color: CasinoColors.gold.withValues(alpha: 0.4),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No activity yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Play games and connect with friends to see updates here',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Play',
                onTap: () => context.go('/lobby'),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.person_add_rounded,
                label: 'Find Friends',
                onTap: () => context.go('/friends'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: CasinoColors.gold,
        backgroundColor: CasinoColors.gold.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/social/models/social_activity.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'dart:ui';

/// Nanobanana-style Activity Feed with Glassmorphism
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

    final activitiesAsync = ref.watch(activityFeedProvider(maxItems));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title (outside glassmorphism container)
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Activity Feed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Glassmorphism Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: activitiesAsync.when(
                loading: () => _LoadingState(),
                error: (err, stack) => _EmptyFeedState(),
                data: (activities) {
                  if (activities.isEmpty) {
                    return _EmptyFeedState();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: activities.asMap().entries.map((entry) {
                        final index = entry.key;
                        final activity = entry.value;
                        return _ActivityFeedItem(
                          activity: activity,
                        ).animate(delay: (50 * index).ms)
                            .fadeIn()
                            .slideX(begin: -0.05);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Nanobanana-style single activity item
class _ActivityFeedItem extends StatelessWidget {
  final SocialActivity activity;

  const _ActivityFeedItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Avatar with gold border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF2d1b4e),
              backgroundImage: activity.userAvatar != null
                  ? NetworkImage(activity.userAvatar!)
                  : null,
              child: activity.userAvatar == null
                  ? Text(
                      activity.userName.isNotEmpty 
                          ? activity.userName[0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  activity.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action Button
          OutlinedButton(
            onPressed: () => _handleAction(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(0, 32),
            ),
            child: Text(
              _getActionLabel(),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _getActionLabel() {
    switch (activity.type) {
      case 'game_won':
        return 'Congratulate';
      case 'club_joined':
        return 'View Club';
      case 'friend_added':
        return 'View';
      case 'message':
        return 'Reply';
      default:
        return 'View';
    }
  }

  void _handleAction(BuildContext context) {
    switch (activity.type) {
      case 'game_won':
      case 'game_lost':
        context.go('/history');
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
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.dynamic_feed_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No activity yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

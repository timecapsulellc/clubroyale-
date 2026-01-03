import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/social/services/presence_service.dart';
import 'package:clubroyale/features/social/services/friend_service.dart';
import 'package:clubroyale/features/social/models/social_user_model.dart';

/// Horizontal scrollable bar showing online friends with presence indicators
class OnlineFriendsBar extends ConsumerWidget {
  const OnlineFriendsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendService = ref.watch(friendServiceProvider);

    return StreamBuilder<List<String>>(
      stream: friendService.watchMyFriendIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _EmptyFriendsState();
        }

        final friendIds = snapshot.data!;

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: CasinoColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: CasinoColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${friendIds.length}',
                        style: TextStyle(
                          color: CasinoColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go('/friends'),
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: CasinoColors.gold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: friendIds.length,
                  itemBuilder: (context, index) {
                    return _FriendAvatar(
                          userId: friendIds[index],
                          onTap: () => context.go('/user/${friendIds[index]}'),
                        )
                        .animate(delay: (50 * index).ms)
                        .fadeIn()
                        .slideX(begin: 0.2);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FriendAvatar extends ConsumerWidget {
  final String userId;
  final VoidCallback onTap;

  const _FriendAvatar({required this.userId, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenceService = ref.watch(presenceServiceProvider);

    return StreamBuilder<SocialUserStatus>(
      stream: presenceService.watchUserStatus(userId),
      builder: (context, snapshot) {
        final presence = snapshot.data;
        final isOnline =
            presence?.status == UserStatus.online ||
            presence?.status == UserStatus.inGame;
        final isInGame = presence?.status == UserStatus.inGame;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isInGame
                              ? Colors.amber
                              : (isOnline ? Colors.green : Colors.grey),
                          width: 2,
                        ),
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color:
                                      (isInGame ? Colors.amber : Colors.green)
                                          .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipOval(child: _buildAvatar(userId)),
                    ),
                    // Status indicator
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isInGame
                              ? Colors.amber
                              : (isOnline ? Colors.green : Colors.grey),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CasinoColors.darkPurple,
                            width: 2,
                          ),
                        ),
                        child: isInGame
                            ? const Icon(
                                Icons.gamepad,
                                size: 8,
                                color: Colors.black,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatUserId(userId),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatUserId(String id) {
    // Show first 6 chars or the whole thing if shorter
    if (id.length > 8) {
      return '${id.substring(0, 6)}...';
    }
    return id;
  }

  Widget _buildAvatar(String id) {
    // Generate color based on id
    final hue = (id.hashCode % 360).abs().toDouble();
    final bgColor = HSLColor.fromAHSL(1.0, hue, 0.6, 0.4).toColor();

    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          id.isNotEmpty ? id[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _EmptyFriendsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => context.go('/friends'),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_rounded,
              color: CasinoColors.gold.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Find friends to play with',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

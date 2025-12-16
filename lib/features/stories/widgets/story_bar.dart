import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/stories/models/story.dart';
import 'package:clubroyale/features/stories/services/story_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Ring color types for story avatars (Nanobanana style)
enum StoryRingType { gold, teal, purple, gray }

/// Story circle widget with colored gradient ring borders
class StoryCircle extends ConsumerWidget {
  final UserStories? userStories;
  final bool isCurrentUser;
  final StoryRingType? ringType;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const StoryCircle({
    super.key,
    this.userStories,
    this.isCurrentUser = false,
    this.ringType,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnviewed = userStories?.hasUnviewed ?? false;
    final hasStories = (userStories?.stories.isNotEmpty ?? false);
    
    // Determine ring type based on story state or explicit override
    final effectiveRingType = ringType ?? 
        (isCurrentUser ? StoryRingType.gold : 
         hasUnviewed ? StoryRingType.purple : 
         hasStories ? StoryRingType.teal : StoryRingType.gray);

    return GestureDetector(
      onTap: isCurrentUser && !hasStories ? onAddTap : onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.only(right: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Avatar with colored ring
                Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _getRingGradient(effectiveRingType),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1a0a2e),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF2d1b4e),
                      backgroundImage: userStories?.userPhotoUrl != null
                          ? NetworkImage(userStories!.userPhotoUrl!)
                          : null,
                      child: userStories?.userPhotoUrl == null
                          ? const Icon(Icons.person, size: 26, color: Colors.white54)
                          : null,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => hasUnviewed ? controller.repeat() : null)
                .shimmer(
                   duration: 2000.ms, 
                   color: hasUnviewed ? Colors.white.withOpacity(0.4) : Colors.transparent
                ),
                
                // Add button for current user
                if (isCurrentUser)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1a0a2e),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: Color(0xFF1a0a2e),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isCurrentUser ? 'Your Story' : (userStories?.userName ?? 'User'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: hasUnviewed ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getRingGradient(StoryRingType type) {
    switch (type) {
      case StoryRingType.gold:
        return const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case StoryRingType.teal:
        return const LinearGradient(
          colors: [Color(0xFF14b8a6), Color(0xFF0d9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case StoryRingType.purple:
        return const LinearGradient(
          colors: [Color(0xFF7c3aed), Color(0xFF5b21b6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case StoryRingType.gray:
        return LinearGradient(
          colors: [Colors.grey.shade600, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

/// Horizontal story bar with section title (Nanobanana style)
class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsStoriesAsync = ref.watch(friendsStoriesProvider);
    final myStoriesAsync = ref.watch(myStoriesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final userProfile = ref.watch(authStateProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Story Bar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Story circles
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // Current user's story circle (gold ring)
              StoryCircle(
                isCurrentUser: true,
                ringType: StoryRingType.gold,
                userStories: myStoriesAsync.whenOrNull(
                  data: (stories) => stories.isEmpty
                      ? null
                      : UserStories(
                          userId: currentUserId ?? '',
                          userName: userProfile?.displayName ?? 'You',
                          userPhotoUrl: userProfile?.photoURL,
                          stories: stories,
                          hasUnviewed: false,
                        ),
                ),
                onAddTap: () => context.push('/stories/create'),
                onTap: () {
                  final stories = myStoriesAsync.value ?? [];
                  if (stories.isNotEmpty) {
                    context.push('/stories/view', extra: {
                      'stories': stories,
                      'initialIndex': 0,
                      'isOwn': true,
                    });
                  } else {
                    context.push('/stories/create');
                  }
                },
              ),
              // Friends' stories with alternating ring colors
              friendsStoriesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
                data: (userStoriesList) => Row(
                  children: userStoriesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final userStories = entry.value;
                    // Alternate between teal and purple for variety
                    final ringType = userStories.hasUnviewed 
                        ? (index % 2 == 0 ? StoryRingType.purple : StoryRingType.teal)
                        : StoryRingType.gray;
                    
                    return StoryCircle(
                      userStories: userStories,
                      ringType: ringType,
                      onTap: () {
                        context.push('/stories/view', extra: {
                          'stories': userStories.stories,
                          'initialIndex': 0,
                          'isOwn': false,
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

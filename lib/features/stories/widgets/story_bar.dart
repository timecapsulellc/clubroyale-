import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/features/stories/models/story.dart';
import 'package:taasclub/features/stories/services/story_service.dart';
import 'package:taasclub/features/auth/auth_service.dart';

/// Story circle widget for the story bar
class StoryCircle extends ConsumerWidget {
  final UserStories? userStories;
  final bool isCurrentUser;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const StoryCircle({
    super.key,
    this.userStories,
    this.isCurrentUser = false,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final hasUnviewed = userStories?.hasUnviewed ?? false;
    final hasStories = (userStories?.stories.isNotEmpty ?? false);

    return GestureDetector(
      onTap: isCurrentUser && !hasStories ? onAddTap : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              // Story ring (gradient when has unviewed stories)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStories
                      ? LinearGradient(
                          colors: hasUnviewed
                              ? [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                  colorScheme.tertiary,
                                ]
                              : [
                                  Colors.grey.shade400,
                                  Colors.grey.shade500,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: !hasStories
                      ? Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: userStories?.userPhotoUrl != null
                        ? NetworkImage(userStories!.userPhotoUrl!)
                        : null,
                    child: userStories?.userPhotoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                ),
              ),
              // Add button for current user
              if (isCurrentUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 72,
            child: Text(
              isCurrentUser ? 'Your Story' : (userStories?.userName ?? 'User'),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: hasUnviewed ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal story bar widget
class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsStoriesAsync = ref.watch(friendsStoriesProvider);
    final myStoriesAsync = ref.watch(myStoriesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final userProfile = ref.watch(authStateProvider).value;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // Current user's story circle
          StoryCircle(
            isCurrentUser: true,
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
          const SizedBox(width: 8),
          // Friends' stories
          friendsStoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (userStoriesList) => Row(
              children: userStoriesList.map((userStories) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: StoryCircle(
                    userStories: userStories,
                    onTap: () {
                      context.push('/stories/view', extra: {
                        'stories': userStories.stories,
                        'initialIndex': 0,
                        'isOwn': false,
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/utils/haptic_helper.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';
import 'package:clubroyale/features/profile/user_profile.dart';
import 'package:clubroyale/features/profile/profile_service.dart';

/// Screen to display followers or following list
class FollowersListScreen extends ConsumerWidget {
  final String userId;
  final bool isFollowers; // true = followers, false = following

  const FollowersListScreen({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = isFollowers
        ? ref.watch(followersProvider(userId))
        : ref.watch(followingProvider(userId));

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isFollowers ? 'Followers' : 'Following'),
      ),
      body: listAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonLeaderboard(itemCount: 5),
        ),
        error: (e, _) => Center(child: Text(ErrorHelper.getFriendlyMessage(e))),
        data: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFollowers ? Icons.people_outline : Icons.person_add_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFollowers ? 'No followers yet' : 'Not following anyone yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _UserTile(profile: profile);
            },
          );
        },
      ),
    );
  }
}

/// Single user tile for followers/following list
class _UserTile extends ConsumerWidget {
  final UserProfile profile;

  const _UserTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFollowingAsync = ref.watch(isFollowingProvider(profile.id));

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: profile.avatarUrl != null
            ? NetworkImage(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? Text(
                profile.displayName.isNotEmpty
                    ? profile.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              profile.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (profile.isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ],
      ),
      subtitle: Text(
        '${profile.rankTitle} • ${profile.followersCount} followers',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: isFollowingAsync.when(
        loading: () => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (isFollowing) => SizedBox(
          width: 100,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? colorScheme.surfaceContainerHighest : colorScheme.primary,
              foregroundColor: isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () async {
              HapticHelper.lightTap();
              final service = ref.read(profileServiceProvider);
              if (isFollowing) {
                await service.unfollowUser(profile.id);
              } else {
                await service.followUser(profile.id);
              }
              ref.invalidate(isFollowingProvider(profile.id));
            },
            child: Text(
              isFollowing ? 'Following' : 'Follow',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
      onTap: () => context.push('/user/${profile.id}'),
    );
  }
}

/// User search delegate for finding users
class UserSearchDelegate extends SearchDelegate<UserProfile?> {
  final WidgetRef ref;

  UserSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: Implement search with Firestore query
    return Center(
      child: Text('Search for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Search for users by name'),
      );
    }
    return buildResults(context);
  }
}

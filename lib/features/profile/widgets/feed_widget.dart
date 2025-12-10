import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/profile/user_profile.dart';
import 'package:clubroyale/features/profile/profile_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Feed widget showing posts from followed users
class FeedWidget extends ConsumerWidget {
  const FeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileService = ref.watch(profileServiceProvider);

    return StreamBuilder<List<UserPost>>(
      stream: profileService.getFeedPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const _EmptyFeed();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
    );
  }
}

/// Empty feed placeholder
class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dynamic_feed_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Follow some players to see their posts!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

/// Post card widget
class PostCard extends ConsumerWidget {
  final UserPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUserId = ref.watch(currentUserIdProvider);
    final isLiked = currentUserId != null && post.likedBy.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userAvatarUrl != null
                  ? NetworkImage(post.userAvatarUrl!)
                  : null,
              child: post.userAvatarUrl == null
                  ? Text(post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?')
                  : null,
            ),
            title: Text(
              post.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              timeago.format(post.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showPostOptions(context, ref, post),
            ),
            onTap: () => context.push('/user/${post.userId}'),
          ),

          // Game highlight badge
          if (post.gameId != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_esports, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      post.gameType ?? 'Game',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(post.content),
            ),

          // Media
          if (post.mediaUrl != null) ...[
            ClipRRect(
              child: Image.network(
                post.mediaUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Like
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: () async {
                    final service = ref.read(profileServiceProvider);
                    if (isLiked) {
                      await service.unlikePost(post.id);
                    } else {
                      await service.likePost(post.id);
                    }
                  },
                ),
                Text('${post.likesCount}'),
                const SizedBox(width: 16),

                // Comment
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // TODO: Open comments
                  },
                ),
                Text('${post.commentsCount}'),
                const SizedBox(width: 16),

                // Share
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: Share post
                  },
                ),
                Text('${post.sharesCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context, WidgetRef ref, UserPost post) {
    final currentUserId = ref.read(currentUserIdProvider);
    final isOwn = currentUserId == post.userId;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwn) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Post?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(profileServiceProvider).deletePost(post.id);
                  }
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Copy link
              },
            ),
            if (!isOwn) ...[
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Report
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

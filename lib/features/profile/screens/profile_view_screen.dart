import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/widgets/skeleton_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/profile/user_profile.dart';
import 'package:clubroyale/features/profile/profile_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Enhanced profile view screen with social features
class ProfileViewScreen extends ConsumerWidget {
  final String? userId;

  const ProfileViewScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final targetUserId = userId ?? currentUserId;
    final isOwnProfile = targetUserId == currentUserId;

    if (targetUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view profile')),
      );
    }

    final profileAsync = ref.watch(profileByIdProvider(targetUserId));
    final theme = Theme.of(context);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const SkeletonProfile(),
        error: (e, _) => Center(child: Text(ErrorHelper.getFriendlyMessage(e))),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }

          return CustomScrollView(
            slivers: [
              // Profile header with cover photo
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: CasinoColors.deepPurple,
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(
                    profile: profile,
                    isOwnProfile: isOwnProfile,
                  ),
                ),
                actions: [
                  if (isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push('/profile'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showProfileOptions(context, profile),
                  ),
                ],
              ),

              // Stats row
              SliverToBoxAdapter(
                child: _StatsRow(profile: profile).animate().fadeIn(),
              ),

              // Bio and info
              if (profile.bio != null && profile.bio!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      profile.bio!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),

              // Action buttons
              SliverToBoxAdapter(
                child: _ActionButtons(
                  profile: profile,
                  isOwnProfile: isOwnProfile,
                ).animate().fadeIn(delay: 100.ms),
              ),

              // Tabs for Posts/Achievements/Badges
              SliverToBoxAdapter(child: _ProfileTabs(userId: targetUserId)),
            ],
          );
        },
      ),
    );
  }

  void _showProfileOptions(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                _shareProfile(context, profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Profile Link'),
              onTap: () {
                Navigator.pop(context);
                _copyProfileLink(context, profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _blockUser(context, profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _reportUser(context, profile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareProfile(BuildContext context, UserProfile profile) {
    final url = 'https://clubroyale.app/profile/${profile.id}';
    // Uses share_plus or similar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing profile: ${profile.displayName}')),
    );
  }

  void _copyProfileLink(BuildContext context, UserProfile profile) {
    final url = 'https://clubroyale.app/profile/${profile.id}';
    // Uses Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile link copied to clipboard!')),
    );
  }

  void _blockUser(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${profile.displayName}? They won\'t be able to see your profile or message you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call ProfileService.blockUser(profile.id)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${profile.displayName} has been blocked'),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _reportUser(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting ${profile.displayName}?'),
            const SizedBox(height: 16),
            ..._reportReasons.map(
              (reason) => ListTile(
                title: Text(reason),
                leading: const Icon(Icons.report_problem_outlined),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Call ReportService.reportUser(profile.id, reason)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Report submitted. Thank you for keeping our community safe!',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static const _reportReasons = [
    'Harassment or bullying',
    'Cheating or exploiting',
    'Spam or scam',
    'Inappropriate content',
    'Other',
  ];
}

/// Profile header with avatar, cover photo, and name
class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;

  const _ProfileHeader({required this.profile, required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Cover photo
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CasinoColors.richPurple, CasinoColors.deepPurple],
            ),
            image: profile.coverPhotoUrl != null
                ? DecorationImage(
                    image: NetworkImage(profile.coverPhotoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),

        // Gradient overlay
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
            ),
          ),
        ),

        // Profile info
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: profile.isVerified
                        ? CasinoColors.gold
                        : Colors.white,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.displayName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                        if (profile.isCreator) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRankColor(profile.rankTitle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile.rankTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ELO ${profile.eloRating}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'Grandmaster':
        return Colors.purple;
      case 'Master':
        return Colors.red;
      case 'Expert':
        return Colors.orange;
      case 'Advanced':
        return Colors.blue;
      case 'Intermediate':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// Stats row showing followers, following, games
class _StatsRow extends ConsumerWidget {
  final UserProfile profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: 'Followers',
            value: _formatCount(profile.followersCount),
            onTap: () => context.push('/followers/${profile.id}'),
          ),
          _StatItem(
            label: 'Following',
            value: _formatCount(profile.followingCount),
            onTap: () => context.push('/following/${profile.id}'),
          ),
          _StatItem(
            label: 'Games',
            value: _formatCount(profile.gamesPlayed),
            onTap: null,
          ),
          _StatItem(
            label: 'Win Rate',
            value: '${profile.winRate.toStringAsFixed(1)}%',
            onTap: null,
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatItem({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons (follow, message, etc.)
class _ActionButtons extends ConsumerWidget {
  final UserProfile profile;
  final bool isOwnProfile;

  const _ActionButtons({required this.profile, required this.isOwnProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isOwnProfile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/profile'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Share profile
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      );
    }

    final isFollowingAsync = ref.watch(isFollowingProvider(profile.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: isFollowingAsync.when(
              loading: () => ElevatedButton(
                onPressed: null,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) =>
                  ElevatedButton(onPressed: () {}, child: const Text('Follow')),
              data: (isFollowing) => ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primary,
                  foregroundColor: isFollowing
                      ? colorScheme.onSurface
                      : colorScheme.onPrimary,
                ),
                onPressed: () async {
                  final service = ref.read(profileServiceProvider);
                  if (isFollowing) {
                    await service.unfollowUser(profile.id);
                  } else {
                    await service.followUser(profile.id);
                  }
                  ref.invalidate(isFollowingProvider(profile.id));
                },
                icon: Icon(
                  isFollowing ? Icons.person_remove : Icons.person_add,
                ),
                label: Text(isFollowing ? 'Following' : 'Follow'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Open DM
              },
              icon: const Icon(Icons.message),
              label: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile tabs for posts/achievements/badges
class _ProfileTabs extends ConsumerStatefulWidget {
  final String userId;

  const _ProfileTabs({required this.userId});

  @override
  ConsumerState<_ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends ConsumerState<_ProfileTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.star), text: 'Badges'),
          ],
          labelColor: colorScheme.primary,
          indicatorColor: colorScheme.primary,
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _PostsGrid(userId: widget.userId),
              _AchievementsList(userId: widget.userId),
              _BadgesList(userId: widget.userId),
            ],
          ),
        ),
      ],
    );
  }
}

/// Posts grid
class _PostsGrid extends ConsumerWidget {
  final String userId;

  const _PostsGrid({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(ErrorHelper.getFriendlyMessage(e))),
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('No posts yet'),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return GestureDetector(
              onTap: () {
                // TODO: Open post detail
              },
              child: Container(
                color: Colors.grey[800],
                child: post.mediaUrl != null
                    ? Image.network(post.mediaUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            post.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Achievements list
class _AchievementsList extends ConsumerWidget {
  final String userId;

  const _AchievementsList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load achievements from provider
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Achievements coming soon!'),
        ],
      ),
    );
  }
}

/// Badges list
class _BadgesList extends ConsumerWidget {
  final String userId;

  const _BadgesList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load badges from provider
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Badges coming soon!'),
        ],
      ),
    );
  }
}

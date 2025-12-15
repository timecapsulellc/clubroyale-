/// Badges Grid Widget
/// 
/// Displays user's earned badges and achievements in a horizontal grid

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/profile/user_profile.dart';
import 'package:clubroyale/features/profile/achievements/achievements_data.dart';
import 'package:clubroyale/features/profile/achievements/achievement_service.dart';

/// Horizontal scrolling badges grid
class BadgesGrid extends ConsumerWidget {
  final String userId;
  final int maxDisplay;
  final VoidCallback? onSeeAllTap;

  const BadgesGrid({
    super.key,
    required this.userId,
    this.maxDisplay = 6,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider(userId));

    return achievementsAsync.when(
      data: (achievements) {
        final unlocked = achievements.where((a) => a.isUnlocked).toList();
        
        if (unlocked.isEmpty) {
          return const _EmptyBadgesCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Achievements (${unlocked.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onSeeAllTap != null)
                    TextButton(
                      onPressed: onSeeAllTap,
                      child: const Text('See All'),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: unlocked.length > maxDisplay ? maxDisplay : unlocked.length,
                itemBuilder: (context, index) {
                  final achievement = unlocked[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _BadgeItem(
                      achievement: achievement,
                      onTap: () => _showAchievementDetail(context, achievement),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailSheet(achievement: achievement),
    );
  }
}

/// Single badge item widget
class _BadgeItem extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const _BadgeItem({
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(
      int.parse(
        AchievementsData.getRarityColor(achievement.rarity).replaceFirst('#', '0xFF'),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rarityColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rarityColor.withValues(alpha: 0.2),
              ),
              child: Icon(
                _getIconForAchievement(achievement.id),
                color: rarityColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAchievement(String id) {
    final iconMap = {
      'first_win': Icons.emoji_events,
      'win_10': Icons.star,
      'win_50': Icons.workspace_premium,
      'win_100': Icons.military_tech,
      'win_500': Icons.diamond,
      'marriage_master': Icons.favorite,
      'call_break_ace': Icons.style,
      'teen_patti_king': Icons.casino,
      'perfect_declare': Icons.check_circle,
      'streak_3': Icons.local_fire_department,
      'streak_7': Icons.whatshot,
      'daily_7': Icons.calendar_today,
      'daily_30': Icons.calendar_month,
      'first_friend': Icons.person_add,
      'friends_10': Icons.people,
      'friends_50': Icons.groups,
      'host_5': Icons.home,
      'host_25': Icons.celebration,
      'beta_tester': Icons.bug_report,
      'tournament_winner': Icons.emoji_events,
      'diamond_spender': Icons.paid,
    };
    return iconMap[id] ?? Icons.verified;
  }
}

/// Empty state for badges
class _EmptyBadgesCard extends StatelessWidget {
  const _EmptyBadgesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No achievements yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Play games to earn badges!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievement detail bottom sheet
class AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailSheet({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(
      int.parse(
        AchievementsData.getRarityColor(achievement.rarity).replaceFirst('#', '0xFF'),
      ),
    );
    final rarityName = AchievementsData.getRarityName(achievement.rarity);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Badge icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rarityColor.withValues(alpha: 0.2),
              border: Border.all(color: rarityColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              achievement.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: rarityColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rarityName,
              style: TextStyle(
                color: rarityColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          if (achievement.maxProgress != null && achievement.maxProgress! > 1)
            Column(
              children: [
                LinearProgressIndicator(
                  value: (achievement.progress ?? 0) / achievement.maxProgress!,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(rarityColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${achievement.progress ?? 0} / ${achievement.maxProgress}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          // Unlock date
          if (achievement.isUnlocked && achievement.unlockedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Full achievements screen
class AllAchievementsScreen extends ConsumerWidget {
  final String userId;

  const AllAchievementsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: FutureBuilder<List<Achievement>>(
        future: ref.read(achievementServiceProvider).getAllWithProgress(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final achievements = snapshot.data ?? [];
          final unlocked = achievements.where((a) => a.isUnlocked).toList();
          final locked = achievements.where((a) => !a.isUnlocked).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats card
              _StatsCard(total: achievements.length, unlocked: unlocked.length),
              const SizedBox(height: 24),
              
              // Unlocked section
              if (unlocked.isNotEmpty) ...[
                Text(
                  'Unlocked (${unlocked.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...unlocked.map((a) => _AchievementListTile(achievement: a)),
                const SizedBox(height: 24),
              ],
              
              // Locked section
              Text(
                'In Progress (${locked.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...locked.map((a) => _AchievementListTile(achievement: a)),
            ],
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int total;
  final int unlocked;

  const _StatsCard({required this.total, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (unlocked / total * 100).round() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$unlocked of $total achievements',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: unlocked / total,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementListTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementListTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final rarityColor = Color(
      int.parse(
        AchievementsData.getRarityColor(achievement.rarity).replaceFirst('#', '0xFF'),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: achievement.isUnlocked 
                ? rarityColor.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            border: Border.all(
              color: achievement.isUnlocked ? rarityColor : Colors.grey,
              width: 2,
            ),
          ),
          child: Icon(
            achievement.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
            color: achievement.isUnlocked ? rarityColor : Colors.grey,
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: achievement.isUnlocked ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: achievement.isUnlocked ? null : Colors.grey,
              ),
            ),
            if (achievement.maxProgress != null && achievement.maxProgress! > 1)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(
                  value: (achievement.progress ?? 0) / achievement.maxProgress!,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    achievement.isUnlocked ? rarityColor : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rarityColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            AchievementsData.getRarityName(achievement.rarity),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: rarityColor,
            ),
          ),
        ),
      ),
    );
  }
}

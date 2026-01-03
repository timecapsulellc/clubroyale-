/// Club Detail Screen
///
/// Shows club info, members, and leaderboard
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/clubs/club_model.dart';
import 'package:clubroyale/features/clubs/club_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

class ClubDetailScreen extends ConsumerWidget {
  final String clubId;

  const ClubDetailScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubProvider(clubId));

    return clubAsync.when(
      data: (club) {
        if (club == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Club not found')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _ClubHeader(club: club),
              ],
              body: TabBarView(
                children: [
                  _ActivityTab(clubId: clubId),
                  _LeaderboardTab(clubId: clubId),
                  _MembersTab(club: club),
                ],
              ),
            ),
            floatingActionButton:
                club.memberIds.contains(
                  ref.read(authServiceProvider).currentUser?.uid,
                )
                ? FloatingActionButton.extended(
                    onPressed: () {
                      if (club.chatId != null) {
                        context.push('/social/chat/${club.chatId}');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat not available for this club'),
                          ),
                        );
                      }
                    },
                    label: const Text('Club Chat'),
                    icon: const Icon(Icons.forum),
                  )
                : null,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ClubHeader extends ConsumerWidget {
  final Club club;

  const _ClubHeader({required this.club});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final isMember = club.memberIds.contains(auth.currentUser?.uid);
    final isOwner = club.ownerId == auth.currentUser?.uid;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(club.name),
            if (club.isVerified)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.verified, size: 16, color: Colors.blue),
              ),
          ],
        ),
        background: club.bannerUrl != null
            ? Image.network(club.bannerUrl!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        if (isOwner)
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        if (isMember && !isOwner)
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'leave', child: Text('Leave Club')),
            ],
            onSelected: (value) async {
              if (value == 'leave') {
                await ref
                    .read(clubServiceProvider)
                    .leaveClub(clubId: club.id, oderId: auth.currentUser!.uid);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
      ],
      bottom: const TabBar(
        tabs: [
          Tab(text: 'Activity'),
          Tab(text: 'Leaderboard'),
          Tab(text: 'Members'),
        ],
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final String clubId;

  const _ActivityTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dynamic_feed_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Club activity feed coming soon!'),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends ConsumerWidget {
  final String clubId;

  const _LeaderboardTab({required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<ClubLeaderboardEntry>>(
      future: ref.read(clubServiceProvider).getLeaderboard(clubId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return const Center(child: Text('No leaderboard data yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(entry.rank),
                  child: Text(
                    '${entry.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(entry.userName),
                subtitle: Text(
                  '${entry.games} games • ${(entry.winRate! * 100).toStringAsFixed(0)}% win rate',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.points}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'points',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.blueGrey;
    }
  }
}

class _MembersTab extends StatelessWidget {
  final Club club;

  const _MembersTab({required this.club});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${club.memberCount} Members',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        // Placeholder - would fetch actual member details
        ...List.generate(club.memberIds.length, (index) {
          final isOwner = club.memberIds[index] == club.ownerId;
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(isOwner ? club.ownerName : 'Member ${index + 1}'),
            trailing: isOwner
                ? const Chip(
                    label: Text('Owner'),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          );
        }),
      ],
    );
  }
}

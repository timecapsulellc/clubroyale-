/// Clubs List Screen
/// 
/// Shows user's clubs and discovery
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/clubs/club_model.dart';
import 'package:clubroyale/features/clubs/club_service.dart';
import 'package:clubroyale/features/clubs/screens/club_detail_screen.dart';
import 'package:clubroyale/features/clubs/screens/create_club_screen.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class ClubsListScreen extends ConsumerWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final userId = auth.currentUser?.uid;
    
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }

    final myClubsAsync = ref.watch(userClubsProvider(userId));
    final invitesAsync = ref.watch(pendingClubInvitesProvider(userId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clubs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Clubs'),
              Tab(text: 'Discover'),
            ],
          ),
          actions: [
            // Pending invites badge
            invitesAsync.when(
              data: (invites) => invites.isNotEmpty
                  ? Badge(
                      label: Text('${invites.length}'),
                      child: IconButton(
                        icon: const Icon(Icons.mail),
                        onPressed: () => _showInvitesSheet(context, invites, ref),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.mail_outline),
                      onPressed: () {},
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // My Clubs Tab
            myClubsAsync.when(
              data: (clubs) => clubs.isEmpty
                  ? const _EmptyMyClubs()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) => _ClubCard(club: clubs[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            // Discover Tab
            const _DiscoverTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateClubScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Club'),
        ),
      ),
    );
  }

  void _showInvitesSheet(BuildContext context, List<ClubInvite> invites, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Club Invites', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...invites.map((invite) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.groups)),
              title: Text(invite.clubName),
              subtitle: Text('From ${invite.inviterName}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      final auth = ref.read(authServiceProvider);
                      await ref.read(clubServiceProvider).acceptInvite(
                        inviteId: invite.id,
                        oderId: auth.currentUser!.uid,
                        userName: auth.currentUser!.displayName ?? 'Player',
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Club club;

  const _ClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: club.id)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: club.avatarUrl != null ? NetworkImage(club.avatarUrl!) : null,
                child: club.avatarUrl == null
                    ? Text(club.name[0].toUpperCase(), style: const TextStyle(fontSize: 24))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          club.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (club.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified, color: Colors.blue, size: 18),
                          ),
                      ],
                    ),
                    Text(
                      '${club.memberCount} members',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMyClubs extends StatelessWidget {
  const _EmptyMyClubs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text('No Clubs Yet', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Join or create a club to play with friends!'),
        ],
      ),
    );
  }
}

class _DiscoverTab extends ConsumerStatefulWidget {
  const _DiscoverTab();

  @override
  ConsumerState<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<_DiscoverTab> {
  final _searchController = TextEditingController();
  List<Club> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search clubs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : null,
            ),
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(child: Text('Search for clubs to join'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) => _ClubCard(club: _searchResults[index]),
                    ),
        ),
      ],
    );
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      final results = await ref.read(clubServiceProvider).searchClubs(query);
      setState(() => _searchResults = results);
    } finally {
      setState(() => _isSearching = false);
    }
  }
}

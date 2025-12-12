/// Tournament Detail Screen
/// 
/// Shows tournament info, bracket, and participants

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';
import 'package:clubroyale/features/tournament/tournament_service.dart';
import 'package:clubroyale/features/tournament/widgets/bracket_view.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Tournament not found')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(tournament.name),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Info'),
                  Tab(text: 'Bracket'),
                  Tab(text: 'Standings'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _InfoTab(tournament: tournament),
                _BracketTab(tournament: tournament),
                _StandingsTab(tournamentId: tournamentId),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final Tournament tournament;

  const _InfoTab({required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final isHost = tournament.hostId == auth.currentUser?.uid;
    final isJoined = tournament.participantIds.contains(auth.currentUser?.uid);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text('by ${tournament.hostName}'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (tournament.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(tournament.description),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                label: 'Players',
                value: '${tournament.participantIds.length}/${tournament.maxParticipants}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                icon: Icons.style,
                label: 'Game',
                value: _getGameName(tournament.gameType),
              ),
            ),
            if (tournament.prizePool != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.diamond,
                  label: 'Prize',
                  value: '${tournament.prizePool}',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

        // Action buttons
        if (tournament.status == TournamentStatus.registration) ...[
          if (!isJoined && !isHost)
            FilledButton.icon(
              onPressed: () => _joinTournament(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Join Tournament'),
            ),
          if (isJoined && !isHost)
            OutlinedButton.icon(
              onPressed: () => _leaveTournament(context, ref),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Leave Tournament'),
            ),
          if (isHost && tournament.participantIds.length >= 2)
            FilledButton.icon(
              onPressed: () => _startTournament(context, ref),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Tournament'),
            ),
        ],
        const SizedBox(height: 24),

        // Participants list
        Text('Participants', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...tournament.participantIds.asMap().entries.map((entry) {
          return ListTile(
            leading: CircleAvatar(child: Text('${entry.key + 1}')),
            title: Text('Player ${entry.key + 1}'),
            trailing: entry.value == tournament.hostId
                ? const Chip(label: Text('Host'))
                : null,
          );
        }),
      ],
    );
  }

  Future<void> _joinTournament(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await ref.read(tournamentServiceProvider).joinTournament(
      tournamentId: tournament.id,
      oderId: user.uid,
      userName: user.displayName ?? 'Player',
    );
  }

  Future<void> _leaveTournament(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    await ref.read(tournamentServiceProvider).leaveTournament(
      tournamentId: tournament.id,
      oderId: auth.currentUser!.uid,
    );
  }

  Future<void> _startTournament(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Tournament?'),
        content: const Text('This will generate brackets and begin matches.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tournamentServiceProvider).startTournament(tournament.id);
    }
  }

  String _getGameName(String type) {
    switch (type) {
      case 'marriage': return 'Marriage';
      case 'call_break': return 'Call Break';
      case 'teen_patti': return 'Teen Patti';
      default: return type;
    }
  }
}

class _BracketTab extends StatelessWidget {
  final Tournament tournament;

  const _BracketTab({required this.tournament});

  @override
  Widget build(BuildContext context) {
    if (tournament.brackets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text('Brackets will appear when the tournament starts'),
          ],
        ),
      );
    }

    return BracketView(brackets: tournament.brackets);
  }
}

class _StandingsTab extends ConsumerWidget {
  final String tournamentId;

  const _StandingsTab({required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<TournamentStanding>>(
      future: ref.read(tournamentServiceProvider).getStandings(tournamentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final standings = snapshot.data ?? [];
        if (standings.isEmpty) {
          return const Center(child: Text('No standings yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final standing = standings[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(standing.rank),
                  child: Text(
                    '${standing.rank}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(standing.userName),
                subtitle: Text('${standing.wins}W - ${standing.losses}L'),
                trailing: Text(
                  '${standing.totalPoints} pts',
                  style: Theme.of(context).textTheme.titleMedium,
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
      case 1: return Colors.amber;
      case 2: return Colors.grey.shade400;
      case 3: return Colors.brown.shade300;
      default: return Colors.blueGrey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

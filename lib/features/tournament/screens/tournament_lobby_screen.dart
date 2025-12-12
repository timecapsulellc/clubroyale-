/// Tournament Lobby Screen
/// 
/// Displays list of tournaments and join options

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';
import 'package:clubroyale/features/tournament/tournament_service.dart';
import 'package:clubroyale/features/tournament/screens/tournament_creation_screen.dart';
import 'package:clubroyale/features/tournament/screens/tournament_detail_screen.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Main tournament lobby
class TournamentLobbyScreen extends ConsumerWidget {
  const TournamentLobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(allTournamentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: tournamentsAsync.when(
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return const _EmptyState();
          }

          // Group by status
          final open = tournaments.where((t) => t.status == TournamentStatus.registration).toList();
          final inProgress = tournaments.where((t) => t.status == TournamentStatus.inProgress).toList();
          final completed = tournaments.where((t) => t.status == TournamentStatus.completed).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (open.isNotEmpty) ...[
                _SectionHeader(title: 'Open for Registration', count: open.length),
                ...open.map((t) => _TournamentCard(tournament: t)),
                const SizedBox(height: 24),
              ],
              if (inProgress.isNotEmpty) ...[
                _SectionHeader(title: 'In Progress', count: inProgress.length),
                ...inProgress.map((t) => _TournamentCard(tournament: t)),
                const SizedBox(height: 24),
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader(title: 'Recently Completed', count: completed.length),
                ...completed.map((t) => _TournamentCard(tournament: t)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TournamentCreationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Tournaments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('Marriage'), selected: true, onSelected: (_) {}),
                FilterChip(label: const Text('Call Break'), selected: false, onSelected: (_) {}),
                FilterChip(label: const Text('Teen Patti'), selected: false, onSelected: (_) {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentCard extends ConsumerWidget {
  final Tournament tournament;

  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final isJoined = tournament.participantIds.contains(auth.currentUser?.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TournamentDetailScreen(tournamentId: tournament.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getGameColor(tournament.gameType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: _getGameColor(tournament.gameType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hosted by ${tournament.hostName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: tournament.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.people,
                    label: '${tournament.participantIds.length}/${tournament.maxParticipants}',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.style,
                    label: _getGameName(tournament.gameType),
                  ),
                  if (tournament.prizePool != null) ...[
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.diamond,
                      label: '${tournament.prizePool}',
                    ),
                  ],
                ],
              ),
              if (tournament.status == TournamentStatus.registration) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: isJoined
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check),
                          label: const Text('Joined'),
                        )
                      : FilledButton(
                          onPressed: () => _joinTournament(context, ref),
                          child: const Text('Join Tournament'),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinTournament(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    final result = await ref.read(tournamentServiceProvider).joinTournament(
      tournamentId: tournament.id,
      oderId: user.uid,
      userName: user.displayName ?? 'Player',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Joined tournament!' : 'Failed to join'),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Color _getGameColor(String type) {
    switch (type) {
      case 'marriage':
        return Colors.pink;
      case 'call_break':
        return Colors.blue;
      case 'teen_patti':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  String _getGameName(String type) {
    switch (type) {
      case 'marriage':
        return 'Marriage';
      case 'call_break':
        return 'Call Break';
      case 'teen_patti':
        return 'Teen Patti';
      default:
        return type;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TournamentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _getStatusInfo();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo() {
    switch (status) {
      case TournamentStatus.registration:
        return (Colors.green, 'OPEN');
      case TournamentStatus.inProgress:
        return (Colors.orange, 'LIVE');
      case TournamentStatus.completed:
        return (Colors.grey, 'ENDED');
      case TournamentStatus.cancelled:
        return (Colors.red, 'CANCELLED');
      case TournamentStatus.draft:
        return (Colors.blue, 'DRAFT');
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Tournaments Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to create one!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

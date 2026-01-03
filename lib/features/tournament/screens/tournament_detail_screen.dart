/// Tournament Detail Screen
///
/// Shows tournament info, bracket, and participants
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';
import 'package:clubroyale/features/tournament/tournament_service.dart';
import 'package:clubroyale/features/tournament/widgets/bracket_view.dart';
import 'package:clubroyale/features/tournament/widgets/prize_distribution_card.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/services/sound_service.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentProvider(tournamentId));

    return tournamentAsync.when(
      data: (tournament) {
        if (tournament == null) {
          return const Scaffold(
            backgroundColor: CasinoColors.deepPurple,
            body: Center(
              child: Text(
                'Tournament not found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: CasinoColors.deepPurple,
            appBar: AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.8),
              iconTheme: const IconThemeData(color: CasinoColors.gold),
              title: Text(
                tournament.name,
                style: const TextStyle(
                  color: CasinoColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: const TabBar(
                labelColor: CasinoColors.gold,
                unselectedLabelColor: Colors.white54,
                indicatorColor: CasinoColors.gold,
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
        backgroundColor: CasinoColors.deepPurple,
        body: Center(
          child: CircularProgressIndicator(color: CasinoColors.gold),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: CasinoColors.deepPurple,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CasinoColors.richPurple, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CasinoColors.gold),
            boxShadow: [
              BoxShadow(
                color: CasinoColors.gold.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CasinoColors.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 32,
                      color: CasinoColors.gold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'by ${tournament.hostName}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (tournament.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  tournament.description,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                label: 'Players',
                value:
                    '${tournament.participantIds.length}/${tournament.maxParticipants}',
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
        ).animate().fadeIn(delay: 100.ms),

        if (tournament.prizePool != null) ...[
          const SizedBox(height: 16),
          PrizeDistributionCard(
            prizePool: tournament.prizePool!,
            participantCount: tournament.maxParticipants,
          ),
        ],

        const SizedBox(height: 24),

        // Action buttons
        if (tournament.status == TournamentStatus.registration) ...[
          if (!isJoined && !isHost)
            _buildActionButton(
              context,
              label: 'Join Tournament',
              icon: Icons.add,
              color: CasinoColors.gold,
              textColor: Colors.black,
              onPressed: () => _joinTournament(context, ref),
            ),
          if (isJoined && !isHost)
            _buildActionButton(
              context,
              label: 'Leave Tournament',
              icon: Icons.exit_to_app,
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () => _leaveTournament(context, ref),
            ),
          if (isHost && tournament.participantIds.length >= 2)
            _buildActionButton(
              context,
              label: 'Start Tournament',
              icon: Icons.play_arrow,
              color: Colors.green,
              textColor: Colors.white,
              onPressed: () => _startTournament(context, ref),
            ),
        ],
        const SizedBox(height: 24),

        // Participants list
        const Text(
          'Participants',
          style: TextStyle(
            color: CasinoColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...tournament.participantIds.asMap().entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                child: Text(
                  '${entry.key + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                'Player ${entry.key + 1}',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: entry.value == tournament.hostId
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CasinoColors.richPurple,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CasinoColors.gold),
                      ),
                      child: const Text(
                        'HOST',
                        style: TextStyle(
                          color: CasinoColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
          ).animate().fadeIn(
            delay: Duration(milliseconds: 200 + (entry.key * 50)),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: color.withValues(alpha: 0.5),
      ),
    ).animate().scale();
  }

  Future<void> _joinTournament(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    SoundService.playChipSound();

    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    await ref
        .read(tournamentServiceProvider)
        .joinTournament(
          tournamentId: tournament.id,
          oderId: user.uid,
          userName: user.displayName ?? 'Player',
        );
  }

  Future<void> _leaveTournament(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final auth = ref.read(authServiceProvider);
    await ref
        .read(tournamentServiceProvider)
        .leaveTournament(
          tournamentId: tournament.id,
          oderId: auth.currentUser!.uid,
        );
  }

  Future<void> _startTournament(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CasinoColors.deepPurple,
        title: const Text(
          'Start Tournament?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will generate brackets and begin matches.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: CasinoColors.gold,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      SoundService.playRoundEnd(); // Big sound for start
      await ref.read(tournamentServiceProvider).startTournament(tournament.id);
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
              color: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            const Text(
              'Brackets will appear when the tournament starts',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // Wrap BracketView in dark theme context if needed, but for now assuming it adapts or we might need to check standard widgets inside it.
    // Ideally we'd refactor BracketView too, but for scope let's wrap it in a Container with correct background.
    return Container(
      color: CasinoColors.deepPurple,
      child: BracketView(brackets: tournament.brackets),
    );
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
          return const Center(
            child: CircularProgressIndicator(color: CasinoColors.gold),
          );
        }

        final standings = snapshot.data ?? [];
        if (standings.isEmpty) {
          return const Center(
            child: Text(
              'No standings yet',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final standing = standings[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(standing.rank),
                  foregroundColor: Colors.black,
                  child: Text(
                    '${standing.rank}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  standing.userName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${standing.wins}W - ${standing.losses}L',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Text(
                  '${standing.totalPoints} pts',
                  style: const TextStyle(
                    color: CasinoColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ).animate().slideX(delay: Duration(milliseconds: index * 100));
          },
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return CasinoColors.gold;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.blueGrey;
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: CasinoColors.gold, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

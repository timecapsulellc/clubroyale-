/// Bracket View Widget
/// 
/// Displays tournament brackets visually

import 'package:flutter/material.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';

class BracketView extends StatelessWidget {
  final List<TournamentBracket> brackets;

  const BracketView({super.key, required this.brackets});

  @override
  Widget build(BuildContext context) {
    // Group brackets by round
    final roundsMap = <int, List<TournamentBracket>>{};
    for (final bracket in brackets) {
      roundsMap.putIfAbsent(bracket.round, () => []).add(bracket);
    }

    final rounds = roundsMap.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final round in rounds) ...[
            _RoundColumn(
              roundNumber: round,
              matches: roundsMap[round]!,
              isLastRound: round == rounds.last,
            ),
            if (round != rounds.last) const SizedBox(width: 24),
          ],
        ],
      ),
    );
  }
}

class _RoundColumn extends StatelessWidget {
  final int roundNumber;
  final List<TournamentBracket> matches;
  final bool isLastRound;

  const _RoundColumn({
    required this.roundNumber,
    required this.matches,
    required this.isLastRound,
  });

  @override
  Widget build(BuildContext context) {
    final roundName = isLastRound ? 'Final' : 'Round $roundNumber';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            roundName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...matches.map((match) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _MatchCard(bracket: match),
        )),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final TournamentBracket bracket;

  const _MatchCard({required this.bracket});

  @override
  Widget build(BuildContext context) {
    final isComplete = bracket.status == BracketStatus.completed;
    final isLive = bracket.status == BracketStatus.inProgress;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive
              ? Colors.orange
              : isComplete
                  ? Colors.green
                  : Theme.of(context).colorScheme.outline,
          width: isLive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Match header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Match ${bracket.matchNumber}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isComplete)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
          ),
          // Player 1
          _PlayerRow(
            name: bracket.player1Name,
            score: bracket.player1Score,
            isWinner: bracket.winnerId == bracket.player1Id,
            isComplete: isComplete,
          ),
          const Divider(height: 1),
          // Player 2
          _PlayerRow(
            name: bracket.player2Name ?? 'BYE',
            score: bracket.player2Score,
            isWinner: bracket.winnerId == bracket.player2Id,
            isComplete: isComplete,
            isBye: bracket.isBye,
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final String name;
  final int? score;
  final bool isWinner;
  final bool isComplete;
  final bool isBye;

  const _PlayerRow({
    required this.name,
    this.score,
    required this.isWinner,
    required this.isComplete,
    this.isBye = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: isWinner && isComplete
          ? Colors.green.withValues(alpha: 0.1)
          : null,
      child: Row(
        children: [
          if (isWinner && isComplete)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.emoji_events, color: Colors.amber, size: 16),
            ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : null,
                color: isBye ? Colors.grey : null,
                fontStyle: isBye ? FontStyle.italic : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score != null && !isBye)
            Text(
              '$score',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.green : null,
              ),
            ),
        ],
      ),
    );
  }
}

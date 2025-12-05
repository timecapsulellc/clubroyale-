import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/auth/auth_service.dart';
import 'package:myapp/features/game/call_break_service.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/engine/models/card.dart';
import 'package:myapp/features/game/models/game_state.dart';
import 'package:myapp/features/lobby/lobby_service.dart';
import 'widgets/card_widgets.dart';
import 'widgets/bidding_dialog.dart';
import 'widgets/game_table_widgets.dart';

import 'package:myapp/features/game/services/bot_service.dart';

/// Main screen for Call Break gameplay
class CallBreakGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const CallBreakGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<CallBreakGameScreen> createState() => _CallBreakGameScreenState();
}

class _CallBreakGameScreenState extends ConsumerState<CallBreakGameScreen> {
  PlayingCard? _selectedCard;
  bool _isProcessing = false;
  bool _botServiceStarted = false;

  @override
  void dispose() {
    // Stop bot service if it was running
    if (_botServiceStarted) {
      ref.read(botServiceProvider).stopMonitoring();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = ref.watch(lobbyServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUserId = authService.currentUser?.uid;

    return StreamBuilder<GameRoom?>(
      stream: lobbyService.watchRoom(widget.gameId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final game = snapshot.data!;
        final playerIds = game.players.map((p) => p.id).toList();
        final playerNames = {
          for (var p in game.players) p.id: p.name,
        };
        final isHost = game.hostId == currentUserId;
        final isMyTurn = game.currentTurn == currentUserId;
        final myHand = game.playerHands[currentUserId] ?? [];

        // Start bot service if host and not started
        if (isHost && !_botServiceStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_botServiceStarted) {
              ref.read(botServiceProvider).startMonitoring(widget.gameId);
              _botServiceStarted = true;
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Round ${game.currentRound}/${game.config.totalRounds}'),
            centerTitle: true,
            actions: [
              // Show host indicator
              if (isHost)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.star, color: Colors.amber),
                ),
              // Show scores
              IconButton(
                icon: const Icon(Icons.leaderboard),
                onPressed: () => _showScoreboard(context, game, playerNames),
                tooltip: 'Scoreboard',
              ),
            ],
          ),
          body: _buildGameBody(game, playerIds, playerNames, currentUserId!, myHand, isMyTurn),
          bottomNavigationBar: _buildBottomBar(game, currentUserId, isMyTurn, myHand),
        );
      },
    );
  }

  Widget _buildGameBody(
    GameRoom game,
    List<String> playerIds,
    Map<String, String> playerNames,
    String currentUserId,
    List<PlayingCard> myHand,
    bool isMyTurn,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Other players' status (top row)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: playerIds
                .where((id) => id != currentUserId)
                .map((playerId) => PlayerBidStatus(
                      playerName: playerNames[playerId] ?? 'Player',
                      bid: game.bids[playerId]?.amount,
                      tricksWon: game.tricksWon[playerId] ?? 0,
                      isCurrentTurn: game.currentTurn == playerId,
                    ))
                .toList(),
          ),
        ),

        // Game area
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Phase indicator
                if (game.gamePhase != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getPhaseColor(game.gamePhase!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getPhaseText(game.gamePhase!),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Trick area
                TrickAreaWidget(
                  currentTrick: game.currentTrick,
                  playerNames: playerNames,
                ),

                const SizedBox(height: 16),

                // Turn indicator
                if (game.gamePhase == GamePhase.playing) ...[
                  Text(
                    isMyTurn ? 'Your turn!' : '${playerNames[game.currentTurn]}\'s turn',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isMyTurn ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (game.currentTrick?.ledSuit != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Must follow: ${game.currentTrick!.ledSuit.symbol}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: game.currentTrick!.ledSuit.isRed
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),

        // My status
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PlayerBidStatus(
            playerName: 'You',
            bid: game.bids[currentUserId]?.amount,
            tricksWon: game.tricksWon[currentUserId] ?? 0,
            isCurrentTurn: isMyTurn,
          ),
        ),

        // My hand
        const SizedBox(height: 8),
        PlayerHandWidget(
          cards: myHand,
          selectedCard: _selectedCard,
          requiredSuit: game.currentTrick?.ledSuit,
          isMyTurn: isMyTurn && game.gamePhase == GamePhase.playing,
          onCardSelected: (card) {
            setState(() => _selectedCard = card);
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomBar(
    GameRoom game,
    String currentUserId,
    bool isMyTurn,
    List<PlayingCard> myHand,
  ) {
    final callBreakService = ref.read(callBreakServiceProvider);

    // Bidding phase - show bid button
    if (game.gamePhase == GamePhase.bidding && isMyTurn) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _isProcessing ? null : () => _showBidDialog(game, currentUserId),
            icon: const Icon(Icons.gavel),
            label: const Text('Place Your Bid'),
          ),
        ),
      );
    }

    // Playing phase - show play card button
    if (game.gamePhase == GamePhase.playing && isMyTurn && _selectedCard != null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _playCard(game.id!, _selectedCard!, callBreakService),
            icon: const Icon(Icons.play_arrow),
            label: Text('Play ${_selectedCard!.displayString}'),
          ),
        ),
      );
    }

    // Round end - show start next round
    if (game.gamePhase == GamePhase.roundEnd && game.hostId == currentUserId) {
      final playerIds = game.players.map((p) => p.id).toList();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _startNextRound(game.id!, playerIds, callBreakService),
            icon: const Icon(Icons.refresh),
            label: const Text('Start Next Round'),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showBidDialog(GameRoom game, String currentUserId) async {
    final bid = await showBiddingDialog(
      context: context,
      playerName: 'You',
    );

    if (bid != null && mounted) {
      setState(() => _isProcessing = true);
      try {
        final callBreakService = ref.read(callBreakServiceProvider);
        await callBreakService.placeBid(game.id!, currentUserId, bid);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to place bid: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _playCard(String gameId, PlayingCard card, CallBreakService service) async {
    setState(() => _isProcessing = true);
    try {
      final currentUserId = ref.read(authServiceProvider).currentUser!.uid;
      await service.playCard(gameId, currentUserId, card);
      setState(() => _selectedCard = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _startNextRound(String gameId, List<String> playerIds, CallBreakService service) async {
    setState(() => _isProcessing = true);
    try {
      await service.startNewRound(gameId, playerIds);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start round: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showScoreboard(BuildContext context, GameRoom game, Map<String, String> playerNames) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Scoreboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildScoreTable(game, playerNames),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreTable(GameRoom game, Map<String, String> playerNames) {
    final theme = Theme.of(context);

    // Sort by total score
    final sortedPlayers = playerNames.entries.toList()
      ..sort((a, b) =>
          (game.scores[b.key] ?? 0).compareTo(game.scores[a.key] ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(flex: 2, child: Text('Player', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            // Players
            ...sortedPlayers.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final score = game.scores[player.key] ?? 0;
              final isLeader = index == 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (isLeader)
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(player.value),
                    ),
                    Expanded(
                      child: Text(
                        '$score',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: score >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getPhaseColor(GamePhase phase) {
    switch (phase) {
      case GamePhase.bidding:
        return Colors.orange;
      case GamePhase.playing:
        return Colors.green;
      case GamePhase.roundEnd:
        return Colors.blue;
      case GamePhase.gameFinished:
        return Colors.purple;
    }
  }

  String _getPhaseText(GamePhase phase) {
    switch (phase) {
      case GamePhase.bidding:
        return '📝 BIDDING PHASE';
      case GamePhase.playing:
        return '🃏 PLAYING';
      case GamePhase.roundEnd:
        return '🏁 ROUND COMPLETE';
      case GamePhase.gameFinished:
        return '🎉 GAME OVER';
    }
  }
}

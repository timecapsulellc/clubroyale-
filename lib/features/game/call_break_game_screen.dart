import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/utils/haptic_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/game/call_break_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'widgets/card_widgets.dart';
import 'widgets/bidding_dialog.dart';
import 'widgets/game_table_widgets.dart';
import 'widgets/player_avatar.dart';

import 'package:clubroyale/features/game/services/bot_service.dart';

// RTC, Chat, and AI imports
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/features/ai/ai_tip_widget.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';

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
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;

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
            body: ContextualLoader(
              message: 'Loading game...',
              icon: Icons.style,
            ),
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
          backgroundColor: CasinoColors.darkPurple,
          appBar: AppBar(
            backgroundColor: CasinoColors.deepPurple,
            elevation: 0,
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CasinoColors.gold.withValues(alpha: 0.8), CasinoColors.bronzeGold],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Round ${game.currentRound}/${game.config.totalRounds}',
                style: const TextStyle(
                  color: Color(0xFF1a0a2e),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              // Show host indicator
              if (isHost)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CasinoColors.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: CasinoColors.gold, size: 20),
                ).animate().shimmer(duration: 2.seconds, color: CasinoColors.gold.withValues(alpha: 0.3)),
              // Show scores
              IconButton(
                icon: const Icon(Icons.leaderboard, color: Colors.white),
                onPressed: () => _showScoreboard(context, game, playerNames),
                tooltip: 'Scoreboard',
              ),
              // Video Toggle
              IconButton(
                icon: Icon(_showVideoGrid ? Icons.videocam_off : Icons.videocam),
                onPressed: () => setState(() => _showVideoGrid = !_showVideoGrid),
                tooltip: _showVideoGrid ? 'Hide Video' : 'Show Video',
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main game content
              ParticleBackground(
                primaryColor: CasinoColors.gold,
                secondaryColor: CasinoColors.richPurple,
                particleCount: 25,
                child: _buildGameBody(game, playerIds, playerNames, currentUserId!, myHand, isMyTurn),
              ),
              
              // Floating Audio Controls (top-left)
              Positioned(
                top: 8,
                left: 8,
                child: AudioFloatingButton(
                  roomId: widget.gameId,
                  userId: currentUserId,
                ),
              ),
              
              // Floating Chat Overlay (bottom-right)
              Positioned(
                bottom: 80,
                right: 8,
                child: ChatOverlay(
                  roomId: widget.gameId,
                  userId: currentUserId,
                  userName: playerNames[currentUserId] ?? 'Player',
                  isExpanded: _isChatExpanded,
                  onToggle: () => setState(() => _isChatExpanded = !_isChatExpanded),
                ),
              ),
              
              // Video Grid Overlay
              if (_showVideoGrid)
                Positioned(
                  top: 60,
                  right: 16,
                  width: 200,
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: VideoGridWidget(
                      roomId: widget.gameId,
                      userId: currentUserId,
                      userName: playerNames[currentUserId] ?? 'Player',
                    ),
                  ),
                ),
              
              // AI Tip Widget (shown when it's user's turn during playing phase)
              if (isMyTurn && game.gamePhase == GamePhase.playing && myHand.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AiTipWidget(
                    hand: myHand.map((c) => c.displayString).toList(),
                    trickCards: game.currentTrick?.cards.map((c) => c.card.displayString).toList() ?? [],
                    tricksNeeded: (game.bids[currentUserId]?.amount ?? 0) - (game.tricksWon[currentUserId] ?? 0),
                    tricksWon: game.tricksWon[currentUserId] ?? 0,
                    bid: game.bids[currentUserId]?.amount ?? 0,
                    ledSuit: game.currentTrick?.ledSuit.name,
                  ),
                ),
            ],
          ),
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
    
    // Get other players (exclude current user)
    final otherPlayers = playerIds.where((id) => id != currentUserId).toList();

    return Column(
      children: [
        // Game table area with positioned players
        Expanded(
          child: Stack(
            children: [
              // Center content - phase indicator and trick area
              Center(
                child: SingleChildScrollView(
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
                                boxShadow: [
                                  BoxShadow(
                                    color: _getPhaseColor(game.gamePhase!).withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                _getPhaseText(game.gamePhase!),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ).animate().fadeIn().scale(),
                  
                          const SizedBox(height: 16),
                  
                          // Trick area
                          TrickAreaWidget(
                            currentTrick: game.currentTrick,
                            playerNames: playerNames,
                          ),
                  
                          const SizedBox(height: 12),
                  
                          // Turn indicator
                          if (game.gamePhase == GamePhase.playing)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMyTurn ? CasinoColors.gold.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isMyTurn ? CasinoColors.gold : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                isMyTurn ? '🎯 Your turn!' : '${playerNames[game.currentTurn]}\'s turn',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isMyTurn ? CasinoColors.gold : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                          if (game.currentTrick?.ledSuit != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Must follow: ${game.currentTrick!.ledSuit.symbol}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: game.currentTrick!.ledSuit.isRed ? Colors.red.shade300 : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              
              // Top player (opponent across table)
              if (otherPlayers.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: PlayerAvatar(
                      name: playerNames[otherPlayers[0]] ?? 'Player',
                      isCurrentTurn: game.currentTurn == otherPlayers[0],
                      isHost: game.hostId == otherPlayers[0],
                      bid: game.bids[otherPlayers[0]]?.amount,
                      tricksWon: game.tricksWon[otherPlayers[0]] ?? 0,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3),
                  ),
                ),
              
              // Left player (if 3+ players)
              if (otherPlayers.length >= 2)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 100,
                  child: Center(
                    child: PlayerAvatar(
                      name: playerNames[otherPlayers[1]] ?? 'Player',
                      isCurrentTurn: game.currentTurn == otherPlayers[1],
                      isHost: game.hostId == otherPlayers[1],
                      bid: game.bids[otherPlayers[1]]?.amount,
                      tricksWon: game.tricksWon[otherPlayers[1]] ?? 0,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                  ),
                ),
              
              // Right player (if 4 players)
              if (otherPlayers.length >= 3)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 100,
                  child: Center(
                    child: PlayerAvatar(
                      name: playerNames[otherPlayers[2]] ?? 'Player',
                      isCurrentTurn: game.currentTurn == otherPlayers[2],
                      isHost: game.hostId == otherPlayers[2],
                      bid: game.bids[otherPlayers[2]]?.amount,
                      tricksWon: game.tricksWon[otherPlayers[2]] ?? 0,
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3),
                  ),
                ),
            ],
          ),
        ),

        // Current player info bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            border: Border(
              top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMyTurn ? CasinoColors.gold : CasinoColors.feltGreenMid,
                      border: Border.all(color: CasinoColors.gold, width: 2),
                    ),
                    child: Text(
                      'You'[0],
                      style: TextStyle(
                        color: isMyTurn ? CasinoColors.feltGreenDark : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bid: ${game.bids[currentUserId]?.amount ?? "-"}  |  Tricks: ${game.tricksWon[currentUserId] ?? 0}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (game.hostId == currentUserId)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CasinoColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CasinoColors.gold),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: CasinoColors.gold, size: 14),
                      SizedBox(width: 4),
                      Text('Host', style: TextStyle(color: CasinoColors.gold, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // My hand
        PlayerHandWidget(
          cards: myHand,
          selectedCard: _selectedCard,
          requiredSuit: game.currentTrick?.ledSuit,
          isMyTurn: isMyTurn && game.gamePhase == GamePhase.playing,
          onCardSelected: (card) {
            setState(() => _selectedCard = card);
          },
        ),

        const SizedBox(height: 8),
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
        HapticHelper.lightTap();
        final callBreakService = ref.read(callBreakServiceProvider);
        await callBreakService.placeBid(game.id!, currentUserId, bid);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e))),
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
      HapticHelper.cardMove();
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
      HapticHelper.mediumTap();
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

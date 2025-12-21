import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/game/services/test_game_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/widgets/card_widgets.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Test Game Screen - plays using in-memory TestGameService
class TestGameScreen extends ConsumerStatefulWidget {
  const TestGameScreen({super.key});

  @override
  ConsumerState<TestGameScreen> createState() => _TestGameScreenState();
}

class _TestGameScreenState extends ConsumerState<TestGameScreen> {
  @override
  Widget build(BuildContext context) {
    final testGameService = ref.read(testGameServiceProvider);
    
    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      appBar: AppBar(
        backgroundColor: CasinoColors.deepPurple,
        title: const Text('🧪 Test Game', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            testGameService.reset();
            context.go('/');
          },
        ),
      ),
      body: StreamBuilder<GameRoom?>(
        stream: testGameService.watchGame(),
        initialData: testGameService.currentGame,
        builder: (context, snapshot) {
          final game = snapshot.data;
          
          if (game == null) {
            return const Center(
              child: Text('No test game active', style: TextStyle(color: Colors.white)),
            );
          }
          
          return _buildGameBody(game, testGameService);
        },
      ),
    );
  }
  
  Widget _buildGameBody(GameRoom game, TestGameService service) {
    final humanPlayer = game.players.first; // First player is always human
    final myHand = game.playerHands[humanPlayer.id] ?? [];
    final isMyTurn = game.currentTurn == humanPlayer.id;
    final phase = game.gamePhase ?? GamePhase.bidding;
    
    return Column(
      children: [
        // Game info bar
        _buildGameInfoBar(game, phase),
        
        // Current trick
        Expanded(
          child: _buildTrickArea(game, humanPlayer.id, phase),
        ),
        
        // Player's hand
        _buildHandSection(game, service, myHand, isMyTurn, humanPlayer.id, phase),
      ],
    );
  }
  
  Widget _buildGameInfoBar(GameRoom game, GamePhase phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: CasinoColors.cardBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoBadge(
            icon: Icons.flag_rounded,
            label: 'Round',
            value: '${game.currentRound}/${game.config.totalRounds}',
          ),
          _InfoBadge(
            icon: Icons.sports_esports,
            label: 'Phase',
            value: _getPhaseText(phase),
            color: _getPhaseColor(phase),
          ),
          _InfoBadge(
            icon: Icons.person,
            label: 'Turn',
            value: _getPlayerName(game, game.currentTurn),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrickArea(GameRoom game, String myId, GamePhase phase) {
    final currentTrick = game.currentTrick;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Scoreboard
          _buildScoreboard(game, myId),
          
          const SizedBox(height: 24),
          
          // Trick display
          if (currentTrick != null && currentTrick.cards.isNotEmpty)
            _buildCurrentTrick(game, currentTrick)
          else if (phase == GamePhase.bidding)
            _buildBiddingInfo(game, myId)
          else
            const Text('Lead a card!', style: TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
  
  Widget _buildScoreboard(GameRoom game, String myId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CasinoDecorations.glassCard(),
      child: Column(
        children: [
          const Text('Scoreboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: game.players.map((p) {
              final isMe = p.id == myId;
              final score = game.scores[p.id] ?? 0;
              final bid = game.bids[p.id]?.amount ?? '-';
              final tricks = game.tricksWon[p.id] ?? 0;
              
              return Column(
                children: [
                  Text(
                    isMe ? 'You' : p.name.split(' ').last,
                    style: TextStyle(
                      color: isMe ? CasinoColors.gold : Colors.white,
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text('$score pts', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  Text('Bid: $bid  Won: $tricks', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentTrick(GameRoom game, Trick trick) {
    return Column(
      children: [
        const Text('Current Trick', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: trick.cards.map((pc) {
            final playerName = _getPlayerName(game, pc.playerId);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(playerName, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                PlayingCardWidget(
                  card: pc.card,
                  isPlayable: false,
                  width: 60,
                  height: 84,
                  onTap: () {},
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildBiddingInfo(GameRoom game, String myId) {
    final myBid = game.bids[myId];
    
    if (myBid != null) {
      return Column(
        children: [
          const Text('Your bid', style: TextStyle(color: Colors.white70)),
          Text('${myBid.amount}', style: const TextStyle(color: CasinoColors.gold, fontSize: 36, fontWeight: FontWeight.bold)),
          const Text('Waiting for other players...', style: TextStyle(color: Colors.white54)),
        ],
      );
    }
    
    return Column(
      children: [
        const Text('Place your bid (1-13)', style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(13, (i) {
            final bid = i + 1;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                minimumSize: const Size(48, 48),
              ),
              onPressed: () async {
                final service = ref.read(testGameServiceProvider);
                await service.placeBid(myId, bid);
              },
              child: Text('$bid'),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildHandSection(GameRoom game, TestGameService service, List<PlayingCard> hand, bool isMyTurn, String myId, GamePhase phase) {
    if (phase == GamePhase.gameFinished) {
      return Container(
        padding: const EdgeInsets.all(24),
        color: CasinoColors.cardBackground,
        child: Column(
          children: [
            const Text('🎉 Game Complete!', style: TextStyle(color: CasinoColors.gold, fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: CasinoColors.gold),
              onPressed: () {
                service.reset();
                context.go('/');
              },
              child: const Text('Back to Home', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: CasinoColors.cardBackground,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMyTurn ? 'Your turn!' : 'Waiting...',
                style: TextStyle(
                  color: isMyTurn ? CasinoColors.gold : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${hand.length} cards', style: const TextStyle(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hand.length,
              itemBuilder: (context, index) {
                final card = hand[index];
                final canPlay = isMyTurn && phase == GamePhase.playing;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: PlayingCardWidget(
                    card: card,
                    isPlayable: canPlay,
                    width: 70,
                    height: 98,
                    onTap: canPlay 
                      ? () => service.playCard(myId, card) 
                      : () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPlayerName(GameRoom game, String? playerId) {
    if (playerId == null) return '?';
    final player = game.players.firstWhere(
      (p) => p.id == playerId,
      orElse: () => Player(id: playerId, name: 'Unknown'),
    );
    return player.name.length > 10 ? '${player.name.substring(0, 10)}...' : player.name;
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
        return CasinoColors.gold;
    }
  }
  
  String _getPhaseText(GamePhase phase) {
    switch (phase) {
      case GamePhase.bidding:
        return 'Bidding';
      case GamePhase.playing:
        return 'Playing';
      case GamePhase.roundEnd:
        return 'Round End';
      case GamePhase.gameFinished:
        return 'Finished';
    }
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.color = Colors.white,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

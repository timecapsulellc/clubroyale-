
import 'package:flutter/material.dart' hide Card;
import 'package:clubroyale/core/design_system/game/felt_texture_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/games/call_break/call_break_service.dart';
import 'package:clubroyale/games/call_break/call_break_bot_controller.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:clubroyale/core/widgets/game_mode_banner.dart';
import 'package:clubroyale/core/widgets/game_opponent_widget.dart';
import 'package:clubroyale/core/widgets/turn_timer.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

class CallBreakMultiplayerScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const CallBreakMultiplayerScreen({
    required this.roomId,
    super.key,
  });

  @override
  ConsumerState<CallBreakMultiplayerScreen> createState() => _CallBreakMultiplayerScreenState();
}

class _CallBreakMultiplayerScreenState extends ConsumerState<CallBreakMultiplayerScreen> {
  bool _isProcessing = false;
  int _selectedBid = 1;
  final Map<String, Card> _cardCache = {};
  
  // Bot Controllers
  final List<CallBreakBotController> _botControllers = [];
  bool _botsInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _buildCardCache();
  }
  
  @override
  void dispose() {
    for (var controller in _botControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _initBots(CallBreakGameState state, CallBreakService service) {
    if (_botsInitialized) return;
    
    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) return;
    
    // Only the host (or first human player) should manage bots to avoid race conditions
    // Simple heuristic: If I am the first human in playerIds, I manage bots.
    // Or just all clients manage bots? No, that causes duplicate moves.
    // Let's assume the user who created the room (usually player_0) manages bots.
    // Or simply: If I am 'player_0' (host), I run the bots.
    
    // Better: Check if I am the "owner" or first player.
    // Since this is a test/demo environment often:
    // We will spawn controllers for ANY player ID starting with 'bot_'
    // IF we are the host.
    
    // Determining host: usually index 0.
    bool amIHost = state.playerIds.isNotEmpty && state.playerIds[0] == currentUser.uid;
    
    // For simpler testing: If we are in a solo-multiplayer hybrid (user + 3 bots), 
    // the user IS the host.
    
    if (amIHost) {
      for (final pid in state.playerIds) {
        if (pid.startsWith('bot_')) {
          _botControllers.add(CallBreakBotController(
            service: service,
            roomId: widget.roomId,
            botId: pid,
            botName: 'Bot ${pid.split('_').last}',
          ));
        }
      }
      _botsInitialized = true;
      debugPrint('Initialized ${_botControllers.length} bot controllers');
    }
  }
  
  void _buildCardCache() {
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        final card = Card(suit: suit, rank: rank);
        _cardCache[card.id] = card;
      }
    }
  }
  
  Card? _getCard(String id) => _cardCache[id];

  @override
  Widget build(BuildContext context) {
    final callBreakService = ref.watch(callBreakServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }
    
    return StreamBuilder<CallBreakGameState?>(
      stream: callBreakService.watchGameState(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            body: const ContextualLoader(
              message: 'Connecting to table...',
              icon: Icons.style,
            ),
          );
        }
        
        final state = snapshot.data;
        if (state == null) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            appBar: AppBar(backgroundColor: Colors.black54),
            body: const Center(child: Text('Game state not found')),
          );
        }
        
        // Initialize bots if needed
        if (!_botsInitialized) {
           _initBots(state, callBreakService);
        }
        
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final myHandIds = state.hands[currentUser.uid] ?? [];
        final myHand = myHandIds.map((id) => _getCard(id)).whereType<Card>().toList();
        
        // Sort hand: Spade, then others
        myHand.sort((a, b) {
          if (a.suit == Suit.spades && b.suit != Suit.spades) return -1;
          if (a.suit != Suit.spades && b.suit == Suit.spades) return 1;
          if (a.suit == b.suit) return b.rank.value.compareTo(a.rank.value);
          return a.suit.index.compareTo(b.suit.index);
        });

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Call Break - Round ${state.currentRound}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/lobby'),
            ),
          ),
          body: FeltBackground(
             primaryColor: CasinoColors.feltGreenDark,
             secondaryColor: const Color(0xFF0a2814),
             showTexture: true,
             showAmbientLight: true,
             child: SafeArea(
               child: Column(
                 children: [
                   // Game Mode Banner
                   _buildGameModeBanner(state),
                   
                   // Scoreboard (Opponents)
                   _buildScoreBoard(state, currentUser.uid),
                   
                   // Game Area (Center)
                   Expanded(
                     child: _buildGameArea(state, currentUser.uid, isMyTurn),
                   ),
                   
                   // My Hand
                   _buildMyHand(myHand, isMyTurn, state, currentUser.uid),
                 ],
               ),
             ),
          ),
        );
      },
    );
  }
  
  Widget _buildGameModeBanner(CallBreakGameState state) {
    final botCount = state.playerIds.where((id) => id.startsWith('bot_')).length;
    final humanCount = state.playerIds.length - botCount;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GameModeBanner(
        botCount: botCount,
        humanCount: humanCount,
        compact: true,
      ),
    );
  }
  
  Widget _buildScoreBoard(CallBreakGameState state, String myId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OpponentRow(
        avatarSize: 40,
        opponents: state.playerIds.map((pid) {
          final isMe = pid == myId;
          final isCurrent = pid == state.currentPlayerId;
          final score = state.scores[pid] ?? 0;
          final bid = state.bids[pid];
          final won = state.tricksWon[pid] ?? 0;
          final isBot = pid.startsWith('bot_'); // Simple heuristic
          
          return GameOpponent(
            id: pid,
            name: isMe ? 'You' : (isBot ? 'Bot ${pid.split('_').last}' : 'Player'),
            isBot: isBot,
            isCurrentTurn: isCurrent,
            score: score,
            bid: bid,
            tricksWon: won,
            status: isCurrent ? 'Thinking...' : null,
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildGameArea(CallBreakGameState state, String myId, bool isMyTurn) {
    if (state.phase == 'bidding') {
      return _buildBiddingUI(state, myId);
    } else if (state.phase == 'scoring' || state.phase == 'finished') {
      return _buildRoundResults(state, myId);
    } else {
      return _buildTableCenter(state);
    }
  }
  
  Widget _buildBiddingUI(CallBreakGameState state, String myId) {
    final isMyTurn = state.currentPlayerId == myId;
    final myBid = state.bids[myId];
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Place Your Bid',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Turn timer for urgency
            if (isMyTurn)
              const TurnTimer(totalSeconds: 30, remainingSeconds: 30, size: 45),
            const SizedBox(height: 12),
            if (myBid != null)
              Text('You bid: $myBid', style: const TextStyle(color: CasinoColors.gold, fontSize: 20))
            else if (isMyTurn) ...[
               Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.white),
                    onPressed: _selectedBid > 1 ? () => setState(() => _selectedBid--) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: CasinoColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_selectedBid',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _selectedBid < 13 ? () => setState(() => _selectedBid++) : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isProcessing ? null : () => _submitBid(state.roomId, myId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CasinoColors.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Confirm Bid', style: TextStyle(color: Colors.black)),
              ),
            ] else
              const Text('Waiting for others to bid...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTableCenter(CallBreakGameState state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.ledSuit != null)
             Container(
               padding: const EdgeInsets.all(8),
               margin: const EdgeInsets.only(bottom: 8),
               decoration: BoxDecoration(
                 color: Colors.black45,
                 borderRadius: BorderRadius.circular(20),
               ),
               child: Text(
                 'Suit Led: ${state.ledSuit}', 
                 style: const TextStyle(color: Colors.white70),
               ),
             ),
             
          // Turn timer when it's my turn
          if (state.currentPlayerId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TurnTimer(
                totalSeconds: 30, 
                remainingSeconds: 30,
                size: 50,
              ),
            ),
             
          // Current Trick Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.currentTrickCards.map((entry) {
              final parts = entry.split(':');
              final playerId = parts[0];
              final cardId = parts[1];
              final card = _getCard(cardId);
              if (card == null) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CardWidget(card: card, isFaceUp: true, width: 60, height: 90),
                    const SizedBox(height: 4),
                    Text(
                      playerId.startsWith('bot_') ? 'Bot' : 'Player',
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          
          if (state.currentTrickCards.isEmpty)
             const Text('Waiting for lead...', style: TextStyle(color: Colors.white30)),
        ],
      ),
    );
  }
  
  Widget _buildRoundResults(CallBreakGameState state, String myId) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Round Finished!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _startNextRound(state.roomId),
            child: const Text('Next Round'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMyHand(List<Card> hand, bool isMyTurn, CallBreakGameState state, String myId) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.black.withValues(alpha: 0.5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hand.length,
        itemBuilder: (context, index) {
          final card = hand[index];
          // Check if playable
          bool canPlay = isMyTurn && state.phase == 'playing';
          if (canPlay) {
             // Validate follow suit
             if (state.currentTrickCards.isNotEmpty && state.ledSuit != null) {
               final hasSuit = hand.any((c) => c.suit.name == state.ledSuit);
               if (hasSuit && card.suit.name != state.ledSuit) canPlay = false;
             }
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: canPlay ? () => _playCard(state.roomId, myId, card.id) : null,
              child: Opacity(
                opacity: canPlay ? 1.0 : 0.6,
                child: CardWidget(
                  card: card, 
                  isFaceUp: true,
                  isSelected: false,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Actions
  Future<void> _submitBid(String roomId, String playerId) async {
    setState(() => _isProcessing = true);
    try {
      final service = ref.read(callBreakServiceProvider);
      await service.submitBid(roomId, playerId, _selectedBid);
      SoundService.playChipSound();
    } catch (e) {
      debugPrint('Error placing bid: $e');
    } finally {
      if(mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _playCard(String roomId, String playerId, String cardId) async {
    setState(() => _isProcessing = true);
    try {
      final service = ref.read(callBreakServiceProvider);
      await service.playCard(roomId, playerId, cardId);
      SoundService.playCardSlide();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid move! Follow suit.')));
      }
    } finally {
      if(mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _startNextRound(String roomId) async {
    // Only host or logic calls this, but for now allow anyone
    final service = ref.read(callBreakServiceProvider);
    await service.startNextRound(roomId);
  }
}

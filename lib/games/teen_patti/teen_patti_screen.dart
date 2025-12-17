/// Teen Patti Game Screen
/// 
/// Real-time multiplayer Teen Patti game UI
library;

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';

class TeenPattiScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const TeenPattiScreen({
    required this.roomId,
    super.key,
  });

  @override
  ConsumerState<TeenPattiScreen> createState() => _TeenPattiScreenState();
}

class _TeenPattiScreenState extends ConsumerState<TeenPattiScreen> {
  bool _isProcessing = false;
  bool _hasSeenCards = false;
  int _betAmount = 1;
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  
  // Card lookup cache
  // Card lookup cache
  final Map<String, Card> _cardCache = {};
  
  // Audio players removed - using global SoundService
  
  @override
  void initState() {
    super.initState();
    _buildCardCache();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  void _buildCardCache() {
    final deck = Deck.standard();
    for (final card in deck.cards) {
      _cardCache[card.id] = card;
    }
  }
  
  Card? _getCard(String id) => _cardCache[id];
  
  @override
  Widget build(BuildContext context) {
    final teenPattiService = ref.watch(teenPattiServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }
    
    return StreamBuilder<TeenPattiGameState?>(
      stream: teenPattiService.watchGameState(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            body: const Center(
              child: CircularProgressIndicator(color: CasinoColors.gold),
            ),
          );
        }
        
        final state = snapshot.data;
        if (state == null) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            appBar: AppBar(
              backgroundColor: Colors.black54,
              title: const Text('Teen Patti'),
            ),
            body: const Center(
              child: Text('Waiting for game...', style: TextStyle(color: Colors.white70)),
            ),
          );
        }
        
        // Check if game finished
        if (state.phase == 'finished') {
          return _buildGameOverScreen(state, currentUser.uid);
        }
        
        final myHand = state.playerHands[currentUser.uid] ?? [];
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final myStatus = state.playerStatus[currentUser.uid] ?? 'blind';
        
        return Scaffold(
          backgroundColor: CasinoColors.feltGreenDark,
          appBar: AppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/lobby'),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Teen Patti', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                _buildPotBadge(state.pot),
              ],
            ),
            actions: [
              _buildStakeBadge(state.currentStake),
              IconButton( // Toggle Video
                icon: Icon(_showVideoGrid ? Icons.videocam_off : Icons.videocam),
                onPressed: () => setState(() => _showVideoGrid = !_showVideoGrid),
              ),
              AudioFloatingButton(roomId: widget.roomId, userId: currentUser.uid),
            ],
          ),
          body: ParticleBackground(
            primaryColor: CasinoColors.gold,
            secondaryColor: CasinoColors.richPurple,
            particleCount: 15,
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTurnIndicator(isMyTurn, myStatus),
                    Expanded(flex: 2, child: _buildOpponentsArea(state, currentUser.uid)),
                    _buildPotArea(state.pot),
                    Expanded(flex: 3, child: _buildMyCards(myHand, myStatus)),
                    _buildActionBar(isMyTurn, myStatus, state),
                  ],
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
                        roomId: widget.roomId,
                        userId: currentUser.uid,
                        userName: currentUser.displayName ?? 'Player',
                      ),
                    ),
                  ),
                // Chat Overlay
                Positioned(
                  bottom: 140, // Above hand
                  left: 16,
                  child: ChatOverlay(
                    roomId: widget.roomId,
                    userId: currentUser.uid,
                    userName: currentUser.displayName ?? 'Player',
                    isExpanded: _isChatExpanded,
                    onToggle: () => setState(() => _isChatExpanded = !_isChatExpanded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPotBadge(int pot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: CasinoColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CasinoColors.gold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/chips/chip_red.png', width: 16, height: 16),
          const SizedBox(width: 4),
          Text(
            'Pot: $pot',
            style: const TextStyle(color: CasinoColors.gold, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStakeBadge(int stake) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Stake: $stake',
        style: const TextStyle(color: Colors.amber, fontSize: 12),
      ),
    );
  }
  
  Widget _buildTurnIndicator(bool isMyTurn, String myStatus) {
    final statusText = myStatus == 'blind' ? '🙈 Blind' : '👀 Seen';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isMyTurn ? Colors.green.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(
          color: isMyTurn ? Colors.green : Colors.white24,
        )),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isMyTurn ? '🎯 Your Turn' : '⏳ Waiting...',
            style: TextStyle(
              color: isMyTurn ? Colors.green : Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            statusText,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOpponentsArea(TeenPattiGameState state, String myId) {
    final opponents = state.playerHands.keys.where((id) => id != myId).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: opponents.map((playerId) {
          final status = state.playerStatus[playerId] ?? 'blind';
          final bet = state.playerBets[playerId] ?? 0;
          final isCurrentTurn = state.currentPlayerId == playerId;
          final isFolded = status == 'folded';
          
          return Opacity(
            opacity: isFolded ? 0.4 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCurrentTurn ? Colors.green : CasinoColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrentTurn ? Colors.green : CasinoColors.gold.withValues(alpha: 0.5),
                      width: isCurrentTurn ? 3 : 1,
                    ),
                  ),
                  child: Icon(
                    isFolded ? Icons.block : Icons.person,
                    color: isFolded ? Colors.grey : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusEmoji(status),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bet: $bet',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'blind': return Colors.blue;
      case 'seen': return Colors.orange;
      case 'folded': return Colors.grey;
      default: return Colors.white;
    }
  }
  
  String _getStatusEmoji(String status) {
    switch (status) {
      case 'blind': return '🙈';
      case 'seen': return '👀';
      case 'folded': return '🏳️';
      default: return '❓';
    }
  }
  
  Widget _buildPotArea(int pot) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '💰 POT',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/images/chips/chip_stack.png', width: 80),
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CasinoColors.gold),
                ),
                child: Text(
                  '$pot',
                  style: const TextStyle(
                    color: CasinoColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  // Helper method removed - using SoundService directly
  
  Widget _buildMyCards(List<String> cardIds, String myStatus) {
    final showCards = myStatus == 'seen' || _hasSeenCards;
    
    return GestureDetector(
      onTap: myStatus == 'blind' && !_hasSeenCards ? () {
        setState(() => _hasSeenCards = true);
        _seeCards();
      } : null,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cardIds.asMap().entries.map((entry) {
            final index = entry.key;
            final cardId = entry.value;
            final card = _getCard(cardId);
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: showCards
                  ? _buildCardFace(card!)
                  : _buildCardBack(index),
            ).animate(delay: Duration(milliseconds: 100 * index))
             .fadeIn()
             .scale();
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildCardFace(Card card) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: CasinoColors.gold.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.rank.symbol,
            style: TextStyle(
              color: card.suit.isRed ? Colors.red : Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            card.suit.symbol,
            style: TextStyle(
              color: card.suit.isRed ? Colors.red : Colors.black,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardBack(int index) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CasinoColors.richPurple, CasinoColors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Icon(
          Icons.question_mark,
          color: CasinoColors.gold.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildActionBar(bool isMyTurn, String myStatus, TeenPattiGameState state) {
    final isSeen = myStatus == 'seen';
    final minBet = isSeen ? state.currentStake * 2 : state.currentStake;
    final maxBet = isSeen ? state.currentStake * 4 : state.currentStake * 2;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        border: Border(top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bet amount slider
          if (isMyTurn && !_isProcessing)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text('Bet: $_betAmount', style: const TextStyle(color: Colors.white)),
                  Expanded(
                    child: Slider(
                      value: _betAmount.toDouble(),
                      min: minBet.toDouble(),
                      max: maxBet.toDouble(),
                      divisions: maxBet - minBet > 0 ? maxBet - minBet : 1,
                      activeColor: CasinoColors.gold,
                      onChanged: (value) {
                        setState(() => _betAmount = value.round());
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Fold button
              ElevatedButton.icon(
                onPressed: isMyTurn && !_isProcessing ? _fold : null,
                icon: const Icon(Icons.close),
                label: const Text('Fold'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              
              // Bet/Chaal button
              ElevatedButton.icon(
                onPressed: isMyTurn && !_isProcessing ? _bet : null,
                icon: const Icon(Icons.attach_money),
                label: Text('Chaal $_betAmount'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CasinoColors.gold,
                  foregroundColor: Colors.black,
                ),
              ),
              
              // Show button (only when 2 players left)
              if (_getActivePlayerCount(state) == 2)
                ElevatedButton.icon(
                  onPressed: isMyTurn && !_isProcessing ? _showdown : null,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Show'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  int _getActivePlayerCount(TeenPattiGameState state) {
    return state.playerStatus.values.where((s) => s != 'folded').length;
  }
  
  Widget _buildGameOverScreen(TeenPattiGameState state, String myId) {
    final isWinner = state.winnerId == myId;
    
    return Scaffold(
      backgroundColor: CasinoColors.feltGreenDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: isWinner ? CasinoColors.gold : Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              isWinner ? '🎉 You Win!' : '😢 Game Over',
              style: TextStyle(
                color: isWinner ? CasinoColors.gold : Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isWinner ? 'You won ${state.pot} chips!' : 'Better luck next time!',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/lobby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Back to Lobby'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _seeCards() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Play card flip/slide sound
      await SoundService.playCardSlide();
      
      final service = ref.read(teenPattiServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        await service.seeCards(widget.roomId, userId);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _bet() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Play chip bet sound
      await SoundService.playChipSound(); 
      
      final service = ref.read(teenPattiServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        await service.bet(widget.roomId, userId, _betAmount);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _fold() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Play fold sound (using card_slide as placeholder)
      await SoundService.playCardSlide();
      
      final service = ref.read(teenPattiServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        await service.fold(widget.roomId, userId);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _showdown() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Play showdown/win sound
      await SoundService.playRoundEnd();
      
      final service = ref.read(teenPattiServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        await service.showdown(widget.roomId, userId);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

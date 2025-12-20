/// Royal Meld (Marriage) Multiplayer Screen
/// 
/// Real-time multiplayer card game connected to Firebase
/// Uses GameTerminology for multi-region localization
library;

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/features/game/widgets/player_avatar.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_table_layout.dart';


/// Multiplayer Marriage game screen
class MarriageMultiplayerScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const MarriageMultiplayerScreen({
    required this.roomId,
    super.key,
  });

  @override
  ConsumerState<MarriageMultiplayerScreen> createState() => _MarriageMultiplayerScreenState();
}

class _MarriageMultiplayerScreenState extends ConsumerState<MarriageMultiplayerScreen> {
  String? _selectedCardId;
  bool _isProcessing = false;
  // REMOVED: _hasDrawn flag - now using state.turnPhase from Firestore (P0 FIX)
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  final Set<String> _highlightedCardIds = {};  // P2: Cards to highlight in meld suggestions
  
  // Card lookup cache
  final Map<String, Card> _cardCache = {};

  
  @override
  void initState() {
    super.initState();
    _buildCardCache();
  }
  
  void _buildCardCache() {
    // Build a cache of all possible cards for quick lookup
    // Use 4 decks to include all possible cards for 6-8 player games
    final deck = Deck.forMarriage(deckCount: 4);
    for (final card in deck.cards) {
      _cardCache[card.id] = card;
    }
  }
  
  Card? _getCard(String id) => _cardCache[id];
  
  @override
  Widget build(BuildContext context) {
    final marriageService = ref.watch(marriageServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }
    
    return StreamBuilder<MarriageGameState?>(
      stream: marriageService.watchGameState(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: CasinoColors.gold),
                  const SizedBox(height: 16),
                  const Text('Loading game...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        }
        
        final state = snapshot.data;
        if (state == null) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            appBar: AppBar(
              backgroundColor: Colors.black54,
              title: const Text('Marriage'),
            ),
            body: const Center(
              child: Text('Waiting for game to start...', 
                style: TextStyle(color: Colors.white70)),
            ),
          );
        }
        
        final myHand = state.playerHands[currentUser.uid] ?? [];
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final tiplu = state.tipluCardId.isNotEmpty ? _getCard(state.tipluCardId) : null;
        final topDiscard = state.discardPile.isNotEmpty 
            ? _getCard(state.discardPile.last) 
            : null;
        
        return Scaffold(

          backgroundColor: CasinoColors.feltGreenDark,
          appBar: AppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/lobby'),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use GameTerminology for multi-region support
                Text(GameTerminology.royalMeldGame, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CasinoColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CasinoColors.gold),
                  ),
                  child: Text(
                    'Round ${state.currentRound}',
                    style: const TextStyle(color: CasinoColors.gold, fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              // P1 FIX: Enhanced Tiplu indicator with Jhiplu/Poplu info
              if (tiplu != null)
                GestureDetector(
                  onTap: () => _showTipluDialog(tiplu),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑 ', style: TextStyle(fontSize: 12)),
                        Text(
                          tiplu.displayName,
                          style: TextStyle(
                            color: tiplu.suit.isRed ? Colors.red.shade300 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.info_outline, color: Colors.white54, size: 14),
                      ],
                    ),
                  ),
                ),

                
              // Video Toggle
              IconButton(
                icon: Icon(_showVideoGrid ? Icons.videocam_off : Icons.videocam),
                onPressed: () => setState(() => _showVideoGrid = !_showVideoGrid),
                tooltip: _showVideoGrid ? 'Hide Video' : 'Show Video',
              ),
              
              // Audio Mute/Unmute (Mini implementation)
              AudioFloatingButton(roomId: widget.roomId, userId: currentUser.uid),
            ],
          ),
          body: ParticleBackground(
            primaryColor: CasinoColors.gold,
            secondaryColor: CasinoColors.feltGreenMid,
            particleCount: 15,
            child: Stack(
              children: [
                // Main Game Layer
                // Main Game Layer
                MarriageTableLayout(
                  centerArea: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       if (isMyTurn) _buildPhaseIndicator(state),
                       // Center deck/discard
                       _buildCenterArea(state, topDiscard, isMyTurn),
                       // Meld suggestions
                       _buildMeldSuggestions(myHand, tiplu),
                    ],
                  ),
                  opponents: _buildOpponentWidgets(state, currentUser.uid),
                  myHand: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Turn indicator
                      _buildTurnIndicator(state, currentUser.uid),
                      // Hand
                      _buildMyHand(myHand, isMyTurn),
                      // Action bar
                      _buildActionBar(isMyTurn, state, currentUser.uid),
                    ],
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
  
  Widget _buildMeldSuggestions(List<String> handIds, Card? tiplu) {
    if (handIds.isEmpty) return const SizedBox.shrink();
    
    // Convert IDs to Cards
    final cards = handIds.map((id) => _getCard(id)).whereType<Card>().toList();
    final melds = MeldDetector.findAllMelds(cards, tiplu: tiplu);
    
    if (melds.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: melds.length,
        itemBuilder: (context, index) {
          final meld = melds[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getMeldColor(meld.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getMeldColor(meld.type)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMeldTypeName(meld.type),
                  style: TextStyle(color: _getMeldColor(meld.type), fontSize: 12),
                ),
                const SizedBox(width: 8),
                ...meld.cards.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    c.displayName,
                    style: TextStyle(
                      color: c.suit.isRed ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Color _getMeldColor(MeldType type) {
    switch (type) {
      case MeldType.set: return Colors.blue;
      case MeldType.run: return Colors.green;
      case MeldType.tunnel: return Colors.orange;
      case MeldType.marriage: return Colors.pink;
    }
  }
  
  String _getMeldTypeName(MeldType type) {
    // Use GameTerminology for multi-region support
    switch (type) {
      case MeldType.set: return GameTerminology.trial;
      case MeldType.run: return GameTerminology.sequence;
      case MeldType.tunnel: return GameTerminology.triple;
      case MeldType.marriage: return GameTerminology.royalSequenceShort;
    }
  }

  
  /// P0 FIX: Phase indicator showing draw/discard phase
  Widget _buildPhaseIndicator(MarriageGameState state) {
    final isDrawingPhase = state.isDrawingPhase;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDrawingPhase 
            ? Colors.blue.withValues(alpha: 0.85) 
            : Colors.orange.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDrawingPhase ? Colors.blue : Colors.orange).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDrawingPhase ? Icons.download_rounded : Icons.upload_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            isDrawingPhase ? '📥 DRAW A CARD' : '📤 DISCARD A CARD',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }

  
  Widget _buildTurnIndicator(MarriageGameState state, String myId) {
    final isMyTurn = state.currentPlayerId == myId;
    final marriageService = ref.read(marriageServiceProvider);
    final remainingTime = marriageService.getRemainingTurnTime(state);
    final hasTimeout = state.config.turnTimeoutSeconds > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isMyTurn ? Colors.green.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(
          color: isMyTurn ? Colors.green : Colors.white24,
        )),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMyTurn ? Icons.play_arrow : Icons.hourglass_empty,
            color: isMyTurn ? Colors.green : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isMyTurn ? 'Your Turn' : 'Waiting for opponent...',
            style: TextStyle(
              color: isMyTurn ? Colors.green : Colors.white54,
              fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          // Timer display
          if (hasTimeout && isMyTurn) ...[
            const SizedBox(width: 16),
            _buildTimerWidget(remainingTime, state.config.turnTimeoutSeconds),
          ],
        ],
      ),
    ).animate().fadeIn();
  }
  
  /// Build circular timer widget
  Widget _buildTimerWidget(int remaining, int total) {
    final progress = remaining / total;
    final isLow = remaining <= 10;
    final isCritical = remaining <= 5;
    
    final color = isCritical 
        ? Colors.red 
        : isLow 
            ? Colors.orange 
            : Colors.green;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: color.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${remaining}s',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate(
      onComplete: (controller) => controller.repeat(),
    ).shimmer(
      duration: isCritical ? 500.ms : 1000.ms,
      color: isCritical ? Colors.red.withValues(alpha: 0.3) : Colors.transparent,
    );
  }
  
  List<Widget> _buildOpponentWidgets(MarriageGameState state, String myId) {
    final opponents = state.playerHands.keys.where((id) => id != myId).toList();
    
    return opponents.map((playerId) {
      final cardCount = state.playerHands[playerId]?.length ?? 0;
      final isCurrentTurn = state.currentPlayerId == playerId;
      
      return PlayerAvatar(
        name: 'Player ${opponents.indexOf(playerId) + 2}', // TODO: Get real name
        isCurrentTurn: isCurrentTurn,
        isHost: false, // TODO: Get host status
        bid: null,
        tricksWon: cardCount, // Showing card count as "score" for now
      ).animate().fadeIn(delay: 200.ms);
    }).toList();
  }
  
  Widget _buildCenterArea(MarriageGameState state, Card? topDiscard, bool isMyTurn) {
    // P0 FIX: Use state.isDrawingPhase instead of local _hasDrawn
    final canDraw = isMyTurn && state.isDrawingPhase;
    
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Deck
          GestureDetector(
            onTap: canDraw ? _drawFromDeck : null,
            child: _buildDeckPile(state.deckCards.length, canDraw),
          ),
          
          const SizedBox(width: 20),
          
          // Discard pile
          GestureDetector(
            onTap: canDraw && topDiscard != null ? _drawFromDiscard : null,
            child: _buildDiscardPile(topDiscard, canDraw),
          ),
        ],
      ),
    );
  }

  
  Widget _buildDeckPile(int count, bool canDraw) {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: CasinoColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canDraw ? CasinoColors.gold : CasinoColors.gold.withValues(alpha: 0.3),
          width: canDraw ? 2 : 1,
        ),
        boxShadow: canDraw ? [
          BoxShadow(
            color: CasinoColors.gold.withValues(alpha: 0.4),
            blurRadius: 12,
          ),
        ] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CasinoColors.richPurple, CasinoColors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(Icons.style, 
                color: CasinoColors.gold.withValues(alpha: 0.5), 
                size: 32,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          if (canDraw)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDiscardPile(Card? topCard, bool canDraw) {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: topCard != null ? Colors.white : CasinoColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canDraw && topCard != null ? CasinoColors.gold : CasinoColors.gold.withValues(alpha: 0.3),
          width: canDraw && topCard != null ? 2 : 1,
        ),
      ),
      child: topCard != null
          ? _buildCardWidget(topCard, false, isLarge: true)
          : Center(
              child: Text(
                'Discard',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
              ),
            ),
    );
  }
  
  Widget _buildMyHand(List<String> cardIds, bool isMyTurn) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cardIds.asMap().entries.map((entry) {
            final index = entry.key;
            final cardId = entry.value;
            final card = _getCard(cardId);
            if (card == null) return const SizedBox();
            
            final isSelected = _selectedCardId == cardId;
            
            return GestureDetector(
              onTap: isMyTurn ? () {
                setState(() {
                  _selectedCardId = isSelected ? null : cardId;
                });
              } : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
                margin: EdgeInsets.only(right: index < cardIds.length - 1 ? -25 : 0),
                child: _buildCardWidget(card, isSelected),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 30 * index));
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildCardWidget(Card card, bool isSelected, {bool isLarge = false}) {
    final size = isLarge ? const Size(70, 100) : const Size(60, 85);
    
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? CasinoColors.gold : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? CasinoColors.gold.withValues(alpha: 0.4) 
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(1, 2),
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
              fontSize: isLarge ? 24 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            card.suit.symbol,
            style: TextStyle(
              color: card.suit.isRed ? Colors.red : Colors.black,
              fontSize: isLarge ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionBar(bool isMyTurn, MarriageGameState state, String myId) {
    // P0 FIX: Use state.isDiscardingPhase instead of local _hasDrawn
    final canDiscard = isMyTurn && state.isDiscardingPhase && _selectedCardId != null;
    final canDeclare = isMyTurn && state.isDiscardingPhase;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Discard button
          ElevatedButton.icon(
            onPressed: canDiscard ? _discardCard : null,
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Discard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: CasinoColors.gold,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade700,
            ),
          ),
          
          // Sort button
          OutlinedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.sort),
            label: const Text('Sort'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          
          // Declare button (Go Royale in global mode)
          ElevatedButton.icon(
            onPressed: canDeclare ? _declare : null,
            icon: const Icon(Icons.check_circle),
            label: Text(GameTerminology.declare),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade700,
            ),
          ),

        ],
      ),
    );
  }
  
  Future<void> _drawFromDeck() async {
    if (_isProcessing) return;
    // P0 FIX: No need to check _hasDrawn - service validates turnPhase
    
    setState(() => _isProcessing = true);
    
    try {
      final marriageService = ref.read(marriageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        await marriageService.drawFromDeck(widget.roomId, userId);
        SoundService.playCardSlide();
        // P0 FIX: No need to set _hasDrawn - state updates from Firestore stream
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _drawFromDiscard() async {
    if (_isProcessing) return;
    // P0 FIX: No need to check _hasDrawn - service validates turnPhase
    
    setState(() => _isProcessing = true);
    
    try {
      final marriageService = ref.read(marriageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final result = await marriageService.drawFromDiscard(widget.roomId, userId);
        
        if (result == null) {
          // Draw was blocked - show toast explaining why
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🃏 Cannot pick this card!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Joker or Wild card blocks pickup. Draw from deck instead.',
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          SoundService.playCardSlide();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _discardCard() async {
    if (_selectedCardId == null || _isProcessing) return;
    // P0 FIX: No need to check _hasDrawn - service validates turnPhase
    
    setState(() => _isProcessing = true);
    
    try {
      final marriageService = ref.read(marriageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        await marriageService.discardCard(widget.roomId, userId, _selectedCardId!);
        SoundService.playCardSlide();
        setState(() {
          _selectedCardId = null;
          // P0 FIX: No need to reset _hasDrawn - state updates from Firestore stream
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  Future<void> _declare() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final marriageService = ref.read(marriageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final success = await marriageService.declare(widget.roomId, userId);
        if (success) {
          SoundService.playRoundEnd(); // Victory sound!
          if (mounted) _showWinDialog();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot declare yet - complete all melds first!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  void _showWinDialog() {
    // Get the score details from Firestore stream
    final marriageService = ref.read(marriageServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreamBuilder<MarriageGameState?>(
        stream: marriageService.watchGameState(widget.roomId),
        builder: (context, snapshot) {
          final state = snapshot.data;
          final scores = state?.toJson()['roundScores'] as Map<String, dynamic>? ?? {};
          final details = state?.toJson()['scoreDetails'] as Map<String, dynamic>? ?? {};
          final declarerId = state?.toJson()['declarerId'] as String?;
          
          return AlertDialog(
            backgroundColor: CasinoColors.cardBackground,
            title: Row(
              children: [
                const Text('🎉 ', style: TextStyle(fontSize: 28)),
                const Text('Round Complete!', style: TextStyle(color: CasinoColors.gold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Winner announcement
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: CasinoColors.gold, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Winner', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(
                                declarerId != null ? 'Player ${declarerId.substring(0, 4)}...' : 'Unknown',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Score breakdown header
                  const Text('Score Breakdown', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const Divider(color: Colors.white24),
                  
                  // Player scores
                  ...scores.entries.map((entry) {
                    final playerId = entry.key;
                    final score = entry.value as int;
                    final playerDetails = details[playerId] as Map<String, dynamic>? ?? {};
                    final isDeclarer = playerDetails['isDeclarer'] == true;
                    final hasPure = playerDetails['hasPureSequence'] == true;
                    final hasDublee = playerDetails['hasDublee'] == true;
                    final marriages = playerDetails['marriageCount'] as int? ?? 0;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDeclarer 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDeclarer ? Colors.green.withValues(alpha: 0.5) : Colors.white24,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDeclarer ? Icons.star : Icons.person,
                                color: isDeclarer ? CasinoColors.gold : Colors.white54,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Player ${playerId.substring(0, 6)}...',
                                  style: TextStyle(
                                    color: isDeclarer ? Colors.white : Colors.white70,
                                    fontWeight: isDeclarer ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                score >= 0 ? '+$score' : '$score',
                                style: TextStyle(
                                  color: score <= 0 ? Colors.green : Colors.red.shade300,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          // Bonuses/penalties
                          if (hasPure || hasDublee || marriages > 0 || isDeclarer)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 6,
                                children: [
                                  if (hasPure) _buildBadge('Pure ✓', Colors.blue),
                                  if (hasDublee) _buildBadge('Dublee +25', Colors.purple),
                                  if (marriages > 0) _buildBadge('Marriage x$marriages', Colors.pink),
                                  if (isDeclarer) _buildBadge('Winner', Colors.green),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/lobby');
                },
                child: const Text('Back to Lobby'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Build a small badge for bonuses
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  /// P1 FIX: Show detailed Tiplu/Jhiplu/Poplu dialog
  void _showTipluDialog(Card tiplu) {
    // Calculate Jhiplu (tiplu - 1) and Poplu (tiplu + 1)
    final tipluValue = tiplu.rank.value;
    final jhipluRank = Rank.values.firstWhere(
      (r) => r.value == tipluValue - 1,
      orElse: () => Rank.ace,
    );
    final popluRank = Rank.values.firstWhere(
      (r) => r.value == tipluValue + 1,
      orElse: () => Rank.king,
    );
    
    final suitColor = tiplu.suit.isRed ? Colors.red : Colors.white;
    final suitSymbol = tiplu.suit.symbol;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CasinoColors.cardBackground,
        title: Row(
          children: [
            const Text('👑 ', style: TextStyle(fontSize: 24)),
            // Use GameTerminology for multi-region support
            Text('${GameTerminology.wildCardFull}s', style: TextStyle(color: CasinoColors.gold, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wild Card (Tiplu)
            _buildWildCardRow('${GameTerminology.wildCard.toUpperCase()} (${GameTerminology.wildCardFull})', tiplu.rank.symbol, suitSymbol, suitColor, 'Can substitute any card'),
            const SizedBox(height: 12),
            
            // Low Wild (Jhiplu)
            _buildWildCardRow(GameTerminology.lowWild.toUpperCase(), jhipluRank.symbol, suitSymbol, suitColor, 'One rank below ${GameTerminology.wildCard}'),
            const SizedBox(height: 12),
            
            // High Wild (Poplu)
            _buildWildCardRow(GameTerminology.highWild.toUpperCase(), popluRank.symbol, suitSymbol, suitColor, 'One rank above ${GameTerminology.wildCard}'),
            
            const SizedBox(height: 20),
            
            // Royal Sequence Bonus (Marriage)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.pink),
              ),
              child: Column(
                children: [
                  Text('💒 ${GameTerminology.royalSequence.toUpperCase()} BONUS', 
                    style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${jhipluRank.symbol}$suitSymbol + ${tiplu.rank.symbol}$suitSymbol + ${popluRank.symbol}$suitSymbol',
                    style: TextStyle(color: suitColor, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('= 100 BONUS POINTS! 🎉',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),

                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT', style: TextStyle(color: CasinoColors.gold)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWildCardRow(String label, String rank, String suit, Color color, String desc) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rank, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(suit, style: TextStyle(color: color, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(desc, style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

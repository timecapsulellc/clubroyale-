/// Royal Meld (Marriage) Multiplayer Screen
/// 
/// Real-time multiplayer card game connected to Firebase
/// Uses GameTerminology for multi-region localization
library;

import 'package:flutter/material.dart' hide Card;
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
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
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_table_layout.dart';
import 'package:clubroyale/core/widgets/game_top_bar.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart'; // Import DiamondService
import 'package:clubroyale/core/widgets/game_mode_banner.dart';
import 'package:clubroyale/core/widgets/game_opponent_widget.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';
import 'package:clubroyale/games/marriage/screens/marriage_guidebook_screen.dart';


/// Sort modes for hand display
enum SortMode {
  /// Sort by suit first, then rank (good for sequences)
  bySuit,
  
  /// Sort by rank first, then suit (good for pairs/dublee)
  byRank,
}

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
  
  // Sort mode: 'suit' for sequences, 'rank' for dublee pairs
  SortMode _sortMode = SortMode.bySuit;
  
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
  
  String _getBotName(String botId) {
    final id = botId.toLowerCase();
    if (id.contains('trickmaster')) return 'TrickMaster';
    if (id.contains('cardshark')) return 'CardShark';
    if (id.contains('luckydice')) return 'LuckyDice';
    if (id.contains('deepthink')) return 'DeepThink';
    if (id.contains('royalace')) return 'RoyalAce';
    return 'Bot ${botId.split('_').last}';
  }
  
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
            body: const ContextualLoader(
              message: 'Shuffling cards...',
              icon: Icons.style,
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
          body: TableLayout(
            child: Stack(
              children: [
                // 1. Content Layer (Particles + Game Board)
                ParticleBackground(
                  primaryColor: CasinoColors.gold,
                  secondaryColor: CasinoColors.feltGreenMid,
                  particleCount: 15,
                  hasBackground: false,
                  child: Stack(
                    children: [
                   // ... existing children
                  // Main Game Layer
                  MarriageTableLayout(
                    centerArea: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         _buildGameModeBanner(state),
                         if (isMyTurn) _buildPhaseIndicator(state),
                         _buildCenterArea(state, topDiscard, isMyTurn),
                         _buildMeldSuggestions(myHand, tiplu),
                      ],
                    ),
                    opponents: _buildOpponentWidgets(state, currentUser.uid),
                    myHand: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                            const Color(0xFF0F0F1A),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border(
                          top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3), width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCompactStatusBar(state, currentUser.uid),
                          _buildMyHand(myHand, isMyTurn, tiplu: tiplu),
                          _buildActionBar(isMyTurn, state, currentUser.uid),
                        ],
                      ),
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
                    
                  // Chat Overlay moved to top right
                ],
              ),
            ),
            
            // Custom Top Bar (Floating)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Consumer(
                builder: (context, ref, child) {
                  final diamondService = ref.watch(diamondServiceProvider);
                  return StreamBuilder(
                    stream: diamondService.watchWallet(currentUser.uid),
                    builder: (context, walletSnapshot) {
                      final balance = walletSnapshot.data?.balance ?? 0;
                      final maalPoints = state.getMaalPoints(currentUser.uid);
                      
                      return GameTopBar(
                        roomName: GameTerminology.royalMeldGame,
                        roomId: widget.roomId.substring(0, widget.roomId.length > 6 ? 6 : widget.roomId.length),
                        points: 'Maal: $maalPoints',
                        balance: '💎 $balance', 
                        onExit: () => context.go('/lobby'),
                        onSettings: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarriageGuidebookScreen())),
                      );
                    }
                  );
                },
              ),
            ),

            // Video/Audio Controls (Floating Top Right, below TopBar)
            Positioned(
               top: 70, right: 16,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   // Chat Button (Top)
                   Container(
                     margin: const EdgeInsets.only(bottom: 8),
                     child: ChatOverlay(
                        roomId: widget.roomId,
                        userId: currentUser.uid,
                        userName: currentUser.displayName ?? 'Player',
                        isExpanded: _isChatExpanded,
                        onToggle: () => setState(() => _isChatExpanded = !_isChatExpanded),
                     ),
                   ),
                   Container(
                     margin: const EdgeInsets.only(bottom: 8),
                     decoration: BoxDecoration(
                       color: Colors.black.withValues(alpha: 0.3),
                       shape: BoxShape.circle,
                       border: Border.all(color: Colors.white24),
                     ),
                     child: IconButton(
                       icon: Icon(_showVideoGrid ? Icons.videocam : Icons.videocam_off, color: Colors.white, size: 20),
                       onPressed: () => setState(() => _showVideoGrid = !_showVideoGrid),
                     ),
                   ),
                   AudioFloatingButton(roomId: widget.roomId, userId: currentUser.uid),
                 ],
               ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
  
  /// Build the game mode banner showing AI/Multiplayer status
  Widget _buildGameModeBanner(MarriageGameState state) {
    final allPlayers = state.playerHands.keys.toList();
    final botCount = allPlayers.where((id) => id.startsWith('bot_')).length;
    final humanCount = allPlayers.length - botCount;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GameModeBanner(
        botCount: botCount,
        humanCount: humanCount,
        compact: true,
      ),
    );
  }

  Widget _buildMeldSuggestions(List<String> handIds, Card? tiplu) {
    if (handIds.isEmpty) return const SizedBox.shrink();
    
    // Convert IDs to Cards
    final cards = handIds.map((id) => _getCard(id)).whereType<Card>().toList();
    final melds = MeldDetector.findAllMelds(cards, tiplu: tiplu);
    
    if (melds.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 28, // Reduced from 40
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: melds.length,
        itemBuilder: (context, index) {
          final meld = melds[index];
          return Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMeldColor(meld.type).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _getMeldColor(meld.type)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMeldTypeName(meld.type),
                  style: TextStyle(color: _getMeldColor(meld.type), fontSize: 10),
                ),
                const SizedBox(width: 4),
                ...meld.cards.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: Text(
                    c.displayString,
                    style: TextStyle(
                      color: c.suit.isRed ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
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

  
  /// P0 FIX: Phase indicator showing draw/discard phase (compact)
  Widget _buildPhaseIndicator(MarriageGameState state) {
    final isDrawingPhase = state.isDrawingPhase;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isDrawingPhase 
            ? Colors.blue.withValues(alpha: 0.85) 
            : Colors.orange.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (isDrawingPhase ? Colors.blue : Colors.orange).withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
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
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isDrawingPhase ? '📥 DRAW' : '📤 DISCARD',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.95, 0.95));
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
  
  /// Build sort mode toggle bar
  Widget _buildSortToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sort: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 4),
          
          // By Suit button (for sequences)
          _buildSortButton(
            mode: SortMode.bySuit,
            label: '♠♥♦♣ Suit',
            tooltip: 'Group by suit (for sequences)',
          ),
          
          const SizedBox(width: 8),
          
          // By Rank button (for dublee/pairs)
          _buildSortButton(
            mode: SortMode.byRank,
            label: 'AKQJ Rank',
            tooltip: 'Group by rank (for pairs/dublee)',
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortButton({
    required SortMode mode,
    required String label,
    required String tooltip,
  }) {
    final isSelected = _sortMode == mode;
    
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => _sortMode = mode);
            // Play subtle sound
            SoundService.playCardSlide();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? CasinoColors.gold.withValues(alpha: 0.3) 
                : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? CasinoColors.gold : Colors.white24,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? CasinoColors.gold : Colors.white54,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Compact status bar combining Turn + Timer + Sort in one row
  Widget _buildCompactStatusBar(MarriageGameState state, String myId) {
    final isMyTurn = state.currentPlayerId == myId;
    final marriageService = ref.read(marriageServiceProvider);
    final remainingTime = marriageService.getRemainingTurnTime(state);
    final hasTimeout = state.config.turnTimeoutSeconds > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(
          color: isMyTurn ? Colors.green : Colors.white24,
        )),
      ),
      child: Row(
        children: [
          // Turn indicator (left side)
          Icon(
            isMyTurn ? Icons.play_arrow : Icons.hourglass_empty,
            color: isMyTurn ? Colors.green : Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isMyTurn ? 'Your Turn' : 'Waiting...',
            style: TextStyle(
              color: isMyTurn ? Colors.green : Colors.white54,
              fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          // Timer (middle, only if applicable)
          if (hasTimeout && isMyTurn) ...[
            const SizedBox(width: 8),
            _buildTimerWidget(remainingTime, state.config.turnTimeoutSeconds),
          ],
          // Spacer
          const Spacer(),
          // Sort buttons (right side, compact)
          _buildSortButton(
            mode: SortMode.bySuit,
            label: '♦♥ Suit',
            tooltip: 'Group by suit',
          ),
          const SizedBox(width: 6),
          _buildSortButton(
            mode: SortMode.byRank,
            label: 'AKQJ',
            tooltip: 'Group by rank',
          ),
        ],
      ),
    );
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
      final visited = state.hasVisited(playerId);
      final maalPoints = state.getMaalPoints(playerId);
      final isBot = playerId.startsWith('bot_');
      
      // Use Stack to overlay lock/unlock icon on avatar
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GameOpponentWidget(
            opponent: GameOpponent(
              id: playerId,
              name: isBot ? _getBotName(playerId) : 'Player', // Validated mapping
              isBot: isBot,
              isCurrentTurn: isCurrentTurn,
              cardCount: cardCount,
              status: isCurrentTurn ? 'Thinking' : null,
              score: null, // Don't show score yet mid-game?
            ),
            size: 50,
            showStats: true,
          ),
          
          // Visited Status Indicator (lock)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: visited ? Colors.green : Colors.grey.shade800,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                visited ? Icons.lock_open : Icons.lock,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
          
          // Maal Points Badge (only if visited)
          if (visited && maalPoints > 0)
            Positioned(
              bottom: 20, // Adjust to sit near name
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  '💎$maalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ).animate().fadeIn(delay: 200.ms);
    }).toList();
  }
  
  Widget _buildCenterArea(MarriageGameState state, Card? topDiscard, bool isMyTurn) {
    // P0 FIX: Use state.isDrawingPhase instead of local _hasDrawn
    final canDraw = isMyTurn && state.isDrawingPhase;
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.8),
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // CLOSED DECK (Draw pile)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: canDraw ? _drawFromDeck : null,
                child: _buildDeckPile(state.deckCards.length, canDraw),
              ),
              const SizedBox(height: 6),
              Text('CLOSED DECK', style: labelStyle),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // FINISH SLOT (Declare button area)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: CasinoColors.feltGreenDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CasinoColors.gold.withValues(alpha: 0.4),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_outlined, color: CasinoColors.gold.withValues(alpha: 0.6), size: 24),
                      const SizedBox(height: 4),
                      Text('FINISH', style: TextStyle(color: CasinoColors.gold.withValues(alpha: 0.6), fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('FINISH SLOT', style: labelStyle),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // OPEN DECK (Discard pile)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: canDraw && topDiscard != null ? _drawFromDiscard : null,
                child: _buildDiscardPile(topDiscard, canDraw),
              ),
              const SizedBox(height: 6),
              Text('OPEN DECK', style: labelStyle),
            ],
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
    // P0 FIX: Validation logic for drag target
    final state = ref.read(marriageServiceProvider).watchGameState(widget.roomId).last; 
    // Note: Stream logic is complex here, relying on parent rebuilding calls.
    // Simplifying: The _discardCard function checks state anyway.
    
    return DragTarget<String>(
      onWillAccept: (cardId) {
         // Basic check: is it non-null? Deep validation happens in onAccept logic via _discardCard
         return cardId != null;
      },
      onAccept: (cardId) {
        setState(() => _selectedCardId = cardId);
        _discardCard();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return Container(
          width: 80,
          height: 110,
          decoration: BoxDecoration(
            color: isHovering 
                ? Colors.red.withValues(alpha: 0.3) 
                : (topCard != null ? Colors.white : CasinoColors.cardBackground.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovering ? Colors.redAccent : (canDraw && topCard != null ? CasinoColors.gold : CasinoColors.gold.withValues(alpha: 0.3)),
              width: isHovering ? 2 : (canDraw && topCard != null ? 2 : 1),
            ),
          ),
          child: topCard != null
              ? _buildCardWidget(topCard, false, isLarge: true)
              : Center(
                  child: isHovering 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Icon(Icons.delete_outline, color: Colors.white, size: 24),
                             Text('Drop', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        )
                      : Text(
                          'Discard',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                        ),
                ),
        );
      },
    );
  }

  
  Widget _buildMyHand(List<String> cardIds, bool isMyTurn, {Card? tiplu}) {
    // Sort cards based on current sort mode
    final sortedCards = _sortCardIds(cardIds);
    
    // Create Maal calculator if tiplu is available
    final maalCalculator = tiplu != null 
        ? MarriageMaalCalculator(tiplu: tiplu)
        : null;
    
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, // Allow cards to show outside bounds
        child: Row(
          children: sortedCards.asMap().entries.map((entry) {
            final index = entry.key;
            final cardId = entry.value;
            final card = _getCard(cardId);
            if (card == null) return const SizedBox();
            
            final isSelected = _selectedCardId == cardId;
            final isLast = index == sortedCards.length - 1;
            
            // Detect Maal type for glow effect
            final maalType = maalCalculator?.getMaalType(card) ?? MaalType.none;
            
            // Use SizedBox with reduced width to create overlap
            // Last card gets full width (60px), others get 35px (60 - 25 overlap)
            return SizedBox(
              width: isLast ? 60 : 35,
              child: isMyTurn ? Draggable<String>(
                data: cardId,
                feedback: Material(
                  type: MaterialType.transparency,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: _buildCardWidget(card, true, isLarge: true),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: _buildCardWidget(card, isSelected, maalType: maalType),
                ),
                onDragStarted: () {
                   if (isMyTurn) {
                      setState(() => _selectedCardId = cardId);
                      SoundService.playCardSlide();
                   }
                },
                maxSimultaneousDrags: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
                  child: _buildCardWidget(card, isSelected, maalType: maalType),
                ),
              ) : GestureDetector(
                onTap: null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
                  child: _buildCardWidget(card, isSelected, maalType: maalType),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 30 * index));
          }).toList(),
        ),
      ),
    );
  }
  
  /// Sort card IDs based on current sort mode
  List<String> _sortCardIds(List<String> cardIds) {
    // Convert to cards, sort, return IDs
    final cards = cardIds
        .map((id) => (id, _getCard(id)))
        .where((pair) => pair.$2 != null)
        .toList();
    
    cards.sort((a, b) {
      final cardA = a.$2!;
      final cardB = b.$2!;
      
      if (_sortMode == SortMode.bySuit) {
        // Primary: Suit, Secondary: Rank
        final suitCompare = cardA.suit.index.compareTo(cardB.suit.index);
        if (suitCompare != 0) return suitCompare;
        return cardA.rank.value.compareTo(cardB.rank.value);
      } else {
        // Primary: Rank, Secondary: Suit (for Dublee/pairs)
        final rankCompare = cardA.rank.value.compareTo(cardB.rank.value);
        if (rankCompare != 0) return rankCompare;
        return cardA.suit.index.compareTo(cardB.suit.index);
      }
    });
    
    return cards.map((pair) => pair.$1).toList();
  }
  
  Widget _buildCardWidget(Card card, bool isSelected, {bool isLarge = false, MaalType maalType = MaalType.none}) {
    final size = isLarge ? const Size(70, 100) : const Size(60, 85);
    
    // Maal glow colors
    final hasMaalGlow = maalType != MaalType.none;
    final maalColor = _getMaalColor(maalType);
    final maalLabel = _getMaalLabel(maalType);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasMaalGlow 
                  ? maalColor 
                  : (isSelected ? CasinoColors.gold : Colors.grey.shade300),
              width: hasMaalGlow ? 2.5 : (isSelected ? 2 : 1),
            ),
            boxShadow: [
              BoxShadow(
                color: hasMaalGlow 
                    ? maalColor.withValues(alpha: 0.5) 
                    : (isSelected 
                        ? CasinoColors.gold.withValues(alpha: 0.4) 
                        : Colors.black.withValues(alpha: 0.2)),
                blurRadius: hasMaalGlow ? 10 : (isSelected ? 8 : 4),
                spreadRadius: hasMaalGlow ? 2 : 0,
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
        ),
        
        // Maal badge (only for non-large cards in hand)
        if (hasMaalGlow && !isLarge)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: maalColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                maalLabel,
                style: const TextStyle(fontSize: 8),
              ),
            ),
          ),
      ],
    );
  }
  
  /// Get Maal type color for glow effect
  Color _getMaalColor(MaalType type) {
    switch (type) {
      case MaalType.tiplu:
        return Colors.purple;        // 3 pts - main wild
      case MaalType.poplu:
        return Colors.blue;          // 2 pts - rank +1
      case MaalType.jhiplu:
        return Colors.cyan;          // 2 pts - rank -1
      case MaalType.alter:
        return Colors.orange;        // 5 pts - same rank+color
      case MaalType.man:
        return Colors.green;         // Joker
      case MaalType.none:
        return Colors.transparent;
    }
  }
  
  /// Get Maal badge label
  String _getMaalLabel(MaalType type) {
    switch (type) {
      case MaalType.tiplu:
        return '👑';    // Crown for main wild
      case MaalType.poplu:
        return '⬆️';    // Up for +1
      case MaalType.jhiplu:
        return '⬇️';    // Down for -1
      case MaalType.alter:
        return '💎';    // Diamond for alter
      case MaalType.man:
        return '🃏';    // Joker
      case MaalType.none:
        return '';
    }
  }
  
  Widget _buildActionBar(bool isMyTurn, MarriageGameState state, String myId) {
    // P0 FIX: Use state.isDiscardingPhase instead of local _hasDrawn
    final canDiscard = isMyTurn && state.isDiscardingPhase && _selectedCardId != null;
    final canDeclare = isMyTurn && state.isDiscardingPhase;
    
    final hasVisited = state.hasVisited(myId);
    final canVisit = isMyTurn && !hasVisited;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Discard Button (Left)
            _buildGameActionButton(
              label: '↑ Discard',
              color: Colors.grey.shade800,
              icon: Icons.arrow_upward,
              isEnabled: canDiscard,
              onPressed: _discardCard,
            ),
            
            // Visit (Center - Main Action)
            if (!hasVisited)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildGameActionButton(
                    label: '🔒 VISIT (Unlock Maal)',
                    color: Colors.purple, // Matching the user's reference Guide color
                    icon: Icons.lock_open,
                    isEnabled: canVisit,
                    onPressed: _attemptVisit,
                    isPrimary: true,
                  ),
                ),
              )
            else
               Expanded(
                 child: Container(
                   margin: const EdgeInsets.symmetric(horizontal: 16),
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   decoration: BoxDecoration(
                     color: Colors.purple.withValues(alpha: 0.2),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
                   ),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                        const Text('🔓 VISITED', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('💎 Maal: ${state.getMaalPoints(myId)}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                     ],
                   )
                 ),
               ),
            
            // Declare/Go Royale (Right)
            _buildGameActionButton(
              label: '✓ Go Royale',
              color: Colors.green,
              icon: Icons.check_circle,
              isEnabled: canDeclare,
              onPressed: _declare,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade900,
        disabledForegroundColor: Colors.grey.shade600,
        elevation: isEnabled ? 4 : 0,
        padding: EdgeInsets.symmetric(horizontal: isPrimary ? 20 : 16, vertical: isPrimary ? 16 : 12),
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
           side: BorderSide(color: isEnabled ? Colors.white24 : Colors.transparent),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isPrimary ? 24 : 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: isPrimary ? 13 : 11, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          )),
        ],
      ),
    );
  }
  
  Future<void> _attemptVisit() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final marriageService = ref.read(marriageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) return;
      
      // Attempt to visit
      final (success, type, reason) = await marriageService.attemptVisit(
        widget.roomId, 
        currentUser.uid
      );
      
      if (success) {
        // Show success animation
        if (mounted) {
           _showCelebrationEffect(context);
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('🎉 Visited Successfully via $type! Maal Unlocked!'),
               backgroundColor: Colors.purple,
               duration: const Duration(seconds: 3),
             ),
           );
        }
      } else {
        // Show error toast
        if (mounted && reason != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Cannot Visit: $reason'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  // Celebration effect for visiting
  void _showCelebrationEffect(BuildContext context) {
    // Uses the existing particle system or creates a specialized overlay
    // For now, simple sound effect
    SoundService.playTrickWon(); // Reuse win sound or add 'unlock'
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
          SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e)), backgroundColor: Colors.red),
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
          SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e)), backgroundColor: Colors.red),
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
          SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e)), backgroundColor: Colors.red),
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
          SnackBar(content: Text(ErrorHelper.getFriendlyMessage(e)), backgroundColor: Colors.red),
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

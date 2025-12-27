/// Premium Marriage Game Screen
/// 
/// Enhanced version using premium gaming UI components:
/// - PremiumGameTable with felt texture
/// - PremiumHandWidget with expand/collapse
/// - PremiumCardWidget with 3D effects
/// - NepaliRulesOverlay for game status
library;

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';

// Premium UI Components
import 'package:clubroyale/core/design_system/game/game_design_system.dart';
import 'package:clubroyale/core/design_system/animations/rive_animations.dart';
import 'package:clubroyale/core/services/game_audio_mixin.dart';

/// Premium Marriage game screen with enhanced UI
class PremiumMarriageScreen extends ConsumerStatefulWidget {
  final String roomId;

  const PremiumMarriageScreen({
    required this.roomId,
    super.key,
  });

  @override
  ConsumerState<PremiumMarriageScreen> createState() => _PremiumMarriageScreenState();
}

class _PremiumMarriageScreenState extends ConsumerState<PremiumMarriageScreen> with GameAudioMixin {
  String? _selectedCardId;
  bool _isProcessing = false;
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  bool _showConfetti = false;

  // Card lookup cache
  final Map<String, Card> _cardCache = {};

  @override
  void initState() {
    super.initState();
    _buildCardCache();
    // Initialize audio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAudio(ref);
    });
  }

  void _buildCardCache() {
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
          return _buildLoadingScreen();
        }

        final state = snapshot.data;
        if (state == null) {
          return _buildWaitingScreen();
        }

        final myHand = state.playerHands[currentUser.uid] ?? [];
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final tiplu = state.tipluCardId.isNotEmpty ? _getCard(state.tipluCardId) : null;
        final topDiscard = state.discardPile.isNotEmpty
            ? _getCard(state.discardPile.last)
            : null;
        final hasVisited = state.hasVisited(currentUser.uid);
        final maalPoints = _calculateMaalPoints(myHand, tiplu);

        return Scaffold(
          backgroundColor: const Color(0xFF0a2814),
          appBar: _buildAppBar(state, tiplu, currentUser),
          body: Stack(
            children: [
              // Main Game Table
              PremiumGameTable(
                statusOverlay: NepaliRulesOverlay(
                  tiplu: tiplu,
                  isVisited: hasVisited,
                  maalPoints: maalPoints,
                  hasMarriageBonus: _hasMarriageBonus(myHand, tiplu),
                  roundNumber: state.currentRound,
                  onRulesTap: () => _showRulesDialog(context),
                ),
                centerContent: _buildCenterArea(state, tiplu, topDiscard, isMyTurn),
                opponents: _buildOpponents(state, currentUser.uid),
                playerHand: _buildPlayerHand(myHand, isMyTurn, tiplu, state),
                actionBar: _buildActionBar(isMyTurn, state, currentUser.uid),
                myPlayerId: currentUser.uid,
                isMyTurn: isMyTurn,
                onCardDroppedOnDiscard: _discardSpecificCard,
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
                bottom: 200,
                left: 16,
                child: ChatOverlay(
                  roomId: widget.roomId,
                  userId: currentUser.uid,
                  userName: currentUser.displayName ?? 'Player',
                  isExpanded: _isChatExpanded,
                  onToggle: () => setState(() => _isChatExpanded = !_isChatExpanded),
                ),
              ),

              // Rive Confetti Overlay
              if (_showConfetti)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showConfetti = false), // Tap to dismiss
                    child: const RiveConfetti(play: true),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFF0a2814),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
            SizedBox(height: 16),
            Text('Loading game...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0a2814),
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(GameTerminology.royalMeldGame),
      ),
      body: const Center(
        child: Text(
          'Waiting for game to start...',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    MarriageGameState state,
    Card? tiplu,
    dynamic currentUser,
  ) {
    return AppBar(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/lobby'),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            GameTerminology.royalMeldGame,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37)),
            ),
            child: Text(
              'Round ${state.currentRound}',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Video Toggle
        IconButton(
          icon: Icon(_showVideoGrid ? Icons.videocam_off : Icons.videocam),
          onPressed: () => setState(() => _showVideoGrid = !_showVideoGrid),
          tooltip: _showVideoGrid ? 'Hide Video' : 'Show Video',
        ),

        // Audio Controls
        AudioFloatingButton(
          roomId: widget.roomId,
          userId: currentUser.uid,
        ),
      ],
    );
  }

  Widget _buildCenterArea(
    MarriageGameState state,
    Card? tiplu,
    Card? topDiscard,
    bool isMyTurn,
  ) {
    final canDraw = isMyTurn && state.isDrawingPhase;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phase indicator
        if (isMyTurn) _buildPhaseIndicator(state),
        
        const SizedBox(height: 16),

        // Deck, Tiplu, Discard
        TableCenterArea(
          deckWidget: PremiumCardWidget(
            card: Card(rank: Rank.ace, suit: Suit.spades), // Dummy for back
            isFaceUp: false,
            width: 70,
            height: 100,
          ),
          deckCount: state.deckCards.length,
          onDeckTap: canDraw ? _drawFromDeck : null,
          tipluWidget: tiplu != null
              ? PremiumCardWidget(
                  card: tiplu,
                  maalType: MaalType.tiplu,
                  width: 70,
                  height: 100,
                )
              : null,
          discardWidget: topDiscard != null
              ? PremiumCardWidget(
                  card: topDiscard,
                  width: 70,
                  height: 100,
                )
              : null,
          onDiscardTap: canDraw && topDiscard != null ? _drawFromDiscard : null,
        ),

        const SizedBox(height: 8),

        // Meld suggestions
        _buildMeldSuggestions(state.playerHands[ref.read(authServiceProvider).currentUser?.uid] ?? [], tiplu),
      ],
    );
  }

  Widget _buildPhaseIndicator(MarriageGameState state) {
    final isDrawing = state.isDrawingPhase;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDrawing
            ? Colors.blue.withValues(alpha: 0.85)
            : Colors.orange.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDrawing ? Colors.blue : Colors.orange).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDrawing ? Icons.download_rounded : Icons.upload_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            isDrawing ? '📥 DRAW A CARD' : '📤 DISCARD A CARD',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }

  List<OpponentData> _buildOpponents(MarriageGameState state, String myId) {
    final opponents = state.playerHands.keys.where((id) => id != myId).toList();

    return opponents.asMap().entries.map((entry) {
      final index = entry.key;
      final playerId = entry.value;
      final cardCount = state.playerHands[playerId]?.length ?? 0;
      final isVisited = state.hasVisited(playerId);
      final maalPoints = state.getMaalPoints(playerId);
      
      // Reconstruct melds from JSON
      final melds = <Meld>[];
      if (isVisited) {
         final declaredJson = state.playerDeclaredMelds[playerId] ?? [];
         final tiplu = state.tipluCardId.isNotEmpty ? _getCard(state.tipluCardId) : null;
         
         for (final json in declaredJson) {
            try {
              final typeName = json['type'] as String;
              final type = MeldType.values.firstWhere(
                (e) => e.name == typeName, 
                orElse: () => MeldType.set
              );
              final cardIds = List<String>.from(json['cardIds'] ?? []);
              final cards = cardIds.map((id) => _getCard(id)).whereType<Card>().toList();
              
              melds.add(Meld.fromTypeAndCards(type, cards, tiplu: tiplu));
            } catch (e) {
              debugPrint('Error parsing meld: $e');
            }
         }
      }

      return OpponentData(
        playerId: playerId,
        name: 'Player ${index + 2}', // TODO: Get real name
        cardCount: cardCount,
        isVisited: isVisited,
        maalPoints: maalPoints,
        melds: melds,
      );
    }).toList();
  }

  Widget _buildPlayerHand(
    List<String> cardIds,
    bool isMyTurn,
    Card? tiplu,
    MarriageGameState state,
  ) {
    // Convert IDs to Cards
    final cards = cardIds.map((id) => _getCard(id)).whereType<Card>().toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Turn indicator
        _buildTurnIndicator(state, ref.read(authServiceProvider).currentUser?.uid ?? ''),

        // Premium hand widget
        PremiumHandWidget(
          cards: cards,
          tiplu: tiplu,
          selectedCardId: _selectedCardId,
          isMyTurn: isMyTurn,
          canSelect: isMyTurn && state.isDiscardingPhase,
          onCardTap: (card) {
            if (isMyTurn) {
              setState(() {
                _selectedCardId = _selectedCardId == card.id ? null : card.id;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTurnIndicator(MarriageGameState state, String myId) {
    final isMyTurn = state.currentPlayerId == myId;
    final marriageService = ref.read(marriageServiceProvider);
    final remainingTime = marriageService.getRemainingTurnTime(state);
    final hasTimeout = state.config.turnTimeoutSeconds > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isMyTurn
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: isMyTurn ? Colors.green : Colors.white24,
          ),
        ),
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
          if (hasTimeout && isMyTurn) ...[
            const SizedBox(width: 16),
            _buildTimer(remainingTime, state.config.turnTimeoutSeconds),
          ],
        ],
      ),
    );
  }

  Widget _buildTimer(int remaining, int total) {
    final progress = remaining / total;
    final isCritical = remaining <= 5;
    final color = isCritical ? Colors.red : remaining <= 10 ? Colors.orange : Colors.green;

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
    );
  }

  Widget _buildActionBar(bool isMyTurn, MarriageGameState state, String myId) {
    final canDiscard = isMyTurn && state.isDiscardingPhase && _selectedCardId != null;
    final canDeclare = isMyTurn && state.isDiscardingPhase;
    final hasVisited = state.hasVisited(myId);
    final canVisit = isMyTurn && !hasVisited;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          ),
        ),
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
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade700,
            ),
          ),

          // Visit Button / Status
          if (!hasVisited)
            ElevatedButton.icon(
              onPressed: canVisit ? _attemptVisit : null,
              icon: const Icon(Icons.lock_open),
              label: const Text('Visit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade700,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.purple, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Visited (💎${state.getMaalPoints(myId)})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Declare button
          ElevatedButton.icon(
            onPressed: canDeclare ? _attemptDeclare : null,
            icon: const Icon(Icons.emoji_events),
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

  Widget _buildMeldSuggestions(List<String> handIds, Card? tiplu) {
    if (handIds.isEmpty) return const SizedBox.shrink();

    final cards = handIds.map((id) => _getCard(id)).whereType<Card>().toList();
    final melds = MeldDetector.findAllMelds(cards, tiplu: tiplu);

    if (melds.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  _getMeldName(meld.type),
                  style: TextStyle(
                    color: _getMeldColor(meld.type),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                ...meld.cards.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    c.displayString,
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

  // Helper methods
  int _calculateMaalPoints(List<String> cardIds, Card? tiplu) {
    if (tiplu == null) return 0;
    final calculator = MarriageMaalCalculator(tiplu: tiplu);
    final cards = cardIds.map((id) => _getCard(id)).whereType<Card>().toList();
    return calculator.calculateMaalPoints(cards);
  }

  bool _hasMarriageBonus(List<String> cardIds, Card? tiplu) {
    if (tiplu == null) return false;
    final cards = cardIds.map((id) => _getCard(id)).whereType<Card>().toList();
    final melds = MeldDetector.findAllMelds(cards, tiplu: tiplu);
    return melds.any((m) => m.type == MeldType.marriage);
  }

  Color _getMeldColor(MeldType type) {
    return switch (type) {
      MeldType.set => Colors.blue,
      MeldType.run => Colors.green,
      MeldType.tunnel => Colors.orange,
      MeldType.marriage => Colors.pink,
      MeldType.impureRun => Colors.orange.shade300,
      MeldType.impureSet => Colors.teal,
    };
  }

  String _getMeldName(MeldType type) {
    return switch (type) {
      MeldType.set => GameTerminology.trial,
      MeldType.run => GameTerminology.sequence,
      MeldType.tunnel => GameTerminology.triple,
      MeldType.marriage => GameTerminology.royalSequenceShort,
      MeldType.impureRun => 'Impure Sequence',
      MeldType.impureSet => 'Impure Trial',
    };
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a2e),
        title: const Text(
          'Marriage Rules',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👑 Tiplu: Main wild card (3 pts)',
                  style: TextStyle(color: Colors.purple)),
              SizedBox(height: 4),
              Text('⬆️ Poplu: Rank +1 of Tiplu suit (2 pts)',
                  style: TextStyle(color: Colors.blue)),
              SizedBox(height: 4),
              Text('⬇️ Jhiplu: Rank -1 of Tiplu suit (2 pts)',
                  style: TextStyle(color: Colors.cyan)),
              SizedBox(height: 4),
              Text('💎 Alter: Same rank & color (5 pts)',
                  style: TextStyle(color: Colors.orange)),
              SizedBox(height: 4),
              Text('🃏 Man: Joker card',
                  style: TextStyle(color: Colors.green)),
              SizedBox(height: 16),
              Text('🔒 Visit: Required to declare (3 pts min)',
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 4),
              Text('💍 Marriage: K-Q of same suit (+100 pts)',
                  style: TextStyle(color: Colors.pink)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Game actions
  Future<void> _drawFromDeck() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser == null) return;
      await marriageService.drawFromDeck(widget.roomId, currentUser.uid);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _drawFromDiscard() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser == null) return;
      await marriageService.drawFromDiscard(widget.roomId, currentUser.uid);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _discardCard() async {
    if (_isProcessing || _selectedCardId == null) return;
    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser == null) return;
      await marriageService.discardCard(widget.roomId, currentUser.uid, _selectedCardId!);
      setState(() => _selectedCardId = null);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }


  Future<void> _discardSpecificCard(String cardId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser == null) return;
      await marriageService.discardCard(widget.roomId, currentUser.uid, cardId);
      // Clear selection if the discarded card was selected
      if (_selectedCardId == cardId) {
         setState(() => _selectedCardId = null);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _attemptVisit() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser == null) return;
      await marriageService.attemptVisit(widget.roomId, currentUser.uid);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _attemptDeclare() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;
      if (currentUser == null) return;
      await marriageService.declare(widget.roomId, currentUser.uid);
      
      // Success! Show effects
      if (mounted) {
        playMarriageDeclare(); // Play declare sound
        playWin(); // Play win sound
        setState(() => _showConfetti = true);
        
        // Hide confetti after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showConfetti = false);
        });
        
        // Show winner dialog
        _showWinnerDialog(context, currentUser.displayName ?? 'You');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to declare: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showWinnerDialog(BuildContext context, String winnerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a2e),
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20),
           side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
        title: Column(
          children: [
            const Text(
              '🎉 WINNER! 🎉',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const RiveWinnerTrophy(size: 150),
          ],
        ),
        content: Text(
          '$winnerName declared a Royal Marriage sequence!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/lobby'); // Back to lobby
            },
            child: const Text('Back to Lobby'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Rematch logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
}
}

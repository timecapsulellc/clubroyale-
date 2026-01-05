/// Teen Patti Game Screen
///
/// Real-time multiplayer Teen Patti game UI
library;

import 'dart:math' as math;
import 'package:flutter/material.dart' hide Card;
import 'package:clubroyale/core/utils/haptic_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:clubroyale/core/widgets/game_mode_banner.dart';
import 'package:clubroyale/core/widgets/game_opponent_widget.dart';
import 'package:clubroyale/core/widgets/turn_timer.dart';
import 'package:clubroyale/core/widgets/dynamic_chip_stack.dart';
import 'package:clubroyale/core/widgets/tutorial_overlay.dart'; // Tutorial
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/features/game/ui/components/card_preview_overlay.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/games/teen_patti/teen_patti_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';
import 'package:clubroyale/features/game/ui/components/unified_game_sidebar.dart';
import 'package:clubroyale/features/game/ui/components/game_settings_modal.dart';

class TeenPattiScreen extends ConsumerStatefulWidget {
  final String roomId;

  const TeenPattiScreen({required this.roomId, super.key});

  @override
  ConsumerState<TeenPattiScreen> createState() => _TeenPattiScreenState();
}

class _TeenPattiScreenState extends ConsumerState<TeenPattiScreen> {
  bool _isProcessing = false;
  bool _hasSeenCards = false;
  int _betAmount = 1;
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  // Pro Layout
  bool _isSidebarOpen = false;

  // Tutorial state
  bool _showTutorial = true;
  final GlobalKey _cardsKey = GlobalKey();
  final GlobalKey _potKey = GlobalKey();
  final GlobalKey _actionBarKey = GlobalKey();
  final GlobalKey _rulesKey = GlobalKey();

  List<TutorialStep> get _tutorialSteps => [
    TutorialStep(
      title: 'Welcome to Teen Patti! 🃏',
      description:
          'The goal is to have the best 3-card hand. Trail (3-of-a-kind) beats all!',
    ),
    TutorialStep(
      title: 'Your Cards',
      description:
          'Tap here to see your cards (Seen mode). Playing Blind costs fewer chips!',
      targetKey: _cardsKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'The Pot',
      description: 'All bets go here. The winner takes it all!',
      targetKey: _potKey,
      tooltipAlignment: Alignment.bottomCenter,
    ),
    TutorialStep(
      title: 'Actions',
      description:
          'Fold to give up, Bet to stay in, or Show when only 2 players remain.',
      targetKey: _actionBarKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'Need Help?',
      description: 'Tap here anytime to see hand rankings and rules.',
      targetKey: _rulesKey,
      tooltipAlignment: Alignment.bottomLeft,
    ),
  ];

  // Card lookup cache
  final Map<String, Card> _cardCache = {};

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
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return StreamBuilder<TeenPattiGameState?>(
      stream: teenPattiService.watchGameState(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            body: const ContextualLoader(
              message: 'Dealing cards...',
              icon: Icons.casino,
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
              child: Text(
                'Waiting for game...',
                style: TextStyle(color: Colors.white70),
              ),
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
          body: Stack(
            children: [
              // 1. Game Table Layer
              TableLayout(
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Top spacer
                      _buildGameModeBanner(state, currentUser.uid),
                      _buildTurnIndicator(isMyTurn, myStatus),
                      
                      Expanded(
                        flex: 2,
                        child: _buildOpponentsArea(state, currentUser.uid),
                      ),
                      
                      Container(
                        key: _potKey,
                        child: _buildPotArea(state.pot),
                      ),
                      
                      Expanded(
                        flex: 3,
                        child: Container(
                          key: _cardsKey,
                          child: _buildMyCards(myHand, myStatus),
                        ),
                      ),
                      
                      Container(
                        key: _actionBarKey,
                        child: _buildActionBar(isMyTurn, myStatus, state),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Sidebar Backdrop
               if (_isSidebarOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _isSidebarOpen = false),
                    child: Container(color: Colors.black54),
                  ),
                ),

              // 3. Sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _isSidebarOpen ? 0 : -220,
                top: 0,
                bottom: 0,
                width: 220,
                child: UnifiedGameSidebar(
                  roomId: widget.roomId,
                  userId: currentUser.uid,
                  headerContent: Column(
                    children: [
                       const Text('Teen Patti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 4),
                       Text('Room: ${widget.roomId.substring(0, 4)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  onSettings: () => GameSettingsModal.show(context, gameName: 'Teen Patti'),
                  onHelp: () => _showRules(context),
                  onQuitGame: () => context.go('/lobby'),
                  onToggleChat: () => setState(() { _isSidebarOpen = false; _isChatExpanded = !_isChatExpanded; }),
                  onToggleVideo: () => setState(() { _isSidebarOpen = false; _showVideoGrid = !_showVideoGrid; }),
                ),
              ),

              // 4. Smart Menu Button
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.grid_view_rounded, color: Colors.white70),
                      onPressed: () => setState(() => _isSidebarOpen = true),
                      tooltip: 'Menu',
                    ),
                  ),
                ),
              ),

              // 5. Overlays
              if (_showVideoGrid)
                Positioned(
                  top: 60, right: 16, width: 200, height: 300,
                  child: VideoGridWidget(roomId: widget.roomId, userId: currentUser.uid, userName: currentUser.displayName ?? 'Player'),
                ),

              if (_isChatExpanded)
                Positioned(
                  bottom: 160, left: 16,
                  child: ChatOverlay(
                    roomId: widget.roomId,
                    userId: currentUser.uid,
                    userName: currentUser.displayName ?? 'Player',
                    isExpanded: true,
                    onToggle: () => setState(() => _isChatExpanded = false),
                  ),
                ),

              if (_showTutorial)
                TutorialOverlay(
                  steps: _tutorialSteps,
                  onComplete: () => setState(() => _showTutorial = false),
                  onSkip: () => setState(() => _showTutorial = false),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showRules(BuildContext context) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: CasinoColors.cardBackground,
          title: const Text('Teen Patti Rules (Flash)', style: TextStyle(color: CasinoColors.gold)),
          content: const SingleChildScrollView(
            child: Text(
              '1. Highest to Lowest Rankings:\n'
              '   • TRAIL (Set): 3 cards of same rank (AAA is highest)\n'
              '   • PURE SEQUENCE: 3 consecutive cards of same suit\n'
              '   • SEQUENCE: 3 consecutive cards\n'
              '   • COLOR: 3 cards of same suit\n'
              '   • PAIR: 2 cards of same rank\n'
              '   • HIGH CARD: Highest individual card\n\n'
              '2. Blind vs Seen:\n'
              '   • Blind player bets 1x.\n'
              '   • Seen player must bet 2x current stake.\n\n'
              '3. Show:\n'
              '   • Only possible when 2 players remain.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Got it'))],
        ),
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
          Image.asset(
            'assets/images/chips/chip_red.png',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Pot: $pot',
            style: const TextStyle(
              color: CasinoColors.gold,
              fontWeight: FontWeight.bold,
            ),
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
        color: isMyTurn
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: isMyTurn ? Colors.green : Colors.white24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                isMyTurn ? '🎯 Your Turn' : '⏳ Waiting...',
                style: TextStyle(
                  color: isMyTurn ? Colors.green : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isMyTurn) ...[
                const SizedBox(width: 12),
                const TurnTimerBadge(remainingSeconds: 30, totalSeconds: 30),
              ],
            ],
          ),
          Text(statusText, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  /// Build the game mode banner showing AI/Multiplayer status
  Widget _buildGameModeBanner(TeenPattiGameState state, String myId) {
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

  Widget _buildOpponentsArea(TeenPattiGameState state, String myId) {
    final opponents = state.playerHands.keys.where((id) => id != myId).toList();

    // Convert to GameOpponent objects for the new widget
    final opponentWidgets = opponents.map((playerId) {
      final status = state.playerStatus[playerId] ?? 'blind';
      final bet = state.playerBets[playerId] ?? 0;
      final isCurrentTurn = state.currentPlayerId == playerId;
      final isFolded = status == 'folded';
      final isBot = playerId.startsWith('bot_');

      return GameOpponent(
        id: playerId,
        name: isBot ? _getBotDisplayName(playerId) : 'Player',
        isBot: isBot,
        isCurrentTurn: isCurrentTurn,
        isFolded: isFolded,
        status: status,
        bet: bet,
        cardCount: state.playerHands[playerId]?.length ?? 0,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: OpponentRow(opponents: opponentWidgets, avatarSize: 50),
    );
  }

  /// Get a display name for bot players
  String _getBotDisplayName(String botId) {
    final botNames = [
      'TrickMaster',
      'CardShark',
      'LuckyDice',
      'DeepThink',
      'RoyalAce',
    ];
    final index = botId.hashCode.abs() % botNames.length;
    return botNames[index];
  }

  Widget _buildPotArea(int pot) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: PotDisplay(potAmount: pot, label: '💰 POT', size: 70),
    );
  }

  // Helper method removed - using SoundService directly

  Widget _buildMyCards(List<String> cardIds, String myStatus) {
    final showCards = myStatus == 'seen' || _hasSeenCards;

    return GestureDetector(
      onTap: myStatus == 'blind' && !_hasSeenCards
          ? () {
              setState(() => _hasSeenCards = true);
              _seeCards();
            }
          : null,
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
                )
                .animate(delay: Duration(milliseconds: 100 * index))
                .fadeIn()
                .scale();
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardFace(Card card) {
    // Convert core Card to PlayingCard for shared widget
    final playingCard = PlayingCard(
      suit: CardSuit.values.firstWhere((s) => s.name == card.suit.name.toLowerCase()),
      rank: CardRank.values.firstWhere((r) => r.symbol == card.rank.symbol),
    );
    
    return CardWithPreview(
      card: playingCard,
      child: CardWidget(
        card: playingCard,
        isFaceUp: true,
        width: 80,
        height: 120,
        glowColor: CasinoColors.gold.withValues(alpha: 0.3),
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

  Widget _buildActionBar(
    bool isMyTurn,
    String myStatus,
    TeenPattiGameState state,
  ) {
    final isSeen = myStatus == 'seen';
    final minBet = isSeen ? state.currentStake * 2 : state.currentStake;
    final maxBet = isSeen ? state.currentStake * 4 : state.currentStake * 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3)),
        ),
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
                  Text(
                    'Bet: $_betAmount',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: _betAmount.toDouble().clamp(
                        minBet.toDouble(),
                        maxBet.toDouble(),
                      ),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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

                const SizedBox(width: 8),

                // Bet/Chaal button
                ElevatedButton.icon(
                  onPressed: isMyTurn && !_isProcessing
                      ? () => _bet(minBet, maxBet)
                      : null,
                  icon: const Icon(Icons.attach_money),
                  // P0 FIX: Display valid amount matching the slider
                  label: Text(
                    isSeen
                        ? 'Chaal ${math.max(_betAmount, minBet)}'
                        : 'Blind ${math.max(_betAmount, minBet)}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CasinoColors.gold,
                    foregroundColor: Colors.black,
                  ),
                ),

                const SizedBox(width: 8),

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

    if (isWinner) {
      HapticHelper.winCelebration();
    }

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
              isWinner
                  ? 'You won ${state.pot} chips!'
                  : 'Better luck next time!',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/lobby'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
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
      // Haptic feedback for card reveal
      HapticHelper.cardMove();
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

  Future<void> _bet(int minBet, int maxBet) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Haptic feedback for betting
      HapticHelper.chipPlace();
      // Play chip bet sound
      await SoundService.playChipSound();

      final service = ref.read(teenPattiServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        // Ensure bet amount is valid
        final validAmount = _betAmount.clamp(minBet, maxBet);
        await service.bet(widget.roomId, userId, validAmount);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _fold() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Haptic feedback for fold action
      HapticHelper.lightTap();
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
      // Haptic feedback for showdown moment
      HapticHelper.success();
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

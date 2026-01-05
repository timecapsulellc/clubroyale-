/// In Between Game Screen
///
/// Real-time multiplayer In Between game UI
library;

import 'package:flutter/material.dart' hide Card;
import 'package:clubroyale/core/utils/error_helper.dart';
import 'package:clubroyale/core/widgets/contextual_loader.dart';
import 'package:clubroyale/core/widgets/game_mode_banner.dart';
import 'package:clubroyale/core/widgets/game_opponent_widget.dart';
import 'package:clubroyale/core/widgets/turn_timer.dart';
import 'package:clubroyale/core/widgets/tutorial_overlay.dart'; // Tutorial
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/games/in_between/in_between_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/features/game/ui/components/card_preview_overlay.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/unified_game_sidebar.dart';
import 'package:clubroyale/features/game/ui/components/game_settings_modal.dart';

class InBetweenScreen extends ConsumerStatefulWidget {
  final String roomId;

  const InBetweenScreen({required this.roomId, super.key});

  @override
  ConsumerState<InBetweenScreen> createState() => _InBetweenScreenState();
}

class _InBetweenScreenState extends ConsumerState<InBetweenScreen> {
  bool _isProcessing = false;
  int _betAmount = 0;
  String? _lastResult;
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  // Pro Layout
  bool _isSidebarOpen = false;

  // Tutorial state
  bool _showTutorial = true;
  final GlobalKey _cardsKey = GlobalKey();
  final GlobalKey _bettingKey = GlobalKey();
  final GlobalKey _actionsKey = GlobalKey();
  final GlobalKey _rulesKey = GlobalKey();

  List<TutorialStep> get _tutorialSteps => [
    TutorialStep(
      title: 'Welcome to In-Between! 🎰',
      description:
          'The goal is to guess if the third card falls between the first two cards.',
    ),
    TutorialStep(
      title: 'The Cards',
      description:
          'The first two cards are "Low" and "High" - your third card needs to fall in between!',
      targetKey: _cardsKey,
      tooltipAlignment: Alignment.bottomCenter,
    ),
    TutorialStep(
      title: 'Place Your Bet',
      description:
          'Use the slider to choose how much you want to bet. Higher probability = safer bet.',
      targetKey: _bettingKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'Actions',
      description:
          'Pass to skip your turn, or Bet to reveal the middle card. Reveal to see your fate!',
      targetKey: _actionsKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'Rules',
      description:
          'Tap here to learn about "Hitting the Post" and other rules.',
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

  int _cardValue(Card card) {
    switch (card.rank) {
      case Rank.ace:
        return 14;
      case Rank.king:
        return 13;
      case Rank.queen:
        return 12;
      case Rank.jack:
        return 11;
      default:
        return card.rank.points;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inBetweenService = ref.watch(inBetweenServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return StreamBuilder<InBetweenGameState?>(
      stream: inBetweenService.watchGameState(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            body: const ContextualLoader(
              message: 'Setting up table...',
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
              title: Text(GameTerminology.inBetweenGame),
            ),
            body: const Center(
              child: Text(
                'Waiting for game...',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final myChips = state.playerChips[currentUser.uid] ?? 0;
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final maxBet = myChips < state.pot ? myChips : state.pot;

        return Scaffold(
          body: Stack(
            children: [
              // 1. Game Table Layer
              TableLayout(
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Game mode indicator
                          _buildGameModeBanner(state),

                          // Opponents area
                          _buildOpponentsArea(state, currentUser.uid),

                          // Turn indicator
                          _buildTurnIndicator(isMyTurn, state.phase),

                          const Spacer(),

                          // Cards area
                          Container(
                            key: _cardsKey,
                            child: _buildCardsArea(state),
                          ),

                          // Result display
                          if (_lastResult != null)
                            _buildResultBanner(_lastResult!),

                          const Spacer(),

                          // Betting area
                          if (isMyTurn && state.phase == 'betting')
                            Container(
                              key: _bettingKey,
                              child: _buildBettingArea(
                                state.pot,
                                myChips,
                                maxBet,
                              ),
                            ),

                          // Action buttons
                          Container(
                            key: _actionsKey,
                            child: _buildActionBar(isMyTurn, state),
                          ),
                          
                          // Bottom padding
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
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
                       Text(GameTerminology.inBetweenGame, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 4),
                       Text('Room: ${widget.roomId.substring(0, 4)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  onSettings: () => GameSettingsModal.show(context, gameName: 'In-Between'),
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
                  bottom: 140, left: 16,
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
          title: Text(
            '${GameTerminology.inBetweenGame} Rules',
            style: const TextStyle(color: CasinoColors.gold),
          ),
          content: const Text(
            '1. Place a bet based on the probability.\n'
            '2. A "Low" and "High" card are dealt.\n'
            '3. A third "Middle" card is dealt.\n'
            '4. WIN if the Middle card is literally in-between.\n'
            '5. LOSE if outside the range.\n'
            '6. POST (Hit the Post): If Middle card matches High or Low, you lose 2x the bet!',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Got it'))],
        ),
      );
  }

  Widget _buildChipsBadge(int chips) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/chips/chip_blue.png',
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$chips',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPotBadge(int pot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: CasinoColors.gold.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CasinoColors.gold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/chips/chip_red.png',
            width: 18,
            height: 18,
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

  Widget _buildOpponentsArea(InBetweenGameState state, String myId) {
    // Other players
    final opponents = state.playerChips.keys.where((id) => id != myId).toList();
    if (opponents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: OpponentRow(
        opponents: opponents.map((pid) {
          final chips = state.playerChips[pid] ?? 0;
          final isCurrent = state.currentPlayerId == pid;
          final isBot = pid.startsWith('bot_');

          return GameOpponent(
            id: pid,
            name: isBot ? 'Bot ${pid.split('_').last}' : 'Player',
            isBot: isBot,
            isCurrentTurn: isCurrent,
            score: chips, // Use chips as "score" display
            status: isCurrent ? 'Thinking' : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTurnIndicator(bool isMyTurn, String phase) {
    String message;
    Color color;

    if (phase == 'result') {
      message = 'Waiting for next turn...';
      color = Colors.orange;
    } else if (isMyTurn) {
      message = phase == 'betting'
          ? '🎲 Your Turn - Place a Bet!'
          : '🎯 Reveal the Card!';
      color = Colors.green;
    } else {
      message = '⏳ Waiting for opponent...';
      color = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border(bottom: BorderSide(color: color)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (isMyTurn) ...[
            const SizedBox(width: 12),
            const TurnTimerBadge(remainingSeconds: 30, totalSeconds: 30),
          ],
        ],
      ),
    );
  }

  /// Build the game mode banner showing AI/Multiplayer status
  Widget _buildGameModeBanner(InBetweenGameState state) {
    final allPlayers = state.playerChips.keys.toList();
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

  Widget _buildCardsArea(InBetweenGameState state) {
    final lowCard = _getCard(state.lowCardId);
    final highCard = _getCard(state.highCardId);
    final middleCard = state.middleCardId != null
        ? _getCard(state.middleCardId!)
        : null;

    // Calculate probability
    double probability = 0;
    if (lowCard != null && highCard != null) {
      final lowValue = _cardValue(lowCard);
      final highValue = _cardValue(highCard);
      final winningCards = highValue - lowValue - 1;
      probability = winningCards > 0 ? (winningCards / 14) : 0;
    }

    return Column(
      children: [
        // Probability indicator
        if (state.phase == 'betting')
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _probabilityColor(probability).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(probability * 100).toStringAsFixed(0)}% chance',
              style: TextStyle(
                color: _probabilityColor(probability),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

        // Cards row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Low card
            if (lowCard != null) _buildCardWidget(lowCard, 'LOW'),

            const SizedBox(width: 16),

            // Middle card (or placeholder)
            middleCard != null
                ? _buildCardWidget(middleCard, 'MIDDLE', isMiddle: true)
                : _buildCardBack(),

            const SizedBox(width: 16),

            // High card
            if (highCard != null) _buildCardWidget(highCard, 'HIGH'),
          ],
        ),
      ],
    );
  }

  Color _probabilityColor(double p) {
    if (p >= 0.5) return Colors.green;
    if (p >= 0.3) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCardWidget(Card card, String label, {bool isMiddle = false}) {
    // Convert core Card to PlayingCard for shared widget
    final playingCard = PlayingCard(
      suit: CardSuit.values.firstWhere((s) => s.name == card.suit.name.toLowerCase()),
      rank: CardRank.values.firstWhere((r) => r.symbol == card.rank.symbol),
    );
    
    final cardWidth = isMiddle ? 120.0 : 100.0;
    final cardHeight = isMiddle ? 175.0 : 145.0;
    
    return Column(
      children: [
        CardWithPreview(
          card: playingCard,
          child: CardWidget(
            card: playingCard,
            isFaceUp: true,
            width: cardWidth,
            height: cardHeight,
            glowColor: isMiddle
                ? CasinoColors.gold.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.3),
          ),
        ).animate().fadeIn().scale(),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack() {
    return Column(
      children: [
        Container(
              width: 120,
              height: 175,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [CasinoColors.richPurple, CasinoColors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CasinoColors.gold.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: CasinoColors.gold.withValues(alpha: 0.6),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 1.5.seconds),
        const SizedBox(height: 8),
        Text(
          'MIDDLE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildResultBanner(String result) {
    Color color;
    String text;
    IconData icon;

    switch (result) {
      case 'win':
        color = Colors.green;
        text = '🎉 WIN! +$_betAmount';
        icon = Icons.celebration;
        break;
      case 'lose':
        color = Colors.red;
        text = '😢 LOSE -$_betAmount';
        icon = Icons.sentiment_dissatisfied;
        break;
      case 'post':
        color = Colors.orange;
        text = '💥 POST! -${_betAmount * 2}';
        icon = Icons.warning;
        break;
      default:
        return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildBettingArea(int pot, int chips, int maxBet) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Bet Amount: $_betAmount',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _betAmount.toDouble(),
            min: 0,
            max: maxBet.toDouble(),
            divisions: maxBet > 0 ? maxBet : 1,
            activeColor: CasinoColors.gold,
            onChanged: (value) {
              setState(() => _betAmount = value.round());
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickBetButton('Min', 0),
              _buildQuickBetButton('25%', (maxBet * 0.25).round()),
              _buildQuickBetButton('50%', (maxBet * 0.5).round()),
              _buildQuickBetButton('Max', maxBet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBetButton(String label, int amount) {
    return ElevatedButton(
      onPressed: () => setState(() => _betAmount = amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: CasinoColors.cardBackground,
        foregroundColor: CasinoColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Widget _buildActionBar(bool isMyTurn, InBetweenGameState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (state.phase == 'betting' && isMyTurn) ...[
            // Pass button
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _pass,
              icon: const Icon(Icons.skip_next),
              label: const Text('Pass'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
            ),

            // Bet button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _placeBet,
              icon: const Icon(Icons.attach_money),
              label: Text('Bet $_betAmount'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ] else if (state.phase == 'revealing' && isMyTurn) ...[
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _reveal,
              icon: const Icon(Icons.visibility),
              label: const Text('Reveal Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ] else if (state.phase == 'result' && isMyTurn) ...[
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _nextTurn,
              icon: const Icon(Icons.skip_next),
              label: const Text('Next Turn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ] else ...[
            Text(
              'Waiting...',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pass() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Play pass sound
      await SoundService.playCardSlide();

      final service = ref.read(inBetweenServiceProvider);
      await service.pass(widget.roomId);
      setState(() {
        _lastResult = null;
        _betAmount = 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _placeBet() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Play bet sound
      await SoundService.playChipSound();

      final service = ref.read(inBetweenServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        await service.placeBet(widget.roomId, userId, _betAmount);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _reveal() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Play reveal sound
      await SoundService.playCardSlide();

      final service = ref.read(inBetweenServiceProvider);
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId != null) {
        final result = await service.reveal(widget.roomId, userId);
        setState(() => _lastResult = result);

        // Play result sound
        if (result == 'win') {
          await SoundService.playRoundEnd();
        } else if (result == 'post') {
          // TODO: Add specific sound for hitting post if available
          await SoundService.playTrickWon();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _nextTurn() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final service = ref.read(inBetweenServiceProvider);
      await service.nextTurn(widget.roomId);
      setState(() {
        _lastResult = null;
        _betAmount = 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Helper method removed - using SoundService directly
}

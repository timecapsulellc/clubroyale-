/// Royal Meld (Marriage) Practice Screen
///
/// UI for playing Royal Meld card game
/// Uses GameTerminology for multi-region localization
library;

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/theme/app_theme.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/games/base_game.dart';
import 'package:clubroyale/core/card_engine/meld.dart' as meld_engine;
import 'package:clubroyale/core/card_engine/pile.dart'; // For Card class
import 'package:clubroyale/games/marriage/marriage_game.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';
import 'package:clubroyale/features/game/ui/components/game_log_overlay.dart';
import 'package:clubroyale/features/game/ui/components/casino_button.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/features/ai/ai_service.dart';
import 'package:clubroyale/games/marriage/widgets/visit_button_widget.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_table_layout.dart';
import 'package:clubroyale/games/marriage/widgets/game_timer_widget.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_hud_overlay.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/features/game/ui/screens/game_settlement_dialog.dart';
import 'package:clubroyale/games/marriage/marriage_visit_validator.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/core/design_system/game/flying_card_animation.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/marriage/marriage_scorer.dart';
import 'package:clubroyale/core/widgets/game_mode_banner.dart';
import 'package:clubroyale/core/widgets/game_opponent_widget.dart';
import 'dart:async';

import 'package:clubroyale/core/widgets/tutorial_overlay.dart'; // Import TutorialOverlay
import 'package:clubroyale/games/marriage/screens/marriage_guidebook_screen.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_hand_widget.dart';

// ... (existing imports)

class MarriageGameScreen extends ConsumerStatefulWidget {
  const MarriageGameScreen({super.key});

  @override
  ConsumerState<MarriageGameScreen> createState() => _MarriageGameScreenState();
}

class _MarriageGameScreenState extends ConsumerState<MarriageGameScreen> {
  // ... (existing vars)

  // Tutorial Keys
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _deckKey =
      GlobalKey(); // Renamed from centerDeckKey to avoid confusion
  final GlobalKey _handKey = GlobalKey(); // Renamed from myHandKey
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _visitKey = GlobalKey();

  bool _showTutorial = true; // Auto-show for demo

  List<TutorialStep> get _tutorialSteps => [
    TutorialStep(
      title: 'Welcome to Marriage! 👑',
      description:
          'The goal is to arrange your 21 cards into Sets (AAA) and Sequences (678).',
      targetKey: null, // Center modal
    ),
    TutorialStep(
      title: 'Your Hand',
      description: 'Your cards are here. Drag to rearrange or tap to select.',
      targetKey: _handKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'Draw & Discard',
      description:
          'Tap the Deck to draw a card, or pick from the Discard pile if you have a pair.',
      targetKey: _deckKey,
      tooltipAlignment: Alignment.bottomCenter,
    ),
    TutorialStep(
      title: 'Sort Your Cards',
      description: 'Use Sort to automatically group cards by Suit or Rank.',
      targetKey: _sortKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'Visit / Maal',
      description:
          'Once you have 3 Pure Sequences, tap here to "Visit" and unlock Bonus Points (Maal).',
      targetKey: _visitKey,
      tooltipAlignment: Alignment.topCenter,
    ),
    TutorialStep(
      title: 'Guidebook',
      description: 'Check the detailed rules anytime here.',
      targetKey: _menuKey,
      tooltipAlignment: Alignment.bottomLeft,
    ),
  ];

  // Core game state
  late MarriageGame _game;
  final String _playerId = 'player_1';
  final List<String> _botIds = List.generate(5, (i) => 'bot_${i + 1}');
  String? _selectedCardId;
  bool _isProcessing = false;

  // Visit related state
  final MarriageGameConfig _config = MarriageGameConfig.nepaliStandard;
  bool _hasVisited = false;
  VisitButtonState _visitStatus = VisitButtonState.locked;
  String _visitLabel = 'VISIT';
  String _visitSubLabel = 'Need 3 Pure Sequences';

  // Maal state
  int _maalPoints = 0;
  bool _hasMarriageBonus = false;

  // Animations
  final List<Widget> _animations = [];

  // Timer state
  Timer? _turnTimer;
  int _remainingSeconds = 30;

  // Sound state
  bool _isSoundMuted = false;

  // Game log for real-time events
  final List<String> _gameLogs = [];

  // Meld caching for performance
  List<meld_engine.Meld> _cachedMelds = [];
  String? _lastHandHash; // Track hand changes

  // Animation state
  bool _isAnimating = false; // Pause timer during animations

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _config.turnTimeoutSeconds;
    _initGame();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _initGame() {
    _game = MarriageGame();
    _game.initialize(<String>[_playerId, ..._botIds]);
    _game.startRound();

    // Play shuffle sound on deal
    SoundService.playShuffleSound();

    // Check if bots need to play (if user doesn't start)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitStatus();
      _playBotTurns();
      _playDealAnimation();
    });

    // Start timer if it's my turn
    if (_game.currentPlayerId == _playerId) {
      _startTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    setState(() => _remainingSeconds = _config.turnTimeoutSeconds);

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_showTutorial || _isAnimating)
        return; // Pause timer during tutorial and animations
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Timeout! Auto-play
          _stopTimer();
          _handleTimeout();
        }
      });
    });
  }

  void _stopTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
  }

  void _handleTimeout() {
    // Basic auto-play logic: Draw if needed, Discard random
    if (_game.currentPlayerId != _playerId) return;

    final hand = _game.getHand(_playerId);

    // 1. Draw phase if needed
    if (hand.length == 21) {
      _game.drawFromDeck(_playerId);
    }

    // 2. Discard phase
    // Re-fetch hand
    final newHand = _game.getHand(_playerId);
    // Discard the last card (usually the one just picked or right-most)
    final cardToDiscard = newHand.last;

    _game.playCard(_playerId, cardToDiscard);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Turn Timeout! Auto-played.'),
        backgroundColor: Colors.orange,
      ),
    );

    // Proceed
    _playBotTurns();
  }

  void _updateMaalState() {
    if (_game.tiplu == null) return;

    final hand = _game.getHand(_playerId);
    final calculator = MarriageMaalCalculator(
      tiplu: _game.tiplu!,
      config: _config,
    );

    setState(() {
      _maalPoints = calculator.calculateMaalPoints(hand);
      // Simple check for marriage bonus potential (not exact meld check, but close enough for indicator)
      // Actual bonus mostly comes from melds, but let's check generic "Marriage" card presence
      // For now, let's just use total points > 10 as a trigger for "high value" styling
      _hasMarriageBonus = _maalPoints >= 10;
    });
  }

  void _checkVisitStatus() {
    _updateMaalState(); // Also update Maal when checking visit status
    if (_hasVisited) {
      setState(() {
        _visitStatus = VisitButtonState.visited;
      });
      return;
    }

    final hand = _game.getHand(_playerId);
    final validator = MarriageVisitValidator(
      config: _config,
      tiplu: _game.tiplu,
    );

    // Check purely for availability to update button state
    // We try 'attemptVisit' to see if ANY method works
    final result = validator.attemptVisit(hand);

    setState(() {
      if (result.canVisit) {
        _visitStatus = VisitButtonState.ready;
        _visitLabel = result.visitType == VisitType.tunnel
            ? 'TUNNEL WIN'
            : 'VISIT';
        _visitSubLabel = result.visitType == VisitType.dublee
            ? '7 Dublees Ready'
            : 'Sequences Ready';
      } else {
        _visitStatus = VisitButtonState.locked;
        // Provide hint based on what they are closest to or default
        // For simple logic, just show default requirement
        _visitSubLabel = 'Need ${_config.sequencesRequiredToVisit} Pure Seq';
      }
    });
  }

  void _handleVisit() {
    final hand = _game.getHand(_playerId);
    final validator = MarriageVisitValidator(
      config: _config,
      tiplu: _game.tiplu,
    );
    final result = validator.attemptVisit(hand);

    if (result.canVisit) {
      setState(() {
        _hasVisited = true;
        _visitStatus = VisitButtonState.visited;

        // If tunnel win (instant win), handle it
        if (result.visitType == VisitType.tunnel) {
          _showWinDialog(winnerName: 'You (Tunnel Win!)');
        }
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Visited Successfully! Maal Unlocked.'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot visit yet: ${result.reason}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _playDealAnimation() {
    // Set animation flag to pause timer
    setState(() => _isAnimating = true);

    // Determine positions
    // Ideally we use RenderBox from keys, but for simplicity let's use screen logic
    // Center of screen (Deck)
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2 - 50);

    // My Hand (Bottom Center)
    final myHandPos = Offset(size.width / 2 - 50, size.height - 150);

    // Create animation for "My" cards
    // 21 cards is too many to animate individually, let's animate a few batches
    int cardsToAnimate = 5;

    for (int i = 0; i < cardsToAnimate; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!mounted) return;

        setState(() {
          _animations.add(
            FlyingCardAnimation(
              card: _game.getHand(_playerId).isNotEmpty
                  ? _game.getHand(_playerId).first
                  : PlayingCard(
                      suit: Suit.spades,
                      rank: Rank.ace,
                    ), // Dummy card if empty
              startOffset: center,
              endOffset: myHandPos,
              startScale: 0.5,
              endScale: 0.8,
              duration: const Duration(milliseconds: 600),
              onComplete: () {
                if (mounted) {
                  setState(() {
                    if (_animations.isNotEmpty)
                      _animations.removeAt(0); // Cleanup older
                  });
                }
              },
            ),
          );

          SoundService.playCardSlide();
        });
      });
    }

    // End animation after all cards dealt
    Future.delayed(Duration(milliseconds: cardsToAnimate * 150 + 700), () {
      if (mounted) {
        setState(() => _isAnimating = false);
      }
    });
  }

  void _showWinDialog({required String winnerName}) {
    // Calculate actual scores using game scorer
    final winnerId = winnerName.contains('You') ? _playerId : '_bot_1';
    final hands = <String, List<PlayingCard>>{};
    final melds = <String, List<meld_engine.Meld>>{};

    // Get hands for all players
    for (final id in [_playerId, '_bot_1', '_bot_2', '_bot_3']) {
      hands[id] = _game.getHand(id);
      melds[id] = _game.findMelds(id);
    }

    final scorer = MarriageScorer(tiplu: _game.tiplu, config: _game.config);
    final settlement = scorer.calculateFinalSettlement(
      hands: hands,
      melds: melds,
      winnerId: winnerId,
    );

    // Convert to display names
    final displayScores = <String, int>{
      'You': settlement[_playerId] ?? 0,
      'Bot 1': settlement['_bot_1'] ?? 0,
      'Bot 2': settlement['_bot_2'] ?? 0,
      'Bot 3': settlement['_bot_3'] ?? 0,
    };

    // Winner amount is their net score
    final winAmount = (settlement[winnerId] ?? 0).abs();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameSettlementDialog(
        winnerName: winnerName,
        winAmount: winAmount,
        isWinner: winnerName.contains('You'),
        scores: displayScores,
        onNextRound: () {
          Navigator.pop(context);
          setState(() => _initGame());
        },
        onExit: () {
          Navigator.pop(context);
          Navigator.pop(context); // Exit screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myHand = _game.getHand(_playerId);

    // Meld caching: only recalculate when hand changes
    final handHash = myHand.map((c) => c.id).join(',');
    if (handHash != _lastHandHash) {
      _cachedMelds = _game.findMelds(_playerId);
      _lastHandHash = handHash;
    }
    final melds = _cachedMelds;

    return Scaffold(
      backgroundColor: AppTheme.tableGreen,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use GameTerminology for game name
            Text(
              GameTerminology.royalMeldGame,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Card back pattern
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.teal, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.style,
                        color: AppTheme.gold.withValues(alpha: 0.5),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Wild Card indicator (Tiplu)
          if (_game.tiplu != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${GameTerminology.wildCard}: ',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _game.tiplu!.displayString,
                    style: TextStyle(
                      color: _game.tiplu!.suit.isRed
                          ? Colors.red
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _initGame());
            },
            tooltip: 'New Game',
          ),
          // Status Indicator (Simplified - Maal now in HUD)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  _hasVisited ? Icons.lock_open : Icons.lock,
                  color: _hasVisited ? Colors.greenAccent : Colors.white24,
                ),
              ],
            ),
          ),
        ],
      ),
      body: TableLayout(
        child: SafeArea(
          child: Stack(
            children: [
              // Header (Menu, Sound, Info)
              Positioned(
                top: 8,
                left: 16,
                child: Row(
                  children: [
                    _buildHeaderButton(Icons.menu, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MarriageGuidebookScreen(),
                        ),
                      );
                    }, key: _menuKey),
                    const SizedBox(width: 8),
                    _buildHeaderButton(
                      _isSoundMuted ? Icons.volume_off : Icons.volume_up,
                      () {
                        setState(() {
                          _isSoundMuted = !_isSoundMuted;
                          SoundService.setMuted(_isSoundMuted);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    // Timer if my turn
                    if (_game.currentPlayerId == _playerId)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GameTimerWidget(
                          totalSeconds: _config.turnTimeoutSeconds,
                          remainingSeconds: _remainingSeconds,
                        ),
                      ),
                  ],
                ),
              ),

              // Game Logs (Left Side)
              Positioned(
                top: 80,
                left: 16,
                child: GameLogOverlay(
                  logs: _gameLogs.isEmpty
                      ? const ['Game started...']
                      : _gameLogs.take(5).toList(), // Show last 5 logs
                ),
              ),

              // New Elliptical Layout for 8 Players
              Padding(
                padding: const EdgeInsets.only(
                  top: 80,
                ), // Increased top padding to avoid header overlap
                child: MarriageTableLayout(
                  centerArea: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ), // Push deck up slightly from hand
                    child: _buildCenterArea(),
                  ),
                  opponents: _buildOpponentsList(),
                  myHand: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Meld suggestions
                      if (melds.isNotEmpty) _buildMeldSuggestions(melds),
                      const SizedBox(
                        height: 10,
                      ), // Spacing between suggestions and hand
                      // Hand
                      _buildMyHand(myHand),
                      // Actions
                      _buildActionBar(),
                    ],
                  ),
                ),
              ),

              // Polished HUD Overlay (Turn Indicator, Maal, Emotes)
              MarriageHUDOverlay(
                currentPlayerId: _game.currentPlayerId,
                myPlayerId: _playerId,
                maalPoints: _maalPoints,
                onEmoteTap: () => _showEmotePicker(),
              ),

              // Game Mode Banner
              const Positioned(
                top: 50,
                right: 16,
                child: GameModeBanner(
                  botCount: 3, // Update dynamically if needed
                  humanCount: 1,
                  compact: true,
                ),
              ),

              // Flying Card Animations
              ..._animations,

              // Interactive Tutorial Overlay
              if (_showTutorial)
                TutorialOverlay(
                  steps: _tutorialSteps,
                  onComplete: () => setState(() => _showTutorial = false),
                  onSkip: () => setState(() => _showTutorial = false),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onPressed, {Key? key}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.gold, width: 1.5),
      ),
      child: IconButton(
        key: key,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  List<Widget> _buildOpponentsList() {
    return _botIds.map((botId) {
      final isCurrentTurn = _game.currentPlayerId == botId;
      return GameOpponentWidget(
        // Use widget directly, not OpponentRow
        opponent: GameOpponent(
          id: botId,
          name: _getBotName(botId),
          isBot: true,
          isCurrentTurn: isCurrentTurn,
          status: isCurrentTurn ? 'Thinking...' : null,
        ),
        size: 50, // Slightly smaller for 8 players
      );
    }).toList();
  }

  Widget _buildCenterArea() {
    final topDiscard = _game.topDiscard;
    final isMyTurn = _game.currentPlayerId == _playerId;
    // Discard Pickup Rule: Check config and visit status
    final bool visitRequirementMet =
        !_config.mustVisitToPickDiscard || _hasVisited;

    // Check for blocking cards (Joker/Wild)
    bool isDiscardBlocked = false;
    if (topDiscard != null) {
      // Check if joker blocks discard
      if (_config.jokerBlocksDiscard &&
          (topDiscard.isJoker ||
              (!topDiscard.isJoker &&
                  _game.tiplu != null &&
                  topDiscard.rank == _game.tiplu!.rank &&
                  topDiscard.suit == _game.tiplu!.suit &&
                  !_config.canPickupWildFromDiscard))) {
        // Using simplified logic here:
        // 1. Printed Joker always blocks if enabled
        if (topDiscard.isJoker) isDiscardBlocked = true;

        // 2. Wild Cards block if cannot pickup wild
        if (!_config.canPickupWildFromDiscard && _isWildCard(topDiscard)) {
          isDiscardBlocked = true;
        }
      }
    }

    final canDrawFromDiscard =
        isMyTurn &&
        topDiscard != null &&
        _game.getHand(_playerId).length == 21 &&
        visitRequirementMet &&
        !isDiscardBlocked;
    final canDrawFromDeck = isMyTurn && _game.getHand(_playerId).length == 21;

    return Center(
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Deck
            GestureDetector(
              onTap: canDrawFromDeck ? _drawFromDeck : null,
              child: Container(
                key: _deckKey,
                child: CardWidget(
                  card: PlayingCard(rank: CardRank.ace, suit: CardSuit.spades),
                  isFaceUp: false,
                  isSelectable: canDrawFromDeck,
                  isSelected: false,
                  width: 90,
                  height: 130,
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Discard Pile
            GestureDetector(
              onTap: canDrawFromDiscard ? _drawFromDiscard : null,
              child: Stack(
                children: [
                  CardWidget(
                    card:
                        topDiscard ??
                        PlayingCard(
                          rank: CardRank.ace,
                          suit: CardSuit.spades,
                        ), // Show back styled dummy if no discard
                    isFaceUp: topDiscard != null,
                    isSelectable: canDrawFromDiscard,
                    isSelected: false,
                    width: 90,
                    height: 130,
                  ),
                  // Lock Overlay (if visit needed)
                  if (topDiscard != null && !visitRequirementMet && isMyTurn)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Icon(Icons.lock, color: Colors.white70),
                        ),
                      ),
                    ),
                  // Lock Overlay (if blocked by Joker/Wild)
                  if (topDiscard != null && isDiscardBlocked && isMyTurn)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(
                            alpha: 0.3,
                          ), // Red tint for blocked action
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Icon(Icons.block, color: Colors.white70),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeldSuggestions(List<meld_engine.Meld> melds) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.black.withValues(alpha: 0.4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: melds.map((meld) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getMeldColor(meld.type).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getMeldColor(meld.type)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getMeldTypeName(meld.type),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      children: meld.cards
                          .map(
                            (card) => CardWidget(
                              card: card,
                              isFaceUp: true,
                              width: 30,
                              height: 45,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMyHand(List<PlayingCard> hand) {
    return MarriageHandWidget(
      key: _handKey,
      cards: hand,
      selectedCardId: _selectedCardId,
      onCardSelected: (id) {
        setState(() {
          // Toggle selection
          if (_selectedCardId == id) {
            _selectedCardId = null;
          } else {
            _selectedCardId = id;
          }
        });
      },
      tiplu: _game.tiplu,
      config: _config,
    );
  }

  Widget _buildActionBar() {
    final isMyTurn = _game.currentPlayerId == _playerId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Discard button
            CasinoButton(
              label: 'Discard',
              onPressed: isMyTurn && _selectedCardId != null
                  ? _discardCard
                  : null,
              backgroundColor: AppTheme.gold,
              borderColor: AppTheme.goldDark,
            ),

            // Visit Button (New)
            VisitButtonWidget(
              key: _visitKey,
              state: _visitStatus,
              onPressed: (_visitStatus == VisitButtonState.ready)
                  ? _handleVisit
                  : null,
              label: _visitLabel,
              subLabel: _visitSubLabel,
            ),

            // Declare button (Go Royale in global mode)
            CasinoButton(
              label: GameTerminology.declare,
              onPressed: isMyTurn ? _tryDeclare : null,
              backgroundColor: Colors.green,
              borderColor: Colors.lightGreen,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  void _drawFromDeck() {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _game.drawFromDeck(_playerId);
      _addGameLog('You drew from deck');
      _checkVisitStatus(); // Update visit status after drawing
      _isProcessing = false;
    });
  }

  void _drawFromDiscard() {
    if (_isProcessing || _game.topDiscard == null) return;
    final cardPicked = _game.topDiscard!;
    setState(() {
      _isProcessing = true;
      _game.drawFromDiscard(_playerId);
      _addGameLog('You picked ${cardPicked.displayString} from discard');
      _checkVisitStatus(); // Update visit status after drawing
      _isProcessing = false;
    });
  }

  void _discardCard() {
    if (_selectedCardId == null) return;

    final hand = _game.getHand(_playerId);
    final card = hand.firstWhere((c) => c.id == _selectedCardId);

    setState(() {
      _game.playCard(_playerId, card);
      _addGameLog('You discarded ${card.displayString}');
      _selectedCardId = null;
      _stopTimer(); // specific stop timer for human turn end

      // Bot turns
      _playBotTurns();
    });
  }

  // Helper to convert PlayingCard to AI-friendly string (e.g., "AS", "10H")
  String _toAiString(PlayingCard card) {
    if (card.isJoker) return 'Joker';
    return '${card.rank.symbol}${card.suit.name[0].toUpperCase()}';
  }

  // Helper: Check if card is Wild
  bool _isWildCard(PlayingCard card) {
    if (_game.tiplu == null) return false;
    final tiplu = _game.tiplu!;

    // 1. Exact Tiplu
    if (card.rank == tiplu.rank && card.suit == tiplu.suit) return true;

    // 2. Jhiplu / Poplu logic matches MarriageMaalCalculator
    // Simplified: Jhiplu is same rank, opposite color. Poplu is next rank, same suit.
    // For blocking purposes, usually "Maal" in discard is what we care about.
    // Let's use the calculator if possible or simple logic.
    // Replicating basic Maal check:

    // Jhiplu
    if (card.rank == tiplu.rank) return true;

    // Poplu
    if (card.suit == tiplu.suit) {
      final tipluVal = tiplu.rank.value == 1
          ? 14
          : tiplu.rank.value; // Ace high handled in rank?
      // Actually standard rank use:
      // Poplu is +1 rank.
      int tipluV = tiplu.rank.value;
      int cardV = card.rank.value;
      // Adjust for Ace
      if (tipluV == 1) tipluV = 14;
      if (cardV == 1) cardV = 14;

      if (cardV == tipluV + 1) return true;
      if (tipluV == 13 && cardV == 1) return true; // K -> A
    }

    return false;
  }

  Future<void> _playBotTurns() async {
    // Check if it's a bot's turn
    if (!_botIds.contains(_game.currentPlayerId)) return;

    final botId = _game.currentPlayerId!;
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    try {
      final aiService = ref.read(aiServiceProvider);
      final difficulty = 'medium';

      final currentHand = _game.getHand(botId);
      // Serialize hand to "AS", "10H", etc.
      final handStrings = currentHand.map(_toAiString).toList();

      final gameState = {
        'phase': _game.currentPhase == GamePhase.playing
            ? 'drawing'
            : 'discarding',
        'tiplu': _game.tiplu != null ? _toAiString(_game.tiplu!) : null,
        'topDiscard': _game.topDiscard != null
            ? _toAiString(_game.topDiscard!)
            : null,
        'cardsInDeck': _game.cardsRemaining,
        'roundNumber': _game.currentRound,
      };

      // Determine phase logic (same as before)
      final isDrawing = currentHand.length == 21;
      gameState['phase'] = isDrawing ? 'drawing' : 'discarding';

      final decision = await aiService.getMarriageBotPlay(
        difficulty: difficulty,
        hand: handStrings,
        gameState: gameState,
      );

      if (!mounted) return;

      setState(() {
        if (isDrawing) {
          if (decision.action == 'drawDiscard' && _game.topDiscard != null) {
            final pickedCard = _game.topDiscard!;
            _game.drawFromDiscard(botId);
            _addGameLog(
              '${_getBotName(botId)} picked ${pickedCard.displayString}',
            );
          } else {
            _game.drawFromDeck(botId);
            _addGameLog('${_getBotName(botId)} drew from deck');
          }
          // Recursively call for discard phase
          WidgetsBinding.instance.addPostFrameCallback((_) => _playBotTurns());
          return;
        } else {
          // Discarding
          if (decision.action == 'discard') {
            // Find matching card in hand
            // AI returns "AS", we look for any card that maps to "AS"
            final cardToDiscard = currentHand.firstWhere(
              (c) => _toAiString(c) == decision.card,
              orElse: () => currentHand.last, // Fallback
            );
            _game.playCard(botId, cardToDiscard);
            _addGameLog(
              '${_getBotName(botId)} discarded ${cardToDiscard.displayString}',
            );
          } else if (decision.action == 'declare') {
            _tryBotDeclare(botId);
          }

          // Trigger next turn logic
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _playBotTurns(); // Checks if next player is bot

            // If next player is ME, start my timer and check visits
            if (_game.currentPlayerId == _playerId) {
              _startTimer();
              _checkVisitStatus();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('AI Error: $e');
      setState(() {
        // Smart fallback logic - don't discard valuable cards
        final hand = _game.getHand(botId);

        if (hand.length == 21) {
          _game.drawFromDeck(botId);
          _addGameLog('${_getBotName(botId)} drew from deck');
        } else {
          // Find safest card to discard (not wild, not part of sequence)
          final cardToDiscard = _findSafeDiscard(hand);
          _game.playCard(botId, cardToDiscard);
          _addGameLog(
            '${_getBotName(botId)} discarded ${cardToDiscard.displayString}',
          );
        }
      });
    }
  }

  /// Find the safest card to discard (not wild, not valuable)
  PlayingCard _findSafeDiscard(List<PlayingCard> hand) {
    // Priority: avoid discarding wild cards, jokers, and potential meld cards

    // Filter out wild cards and jokers
    final nonWild = hand.where((c) => !_isWildCard(c) && !c.isJoker).toList();
    if (nonWild.isEmpty) return hand.last;

    // Find isolated cards (not part of potential runs or sets)
    for (final card in nonWild) {
      // Check if card is isolated (no cards nearby in same suit)
      final sameSuit = nonWild.where((c) => c.suit == card.suit).toList();
      bool hasNeighbor = sameSuit.any(
        (c) => (c.rank.value - card.rank.value).abs() == 1,
      );

      // Check if part of set
      final sameRank = nonWild.where((c) => c.rank == card.rank).length;

      // Isolated card: no neighbors and less than 2 same rank
      if (!hasNeighbor && sameRank < 2) {
        return card;
      }
    }

    // If no isolated card found, return lowest value non-wild
    nonWild.sort((a, b) => a.rank.value.compareTo(b.rank.value));
    return nonWild.first;
  }

  /// Add a log entry
  void _addGameLog(String message) {
    setState(() {
      _gameLogs.insert(0, message); // Add at beginning
      if (_gameLogs.length > 20) {
        _gameLogs.removeLast(); // Keep max 20 logs
      }
    });
  }

  /// Show emote picker for social gameplay
  void _showEmotePicker() {
    const emotes = [
      {'emoji': '👍', 'label': 'Good Play'},
      {'emoji': '🔥', 'label': 'On Fire'},
      {'emoji': '😂', 'label': 'LOL'},
      {'emoji': '😮', 'label': 'Wow'},
      {'emoji': '🥳', 'label': 'Celebrate'},
      {'emoji': '😎', 'label': 'Cool'},
      {'emoji': '🤔', 'label': 'Thinking'},
      {'emoji': '😤', 'label': 'Frustrated'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send Emote',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: emotes
                  .map(
                    (emote) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _sendEmote(emote['emoji']!, emote['label']!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              emote['emoji']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              emote['label']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Send an emote and show feedback
  void _sendEmote(String emoji, String label) {
    _addGameLog('You: $emoji');

    // Show floating emote animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _tryBotDeclare(String botId) {
    if (_game.declare(botId)) {
      _showWinDialog(winnerName: _getBotName(botId));
    } else {
      // Failed to declare, discard something
      final hand = _game.getHand(botId);
      _game.playCard(botId, hand.last);
    }
  }

  void _tryDeclare() {
    final success = _game.declare(_playerId);
    if (success) {
      _showWinDialog(winnerName: 'You');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot declare yet - complete all melds first!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getBotName(String botId) {
    final index = _botIds.indexOf(botId) + 1;
    return 'Bot $index';
  }

  String _getPlayerName(String id) {
    if (id == _playerId) return 'You';
    return _getBotName(id);
  }

  Color _getMeldColor(meld_engine.MeldType type) {
    switch (type) {
      case meld_engine.MeldType.set:
        return Colors.blue;
      case meld_engine.MeldType.run:
        return Colors.green;
      case meld_engine.MeldType.tunnel:
        return Colors.orange;
      case meld_engine.MeldType.marriage:
        return Colors.pink;
      case meld_engine.MeldType.impureRun:
        return Colors.orange.shade300;
      case meld_engine.MeldType.impureSet:
        return Colors.teal;
      case meld_engine.MeldType.dublee:
        return Colors.indigo;
    }
  }

  String _getMeldTypeName(meld_engine.MeldType type) {
    // Use GameTerminology for multi-region support
    switch (type) {
      case meld_engine.MeldType.set:
        return GameTerminology.trial;
      case meld_engine.MeldType.run:
        return GameTerminology.sequence;
      case meld_engine.MeldType.tunnel:
        return GameTerminology.triple;
      case meld_engine.MeldType.marriage:
        return GameTerminology.royalSequenceShort;
      case meld_engine.MeldType.impureRun:
        return 'Impure Sequence';
      case meld_engine.MeldType.impureSet:
        return 'Impure Trial';
      case meld_engine.MeldType.dublee:
        return 'Dublee';
    }
  }
}

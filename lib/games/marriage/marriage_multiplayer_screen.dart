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
import 'package:clubroyale/games/marriage/widgets/marriage_hand_widget.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/games/marriage/services/services.dart';
import 'package:clubroyale/games/marriage/widgets/hud/right_arc_game_controller.dart';
import 'package:clubroyale/games/marriage/widgets/hud/game_actions_sidebar.dart';
import 'package:clubroyale/games/marriage/widgets/hud/game_log_overlay.dart';
import 'package:clubroyale/games/marriage/widgets/marriage_guided_tutorial.dart';
import 'package:clubroyale/core/widgets/interactive_tutorial.dart';
import 'package:clubroyale/games/marriage/widgets/professional_table_layout.dart';
import 'package:clubroyale/games/marriage/widgets/hud/player_slot_widget.dart';
import 'package:clubroyale/games/marriage/widgets/hud/center_table_area.dart';
import 'package:clubroyale/games/marriage/widgets/hud/action_indicators.dart';
import 'package:clubroyale/features/game/ui/animations/card_animations.dart';
import 'package:clubroyale/features/game/ui/animations/victory_celebration.dart';
import 'package:clubroyale/core/services/haptic_service.dart';
import 'package:clubroyale/core/widgets/reconnection_overlay.dart';
import 'package:clubroyale/core/widgets/turn_timeout_warning.dart';

/// Multiplayer Marriage game screen
class MarriageMultiplayerScreen extends ConsumerStatefulWidget {
  final String roomId;

  const MarriageMultiplayerScreen({required this.roomId, super.key});

  @override
  ConsumerState<MarriageMultiplayerScreen> createState() =>
      _MarriageMultiplayerScreenState();
}

class _MarriageMultiplayerScreenState
    extends ConsumerState<MarriageMultiplayerScreen> {
  String? _selectedCardId;
  bool _isProcessing = false;
  // REMOVED: _hasDrawn flag - now using state.turnPhase from Firestore (P0 FIX)
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  bool _showTutorial = false; // Tutorial overlay state
  bool _showHints = true; // Toggle hints
  bool _isSidebarOpen = false; // Controls GameActionsSidebar visibility
  GameHint? _currentHint; // Current active hint
  final Set<String> _highlightedCardIds = {};
  String? _previousTurnPlayerId; // Track for turn notification sound

  // Services
  late final MarriageHintService _hintService;
  InteractiveTutorialController? _guidedTutorialController;
  final CardAnimationController _cardAnimController = CardAnimationController();

  // Keys for tutorial highlighting
  final Map<String, GlobalKey> _tutorialKeys = {
    'player_hand': GlobalKey(),
    'deck_pile': GlobalKey(),
    'discard_pile': GlobalKey(),
    'tiplu_indicator': GlobalKey(),
    'visit_button': GlobalKey(),
    'finish_button': GlobalKey(),
    'hint_button': GlobalKey(),
  };

  // PlayingCard lookup cache
  final Map<String, PlayingCard> _cardCache = {};

  Stream<MarriageGameState?>? _gameStateStream;

  @override
  void initState() {
    super.initState();
    _hintService = MarriageHintService(); // Initialize hint service

    // Initialize stream once to avoid flickering on rebuilds
    _gameStateStream = ref
        .read(marriageServiceProvider)
        .watchGameState(widget.roomId);

    _buildCardCache();
    _checkFirstTimeTutorial();
    _initGuidedTutorial();

    // Play dealing animation on load (optional)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _cardAnimController.dealCards(); // Not implemented yet
    });
  }

  @override
  void didUpdateWidget(MarriageMultiplayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId) {
      setState(() {
        _gameStateStream = ref
            .read(marriageServiceProvider)
            .watchGameState(widget.roomId);
      });
    }
  }

  void _buildCardCache() {
    // Build a cache of all possible cards for quick lookup
    // Use 4 decks to include all possible cards for 6-8 player games
    final deck = Deck.forMarriage(deckCount: 4);
    for (final card in deck.cards) {
      _cardCache[card.id] = card;
    }
  }

  /// Check if first-time tutorial should be shown
  Future<void> _checkFirstTimeTutorial() async {
    final isCompleted = await MarriageTutorial.isCompleted();
    if (!isCompleted && mounted) {
      // Show tutorial after a brief delay to let the game load
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => _showTutorial = true);
        }
      });
    }
  }

  /// Initialize the guided gameplay tutorial
  void _initGuidedTutorial() {
    _guidedTutorialController = MarriageGuidedTutorial.createController(
      deckKey: _tutorialKeys['deck_pile'],
      discardKey: _tutorialKeys['discard_pile'],
      handKey: _tutorialKeys['player_hand'],
      visitButtonKey: _tutorialKeys['visit_button'],
      tipluIndicatorKey: _tutorialKeys['tiplu_indicator'],
    );
  }

  PlayingCard? _getCard(String id) => _cardCache[id];

  String _getBotName(String botId) {
    final id = botId.toLowerCase();
    if (id.contains('trickmaster')) return 'TrickMaster';
    if (id.contains('cardshark')) return 'CardShark';
    if (id.contains('luckydice')) return 'LuckyDice';
    if (id.contains('deepthink')) return 'DeepThink';
    if (id.contains('royalace')) return 'RoyalAce';
    if (id.contains('speedy')) return 'Speedy';
    if (id.contains('smart')) return 'Smart';
    return 'Bot ${botId.split('_').last}';
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return StreamBuilder<MarriageGameState?>(
      stream: _gameStateStream,
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
              child: Text(
                'Waiting for game to start...',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final myHand = state.playerHands[currentUser.uid] ?? [];
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final tiplu = state.tipluCardId.isNotEmpty
            ? _getCard(state.tipluCardId)
            : null;
        final topDiscard = state.discardPile.isNotEmpty
            ? _getCard(state.discardPile.last)
            : null;

        // Update hints based on new state
        if (_showHints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateHints(state, currentUser.uid, myHand, tiplu, topDiscard);
          });
        }

        // Play "Your Turn" notification sound when turn changes to this player
        if (isMyTurn && _previousTurnPlayerId != currentUser.uid) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SoundService.playYourTurn();
            HapticService.turnNotification();
          });
        }
        _previousTurnPlayerId = state.currentPlayerId;

        final screenSize = MediaQuery.of(context).size;
        final isLandscapeMobile =
            screenSize.width > screenSize.height && screenSize.height < 500;

        return Stack(
          children: [
            Scaffold(
              body: TutorialOverlay(
                showTutorial: _showTutorial,
                onComplete: () => setState(() => _showTutorial = false),
                elementKeys: _tutorialKeys,
                child: TableLayout(
                  child: Stack(
                    children: [
                      // 1. Content Layer (Particles + Game Board)
                      ParticleBackground(
                        primaryColor: CasinoColors.gold,
                        secondaryColor: CasinoColors.tableGreenMid,
                        particleCount: 15,
                        hasBackground: false,
                        child: Stack(
                          children: [
                            // ... existing children
                            // Main Game Layer
                            // Main Game Layer
                            // Main Game Layer
                            ProfessionalTableLayout(
                              centerArea: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Banner moved to Stack
                                  // Only show phase indicator if enough space
                                  if (isMyTurn && !isLandscapeMobile)
                                    _buildPhaseIndicator(state),
                                  _buildProfessionalCenterArea(
                                    state,
                                    topDiscard,
                                    isMyTurn,
                                  ),
                                ],
                              ),
                              opponents: _buildProfessionalOpponents(
                                state,
                                currentUser.uid,
                              ),

                              myHand: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(
                                        0xFF1A1A2E,
                                      ).withValues(alpha: 0.95),
                                      const Color(0xFF0F0F1A),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: CasinoColors.gold.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  top: isLandscapeMobile ? 4 : 12,
                                  left: 8,
                                  right: 8,
                                  bottom: isLandscapeMobile ? 0 : 8,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /* _buildMeldSuggestions - Moved elsewhere or removed */
                                    _buildCompactStatusBar(
                                      state,
                                      currentUser.uid,
                                    ),
                                    MarriageHandWidget(
                                      key: _tutorialKeys['player_hand'],
                                      handCards:
                                          state.playerHands[currentUser.uid] ?? [],
                                      selectedCardId: _selectedCardId,
                                      highlightedCardIds: _highlightedCardIds,
                                      onCardTap: _onCardTap,
                                      onCardDoubleTap: _discardCard,
                                      isMyTurn: isMyTurn,
                                      scale: isLandscapeMobile ? 0.8 : 1.0,
                                      tiplu: tiplu,
                                      config: state.config,
                                    ),
                                    // Legacy action bar removed
                                  ],
                                ),
                              ),
                            ),

                            // 2. HUD Layer - Left Sidebar (Actions)
                            // Collapsible Sidebar with Backdrop
                            if (_isSidebarOpen)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isSidebarOpen = false),
                                  child: Container(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: _isSidebarOpen ? 0 : -220,
                              top: 0,
                              bottom: 0,
                              width: 220,
                              child: GameActionsSidebar(
                                onShowSequence: () {
                                  _handleShowSequence(state);
                                  setState(() => _isSidebarOpen = false);
                                },
                                onShowDublee: () {
                                  _handleShowDublee(state);
                                  setState(() => _isSidebarOpen = false);
                                },
                                onFinishGame: isMyTurn
                                    ? () {
                                        _handleShow(state);
                                        setState(() => _isSidebarOpen = false);
                                      }
                                    : null,
                                onCancelAction: () {
                                  // Handle cancel
                                  setState(() => _isSidebarOpen = false);
                                },
                                onGetTunela: () {
                                  // Handle get tunela
                                  setState(() => _isSidebarOpen = false);
                                },
                                onQuitGame: () => context.go('/lobby'),
                              ),
                            ),

                            // Menu Button (to open sidebar)
                            Positioned(
                              top: 70, // Below TopBar
                              left: 16,
                              child: SafeArea(
                                child: FloatingActionButton.small(
                                  backgroundColor: const Color(0xFF2F4F4F),
                                  foregroundColor: Colors.white,
                                  onPressed: () => setState(() => _isSidebarOpen = true),
                                  child: const Icon(Icons.menu),
                                ),
                              ),
                            ),

                            // 3. HUD Layer - Right Arc Controller
                            Positioned(
                              right: 0,
                              // Push closer to edge on mobile landscape
                              top: isLandscapeMobile ? 20 : 100,
                              bottom: isLandscapeMobile ? 20 : 50,
                              child: Center(
                                child: RightArcGameController(
                                  onShowCards: isMyTurn
                                      ? () => _handleShow(state)
                                      : null,
                                  onSequence: () => _handleShowSequence(state),
                                  onDublee: () => _handleShowDublee(state),
                                  onCancel: () {},
                                  isShowEnabled: isMyTurn && !state.isDrawingPhase,
                                  isSequenceEnabled: true,
                                  isDubleeEnabled: true,
                                  isCancelEnabled: true,
                                ),
                              ),
                            ),

                            // 4. HUD Layer - Game Log Overlay (Left - pushed down if sidebar active?? No, sidebar overlays)
                            Positioned(
                              left: 16,
                              bottom: 120, // Moved to bottom-left to avoid top clutter
                              child: GameLogOverlay(
                                logs: const [],
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

                            // Game Mode Banner (Moved from Center Area)
                            Positioned(
                              top: 60,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: isLandscapeMobile
                                    ? const SizedBox.shrink()
                                    : _buildGameModeBanner(state),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Custom Top Bar (Floating) - Hidden on Mobile Landscape
                      if (!isLandscapeMobile)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Consumer(
                          builder: (context, ref, child) {
                            final diamondService = ref.watch(
                              diamondServiceProvider,
                            );
                            return StreamBuilder(
                              stream: diamondService.watchWallet(
                                currentUser.uid,
                              ),
                              builder: (context, walletSnapshot) {
                                final balance =
                                    walletSnapshot.data?.balance ?? 0;
                                final maalPoints = state.getMaalPoints(
                                  currentUser.uid,
                                );

                                return GameTopBar(
                                  roomName: GameTerminology.royalMeldGame,
                                  roomId: widget.roomId.substring(
                                    0,
                                    widget.roomId.length > 6
                                        ? 6
                                        : widget.roomId.length,
                                  ),
                                  points: 'Maal: $maalPoints',
                                  balance: '💎 $balance',
                                  onExit: () => context.go('/lobby'),
                                  onSettings: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MarriageGuidebookScreen(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Video/Audio Controls (Responsive Row at Top Right)
                      Positioned(
                        // Move to top-right edge if TopBar is hidden
                        top: isLandscapeMobile ? 8 : 56,
                        right: 16,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Chat Button
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChatOverlay(
                                roomId: widget.roomId,
                                userId: currentUser.uid,
                                userName: currentUser.displayName ?? 'Player',
                                isExpanded: _isChatExpanded,
                                onToggle: () => setState(
                                  () => _isChatExpanded = !_isChatExpanded,
                                ),
                              ),
                            ),
                            // Video Toggle
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                icon: Icon(
                                  _showVideoGrid
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(
                                  () => _showVideoGrid = !_showVideoGrid,
                                ),
                              ),
                            ),
                            // Audio Toggle
                            Container(
                               margin: const EdgeInsets.symmetric(horizontal: 4),
                               child: AudioFloatingButton(
                                roomId: widget.roomId,
                                userId: currentUser.uid,
                              ),
                            ),
                            // Help Button
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: CasinoColors.gold.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: CasinoColors.gold),
                              ),
                              child: IconButton(
                                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                icon: const Icon(
                                  Icons.help_outline,
                                  color: CasinoColors.gold,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MarriageGuidebookScreen(),
                                  ),
                                ),
                                tooltip: 'How to Play',
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tutorial Overlay (shows for first-time players)
                      // Now handled by wrapper widget

                      // Hint Tooltip (Floating)
                      if (_currentHint != null && _showHints)
                        Positioned(
                          bottom: 180, // Above hand
                          left: 16,
                          right: 16, // Center horizontally
                          child: Center(
                            child: HintTooltip(
                              hint: _currentHint!,
                              onDismiss: () =>
                                  setState(() => _currentHint = null),
                            ),
                          ),
                        ),

                      // Hint Button (Bottom Right)
                      Positioned(
                        bottom: 240,
                        right: 16,
                        child: Container(
                          key: _tutorialKeys['hint_button'],
                          child: HintButton(
                            currentHint: _currentHint,
                            hintsEnabled: _showHints,
                            onToggle: () {
                              setState(() {
                                _showHints = !_showHints;
                                if (!_showHints) _currentHint = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Victory Celebration (when round ends in scoring phase)
            if (state.phase == 'scoring' && state.winnerId != null)
              VictoryCelebration(
                winnerName: state.winnerId == currentUser.uid
                    ? 'You'
                    : 'Player ${state.winnerId?.substring(0, 4) ?? ''}',
                winnerScore: state.roundScores[state.winnerId] ?? 0,
                scores: state.roundScores.entries
                    .map(
                      (e) => PlayerScore(
                        name: e.key == currentUser.uid
                            ? 'You'
                            : 'Player ${e.key.substring(0, 4)}',
                        maalPoints: state.playerMaalPoints[e.key] ?? 0,
                        totalScore: state.totalScores[e.key] ?? 0,
                        isMe: e.key == currentUser.uid,
                        wasVisited: state.playerVisited[e.key] ?? false,
                      ),
                    )
                    .toList(),
                isMe: state.winnerId == currentUser.uid,
                onDismiss: () {
                  // TODO: Trigger next round or return to lobby
                },
              ),

            // Card Flying Animations
            CardAnimationOverlay(controller: _cardAnimController),

            // Turn Timeout Warning (flashing overlay when time is low)
            if (isMyTurn)
              TurnTimeoutWarning(
                remainingSeconds: state.turnTimeRemaining ?? 30,
                warningThreshold: 15,
                criticalThreshold: 5,
                onTimeout: () {
                  // Auto-discard when timeout (if a card is selected)
                  if (_selectedCardId != null) {
                    _discardCard();
                  }
                },
              ),

            // Reconnection Overlay
            ReconnectionOverlay(
              isConnected: true, // TODO: Wire to actual connection state
              onRetry: () {
                // Trigger UI rebuild by setting state
                setState(() {});
              },
            ),

            // Guided Gameplay Tutorial Overlay
            if (_guidedTutorialController != null && _showTutorial)
              InteractiveTutorialOverlay(
                controller: _guidedTutorialController!,
                onComplete: () async {
                  await MarriageTutorial.markCompleted();
                  if (mounted) {
                    setState(() => _showTutorial = false);
                  }
                },
                onSkip: () async {
                  await MarriageTutorial.markCompleted();
                },
              ),
          ],
        ); // Close outer Stack
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

  Widget _buildMeldSuggestions(List<String> handIds, PlayingCard? tiplu) {
    if (handIds.isEmpty) return const SizedBox.shrink();

    // Convert IDs to PlayingCards
    final cards = handIds
        .map((id) => _getCard(id))
        .whereType<PlayingCard>()
        .toList();
    final melds = MeldDetector.findAllMelds(cards, tiplu: tiplu);

    if (melds.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 28, // Reduced from 40
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
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
                  style: TextStyle(
                    color: _getMeldColor(meld.type),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                ...meld.cards
                    .take(3)
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 1),
                        child: Text(
                          c.displayString,
                          style: TextStyle(
                            color: c.suit.isRed ? Colors.red : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getMeldColor(MeldType type) {
    switch (type) {
      case MeldType.set:
        return Colors.blue;
      case MeldType.run:
        return Colors.green;
      case MeldType.tunnel:
        return Colors.orange;
      case MeldType.marriage:
        return Colors.pink;
      case MeldType.impureRun:
        return Colors.orange.shade300;
      case MeldType.impureSet:
        return Colors.teal;
      case MeldType.dublee:
        return Colors.indigo;
    }
  }

  String _getMeldTypeName(MeldType type) {
    // Use GameTerminology for multi-region support
    switch (type) {
      case MeldType.set:
        return GameTerminology.trial;
      case MeldType.run:
        return GameTerminology.sequence;
      case MeldType.tunnel:
        return GameTerminology.triple;
      case MeldType.marriage:
        return GameTerminology.royalSequenceShort;
      case MeldType.impureRun:
        return 'Impure Sequence';
      case MeldType.impureSet:
        return 'Impure Trial';
      case MeldType.dublee:
        return 'Dublee';
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
            color: (isDrawingPhase ? Colors.blue : Colors.orange).withValues(
              alpha: 0.3,
            ),
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
        color: isMyTurn
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: isMyTurn ? Colors.green : Colors.white24),
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
          // Timer display
          if (hasTimeout && isMyTurn) ...[
            const SizedBox(width: 16),
            _buildTimerWidget(remainingTime, state.config.turnTimeoutSeconds),
          ],
        ],
      ),
    ).animate().fadeIn();
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
        border: Border(
          bottom: BorderSide(color: isMyTurn ? Colors.green : Colors.white24),
        ),
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
        )
        .animate(onComplete: (controller) => controller.repeat())
        .shimmer(
          duration: isCritical ? 500.ms : 1000.ms,
          color: isCritical
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.transparent,
        );
  }

  // === Helper Builders for Professional Layout ===

  Widget _buildProfessionalCenterArea(
    MarriageGameState state,
    PlayingCard? topDiscard,
    bool isMyTurn,
  ) {
    return CenterTableArea(
      deckCount: state.deckCards.length,
      topDiscard: topDiscard,
      discardCount: state.discardPile.length,
      tiplu: state.tipluCardId.isNotEmpty ? _getCard(state.tipluCardId) : null,
      isMyTurn: isMyTurn,
      canDrawFromDeck: isMyTurn && state.turnPhase == 'drawing',
      canDrawFromDiscard: isMyTurn && state.turnPhase == 'drawing',
      turnPhase: state.turnPhase,
      onDeckTap: () => _drawFromDeck(),
      onDiscardTap: () => _drawFromDiscard(),
      deckKey: _tutorialKeys['deck_pile'],
      discardKey: _tutorialKeys['discard_pile'],
      tipluKey: _tutorialKeys['tiplu_indicator'],
      isDiscardBlocked: false,
    );
  }

  List<Widget> _buildProfessionalOpponents(
    MarriageGameState state,
    String myId,
  ) {
    final allPlayers = state.playerHands.keys.toList();
    // Sort players to put me at bottom, then rotate rest
    final myIndex = allPlayers.indexOf(myId);
    final rotatedPlayers = [
      ...allPlayers.sublist(myIndex + 1),
      ...allPlayers.sublist(0, myIndex),
    ];

    // Responsive: Use compact slots if many players
    final isCompact = rotatedPlayers.length > 4;

    return rotatedPlayers.map((playerId) {
      final hand = state.playerHands[playerId] ?? [];
      final isTurn = state.currentPlayerId == playerId;
      final profile = _getBotName(playerId); // Only name, need avatar logic
      final hasVisited = state.hasVisited(playerId);
      final timer = isTurn && state.config.turnTimeoutSeconds > 0
          ? ref.read(marriageServiceProvider).getRemainingTurnTime(state) /
                state.config.turnTimeoutSeconds
          : 0.0;

      // Determine action status for bubble
      OpponentAction? action;
      if (isTurn) {
        action = state.turnPhase == 'drawing'
            ? OpponentAction.thinking
            : OpponentAction.discarding;
      }
      // Ideally we'd track "Drawing..." state too via specific updates

      return Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          isCompact
              ? PlayerSlotCompact(
                  playerName: profile,
                  cardCount: hand.length,
                  isCurrentTurn: isTurn,
                  hasVisited: hasVisited,
                )
              : PlayerSlotWidget(
                  playerName: profile,
                  cardCount: hand.length,
                  isCurrentTurn: isTurn,
                  hasVisited: hasVisited,
                  maalPoints: state.getMaalPoints(playerId),
                  onTap: () {},
                ),

          // Action Bubble
          if (action != null)
            Positioned(
              top: -40,
              child: ActionIndicatorBubble(action: action, isVisible: true),
            ),
        ],
      );
    }).toList();
  }

  // === End Professional Builders ===

  Widget _buildEmptySeat() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: CasinoColors.tableGreenLight.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.event_seat_rounded,
        size: 24,
        color: CasinoColors.tableGreenLight.withValues(alpha: 0.5),
      ),
    );
  }

  void _updateHints(
    MarriageGameState state,
    String myId,
    List<String> handIds,
    PlayingCard? tiplu,
    PlayingCard? topDiscard,
  ) {
    if (handIds.isEmpty) return;

    // Convert IDs to cards
    final hand = handIds
        .map((id) => _getCard(id))
        .whereType<PlayingCard>()
        .toList();

    // Check if it's my turn
    final isMyTurn = state.currentPlayerId == myId;
    final hasVisited = state.hasVisited(myId);

    if (isMyTurn) {
      final hint = _hintService.getPrimaryHint(
        hand: hand,
        topDiscard: topDiscard,
        tiplu: tiplu,
        hasVisited: hasVisited,
        isDrawPhase: state.isDrawingPhase,
        isDiscardPhase: state.isDiscardingPhase,
        canPickFromDiscard: state.isDrawingPhase && topDiscard != null,
        deckCount: state.deckCards.length,
      );

      if (mounted && hint != null && hint.type != _currentHint?.type) {
        setState(() => _currentHint = hint);
      }
    } else {
      if (mounted && _currentHint != null) {
        setState(() => _currentHint = null);
      }
    }
  }

  Widget _buildCenterArea(
    MarriageGameState state,
    Card? topDiscard,
    bool isMyTurn,
  ) {
    // P0 FIX: Use state.isDrawingPhase instead of local _hasDrawn
    final canDraw = isMyTurn && state.isDrawingPhase;
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.8),
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );

    return Container(
      // Padding removed to prevent overflow in restricted 180px height
      // padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // CLOSED DECK (Draw pile)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: canDraw ? _drawFromDeck : null,
                child: Container(
                  key: _tutorialKeys['deck_pile'], // Add key
                  child: _buildDeckPile(state.deckCards.length, canDraw),
                ),
              ),
              const SizedBox(height: 4),
              Text('DECK', style: labelStyle),
            ],
          ),

          const SizedBox(width: 16),

          // FINISH SLOT (Declare button area)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: _tutorialKeys['finish_button'],
                width: 65,
                height: 90,
                decoration: BoxDecoration(
                  color: CasinoColors.feltGreenDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CasinoColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: CasinoColors.gold.withValues(alpha: 0.6),
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'FINISH',
                        style: TextStyle(
                          color: CasinoColors.gold.withValues(alpha: 0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('FINISH', style: labelStyle),
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
              const SizedBox(height: 4),
              Text('DISCARD', style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeckPile(int count, bool canDraw) {
    return Container(
      width: 80,
      height: 115,
      decoration: BoxDecoration(
        color: CasinoColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canDraw
              ? CasinoColors.gold
              : CasinoColors.gold.withValues(alpha: 0.3),
          width: canDraw ? 2 : 1,
        ),
        boxShadow: canDraw
            ? [
                BoxShadow(
                  color: CasinoColors.gold.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ]
            : null,
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
              child: Icon(
                Icons.style,
                color: CasinoColors.gold.withValues(alpha: 0.5),
                size: 40,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (canDraw)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiscardPile(Card? topCard, bool canDraw) {
    // P0 FIX: Validation logic for drag target
    // final state = ref.read(marriageServiceProvider).watchGameState(widget.roomId).last;
    // Note: Stream logic is complex here, relying on parent rebuilding calls.
    // Simplifying: The _discardCard function checks state anyway.

    return DragTarget<PlayingCard>(
      onWillAcceptWithDetails: (card) {
        return card != null;
      },
      onAcceptWithDetails: (card) {
        setState(() => _selectedCardId = card.data.id);
        _discardCard();
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return Container(
          width: 80,
          height: 115,
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.red.withValues(alpha: 0.3)
                : (topCard != null
                      ? Colors.white
                      : CasinoColors.cardBackground.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovering
                  ? Colors.redAccent
                  : (canDraw && topCard != null
                        ? CasinoColors.gold
                        : CasinoColors.gold.withValues(alpha: 0.3)),
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
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            Text(
                              'Drop',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Discard',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                ),
        );
      },
    );
  }

  Widget _buildMyHand(
    List<String> cardIds,
    bool isMyTurn, {
    Key? key,
    Card? tiplu,
    required MarriageGameConfig config,
  }) {
    // Convert IDs to Cards
    final cards = cardIds
        .map((id) => _getCard(id))
        .where((c) => c != null)
        .cast<PlayingCard>()
        .toList();

    return MarriageHandWidget(
      key: key, // Pass key down
      cards: cards,
      selectedCardId: _selectedCardId,
      onCardSelected: (id) =>
          setState(() => _selectedCardId = id == _selectedCardId ? null : id),
      tiplu: tiplu,
      config: config,
    );
  }

  Widget _buildCardWidget(
    Card card,
    bool isSelected, {
    bool isLarge = false,
    MaalType maalType = MaalType.none,
  }) {
    final size = isLarge ? const Size(85, 125) : const Size(75, 110);

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
                  fontSize: isLarge ? 32 : 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                card.suit.symbol,
                style: TextStyle(
                  color: card.suit.isRed ? Colors.red : Colors.black,
                  fontSize: isLarge ? 26 : 20,
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
              child: Text(maalLabel, style: const TextStyle(fontSize: 8)),
            ),
          ),
      ],
    );
  }

  /// Get Maal type color for glow effect
  Color _getMaalColor(MaalType type) {
    switch (type) {
      case MaalType.tiplu:
        return Colors.purple; // 3 pts - main wild
      case MaalType.poplu:
        return Colors.blue; // 2 pts - rank +1
      case MaalType.jhiplu:
        return Colors.cyan; // 2 pts - rank -1
      case MaalType.alter:
        return Colors.orange; // 5 pts - same rank+color
      case MaalType.man:
        return Colors.green; // Joker
      case MaalType.none:
        return Colors.transparent;
    }
  }

  /// Get Maal badge label
  String _getMaalLabel(MaalType type) {
    switch (type) {
      case MaalType.tiplu:
        return '👑'; // Crown for main wild
      case MaalType.poplu:
        return '⬆️'; // Up for +1
      case MaalType.jhiplu:
        return '⬇️'; // Down for -1
      case MaalType.alter:
        return '💎'; // Diamond for alter
      case MaalType.man:
        return '🃏'; // Joker
      case MaalType.none:
        return '';
    }
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
        currentUser.uid,
      );

      if (success) {
        // Show success animation
        HapticService.visitSuccess();
        SoundService.playVisit();
        if (mounted) {
          _showCelebrationEffect(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Visited Successfully via $type! Maal Unlocked!',
              ),
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
          SnackBar(
            content: Text(ErrorHelper.getFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
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
        final result = await marriageService.drawFromDeck(
          widget.roomId,
          userId,
        );

        // Play sound and haptics
        HapticService.cardDraw();
        SoundService.playCardPickup();

        // Animate
        final deckKey = _tutorialKeys['deck_pile'];
        final handKey = _tutorialKeys['player_hand'];
        if (deckKey?.currentContext != null &&
            handKey?.currentContext != null) {
          final start =
              (deckKey!.currentContext!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);
          final end = (handKey!.currentContext!.findRenderObject() as RenderBox)
              .localToGlobal(Offset.zero);

          final card = result != null ? _getCard(result) : null;

          if (card != null) {
            _cardAnimController.animateDrawFromDeck(
              card: card,
              deckPosition: start,
              handPosition: end + const Offset(100, 0),
              onComplete: () {},
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
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
        final result = await marriageService.drawFromDiscard(
          widget.roomId,
          userId,
        );

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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Success - Play sound and haptics
          HapticService.cardDraw();
          SoundService.playCardPickup();

          // Animate
          final discardKey = _tutorialKeys['discard_pile'];
          final handKey = _tutorialKeys['player_hand'];
          if (discardKey?.currentContext != null &&
              handKey?.currentContext != null) {
            final start =
                (discardKey!.currentContext!.findRenderObject() as RenderBox)
                    .localToGlobal(Offset.zero);
            final end =
                (handKey!.currentContext!.findRenderObject() as RenderBox)
                    .localToGlobal(Offset.zero);

            final card = _getCard(result);

            if (card != null) {
              _cardAnimController.animateDrawFromDeck(
                card: card,
                deckPosition: start,
                handPosition: end + const Offset(100, 0),
                onComplete: () {},
              );
            }
          }
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

  Future<void> _discardCard() async {
    if (_selectedCardId == null || _isProcessing) return;
    // P0 FIX: No need to check _hasDrawn - service validates turnPhase

    setState(() => _isProcessing = true);

    try {
      final marriageService = ref.read(marriageServiceProvider);
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        await marriageService.discardCard(
          widget.roomId,
          userId,
          _selectedCardId!,
        );

        // Play sound and haptics
        HapticService.cardDiscard();
        SoundService.playCardPlace();

        // Animate
        final discardKey = _tutorialKeys['discard_pile'];
        final handKey = _tutorialKeys['player_hand'];
        if (discardKey?.currentContext != null &&
            handKey?.currentContext != null) {
          final start =
              (handKey!.currentContext!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero); // ideally specific card pos
          final end =
              (discardKey!.currentContext!.findRenderObject() as RenderBox)
                  .localToGlobal(Offset.zero);

          final card = _getCard(_selectedCardId!);

          if (card != null) {
            _cardAnimController.animateDiscard(
              card: card,
              cardPosition: start + const Offset(100, 0),
              discardPosition: end,
              onComplete: () {},
            );
          }
        }
        setState(() {
          _selectedCardId = null;
          // P0 FIX: No need to reset _hasDrawn - state updates from Firestore stream
        });
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
          final scores =
              state?.toJson()['roundScores'] as Map<String, dynamic>? ?? {};
          final details =
              state?.toJson()['scoreDetails'] as Map<String, dynamic>? ?? {};
          final declarerId = state?.toJson()['declarerId'] as String?;

          return AlertDialog(
            backgroundColor: CasinoColors.cardBackground,
            title: Row(
              children: [
                const Text('🎉 ', style: TextStyle(fontSize: 28)),
                const Text(
                  'Round Complete!',
                  style: TextStyle(color: CasinoColors.gold),
                ),
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
                        const Icon(
                          Icons.emoji_events,
                          color: CasinoColors.gold,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Winner',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                declarerId != null
                                    ? 'Player ${declarerId.substring(0, 4)}...'
                                    : 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score breakdown header
                  const Text(
                    'Score Breakdown',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Divider(color: Colors.white24),

                  // Player scores
                  ...scores.entries.map((entry) {
                    final playerId = entry.key;
                    final score = entry.value as int;
                    final playerDetails =
                        details[playerId] as Map<String, dynamic>? ?? {};
                    final isDeclarer = playerDetails['isDeclarer'] == true;
                    final hasPure = playerDetails['hasPureSequence'] == true;
                    final hasDublee = playerDetails['hasDublee'] == true;
                    final marriages =
                        playerDetails['marriageCount'] as int? ?? 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDeclarer
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDeclarer
                              ? Colors.green.withValues(alpha: 0.5)
                              : Colors.white24,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDeclarer ? Icons.star : Icons.person,
                                color: isDeclarer
                                    ? CasinoColors.gold
                                    : Colors.white54,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Player ${playerId.substring(0, 6)}...',
                                  style: TextStyle(
                                    color: isDeclarer
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isDeclarer
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Text(
                                score >= 0 ? '+$score' : '$score',
                                style: TextStyle(
                                  color: score <= 0
                                      ? Colors.green
                                      : Colors.red.shade300,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          // Bonuses/penalties
                          if (hasPure ||
                              hasDublee ||
                              marriages > 0 ||
                              isDeclarer)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 6,
                                children: [
                                  if (hasPure)
                                    _buildBadge('Pure ✓', Colors.blue),
                                  if (hasDublee)
                                    _buildBadge('Dublee +25', Colors.purple),
                                  if (marriages > 0)
                                    _buildBadge(
                                      'Marriage x$marriages',
                                      Colors.pink,
                                    ),
                                  if (isDeclarer)
                                    _buildBadge('Winner', Colors.green),
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
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
            Text(
              '${GameTerminology.wildCardFull}s',
              style: TextStyle(
                color: CasinoColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wild Card (Tiplu)
            _buildWildCardRow(
              '${GameTerminology.wildCard.toUpperCase()} (${GameTerminology.wildCardFull})',
              tiplu.rank.symbol,
              suitSymbol,
              suitColor,
              'Can substitute any card',
            ),
            const SizedBox(height: 12),

            // Low Wild (Jhiplu)
            _buildWildCardRow(
              GameTerminology.lowWild.toUpperCase(),
              jhipluRank.symbol,
              suitSymbol,
              suitColor,
              'One rank below ${GameTerminology.wildCard}',
            ),
            const SizedBox(height: 12),

            // High Wild (Poplu)
            _buildWildCardRow(
              GameTerminology.highWild.toUpperCase(),
              popluRank.symbol,
              suitSymbol,
              suitColor,
              'One rank above ${GameTerminology.wildCard}',
            ),

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
                  Text(
                    '💒 ${GameTerminology.royalSequence.toUpperCase()} BONUS',
                    style: const TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${jhipluRank.symbol}$suitSymbol + ${tiplu.rank.symbol}$suitSymbol + ${popluRank.symbol}$suitSymbol',
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '= 100 BONUS POINTS! 🎉',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(color: CasinoColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWildCardRow(
    String label,
    String rank,
    String suit,
    Color color,
    String desc,
  ) {
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
              Text(
                rank,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(suit, style: TextStyle(color: color, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(desc, style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleShow(MarriageGameState state) {
    // Implement show/finish logic
    if (state.isDiscardingPhase) {
      _declare();
    }
  }

  void _handleShowSequence(MarriageGameState state) {
    // Logic to show sequences (Visit / Mal Herne)
    _attemptVisit();
  }

  void _handleShowDublee(MarriageGameState state) {
    // Logic to show Dublee
  }
}

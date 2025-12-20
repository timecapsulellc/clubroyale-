/// Royal Meld (Marriage) Practice Screen
/// 
/// UI for playing Royal Meld card game
/// Uses GameTerminology for multi-region localization
library;

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/theme/app_theme.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/games/base_game.dart';
import 'package:clubroyale/core/card_engine/meld.dart' as meld_engine;
import 'package:clubroyale/core/card_engine/pile.dart'; // For Card class
import 'package:clubroyale/games/marriage/marriage_game.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';
import 'package:clubroyale/features/game/ui/components/player_avatar.dart';
import 'package:clubroyale/features/game/ui/components/game_log_overlay.dart';
import 'package:clubroyale/features/game/ui/components/casino_button.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/features/ai/ai_service.dart';
import 'package:clubroyale/games/marriage/widgets/visit_button_widget.dart';
import 'package:clubroyale/games/marriage/widgets/maal_indicator.dart';
import 'package:clubroyale/games/marriage/widgets/game_timer_widget.dart';
import 'package:clubroyale/games/marriage/marriage_visit_validator.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'dart:async';

/// Marriage game screen with test mode
class MarriageGameScreen extends ConsumerStatefulWidget {
  const MarriageGameScreen({super.key});

  @override
  ConsumerState<MarriageGameScreen> createState() => _MarriageGameScreenState();
}

class _MarriageGameScreenState extends ConsumerState<MarriageGameScreen> {
  late MarriageGame _game;
  final String _playerId = 'player_1';
  final List<String> _botIds = ['bot_1', 'bot_2', 'bot_3'];
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

  // Timer state
  Timer? _turnTimer;
  int _remainingSeconds = 30;
  
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
    
    // Check if bots need to play (if user doesn't start)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisitStatus();
      _playBotTurns();
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
      const SnackBar(content: Text('Turn Timeout! Auto-played.'), backgroundColor: Colors.orange),
    );
    
    // Proceed
    _playBotTurns();
  }

  void _updateMaalState() {
    if (_game.tiplu == null) return;
    
    final hand = _game.getHand(_playerId);
    final calculator = MarriageMaalCalculator(tiplu: _game.tiplu!, config: _config);
    
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
    final validator = MarriageVisitValidator(config: _config, tiplu: _game.tiplu);
    
    // Check purely for availability to update button state
    // We try 'attemptVisit' to see if ANY method works
    final result = validator.attemptVisit(hand);
    
    setState(() {
      if (result.canVisit) {
        _visitStatus = VisitButtonState.ready;
        _visitLabel = result.visitType == VisitType.tunnel ? 'TUNNEL WIN' : 'VISIT';
        _visitSubLabel = result.visitType == VisitType.dublee ? '7 Dublees Ready' : 'Sequences Ready';
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
    final validator = MarriageVisitValidator(config: _config, tiplu: _game.tiplu);
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
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myHand = _game.getHand(_playerId);
    final melds = _game.findMelds(_playerId);
    
    return Scaffold(
      backgroundColor: AppTheme.tableGreen,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use GameTerminology for game name
            Text(GameTerminology.royalMeldGame, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      child: Icon(Icons.style, color: AppTheme.gold.withValues(alpha: 0.5), size: 32),
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
                  Text('${GameTerminology.wildCard}: ', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    _game.tiplu!.displayName,
                    style: TextStyle(
                      color: _game.tiplu!.suit.isRed ? Colors.red : Colors.white,
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
          // Status Indicator
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                MaalIndicator(points: _maalPoints, hasMarriage: _hasMarriageBonus),
                const SizedBox(width: 12),
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
                    _buildHeaderButton(Icons.menu, () { /* TODO: Menu */ }),
                    const SizedBox(width: 8),
                    _buildHeaderButton(Icons.volume_up, () { /* TODO: Sound */ }),
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
                  logs: const [
                    "Bot 1 picked card from deck",
                    "Bot 2 threw card 4♥",
                    "Bot 3 showed tunella",
                  ], // Placeholder data, hook up to real game logs later
                ),
              ),
              
              Column(
                children: [
                  // Top Opponents
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 2,
                    child: _buildOpponentsArea(),
                  ),
                  
                  // Center Table (Deck/Discard/Pot)
                  Expanded(
                    flex: 4,
                    child: _buildCenterArea(),
                  ),
                  
                  // Bottom Player Area
                  // Meld suggestions
                  if (melds.isNotEmpty)
                    _buildMeldSuggestions(melds),
                  
                  // My hand
                  _buildMyHand(myHand),
                  
                  // Action bar
                  _buildActionBar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.gold, width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildOpponentsArea() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _botIds.map((botId) {
          final isCurrentTurn = _game.currentPlayerId == botId;
          return PlayerAvatar(
            name: _getBotName(botId),
            isCurrentTurn: isCurrentTurn,
            statusLabel: isCurrentTurn ? "Thinking..." : "Waiting", // Dynamic status
            statusColor: isCurrentTurn ? AppTheme.goldDark : AppTheme.orange,
          ).animate().fadeIn(delay: 200.ms);
        }).toList(),
      ),
    );
  }

  Widget _buildCenterArea() {
    final topDiscard = _game.topDiscard;
    final isMyTurn = _game.currentPlayerId == _playerId;
    // Discard Pickup Rule: Check config and visit status
    final bool visitRequirementMet = !_config.mustVisitToPickDiscard || _hasVisited;
    
    // Check for blocking cards (Joker/Wild)
    bool isDiscardBlocked = false;
    if (topDiscard != null) {
      // Check if joker blocks discard
      if (_config.jokerBlocksDiscard && (topDiscard.isJoker || (!topDiscard.isJoker && _game.tiplu != null && topDiscard.rank == _game.tiplu!.rank && topDiscard.suit == _game.tiplu!.suit && !_config.canPickupWildFromDiscard))) {
         // Using simplified logic here:
         // 1. Printed Joker always blocks if enabled
         if (topDiscard.isJoker) isDiscardBlocked = true;
         
         // 2. Wild Cards block if cannot pickup wild
         if (!_config.canPickupWildFromDiscard && _isWildCard(topDiscard)) {
           isDiscardBlocked = true;
         }
      }
    }

    final canDrawFromDiscard = isMyTurn && topDiscard != null && _game.getHand(_playerId).length == 21 && visitRequirementMet && !isDiscardBlocked;
    final canDrawFromDeck = isMyTurn && _game.getHand(_playerId).length == 21;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Deck
          GestureDetector(
            onTap: canDrawFromDeck ? _drawFromDeck : null,
            child: CardWidget(
              card: Card(rank: Rank.ace, suit: Suit.spades), // Dummy card for back
              isFaceUp: false,
              isSelectable: canDrawFromDeck,
              isSelected: false,
            ),
          ),
          const SizedBox(width: 20),
          // Discard Pile
          GestureDetector(
            onTap: canDrawFromDiscard ? _drawFromDiscard : null,
            child: Stack(
              children: [
                CardWidget(
                  card: topDiscard ?? Card(rank: Rank.ace, suit: Suit.spades), // Show back styled dummy if no discard
                  isFaceUp: topDiscard != null,
                  isSelectable: canDrawFromDiscard,
                  isSelected: false,
                ),
                // Lock Overlay (if visit needed)
                if (topDiscard != null && !visitRequirementMet && isMyTurn)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
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
                        color: Colors.red.withOpacity(0.3), // Red tint for blocked action
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
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Row(
                      children: meld.cards.map((card) => CardWidget(card: card, isFaceUp: true, width: 30, height: 45)).toList(),
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

  Widget _buildMyHand(List<Card> hand) {
    // Calculator for rendering badges
    final calculator = _game.tiplu != null 
        ? MarriageMaalCalculator(tiplu: _game.tiplu!, config: _config) 
        : null;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: hand.map((card) {
              final isSelected = _selectedCardId == card.id;
              
              // Determine Maal visuals
              Color? glowColor;
              Widget? badgeIcon;
              
              if (calculator != null) {
                final type = calculator.getMaalType(card);
                switch (type) {
                  case MaalType.tiplu:
                    glowColor = Colors.purpleAccent;
                    badgeIcon = const Icon(Icons.star, color: Colors.purpleAccent, size: 14);
                    break;
                  case MaalType.poplu:
                    glowColor = Colors.blueAccent;
                    badgeIcon = const Icon(Icons.arrow_upward, color: Colors.blueAccent, size: 14);
                    break;
                  case MaalType.jhiplu:
                    glowColor = Colors.cyanAccent;
                    badgeIcon = const Icon(Icons.arrow_downward, color: Colors.cyanAccent, size: 14);
                    break;
                  case MaalType.alter:
                    glowColor = Colors.orangeAccent;
                    badgeIcon = const Icon(Icons.generating_tokens, color: Colors.orangeAccent, size: 14);
                    break;
                  case MaalType.man:
                    glowColor = Colors.greenAccent;
                    badgeIcon = const Icon(Icons.face, color: Colors.greenAccent, size: 14);
                    break;
                  case MaalType.none:
                    break;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCardId = isSelected ? null : card.id;
                    });
                  },
                  child: CardWidget(
                    card: card,
                    isFaceUp: true,
                    isSelected: isSelected,
                    glowColor: glowColor,
                    cornerBadge: badgeIcon,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    final isMyTurn = _game.currentPlayerId == _playerId;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Discard button
          CasinoButton(
            label: 'Discard',
            onPressed: isMyTurn && _selectedCardId != null ? _discardCard : null,
            backgroundColor: AppTheme.gold,
            borderColor: AppTheme.goldDark,
          ),
          
          // Visit Button (New)
          VisitButtonWidget(
            state: _visitStatus,
            onPressed: (_visitStatus == VisitButtonState.ready) ? _handleVisit : null,
            label: _visitLabel,
            subLabel: _visitSubLabel,
          ),
          
          // Sort button
           CasinoButton(
            label: 'Sort',
            onPressed: () {
              setState(() {});
              _checkVisitStatus(); // Re-check after sort
            },
            backgroundColor: AppTheme.teal,
            borderColor: Colors.white.withValues(alpha: 0.5),
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
    );
  }
  
  void _drawFromDeck() {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _game.drawFromDeck(_playerId);
      _checkVisitStatus(); // Update visit status after drawing
      _isProcessing = false;
    });
  }
  
  void _drawFromDiscard() {
    if (_isProcessing || _game.topDiscard == null) return;
    setState(() {
      _isProcessing = true;
      _game.drawFromDiscard(_playerId);
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
      _selectedCardId = null;
      _stopTimer(); // specific stop timer for human turn end
      
      // Bot turns
      _playBotTurns();
    });
  }
  
  // Helper to convert Card to AI-friendly string (e.g., "AS", "10H")
  String _toAiString(Card card) {
    if (card.isJoker) return 'Joker';
    return '${card.rank.symbol}${card.suit.name[0].toUpperCase()}';
  }

  // Helper: Check if card is Wild
  bool _isWildCard(Card card) {
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
      final tipluVal = tiplu.rank.value == 1 ? 14 : tiplu.rank.value; // Ace high handled in rank?
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
        'phase': _game.currentPhase == GamePhase.playing ? 'drawing' : 'discarding',
        'tiplu': _game.tiplu != null ? _toAiString(_game.tiplu!) : null,
        'topDiscard': _game.topDiscard != null ? _toAiString(_game.topDiscard!) : null,
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
            _game.drawFromDiscard(botId);
          } else {
            _game.drawFromDeck(botId);
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
         // Fallback logic
         if (_game.getHand(botId).length == 21) {
           _game.drawFromDeck(botId);
         } else {
           _game.playCard(botId, _game.getHand(botId).last);
         }
      });
    }
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
      _showWinDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot declare yet - complete all melds first!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showWinDialog({String? winnerName}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.teal,
        title: Text('🎉 ${winnerName ?? 'You'} Win!', style: const TextStyle(color: AppTheme.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Match Results:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._game.calculateScores().entries.map((e) {
              final pid = e.key;
              final isMe = pid == _playerId;
              final score = e.value;
              final hasVisited = _game.getHand(pid).length < 21 || _game.findMelds(pid).isNotEmpty; // Crude check, ideally GameState tracks this
              // For now display raw score
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getPlayerName(pid),
                      style: TextStyle(
                        color: isMe ? Colors.greenAccent : Colors.white70,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      '$score pts',
                      style: TextStyle(
                        color: score < 0 ? Colors.green : (score > 50 ? Colors.red : AppTheme.gold),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(color: Colors.white24),
            const Text(
              'Maal Exchange & Penalties applied.',
              style: TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initGame());
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
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
      case meld_engine.MeldType.set: return Colors.blue;
      case meld_engine.MeldType.run: return Colors.green;
      case meld_engine.MeldType.tunnel: return Colors.orange;
      case meld_engine.MeldType.marriage: return Colors.pink;
    }
  }
  
  String _getMeldTypeName(meld_engine.MeldType type) {
    // Use GameTerminology for multi-region support
    switch (type) {
      case meld_engine.MeldType.set: return GameTerminology.trial;
      case meld_engine.MeldType.run: return GameTerminology.sequence;
      case meld_engine.MeldType.tunnel: return GameTerminology.triple;
      case meld_engine.MeldType.marriage: return GameTerminology.royalSequenceShort;
    }
  }
}

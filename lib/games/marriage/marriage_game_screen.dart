/// Royal Meld (Marriage) Practice Screen
/// 
/// UI for playing Royal Meld card game
/// Uses GameTerminology for multi-region localization

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/core/theme/app_theme.dart';
import 'package:taasclub/core/config/game_terminology.dart';
import 'package:taasclub/games/base_game.dart';
import 'package:taasclub/core/card_engine/meld.dart' as meld_engine;
import 'package:taasclub/core/card_engine/pile.dart'; // For Card class
import 'package:taasclub/games/marriage/marriage_game.dart';
import 'package:taasclub/features/game/ui/components/table_layout.dart';
import 'package:taasclub/features/game/ui/components/player_avatar.dart';
import 'package:taasclub/features/game/ui/components/game_log_overlay.dart';
import 'package:taasclub/features/game/ui/components/casino_button.dart';
import 'package:taasclub/features/game/ui/components/card_widget.dart';
import 'package:taasclub/features/ai/ai_service.dart';

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
  
  @override
  void initState() {
    super.initState();
    _initGame();
  }
  
  void _initGame() {
    _game = MarriageGame();
    _game.initialize(<String>[_playerId, ..._botIds]);
    _game.startRound();
    
    // Check if bots need to play (if user doesn't start)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playBotTurns();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myHand = _game.getHand(_playerId);
    final melds = _game.findMelds(_playerId);
    
    return Scaffold(
      backgroundColor: AppTheme.tableGreen,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
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
                border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                      child: Icon(Icons.style, color: AppTheme.gold.withOpacity(0.5), size: 32),
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
                color: Colors.red.withOpacity(0.2),
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
                    _buildHeaderButton(Icons.info_outline, () { /* TODO: Info */ }),
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
        color: AppTheme.teal.withOpacity(0.8),
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
    final canDrawFromDiscard = isMyTurn && topDiscard != null && _game.getHand(_playerId).length == 21;
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
            child: CardWidget(
              card: topDiscard ?? Card(rank: Rank.ace, suit: Suit.spades), // Show back styled dummy if no discard
              isFaceUp: topDiscard != null,
              isSelectable: canDrawFromDiscard,
              isSelected: false,
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
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: hand.map((card) {
              final isSelected = _selectedCardId == card.id;
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
        color: Colors.black.withOpacity(0.5),
        border: Border(top: BorderSide(color: AppTheme.gold.withOpacity(0.3))),
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
          
          // Sort button
           CasinoButton(
            label: 'Sort',
            onPressed: () => setState(() {}),
            backgroundColor: AppTheme.teal,
            borderColor: Colors.white.withOpacity(0.5),
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
      _isProcessing = false;
    });
  }
  
  void _drawFromDiscard() {
    if (_isProcessing || _game.topDiscard == null) return;
    setState(() {
      _isProcessing = true;
      _game.drawFromDiscard(_playerId);
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
      
      // Bot turns
      _playBotTurns();
    });
  }
  
  // Helper to convert Card to AI-friendly string (e.g., "AS", "10H")
  String _toAiString(Card card) {
    if (card.isJoker) return 'Joker';
    return '${card.rank.symbol}${card.suit.name[0].toUpperCase()}';
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
          children: [
            const Text('Congratulations!', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
              ..._game.calculateScores().entries.map((e) => 
                Text('${_getPlayerName(e.key)}: ${e.value} points',
                     style: TextStyle(color: AppTheme.gold.withValues(alpha: 0.7))),
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

/// Marriage Game Screen
/// 
/// UI for playing Marriage card game (Nepali Rummy)

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:taasclub/config/casino_theme.dart';
import 'package:taasclub/config/visual_effects.dart';
import 'package:taasclub/core/card_engine/pile.dart';
import 'package:taasclub/core/card_engine/meld.dart';
import 'package:taasclub/games/marriage/marriage_game.dart';
import 'package:taasclub/features/game/widgets/player_avatar.dart';

/// Marriage game screen with test mode
class MarriageGameScreen extends StatefulWidget {
  const MarriageGameScreen({super.key});

  @override
  State<MarriageGameScreen> createState() => _MarriageGameScreenState();
}

class _MarriageGameScreenState extends State<MarriageGameScreen> {
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
    _game.initialize([_playerId, ..._botIds]);
    _game.startRound();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myHand = _game.getHand(_playerId);
    final melds = _game.findMelds(_playerId);
    
    return Scaffold(
      backgroundColor: CasinoColors.feltGreenDark,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Marriage', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CasinoColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CasinoColors.gold),
              ),
              child: Text(
                'Round ${_game.currentRound}',
                style: const TextStyle(color: CasinoColors.gold, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          // Tiplu indicator
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
                  const Text('Tiplu: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
      body: ParticleBackground(
        primaryColor: CasinoColors.gold,
        secondaryColor: CasinoColors.feltGreenMid,
        particleCount: 20,
        child: Column(
          children: [
            // Other players
            Expanded(
              flex: 2,
              child: _buildOpponentsArea(),
            ),
            
            // Center - deck and discard
            Expanded(
              flex: 3,
              child: _buildCenterArea(),
            ),
            
            // Meld suggestions
            if (melds.isNotEmpty)
              _buildMeldSuggestions(melds),
            
            // My hand
            _buildMyHand(myHand),
            
            // Action bar
            _buildActionBar(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOpponentsArea() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _botIds.map((botId) {
          final hand = _game.getHand(botId);
          final isCurrentTurn = _game.currentPlayerId == botId;
          return PlayerAvatar(
            name: _getBotName(botId),
            isCurrentTurn: isCurrentTurn,
            isHost: false,
            bid: null,
            tricksWon: hand.length,
          ).animate().fadeIn(delay: 200.ms);
        }).toList(),
      ),
    );
  }
  
  Widget _buildCenterArea() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Deck
          GestureDetector(
            onTap: _game.currentPlayerId == _playerId ? _drawFromDeck : null,
            child: Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                color: CasinoColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CasinoColors.gold.withOpacity(0.5)),
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
                        colors: [CasinoColors.richPurple, CasinoColors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Icon(Icons.style, color: CasinoColors.gold.withOpacity(0.5), size: 32),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_game.cardsRemaining}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Discard pile
          GestureDetector(
            onTap: _game.currentPlayerId == _playerId ? _drawFromDiscard : null,
            child: Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                color: _game.topDiscard != null 
                    ? Colors.white 
                    : CasinoColors.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _game.topDiscard != null 
                      ? CasinoColors.gold 
                      : CasinoColors.gold.withOpacity(0.3),
                ),
              ),
              child: _game.topDiscard != null
                  ? _buildCard(_game.topDiscard!, false, isLarge: true)
                  : Center(
                      child: Text(
                        'Discard',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMeldSuggestions(List<Meld> melds) {
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
              color: _getMeldColor(meld.type).withOpacity(0.2),
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
  
  Widget _buildMyHand(List<Card> cards) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            final isSelected = _selectedCardId == card.id;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCardId = isSelected ? null : card.id;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.translationValues(
                  0, 
                  isSelected ? -15 : 0, 
                  0,
                ),
                margin: EdgeInsets.only(right: index < cards.length - 1 ? -25 : 0),
                child: _buildCard(card, isSelected),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildCard(Card card, bool isSelected, {bool isLarge = false}) {
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
                ? CasinoColors.gold.withOpacity(0.4) 
                : Colors.black.withOpacity(0.2),
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
  
  Widget _buildActionBar() {
    final isMyTurn = _game.currentPlayerId == _playerId;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(top: BorderSide(color: CasinoColors.gold.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Discard button
          ElevatedButton.icon(
            onPressed: isMyTurn && _selectedCardId != null ? _discardCard : null,
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
              side: BorderSide(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          
          // Declare button
          ElevatedButton.icon(
            onPressed: isMyTurn ? _tryDeclare : null,
            icon: const Icon(Icons.check_circle),
            label: const Text('Declare'),
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
  
  void _playBotTurns() {
    // Simple bot AI - each bot draws and discards
    for (final botId in _botIds) {
      if (_game.currentPlayerId == botId) {
        // Draw from deck
        _game.drawFromDeck(botId);
        
        // Discard highest card
        final hand = _game.getHand(botId);
        if (hand.isNotEmpty) {
          final toDiscard = hand.reduce((a, b) => 
              a.rank.points > b.rank.points ? a : b);
          _game.playCard(botId, toDiscard);
        }
      }
    }
    setState(() {});
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
  
  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CasinoColors.cardBackground,
        title: const Text('🎉 You Win!', style: TextStyle(color: CasinoColors.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Congratulations!', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ..._game.calculateScores().entries.map((e) => 
              Text('${_getPlayerName(e.key)}: ${e.value} points',
                   style: const TextStyle(color: Colors.white70)),
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
  
  Color _getMeldColor(MeldType type) {
    switch (type) {
      case MeldType.set: return Colors.blue;
      case MeldType.run: return Colors.green;
      case MeldType.tunnel: return Colors.orange;
      case MeldType.marriage: return Colors.pink;
    }
  }
  
  String _getMeldTypeName(MeldType type) {
    switch (type) {
      case MeldType.set: return 'Trial';
      case MeldType.run: return 'Sequence';
      case MeldType.tunnel: return 'Tunnel';
      case MeldType.marriage: return 'Marriage';
    }
  }
}

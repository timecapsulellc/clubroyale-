/// Call Break Game Screen
/// 
/// UI for the Call Break card game
library;

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/design_system/game/felt_texture_painter.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/games/call_break/call_break_game.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/widgets/game_mode_banner.dart';
import 'package:clubroyale/core/widgets/game_opponent_widget.dart';

class CallBreakGameScreen extends StatefulWidget {
  final String? gameId;
  
  const CallBreakGameScreen({super.key, this.gameId});

  @override
  State<CallBreakGameScreen> createState() => _CallBreakGameScreenState();
}

class _CallBreakGameScreenState extends State<CallBreakGameScreen> {
  late CallBreakGame _game;
  String? _selectedCardId;
  int _selectedBid = 1;
  final String _currentUserId = 'player_0';
  
  @override
  void initState() {
    super.initState();
    _initGame();
  }
  
  void _initGame() {
    _game = CallBreakGame();
    _game.initialize(['player_0', 'player_1', 'player_2', 'player_3']);
    _game.startRound();
    
    // Simulate AI bids for other players
    _simulateAiBids();
  }
  
  void _simulateAiBids() {
    // For testing, auto-bid for AI players
    for (final pid in _game.playerIds) {
      if (pid != _currentUserId && !_game.bids.containsKey(pid)) {
        // AI makes a random bid based on hand strength
        final hand = _game.getHand(pid);
        int bid = _calculateAiBid(hand);
        
        // Need to be current player to bid
        while (_game.currentPlayerId != pid && _game.phase == CallBreakPhase.bidding) {
          // Skip if it's our turn
          if (_game.currentPlayerId == _currentUserId) break;
          // Submit bid for current AI player
          if (!_game.bids.containsKey(_game.currentPlayerId!)) {
            final aiHand = _game.getHand(_game.currentPlayerId!);
            _game.submitBid(_game.currentPlayerId!, _calculateAiBid(aiHand));
          }
        }
      }
    }
  }
  
  int _calculateAiBid(List<Card> hand) {
    // Simple AI: count high cards and spades
    int bid = 0;
    for (final card in hand) {
      if (card.suit == Suit.spades) bid++;
      if (card.rank.value >= 11) bid++; // J, Q, K, A
    }
    return (bid / 3).ceil().clamp(1, 8);
  }
  
  void _submitMyBid() {
    if (_game.submitBid(_currentUserId, _selectedBid)) {
      setState(() {
        // After our bid, let AI players bid
        while (_game.phase == CallBreakPhase.bidding && 
               _game.currentPlayerId != _currentUserId) {
          final aiPid = _game.currentPlayerId!;
          final aiHand = _game.getHand(aiPid);
          _game.submitBid(aiPid, _calculateAiBid(aiHand));
        }
      });
    }
  }
  
  void _playCard() {
    if (_selectedCardId == null) return;
    
    final hand = _game.getHand(_currentUserId);
    final card = hand.firstWhere(
      (c) => c.id == _selectedCardId,
      orElse: () => hand.first,
    );
    
    try {
      final oldTricks = Map<String, int>.from(_game.tricksWon);
      _game.playCard(_currentUserId, card);
      SoundService.playCardSlide();
      
      // Check for trick win
      for (final pid in _game.playerIds) {
        if ((_game.tricksWon[pid] ?? 0) > (oldTricks[pid] ?? 0)) {
           SoundService.playTrickWon();
           break;
        }
      }

      setState(() {
        _selectedCardId = null;
        
        // Let AI players play their cards
        _playAiCards();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid move: $e')),
      );
    }
  }
  
  void _playAiCards() {
    while (_game.phase == CallBreakPhase.playing && 
           _game.currentPlayerId != _currentUserId) {
      final aiPid = _game.currentPlayerId!;
      final validCards = _game.getValidCards(aiPid);
      
      if (validCards.isNotEmpty) {
        // Simple AI: play highest valid card
        final card = validCards.reduce((a, b) => 
          a.rank.value > b.rank.value ? a : b);
        
        final oldTricks = Map<String, int>.from(_game.tricksWon);
        _game.playCard(aiPid, card);
        SoundService.playCardSlide();
        
        // Check for trick win
        for (final pid in _game.playerIds) {
          if ((_game.tricksWon[pid] ?? 0) > (oldTricks[pid] ?? 0)) {
             SoundService.playTrickWon();
             break;
          }
        }
      }
      
      // Check if round ended
      if (_game.phase != CallBreakPhase.playing) break;
    }
    
    setState(() {});
  }
  
  void _startNewRound() {
    setState(() {
      _game.startRound();
    });
  }
  
  void _startNewGame() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Break - Round ${_game.currentRound}'),
        backgroundColor: CasinoColors.deepPurple,
        foregroundColor: CasinoColors.gold,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: FeltBackground(
        primaryColor: CasinoColors.deepPurple,
        secondaryColor: const Color(0xFF2E1A47),
        showTexture: true,
        showAmbientLight: true,
        child: SafeArea(
          child: Column(
            children: [
              // Game mode banner (always AI in local mode)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: GameModeBanner(
                  botCount: 3,
                  humanCount: 1,
                  compact: true,
                ),
              ),
              // Score board
              _buildScoreBoard(),
              
              // Game area
              Expanded(
                child: _buildGameArea(),
              ),
              
              // Player's hand
              _buildMyHand(),
              
              // Action buttons
              _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildScoreBoard() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OpponentRow(
        avatarSize: 40, // Smaller for scoreboard
        opponents: _game.playerIds.map((pid) {
          final isMe = pid == _currentUserId;
          final isCurrent = pid == _game.currentPlayerId;
          final score = _game.calculateScores()[pid] ?? 0;
          final bid = _game.bids[pid];
          final won = _game.tricksWon[pid] ?? 0;
          final isBot = pid != _currentUserId;
          
          return GameOpponent(
            id: pid,
            name: isMe ? 'You' : 'Bot ${pid.split('_').last}',
            isBot: isBot,
            isCurrentTurn: isCurrent,
            score: score,
            bid: bid,
            tricksWon: won,
            status: isCurrent ? 'thinking' : null,
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildGameArea() {
    if (_game.phase == CallBreakPhase.bidding) {
      return _buildBiddingUI();
    } else if (_game.phase == CallBreakPhase.scoring || 
               _game.phase == CallBreakPhase.finished) {
      return _buildRoundResults();
    } else {
      return _buildPlayingArea();
    }
  }
  
  Widget _buildBiddingUI() {
    final isMyTurn = _game.currentPlayerId == _currentUserId;
    final myBid = _game.bids[_currentUserId];
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎯 Bidding Phase',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (myBid != null)
              Text(
                'Your bid: $myBid',
                style: const TextStyle(color: CasinoColors.gold, fontSize: 18),
              )
            else if (isMyTurn) ...[
              const Text(
                'Select your bid (1-13):',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.white),
                    onPressed: _selectedBid > 1 
                      ? () => setState(() => _selectedBid--)
                      : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: CasinoColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_selectedBid',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _selectedBid < 13
                      ? () => setState(() => _selectedBid++)
                      : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitMyBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CasinoColors.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Submit Bid',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ] else
              Text(
                'Waiting for ${_game.currentPlayerId} to bid...',
                style: const TextStyle(color: Colors.white70),
              ),
              
            const SizedBox(height: 16),
            
            // Show other bids
            ...(_game.bids.entries.map((e) => Text(
              '${e.key == _currentUserId ? "You" : e.key}: ${e.value}',
              style: const TextStyle(color: Colors.white70),
            ))),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
  
  Widget _buildPlayingArea() {
    return Column(
      children: [
        // Current trick
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Trick ${(_game.tricksWon.values.fold(0, (a, b) => a + b)) + 1} of 13',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  _buildTrickCards(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrickCards() {
    final trick = _game.currentTrick;
    if (trick == null || trick.cards.isEmpty) {
      return const Text(
        'Lead a card!',
        style: TextStyle(color: Colors.white54),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: trick.cards.map((tc) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCardWidget(tc.card, false, isSmall: true),
              const SizedBox(height: 4),
              Text(
                tc.playerId == _currentUserId ? 'You' : 'P${tc.playerId.split('_').last}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRoundResults() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _game.isFinished ? '🏆 Game Over!' : '📊 Round Results',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._game.playerIds.map((pid) {
              final bid = _game.bids[pid] ?? 0;
              final won = _game.tricksWon[pid] ?? 0;
              final score = _game.calculateScores()[pid] ?? 0;
              final made = won >= bid;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        pid == _currentUserId ? 'You' : 'Player ${pid.split('_').last}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Text(
                      'Bid: $bid  Won: $won  ',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Icon(
                      made ? Icons.check_circle : Icons.cancel,
                      color: made ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total: $score',
                      style: const TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 24),
            
            if (!_game.isFinished)
              ElevatedButton(
                onPressed: _startNewRound,
                child: const Text('Next Round'),
              )
            else
              ElevatedButton(
                onPressed: _startNewGame,
                child: const Text('New Game'),
              ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
  
  Widget _buildMyHand() {
    final hand = _game.getHand(_currentUserId);
    final validCards = _game.getValidCards(_currentUserId);
    final isMyTurn = _game.currentPlayerId == _currentUserId;
    
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: hand.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            final isSelected = _selectedCardId == card.id;
            final isValid = validCards.contains(card);
            
            return GestureDetector(
              onTap: isMyTurn && isValid ? () {
                setState(() {
                  _selectedCardId = isSelected ? null : card.id;
                });
              } : null,
              child: Transform.translate(
                offset: Offset(
                  index > 0 ? -20.0 * index : 0,
                  isSelected ? -15 : 0,
                ),
                child: Opacity(
                  opacity: isMyTurn && !isValid ? 0.5 : 1.0,
                  child: _buildCardWidget(card, isSelected),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 30 * index));
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildCardWidget(Card card, bool isSelected, {bool isSmall = false}) {
    final size = isSmall ? 60.0 : 80.0;
    final height = isSmall ? 84.0 : 112.0;
    
    return Container(
      width: size,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.rank.symbol,
            style: TextStyle(
              fontSize: isSmall ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: card.suit.isRed ? Colors.red : Colors.black,
            ),
          ),
          Text(
            card.suit.symbol,
            style: TextStyle(
              fontSize: isSmall ? 20 : 28,
              color: card.suit.isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionBar() {
    final isMyTurn = _game.currentPlayerId == _currentUserId;
    final canPlay = _game.phase == CallBreakPhase.playing && 
                    isMyTurn && 
                    _selectedCardId != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_game.phase == CallBreakPhase.playing)
            ElevatedButton.icon(
              onPressed: canPlay ? _playCard : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            
          if (!isMyTurn && _game.phase == CallBreakPhase.playing)
            const Text(
              'Waiting for opponent...',
              style: TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

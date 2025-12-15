/// In Between Game Screen
/// 
/// Real-time multiplayer In Between game UI

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'package:clubroyale/core/card_engine/pile.dart';
import 'package:clubroyale/core/card_engine/deck.dart';
import 'package:clubroyale/games/in_between/in_between_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/features/chat/widgets/chat_overlay.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/features/video/widgets/video_grid.dart';
import 'package:clubroyale/core/config/game_terminology.dart';

class InBetweenScreen extends ConsumerStatefulWidget {
  final String roomId;
  
  const InBetweenScreen({
    required this.roomId,
    super.key,
  });

  @override
  ConsumerState<InBetweenScreen> createState() => _InBetweenScreenState();
}

class _InBetweenScreenState extends ConsumerState<InBetweenScreen> {
  bool _isProcessing = false;
  int _betAmount = 0;
  String? _lastResult;
  bool _isChatExpanded = false;
  bool _showVideoGrid = false;
  
  // Audio player removed - using global SoundService
  
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
      case Rank.ace: return 14;
      case Rank.king: return 13;
      case Rank.queen: return 12;
      case Rank.jack: return 11;
      default: return card.rank.points;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final inBetweenService = ref.watch(inBetweenServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }
    
    return StreamBuilder<InBetweenGameState?>(
      stream: inBetweenService.watchGameState(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: CasinoColors.feltGreenDark,
            body: const Center(
              child: CircularProgressIndicator(color: CasinoColors.gold),
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
              child: Text('Waiting for game...', style: TextStyle(color: Colors.white70)),
            ),
          );
        }
        
        final myChips = state.playerChips[currentUser.uid] ?? 0;
        final isMyTurn = state.currentPlayerId == currentUser.uid;
        final maxBet = myChips < state.pot ? myChips : state.pot;
        
        return Scaffold(
          backgroundColor: CasinoColors.feltGreenDark,
          appBar: AppBar(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/lobby'),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(GameTerminology.inBetweenGame, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                _buildChipsBadge(myChips),
              ],
            ),
            actions: [
              _buildPotBadge(state.pot),
              // Video Toggle
              IconButton(
                icon: Icon(_showVideoGrid ? Icons.videocam_off : Icons.videocam),
                onPressed: () => setState(() => _showVideoGrid = !_showVideoGrid),
                tooltip: _showVideoGrid ? 'Hide Video' : 'Show Video',
              ),
              // Audio Mute/Unmute
              AudioFloatingButton(roomId: widget.roomId, userId: currentUser.uid),
              const SizedBox(width: 8),
            ],
          ),
          body: ParticleBackground(
            primaryColor: CasinoColors.gold,
            secondaryColor: Colors.green,
            particleCount: 15,
            child: Stack(
              children: [
                Column(
              children: [
                // Turn indicator
                _buildTurnIndicator(isMyTurn, state.phase),
                
                const Spacer(),
                
                // Cards area
                _buildCardsArea(state),
                
                // Result display
                if (_lastResult != null)
                  _buildResultBanner(_lastResult!),
                
                const Spacer(),
                
                // Betting area
                if (isMyTurn && state.phase == 'betting')
                  _buildBettingArea(state.pot, myChips, maxBet),
                
                // Action buttons
                  _buildActionBar(isMyTurn, state),
                  ],
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
                  bottom: 140, // Above hand
                  left: 16,
                  child: ChatOverlay(
                    roomId: widget.roomId,
                    userId: currentUser.uid,
                    userName: currentUser.displayName ?? 'Player',
                    isExpanded: _isChatExpanded,
                    onToggle: () => setState(() => _isChatExpanded = !_isChatExpanded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          Image.asset('assets/images/chips/chip_blue.png', width: 14, height: 14),
          const SizedBox(width: 4),
          Text(
            '$chips',
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
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
          Image.asset('assets/images/chips/chip_red.png', width: 18, height: 18),
          const SizedBox(width: 4),
          Text(
            'Pot: $pot',
            style: const TextStyle(color: CasinoColors.gold, fontWeight: FontWeight.bold),
          ),
        ],
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
      message = phase == 'betting' ? '🎲 Your Turn - Place a Bet!' : '🎯 Reveal the Card!';
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
      child: Text(
        message,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
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
            if (lowCard != null)
              _buildCardWidget(lowCard, 'LOW'),
            
            const SizedBox(width: 16),
            
            // Middle card (or placeholder)
            middleCard != null
                ? _buildCardWidget(middleCard, 'MIDDLE', isMiddle: true)
                : _buildCardBack(),
            
            const SizedBox(width: 16),
            
            // High card
            if (highCard != null)
              _buildCardWidget(highCard, 'HIGH'),
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
    return Column(
      children: [
        Container(
          width: isMiddle ? 100 : 80,
          height: isMiddle ? 140 : 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isMiddle 
                    ? CasinoColors.gold.withValues(alpha: 0.5) 
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: isMiddle ? 16 : 8,
                spreadRadius: isMiddle ? 2 : 0,
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
                  fontSize: isMiddle ? 36 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                card.suit.symbol,
                style: TextStyle(
                  color: card.suit.isRed ? Colors.red : Colors.black,
                  fontSize: isMiddle ? 28 : 22,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
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
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [CasinoColors.richPurple, CasinoColors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.5), width: 2),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                color: CasinoColors.gold.withValues(alpha: 0.6),
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .shimmer(duration: 1.5.seconds),
        const SizedBox(height: 8),
        Text(
          'MIDDLE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
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
        text = '🎉 WIN! +${_betAmount}';
        icon = Icons.celebration;
        break;
      case 'lose':
        color = Colors.red;
        text = '😢 LOSE -${_betAmount}';
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
        border: Border(top: BorderSide(color: CasinoColors.gold.withValues(alpha: 0.3))),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ]
          else if (state.phase == 'revealing' && isMyTurn) ...[
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _reveal,
              icon: const Icon(Icons.visibility),
              label: const Text('Reveal Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ]
          else if (state.phase == 'result' && isMyTurn) ...[
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _nextTurn,
              icon: const Icon(Icons.skip_next),
              label: const Text('Next Turn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CasinoColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ]
          else ...[
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
          SnackBar(content: Text('Error placing bet: $e'), backgroundColor: Colors.red),
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
          SnackBar(content: Text('Error revealing card: $e'), backgroundColor: Colors.red),
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Helper method removed - using SoundService directly
}

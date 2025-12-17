/// Royal Meld (Marriage) Game Entry Screen
/// 
/// Entry point for Royal Meld game with options to:
/// - Practice (single-player with bots - free)
/// - Create Room (multiplayer - costs diamonds)
/// - Join Room (multiplayer - by room code)
/// Uses GameTerminology for multi-region localization
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';

class MarriageEntryScreen extends ConsumerStatefulWidget {
  const MarriageEntryScreen({super.key});

  @override
  ConsumerState<MarriageEntryScreen> createState() => _MarriageEntryScreenState();
}

class _MarriageEntryScreenState extends ConsumerState<MarriageEntryScreen> {
  bool _isCreatingRoom = false;
  bool _isJoining = false;
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/lobby'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Use GameTerminology emoji based on region
            Text(GameTerminology.currentRegion == GameRegion.southAsia ? '👰' : '👑', 
              style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              GameTerminology.royalMeldGame,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CasinoColors.darkPurple,
              CasinoColors.deepPurple,
              CasinoColors.richPurple,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Game Info Card
                _buildGameInfoCard(),
                const SizedBox(height: 32),
                
                // Main Actions
                _buildCreateRoomButton(),
                const SizedBox(height: 16),
                
                _buildJoinRoomButton(),
                const SizedBox(height: 32),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Practice Mode
                _buildPracticeModeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade800,
            Colors.purple.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_stories, size: 48, color: Colors.amber),
          const SizedBox(height: 16),
          // Use GameTerminology for game description
          Text(
            GameTerminology.royalMeldDescription,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create melds, find the ${GameTerminology.wildCard}, and ${GameTerminology.declare.toLowerCase()} to win!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(Icons.people, '2-8 Players'),
              _buildInfoChip(Icons.timer, '15-30 min'),
              _buildInfoChip(Icons.style, '3-4 Decks'),
            ],
          ),
        ],
      ),
    ).animate()
     .fadeIn(duration: 400.ms)
     .slideY(begin: -0.2, end: 0);
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRoomButton() {
    final isTestMode = TestMode.isEnabled;
    final cost = isTestMode ? 'FREE' : '${DiamondConfig.roomCreationCost} 💎';
    
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isCreatingRoom ? null : _createRoom,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: _isCreatingRoom
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Host a multiplayer game',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cost,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 200.ms)
     .fadeIn(duration: 400.ms)
     .slideX(begin: -0.2, end: 0);
  }

  Widget _buildJoinRoomButton() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: CasinoColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurple.shade400,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showJoinDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.vpn_key, color: Colors.deepPurple, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Join Room',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Enter a 6-digit room code',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 300.ms)
     .fadeIn(duration: 400.ms)
     .slideX(begin: 0.2, end: 0);
  }

  Widget _buildPracticeModeButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade600,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/marriage/practice'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.smart_toy, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Text(
                  GameTerminology.practiceMode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 500.ms)
     .fadeIn(duration: 400.ms);
  }

  Future<void> _createRoom() async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final diamondService = ref.read(diamondServiceProvider);
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create a room')),
      );
      return;
    }

    setState(() => _isCreatingRoom = true);

    final isTestMode = TestMode.isEnabled;
    
    // Check diamond balance (skip in Test Mode)
    if (!isTestMode) {
      final cost = DiamondConfig.roomCreationCost;
      final hasEnough = await diamondService.hasEnoughDiamonds(
        user.uid,
        cost,
      );

      if (!hasEnough && mounted) {
        setState(() => _isCreatingRoom = false);
        _showInsufficientDiamondsDialog();
        return;
      }
    }

    try {
      final config = GameConfig(
        pointValue: 10,
        totalRounds: 5,
      );
      
      final newGameRoom = GameRoom(
        name: 'Marriage #${Random().nextInt(1000)}',
        hostId: user.uid,
        config: config,
        gameType: 'marriage',
        players: [
          Player(id: user.uid, name: user.displayName ?? 'Player 1'),
        ],
        scores: {user.uid: 0},
        createdAt: DateTime.now(),
      );

      final newGameId = await lobbyService.createGame(newGameRoom);

      // Deduct diamonds after successful room creation (skip in Test Mode)
      if (!isTestMode) {
        final cost = DiamondConfig.roomCreationCost;
        final success = await diamondService.deductDiamonds(
          user.uid, 
          cost,
          description: 'Created Marriage Room'
        );
        if (!success) {
          // This case should ideally not happen if hasEnoughDiamonds was checked
          // but good to have a fallback.
          debugPrint('Failed to deduct diamonds after room creation.');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(isTestMode 
                  ? 'Room created! (Test Mode - Free)' 
                  : 'Room created! Create for ${DiamondConfig.roomCreationCost} 💎'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/lobby/$newGameId');
      }
    } catch (e) {
      debugPrint('Error creating room: $e');
      if (mounted) {
        setState(() => _isCreatingRoom = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInsufficientDiamondsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.diamond, size: 48, color: Colors.amber.shade600),
        ),
        title: const Text('Insufficient Diamonds'),
        content: Text(
          'You need ${DiamondConfig.roomCreationCost} diamonds to create a room.\n\n'
          'Would you like to get more diamonds?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/wallet');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade700),
            child: const Text('Get Diamonds'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.vpn_key, size: 48, color: Colors.deepPurple.shade600),
        ),
        title: const Text('Join Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit room code:'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _codeController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isJoining ? null : () {
              final code = _codeController.text.trim();
              if (code.length == 6) {
                Navigator.pop(context);
                _joinByCode(code);
              }
            },
            child: _isJoining 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Join'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinByCode(String code) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    setState(() => _isJoining = true);

    try {
      final player = Player(
        id: user.uid,
        name: user.displayName ?? 'Player',
      );

      final gameId = await lobbyService.joinByCode(code, player);

      if (mounted) {
        _codeController.clear();
        context.go('/lobby/$gameId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }
}

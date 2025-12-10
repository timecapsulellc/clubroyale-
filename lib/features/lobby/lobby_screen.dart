
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:taasclub/features/game/game_room.dart';
import 'package:taasclub/features/game/game_config.dart';
import 'package:taasclub/features/lobby/lobby_service.dart';
import 'package:taasclub/features/wallet/diamond_service.dart';
import 'package:taasclub/features/wallet/diamond_balance_widget.dart';
import 'package:taasclub/features/feedback/feedback_dialog.dart';
import 'package:taasclub/core/config/game_terminology.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

import '../auth/auth_service.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lobbyService = ref.watch(lobbyServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final gamesStream = lobbyService.getGames();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF0D4A2E), // Deep Casino Green
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => context.go('/'),
            ),
            actions: [
              DiamondBalanceBadge(),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.feedback_outlined, color: Colors.white),
                ),
                onPressed: () => FeedbackDialog.show(context),
                tooltip: 'Send Feedback',
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.3), // Gold accent
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.shade600),
                  ),
                  child: const Icon(Icons.pin_outlined, color: Colors.white),
                ),
                onPressed: () => _showJoinByCodeDialog(context, ref),
                tooltip: 'Join by Code',
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Game Lobby',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A6B4A), // Lighter casino green
                      Color(0xFF0D4A2E), // Deep casino green
                      Color(0xFF083323), // Darkest green
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay - card suits
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.08,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                          ),
                          itemCount: 64,
                          itemBuilder: (context, index) {
                            final suits = ['♠', '♥', '♣', '♦'];
                            return Center(
                              child: Text(
                                suits[index % 4],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Center icon - cards
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber.shade400, width: 2),
                        ),
                        child: const Icon(
                          Icons.style_rounded, // Card stack icon
                          size: 56,
                          color: Colors.white,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(duration: 1500.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Actions Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.add_rounded,
                      label: 'Create Room',
                      color: const Color(0xFF1A6B4A), // Casino green
                      onTap: () => _showCreateGameDialog(context, ref),
                    ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.pin_rounded,
                      label: 'Join by Code',
                      color: Colors.amber.shade700, // Gold
                      onTap: () => _showJoinByCodeDialog(context, ref),
                    ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.2),
                  ),
                ],
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Available Rooms',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ),

          // Games List
          StreamBuilder<List<GameRoom>>(
            stream: gamesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.amber),
                        SizedBox(height: 16),
                        Text('Finding rooms...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: _ErrorState(error: snapshot.error.toString()),
                );
              }

              final games = snapshot.data ?? [];

              if (games.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    onCreateRoom: () => _showCreateGameDialog(context, ref),
                    onJoinByCode: () => _showJoinByCodeDialog(context, ref),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns for mobile
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      final isFinished = game.isFinished || game.status == GameStatus.settled;
                      final currentUser = authService.currentUser;
                      final isInGame = game.players.any((p) => p.id == currentUser?.uid);
                      final isHost = game.hostId == currentUser?.uid;

                      return _EnhancedGameCard(
                        game: game,
                        isFinished: isFinished,
                        isInGame: isInGame,
                        isHost: isHost,
                        onTap: () {
                          if (isFinished) {
                            context.go('/ledger/${game.id}');
                          } else if (game.status == GameStatus.waiting) {
                            context.go('/lobby/${game.id}');
                          } else {
                            context.go('/game/${game.id}/play');
                          }
                        },
                        onJoin: isInGame ? null : () => _joinGame(context, ref, game),
                        onShareCode: game.roomCode != null ? () => _shareRoomCode(context, game) : null,
                      ).animate(delay: (100 * index).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
                    },
                    childCount: games.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGameDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Room'),
        backgroundColor: Colors.amber.shade700, // Gold FAB
        foregroundColor: Colors.black, // Dark text for contrast
        elevation: 8,
      ).animate().fadeIn(delay: 500.ms).scale(),
    );
  }

  /// Shows dialog to join a game by 6-digit code
  Future<void> _showJoinByCodeDialog(BuildContext context, WidgetRef ref) async {
    final codeController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D4A2E), // Casino green
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.shade600, width: 2),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber.shade600, width: 2),
          ),
          child: Icon(Icons.pin_rounded, size: 48, color: Colors.amber.shade400),
        ),
        title: const Text('Join by Room Code', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the 6-digit code shared by the host',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.amber.shade600, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          FilledButton(
            onPressed: () {
              if (codeController.text.length == 6) {
                Navigator.pop(context, codeController.text);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.black,
            ),
            child: const Text('Join Room'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      await _joinByCode(context, ref, result);
    }
  }

  /// Shows dialog to create a game with configuration
  Future<void> _showCreateGameDialog(BuildContext context, WidgetRef ref) async {
    double pointValue = 10;
    int totalRounds = 5;
    String gameType = 'call_break';
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0D4A2E), // Casino green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.amber.shade600, width: 2),
          ),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade600, width: 2),
            ),
            child: Icon(Icons.add_rounded, size: 48, color: Colors.amber.shade400),
          ),
          title: const Text('Create Room', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Type Selection
                Text('Game Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade400,
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GameTypeOption(
                        title: 'Call Break',
                        subtitle: 'Trick-taking',
                        icon: Icons.style_rounded,
                        isSelected: gameType == 'call_break',
                        onTap: () => setState(() => gameType = 'call_break'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GameTypeOption(
                        // Use GameTerminology for multi-region support
                        title: GameTerminology.royalMeldGame,
                        subtitle: 'Rummy-style',
                        icon: Icons.layers_rounded,
                        isSelected: gameType == 'marriage',
                        onTap: () => setState(() => gameType = 'marriage'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _GameTypeOption(
                        title: 'Teen Patti',
                        subtitle: 'Betting',
                        icon: Icons.casino_rounded,
                        isSelected: gameType == 'teen_patti',
                        onTap: () => setState(() => gameType = 'teen_patti'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GameTypeOption(
                        title: 'In Between',
                        subtitle: 'Quick bet',
                        icon: Icons.unfold_more_rounded,
                        isSelected: gameType == 'in_between',
                        isNew: true,
                        onTap: () => setState(() => gameType = 'in_between'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Point Value
                Text('Point Value (Units per point)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade400,
                    )),
                const SizedBox(height: 12),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 5, label: Text('5')),
                    ButtonSegment(value: 10, label: Text('10')),
                    ButtonSegment(value: 20, label: Text('20')),
                  ],
                  selected: {pointValue},
                  onSelectionChanged: (values) {
                    setState(() => pointValue = values.first);
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: Colors.amber.shade700,
                    selectedForegroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Rounds
                Text('Number of Rounds',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade400,
                    )),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 5, label: Text('5')),
                    ButtonSegment(value: 10, label: Text('10')),
                  ],
                  selected: {totalRounds},
                  onSelectionChanged: (values) {
                    setState(() => totalRounds = values.first);
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: Colors.amber.shade700,
                    selectedForegroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),

              const SizedBox(height: 16),
              // Cost indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade600),
                ),
                child: Row(
                  children: [
                    Icon(Icons.diamond, color: Colors.amber.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Creating a room costs ${DiamondService.roomCreationCost} diamonds',
                        style: TextStyle(color: Colors.amber.shade200),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'gameType': gameType,
                    'config': GameConfig(
                      pointValue: pointValue,
                      totalRounds: totalRounds,
                    ),
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      final config = result['config'] as GameConfig;
      final gameType = result['gameType'] as String;
      await _createGame(context, ref, config, gameType);
    }
  }

  Future<void> _createGame(BuildContext context, WidgetRef ref, GameConfig config, String gameType) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final diamondService = ref.read(diamondServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    // Skip diamond check in Test Mode - allow free room creation
    final isTestMode = TestMode.isEnabled;
    
    if (!isTestMode) {
      // Check diamond balance (only for real users)
      final hasEnough = await diamondService.hasEnoughDiamonds(
        user.uid,
        DiamondService.roomCreationCost,
      );

      if (!hasEnough && context.mounted) {
        // Show insufficient balance dialog
        final shouldBuy = await showDialog<bool>(
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
              'You need ${DiamondService.roomCreationCost} diamonds to create a room.\n\n'
              'Would you like to get more diamonds?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade700),
                child: const Text('Get Diamonds'),
              ),
            ],
          ),
        );

        if (shouldBuy == true && context.mounted) {
          context.go('/wallet');
        }
        return;
      }
    }

    // Use GameTerminology for multi-region game name
    final gameTypeName = gameType == 'marriage' ? GameTerminology.royalMeldGame : 'Call Break';
    final newGameRoom = GameRoom(
      name: '$gameTypeName #${Random().nextInt(1000)}',
      hostId: user.uid,
      config: config,
      gameType: gameType,
      players: [
        Player(id: user.uid, name: user.displayName ?? 'Player 1'),
      ],
      scores: {user.uid: 0},
      createdAt: DateTime.now(),
    );

    try {
      final newGameId = await lobbyService.createGame(newGameRoom);

      // Deduct diamonds after successful room creation (skip in Test Mode)
      if (!isTestMode) {
        await diamondService.processRoomCreation(user.uid, newGameId);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(isTestMode 
                  ? 'Room created! (Test Mode - Free)' 
                  : 'Room created! ${DiamondService.roomCreationCost} diamonds used.'),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to create room: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _joinByCode(BuildContext context, WidgetRef ref, String code) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    try {
      final gameId = await lobbyService.joinByCode(
        code,
        Player(id: user.uid, name: user.displayName ?? 'Player'),
      );

      if (gameId != null && context.mounted) {
        context.go('/lobby/$gameId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString().replaceAll('Exception: ', ''))),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _joinGame(BuildContext context, WidgetRef ref, GameRoom game) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null || game.id == null) return;

    await lobbyService.joinGame(
      game.id!,
      Player(id: user.uid, name: user.displayName ?? 'Player'),
    );

    if (context.mounted) {
      context.go('/lobby/${game.id}');
    }
  }

  void _shareRoomCode(BuildContext context, GameRoom game) {
    if (game.roomCode == null) return;
    
    // ignore: deprecated_member_use
    Share.share(
      'Join my TaasClub game! 🎮\n\nRoom Code: ${game.roomCode}\n\nOpen the app and enter this code to join.',
    );
  }
}

// Quick action button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced game card
class _EnhancedGameCard extends StatelessWidget {
  final GameRoom game;
  final bool isFinished;
  final bool isInGame;
  final bool isHost;
  final VoidCallback onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onShareCode;

  const _EnhancedGameCard({
    required this.game,
    required this.isFinished,
    required this.isInGame,
    required this.isHost,
    required this.onTap,
    this.onJoin,
    this.onShareCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = isFinished 
        ? Colors.grey 
        : game.status == GameStatus.waiting 
            ? Colors.green 
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.deepPurple.shade50.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFinished 
                        ? [Colors.grey.shade400, Colors.grey.shade600]
                        : [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isFinished ? Icons.check_circle : Icons.sports_esports,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  game.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isHost)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Host',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: statusColor),
                              const SizedBox(width: 6),
                              Text(
                                isFinished ? 'Finished' : (game.status == GameStatus.waiting ? 'Waiting' : 'In Progress'),
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Room code banner
              if (game.roomCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pin, size: 18, color: Colors.deepPurple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Room Code: ',
                        style: TextStyle(color: Colors.deepPurple.shade600),
                      ),
                      Text(
                        game.roomCode!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 16,
                          color: Colors.deepPurple.shade800,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      if (onShareCode != null)
                        IconButton(
                          icon: Icon(Icons.share, size: 20, color: Colors.deepPurple.shade600),
                          onPressed: onShareCode,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),

              // Game info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        _GameStat(
                          icon: Icons.people,
                          value: '${game.players.length}/${game.config.maxPlayers}',
                          label: 'Players',
                        ),
                        const SizedBox(width: 16),
                        _GameStat(
                          icon: Icons.monetization_on,
                          value: '${game.config.pointValue.toInt()}',
                          label: 'Units/pt',
                        ),
                        const SizedBox(width: 16),
                        _GameStat(
                          icon: Icons.repeat,
                          value: '${game.config.totalRounds}',
                          label: 'Rounds',
                        ),
                        const Spacer(),
                        if (isInGame)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Joined',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (!isFinished && onJoin != null)
                          FilledButton(
                            onPressed: onJoin,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Join'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Players
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: game.players.take(5).map((p) {
                        final isCurrentHost = p.id == game.hostId;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCurrentHost ? Colors.amber.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: isCurrentHost ? Border.all(color: Colors.amber) : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isCurrentHost ? Colors.amber : Colors.deepPurple.shade200,
                                child: Text(
                                  p.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentHost ? Colors.white : Colors.deepPurple.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: isCurrentHost ? FontWeight.bold : null,
                                ),
                              ),
                              if (isCurrentHost) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _GameStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinByCode;

  const _EmptyState({required this.onCreateRoom, required this.onJoinByCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade100, Colors.purple.shade50],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_esports_outlined,
                size: 64,
                color: Colors.deepPurple.shade400,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'No Rooms Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'Create a new room or join with a code\nto start playing!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: onCreateRoom,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Room'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onJoinByCode,
                  icon: const Icon(Icons.pin),
                  label: const Text('Join by Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Error state
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Game type option widget for create dialog
class _GameTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isNew;
  final VoidCallback onTap;

  const _GameTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.isNew = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.deepPurple : Colors.black87,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (isNew)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

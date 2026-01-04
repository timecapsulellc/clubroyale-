import 'package:flutter/material.dart';
import 'package:clubroyale/core/utils/haptic_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';
import 'package:clubroyale/features/lobby/lobby_service.dart';
import 'package:clubroyale/core/config/diamond_config.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/feedback/feedback_dialog.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/lobby/widgets/lobby_user_profile.dart';
import 'package:clubroyale/features/lobby/widgets/lobby_main_menu.dart';

import '../auth/auth_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';

/// Track if we've already granted dev diamonds this session
bool _devDiamondsGranted = false;

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Start lobby music when entering lobby
    SoundService.playLobbyMusic();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyService = ref.watch(lobbyServiceProvider);
    final authService = ref.watch(authServiceProvider);
    final gamesStream = lobbyService.getGames();

    // Auto-grant dev diamonds in debug mode (once per session)
    if (kDebugMode && !_devDiamondsGranted) {
      _devDiamondsGranted = true;
      final userId = authService.currentUser?.uid;
      if (userId != null) {
        final diamondService = ref.read(diamondServiceProvider);
        diamondService.grantDevDiamonds(userId).then((success) {
          if (success) {
            debugPrint('💎 Auto-granted dev diamonds to user');
          }
        });
      }
    }

    String selectedGameId = 'marriage'; // Default

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CasinoColors.greenFeltGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. LEFT SIDEBAR (Game Modes)
                  // We wrap it in a Column to put Profile above it, or let Sidebar handle it.
                  // Reference: Profile Top-Left, then Game Modes.
                  // 1. LEFT SIDEBAR (Menu Panel)
                  // Wider panel for the "Command Center" look
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        const LobbyUserProfile(),
                        Expanded(
                          child: LobbyMainMenu(
                            onSinglePlayer: () {
                              // "Practice" Mode
                              context.go('/marriage/practice');
                            },
                            onLocalMultiplayer: () {
                              // Placeholder for Local Networking feature
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Local Multiplayer coming soon!',
                                  ),
                                  backgroundColor: CasinoColors.tableGreenMid,
                                ),
                              );
                            },
                            onOnlinePublic: () {
                              // Just sets filter to default (showing grid)
                              setState(() {
                                selectedGameId = 'marriage';
                              });
                            },
                            onOnlinePrivate: () {
                              _showCreateGameDialog(
                                context,
                                ref,
                                initialGameType: selectedGameId,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. MAIN CONTENT AREA (Center)
                  Expanded(
                    child: Column(
                      children: [
                        // Top Bar (Utilities)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Title / Breadcrumb
                              Text(
                                selectedGameId == 'marriage'
                                    ? GameTerminology.royalMeldGame
                                    : 'Game Lobby',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              // Utilities (Top-Right)
                              Row(
                                children: [
                                  _buildUtilityIcon(
                                    Icons.feedback_outlined,
                                    'Feedback',
                                    () => FeedbackDialog.show(context),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildUtilityIcon(
                                    Icons.privacy_tip_outlined,
                                    'Privacy',
                                    () {},
                                  ),
                                  const SizedBox(width: 12),
                                  _buildUtilityIcon(
                                    Icons.settings_outlined,
                                    'Settings',
                                    () => context.push('/settings'),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildUtilityIcon(
                                    Icons.apps_rounded,
                                    'Other Games',
                                    () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'More games coming soon!',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _buildUtilityIcon(
                                    Icons.account_circle_outlined,
                                    'Account',
                                    () => context.push('/profile'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Main Content ScrollView
                        Expanded(
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // Quick Actions (Play Now, Create, Join)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildPlayNowButton(
                                          context,
                                          ref,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _QuickActionButton(
                                          icon: Icons.add_rounded,
                                          label: 'Create',
                                          color: CasinoColors.tableGreenMid,
                                          onTap: () => _showCreateGameDialog(
                                            context,
                                            ref,
                                            initialGameType: selectedGameId,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _QuickActionButton(
                                          icon: Icons.pin_rounded,
                                          label: 'Join Code',
                                          color: CasinoColors.gold,
                                          onTap: () => _showJoinByCodeDialog(
                                            context,
                                            ref,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Available Rooms Header
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    24,
                                    24,
                                    16,
                                  ),
                                  child: Text(
                                    'ACTIVE TABLES',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                  ),
                                ),
                              ),

                              // Rooms Grid
                              StreamBuilder<List<GameRoom>>(
                                stream: gamesStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SliverFillRemaining(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return SliverFillRemaining(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  }

                                  final allGames = snapshot.data ?? [];
                                  // Filter games by selected mode
                                  final games = allGames
                                      .where(
                                        (g) => g.gameType == selectedGameId,
                                      )
                                      .toList();

                                  if (games.isEmpty) {
                                    return SliverFillRemaining(
                                      child: _EmptyState(
                                        onCreateRoom: () =>
                                            _showCreateGameDialog(
                                              context,
                                              ref,
                                              initialGameType: selectedGameId,
                                            ),
                                        onJoinByCode: () =>
                                            _showJoinByCodeDialog(context, ref),
                                      ),
                                    );
                                  }

                                  return SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                3, // Desktop/Tablet optimized
                                            childAspectRatio: 1.1,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                          ),
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        final game = games[index];
                                        final isFinished =
                                            game.isFinished ||
                                            game.status == GameStatus.settled;
                                        final currentUser =
                                            authService.currentUser;
                                        final isInGame = game.players.any(
                                          (p) => p.id == currentUser?.uid,
                                        );
                                        final isHost =
                                            game.hostId == currentUser?.uid;

                                        return _EnhancedGameCard(
                                          game: games[index],
                                          isFinished: isFinished,
                                          isInGame: isInGame,
                                          isHost: isHost,
                                          onTap: () {
                                            if (isFinished) {
                                              context.go('/ledger/${game.id}');
                                            } else if (game.status ==
                                                GameStatus.waiting) {
                                              context.go('/lobby/${game.id}');
                                            } else {
                                              context.go(
                                                '/game/${game.id}/play',
                                              );
                                            }
                                          },
                                          onJoin: isInGame
                                              ? null
                                              : () => _joinGame(
                                                  context,
                                                  ref,
                                                  game,
                                                ),
                                          onShareCode: game.roomCode != null
                                              ? () => _shareRoomCode(
                                                  context,
                                                  game,
                                                )
                                              : null,
                                        );
                                      }, childCount: games.length),
                                    ),
                                  );
                                },
                              ),

                              const SliverToBoxAdapter(
                                child: SizedBox(height: 100),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 3. SECONDARY NAV (Bottom-Right)
              // Floating over content
              Positioned(
                bottom: 24,
                right: 24,
                child: Row(
                  children: [
                    _buildSecondaryButton(Icons.help_outline, 'Learn', () {}),
                    const SizedBox(width: 16),
                    _buildSecondaryButton(
                      Icons.leaderboard,
                      'Rankings',
                      () => context.push('/rankings'),
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

  Widget _buildUtilityIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSecondaryButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CasinoColors.deepPurple.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: CasinoColors.gold, size: 18),
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
    );
  }

  Widget _buildPlayNowButton(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
          onPressed: () {
            HapticHelper.lightTap();
            _playNow(context, ref);
          },
          icon: const Icon(Icons.bolt, size: 26),
          label: const Text(
            'PLAY NOW',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.green.shade900,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(delay: 2000.ms, duration: 1000.ms, color: Colors.white30);
  }

  /// Shows dialog to join a game by 6-digit code
  Future<void> _showJoinByCodeDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
          child: Icon(
            Icons.pin_rounded,
            size: 48,
            color: Colors.amber.shade400,
          ),
        ),
        title: const Text(
          'Join by Room Code',
          style: TextStyle(color: Colors.white),
        ),
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
                  borderSide: BorderSide(
                    color: Colors.amber.shade600,
                    width: 2,
                  ),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
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
  Future<void> _showCreateGameDialog(
    BuildContext context,
    WidgetRef ref, {
    String initialGameType = 'call_break',
  }) async {
    double pointValue = 10;
    int totalRounds = 5;
    String gameType = initialGameType;

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
            child: Icon(
              Icons.add_rounded,
              size: 48,
              color: Colors.amber.shade400,
            ),
          ),
          title: const Text(
            'Create Room',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Game Type Selection
                Text(
                  'Game Type',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade400,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GameTypeOption(
                        title: GameTerminology.callBreakGame,
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
                        title: GameTerminology.teenPattiGame,
                        subtitle: 'Betting',
                        icon: Icons.casino_rounded,
                        isSelected: gameType == 'teen_patti',
                        onTap: () => setState(() => gameType = 'teen_patti'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GameTypeOption(
                        title: GameTerminology.inBetweenGame,
                        subtitle: GameTerminology.inBetweenDescription,
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
                Text(
                  'Point Value (Units per point)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade400,
                  ),
                ),
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
                Text(
                  'Number of Rounds',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade400,
                  ),
                ),
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
                          'Creating a room costs ${DiamondConfig.roomCreationCost} diamonds',
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
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context, {
                  'gameType': gameType,
                  'config': GameConfig(
                    pointValue: pointValue,
                    totalRounds: totalRounds,
                  ),
                });
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

  Future<void> _createGame(
    BuildContext context,
    WidgetRef ref,
    GameConfig config,
    String gameType,
  ) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final diamondService = ref.read(diamondServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    // Skip diamond check in Test Mode or Debug Mode - allow free room creation for testing
    final isTestMode = TestMode.isEnabled;
    final bypassDiamondCheck = isTestMode || kDebugMode;

    if (!bypassDiamondCheck) {
      // Check diamond balance (only for production users)
      final hasEnough = await diamondService.hasEnoughDiamonds(
        user.uid,
        DiamondConfig.roomCreationCost,
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
              child: Icon(
                Icons.diamond,
                size: 48,
                color: Colors.amber.shade600,
              ),
            ),
            title: const Text('Insufficient Diamonds'),
            content: Text(
              'You need ${DiamondConfig.roomCreationCost} diamonds to create a room.\n\n'
              'Would you like to get more diamonds?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                ),
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
    final gameTypeName = gameType == 'marriage'
        ? GameTerminology.royalMeldGame
        : 'Call Break';
    final newGameRoom = GameRoom(
      name: '$gameTypeName #${Random().nextInt(1000)}',
      hostId: user.uid,
      config: config,
      gameType: gameType,
      players: [Player(id: user.uid, name: user.displayName ?? 'Player 1')],
      scores: {user.uid: 0},
      createdAt: DateTime.now(),
    );

    try {
      final newGameId = await lobbyService.createGame(newGameRoom);

      // Deduct diamonds after successful room creation (skip in Debug/Test Mode)
      if (!bypassDiamondCheck) {
        final cost = DiamondConfig.roomCreationCost;
        final success = await diamondService.deductDiamonds(
          user.uid,
          cost,
          description: 'Created room $gameType',
        );
        if (!success) {
          // This case should ideally not be reached if hasEnoughDiamonds check passed,
          // but good for robustness.
          throw Exception('Failed to deduct diamonds for room creation.');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  bypassDiamondCheck
                      ? 'Room created! (Dev Mode - Free)'
                      : 'Room created! ${DiamondConfig.roomCreationCost} diamonds used.',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _joinByCode(
    BuildContext context,
    WidgetRef ref,
    String code,
  ) async {
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
                Expanded(
                  child: Text(e.toString().replaceAll('Exception: ', '')),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _joinGame(
    BuildContext context,
    WidgetRef ref,
    GameRoom game,
  ) async {
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

  /// Instant play - joins the first available bot room
  Future<void> _playNow(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    final lobbyService = ref.read(lobbyServiceProvider);
    final user = authService.currentUser;

    if (user == null) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Finding a game for you...'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // Get all public waiting games
      final games = await lobbyService.getGames().first;

      // Filter for bot rooms first (instant play), then any room with space
      final botRooms = games
          .where(
            (g) =>
                g.status == GameStatus.waiting &&
                g.players.length < 8 &&
                g.players.any((p) => p.isBot), // Has at least one bot
          )
          .toList();

      final anyAvailableRoom = games
          .where(
            (g) =>
                g.status == GameStatus.waiting &&
                g.players.length < 8 &&
                !g.players.any((p) => p.id == user.uid), // Not already in room
          )
          .toList();

      GameRoom? targetRoom;
      if (botRooms.isNotEmpty) {
        targetRoom = botRooms.first;
      } else if (anyAvailableRoom.isNotEmpty) {
        targetRoom = anyAvailableRoom.first;
      }

      if (targetRoom != null && targetRoom.id != null) {
        await lobbyService.joinGame(
          targetRoom.id!,
          Player(id: user.uid, name: user.displayName ?? 'Player'),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Joined ${targetRoom.name}!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/lobby/${targetRoom.id}');
        }
      } else {
        // No available rooms, create a new one with bots for instant play
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Creating AI game...'),
              backgroundColor: Colors.orange,
            ),
          );

          // Create 8-player Marriage room with bots for testing
          final botConfig = GameConfig(
            pointValue: 10,
            totalRounds: 3,
            maxPlayers: 8, // 8-player Marriage game
          );

          final newRoom = GameRoom(
            name: 'Marriage AI #${Random().nextInt(1000)}',
            hostId: user.uid,
            config: botConfig,
            gameType: 'marriage', // Marriage game (supports 2-8 players)
            players: [Player(id: user.uid, name: user.displayName ?? 'Player')],
            scores: {user.uid: 0},
            createdAt: DateTime.now(),
          );

          try {
            final gameId = await lobbyService.createGame(newRoom);

            // Add 7 bots to fill the 8-player room
            for (int i = 0; i < 7; i++) {
              await lobbyService.addBot(gameId);
              await Future.delayed(
                const Duration(milliseconds: 50),
              ); // Small delay between adds
            }

            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('8-player Marriage game ready! Tap Start.'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/lobby/$gameId');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create AI game: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to find game: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareRoomCode(BuildContext context, GameRoom game) {
    if (game.roomCode == null) return;

    // ignore: deprecated_member_use
    Share.share(
      'Join my ClubRoyale game! 🎮\n\nRoom Code: ${game.roomCode}\n\nOpen the app and enter this code to join.',
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
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.4),
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
                const Color(0xFF0A2F1F), // Very dark green
                const Color(0xFF0F3D29), // Dark green
              ],
            ),
            border: Border.all(
              color: CasinoColors.gold.withValues(alpha: 0.3),
              width: 1,
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
                        : [
                            CasinoColors.tableGreenDark,
                            CasinoColors.tableGreenMid,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.white,
                                      ),
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
                              // Bot Room Badge - shows when room has bot players
                              if (game.players.any((p) => p.isBot))
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.smart_toy,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'AI',
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
                                isFinished
                                    ? 'Finished'
                                    : (game.status == GameStatus.waiting
                                          ? 'Waiting'
                                          : 'In Progress'),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(color: Colors.deepPurple.shade50),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pin,
                        size: 18,
                        color: Colors.deepPurple.shade700,
                      ),
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
                          icon: Icon(
                            Icons.share,
                            size: 20,
                            color: Colors.deepPurple.shade600,
                          ),
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
                          value:
                              '${game.players.length}/${game.config.maxPlayers}',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.green.shade700,
                                ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrentHost
                                ? Colors.amber.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: isCurrentHost
                                ? Border.all(color: Colors.amber)
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isCurrentHost
                                    ? Colors.amber
                                    : Colors.deepPurple.shade200,
                                child: Text(
                                  p.name.isNotEmpty
                                      ? p.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrentHost
                                        ? Colors.white
                                        : Colors.deepPurple.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: isCurrentHost
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                              if (isCurrentHost) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber.shade700,
                                ),
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

  const _GameStat({
    required this.icon,
    required this.value,
    required this.label,
  });

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: onJoinByCode,
                  icon: const Icon(Icons.pin),
                  label: const Text('Join by Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
            if (isNew)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
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

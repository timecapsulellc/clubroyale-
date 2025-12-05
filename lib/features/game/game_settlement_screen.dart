import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/game_room.dart';
import 'package:myapp/features/game/providers/game_state_provider.dart';
import 'package:myapp/features/ledger/services/settlement_service.dart';
import 'package:myapp/features/game/services/sound_service.dart';

class GameSettlementScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameSettlementScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameSettlementScreen> createState() => _GameSettlementScreenState();
}

class _GameSettlementScreenState extends ConsumerState<GameSettlementScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _confetti = [];
  
  @override
  void initState() {
    super.initState();
    ref.read(soundServiceProvider).playGameWin();
    
    // Initialize confetti
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Create confetti particles
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1 - random.nextDouble() * 0.3,
        size: 8 + random.nextDouble() * 8,
        color: [
          Colors.amber,
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.purple,
          Colors.orange,
        ][random.nextInt(6)],
        speed: 0.3 + random.nextDouble() * 0.5,
        rotation: random.nextDouble() * 360,
      ));
    }
    
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(currentGameProvider(widget.gameId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found'));
          }

          final sortedPlayers = List<Player>.from(game.players);
          sortedPlayers.sort((a, b) {
            final scoreA = game.scores[a.id] ?? 0;
            final scoreB = game.scores[b.id] ?? 0;
            return scoreB.compareTo(scoreA);
          });

          final winner = sortedPlayers.first;
          final winnerScore = game.scores[winner.id] ?? 0;

          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.surface,
                      colorScheme.surface,
                    ],
                  ),
                ),
              ),
              
              // Confetti overlay
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      confetti: _confetti,
                      progress: _confettiController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
              
              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Trophy with glow effect
                      _buildTrophySection(theme, colorScheme),
                      
                      const SizedBox(height: 16),
                      
                      // Winner announcement
                      _buildWinnerAnnouncement(theme, colorScheme, winner, winnerScore),
                      
                      const SizedBox(height: 32),
                      
                      // Leaderboard
                      _buildLeaderboard(theme, colorScheme, sortedPlayers, game),
                      
                      const SizedBox(height: 24),
                      
                      // Settlement section
                      _buildSettlementSection(theme, colorScheme, game),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      _buildActionButtons(context, colorScheme),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTrophySection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.amber.shade200.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: Icon(
        Icons.emoji_events_rounded,
        size: 100,
        color: Colors.amber.shade600,
      ),
    )
        .animate()
        .scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.3, 0.3),
        )
        .then()
        .shimmer(
          duration: 1500.ms,
          color: Colors.amber.shade200,
        );
  }

  Widget _buildWinnerAnnouncement(
    ThemeData theme,
    ColorScheme colorScheme,
    Player winner,
    int winnerScore,
  ) {
    return Column(
      children: [
        Text(
          '🎉 Winner! 🎉',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
        
        const SizedBox(height: 12),
        
        Text(
          winner.name,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade600, Colors.orange.shade600],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '$winnerScore pts',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5),
      ],
    );
  }

  Widget _buildLeaderboard(
    ThemeData theme,
    ColorScheme colorScheme,
    List<Player> sortedPlayers,
    GameRoom game,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(Icons.leaderboard, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Final Standings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Player list
          ...sortedPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final score = game.scores[player.id] ?? 0;
            final isWinner = index == 0;

            return _buildPlayerRow(
              theme,
              colorScheme,
              index,
              player,
              score,
              isWinner,
            ).animate(delay: (800 + index * 100).ms).fadeIn().slideX(begin: -0.1);
          }),

          const SizedBox(height: 8),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2);
  }

  Widget _buildPlayerRow(
    ThemeData theme,
    ColorScheme colorScheme,
    int index,
    Player player,
    int score,
    bool isWinner,
  ) {
    final medalColors = [
      Colors.amber.shade600,
      Colors.grey.shade400,
      Colors.brown.shade400,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner 
            ? Colors.amber.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isWinner 
            ? Border.all(color: Colors.amber.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index < 3 
                  ? medalColors[index].withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: index < 3
                  ? Icon(
                      Icons.emoji_events,
                      size: 18,
                      color: medalColors[index],
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Player name
          Expanded(
            child: Text(
              player.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: score > 0
                  ? Colors.green.withValues(alpha: 0.1)
                  : score < 0
                      ? Colors.red.withValues(alpha: 0.1)
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${score > 0 ? '+' : ''}$score',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: score > 0
                    ? Colors.green.shade700
                    : score < 0
                        ? Colors.red.shade700
                        : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementSection(
    ThemeData theme,
    ColorScheme colorScheme,
    GameRoom game,
  ) {
    final settlementService = ref.read(settlementServiceProvider);
    final transactions = settlementService.calculateSettlements(game.scores);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Settlements',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (transactions.isEmpty)
            _buildAllSettledCard(theme, colorScheme)
          else
            ...transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final tx = entry.value;
              final fromPlayer = game.players.firstWhere(
                (p) => p.id == tx.fromPlayerId,
                orElse: () => Player(id: 'unknown', name: 'Unknown'),
              );
              final toPlayer = game.players.firstWhere(
                (p) => p.id == tx.toPlayerId,
                orElse: () => Player(id: 'unknown', name: 'Unknown'),
              );

              return _buildSettlementCard(
                theme,
                colorScheme,
                fromPlayer,
                toPlayer,
                tx.amount,
              ).animate(delay: (1000 + index * 150).ms).fadeIn().slideX(begin: 0.1);
            }),
        ],
      ),
    ).animate(delay: 900.ms).fadeIn();
  }

  Widget _buildAllSettledCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.green.shade700, size: 28),
          ),
          const SizedBox(width: 16),
          Text(
            'All settled up!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Player fromPlayer,
    Player toPlayer,
    int amount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // From player
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.red.shade50,
                  child: Text(
                    fromPlayer.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fromPlayer.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Pays',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Arrow and amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$amount',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
          
          // To player
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.green.shade50,
                  child: Text(
                    toPlayer.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  toPlayer.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Receives',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Share button
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Results'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate(delay: 1200.ms).fadeIn().slideY(begin: 0.3),
          
          const SizedBox(height: 12),
          
          // Back to lobby button
          FilledButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Back to Home'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ).animate(delay: 1300.ms).fadeIn().slideY(begin: 0.3),
        ],
      ),
    );
  }
}

// Confetti particle model
class _ConfettiParticle {
  double x;
  double y;
  final double size;
  final Color color;
  final double speed;
  final double rotation;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.rotation,
  });
}

// Confetti painter
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in confetti) {
      final currentY = particle.y + (progress * particle.speed * 1.5);
      if (currentY > 1.1) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1 - (currentY * 0.5).clamp(0, 1))
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width + sin(progress * 10 + particle.rotation) * 20;
      final y = currentY * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 5 + particle.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

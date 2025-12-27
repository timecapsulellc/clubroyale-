/// Game Mode Banner Widget
/// 
/// Displays the current game mode prominently:
/// - 🤖 Practice with AI (solo bot games)
/// - 👥 Multiplayer (all human players)
/// - 🤖+👥 Mixed Game (humans + bots)
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Enum representing the type of game session
enum GameMode {
  /// Playing against AI bots only
  practiceWithAI,
  
  /// Playing with real human players only
  multiplayer,
  
  /// Playing with a mix of humans and bots
  mixedGame,
}

/// A banner widget that displays the current game mode
/// 
/// Shows a compact, stylish indicator at the top of game screens
/// to help users understand who they're playing against.
class GameModeBanner extends StatelessWidget {
  /// Number of bot players in the game
  final int botCount;
  
  /// Number of human players in the game
  final int humanCount;
  
  /// Whether to show a compact version (single line)
  final bool compact;

  const GameModeBanner({
    super.key,
    required this.botCount,
    required this.humanCount,
    this.compact = true,
  });

  /// Determine the game mode based on player composition
  GameMode get gameMode {
    if (humanCount <= 1 && botCount > 0) {
      return GameMode.practiceWithAI;
    } else if (botCount == 0) {
      return GameMode.multiplayer;
    } else {
      return GameMode.mixedGame;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.color.withValues(alpha: 0.3),
            config.color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation for AI games
            if (gameMode == GameMode.practiceWithAI)
              Icon(
                Icons.smart_toy_rounded,
                size: 16,
                color: config.color,
              ).animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.3))
            else
              Icon(
                config.icon,
                size: 16,
                color: config.color,
              ),
            const SizedBox(width: 6),
            Text(
              config.label,
              style: TextStyle(
                color: config.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              _buildPlayerCounts(config.color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCounts(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (humanCount > 0) ...[
            Icon(Icons.person, size: 12, color: color),
            Text(
              '$humanCount',
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
          if (humanCount > 0 && botCount > 0)
            Text(' + ', style: TextStyle(color: color, fontSize: 10)),
          if (botCount > 0) ...[
            Icon(Icons.smart_toy, size: 12, color: color),
            Text(
              '$botCount',
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  _GameModeConfig _getConfig() {
    switch (gameMode) {
      case GameMode.practiceWithAI:
        return _GameModeConfig(
          icon: Icons.smart_toy_rounded,
          label: 'Practice with AI',
          color: Colors.purple.shade300,
        );
      case GameMode.multiplayer:
        return _GameModeConfig(
          icon: Icons.groups_rounded,
          label: 'Multiplayer',
          color: Colors.green.shade400,
        );
      case GameMode.mixedGame:
        return _GameModeConfig(
          icon: Icons.diversity_3_rounded,
          label: 'Mixed Game',
          color: Colors.orange.shade400,
        );
    }
  }
}

class _GameModeConfig {
  final IconData icon;
  final String label;
  final Color color;

  const _GameModeConfig({
    required this.icon,
    required this.label,
    required this.color,
  });
}

/// A minimal inline indicator for tight spaces (e.g., AppBar)
class GameModeChip extends StatelessWidget {
  final int botCount;
  final int humanCount;

  const GameModeChip({
    super.key,
    required this.botCount,
    required this.humanCount,
  });

  @override
  Widget build(BuildContext context) {
    final isAIGame = humanCount <= 1 && botCount > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAIGame 
            ? Colors.purple.withValues(alpha: 0.3)
            : Colors.green.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAIGame ? Icons.smart_toy : Icons.groups,
            size: 14,
            color: isAIGame ? Colors.purple.shade200 : Colors.green.shade200,
          ),
          const SizedBox(width: 4),
          Text(
            isAIGame ? 'AI' : 'Live',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isAIGame ? Colors.purple.shade200 : Colors.green.shade200,
            ),
          ),
        ],
      ),
    );
  }
}

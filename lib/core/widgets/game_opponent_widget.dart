/// Game Opponent Widget
///
/// A reusable widget for displaying opponent players in game screens.
/// Supports both human players and AI bots with distinctive visual treatment.
library;

import 'package:flutter/material.dart';

/// Data model for an opponent player
class GameOpponent {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isBot;
  final bool isCurrentTurn;
  final bool isFolded;
  final String? status; // 'blind', 'seen', 'folded', etc.
  final int? bet;
  final int? score;
  final int? tricksWon;
  final int? bid;
  final int cardCount;

  const GameOpponent({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isBot = false,
    this.isCurrentTurn = false,
    this.isFolded = false,
    this.status,
    this.bet,
    this.score,
    this.tricksWon,
    this.bid,
    this.cardCount = 0,
  });
}

/// Map of bot IDs to their avatar image paths
class BotAvatars {
  static const Map<String, String> avatars = {
    'trickmaster': 'assets/images/bots/trickmaster.png',
    'cardshark': 'assets/images/bots/cardshark.png',
    'luckydice': 'assets/images/bots/luckydice.png',
    'deepthink': 'assets/images/bots/deepthink.png',
    'royalace': 'assets/images/bots/royalace.png',
  };

  /// Get a bot avatar based on bot ID or index
  static String getAvatar(String botId) {
    // Try to match by name
    for (final entry in avatars.entries) {
      if (botId.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    // Default based on hash
    final index = botId.hashCode.abs() % avatars.length;
    return avatars.values.elementAt(index);
  }

  /// Get all available bot names
  static List<String> get names => avatars.keys.toList();
}

/// Displays a single opponent in the game table
class GameOpponentWidget extends StatelessWidget {
  final GameOpponent opponent;
  final double size;
  final bool showStats;
  final VoidCallback? onTap;

  const GameOpponentWidget({
    super.key,
    required this.opponent,
    this.size = 60,
    this.showStats = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: opponent.isFolded ? 0.4 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with turn indicator
            _buildAvatar(),
            const SizedBox(height: 4),
            // Name
            _buildName(),
            // Stats (bet, score, etc.)
            if (showStats) _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    Widget avatarContent;

    if (opponent.isBot) {
      // Bot avatar with distinctive styling
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          // Bot avatar image
          ClipOval(
            child: Image.asset(
              BotAvatars.getAvatar(opponent.id),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade700, Colors.purple.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
          // AI badge
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (opponent.avatarUrl != null) {
      // Human with custom avatar
      avatarContent = ClipOval(
        child: Image.network(
          opponent.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        ),
      );
    } else {
      // Human with default avatar
      avatarContent = _buildDefaultAvatar();
    }

    // Wrap with turn indicator
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: opponent.isCurrentTurn
              ? Colors.green
              : (opponent.isBot
                    ? Colors.purple.withValues(alpha: 0.5)
                    : Colors.white24),
          width: opponent.isCurrentTurn ? 3 : 1,
        ),
        boxShadow: opponent.isCurrentTurn
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: avatarContent,
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade600, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        opponent.isFolded ? Icons.block : Icons.person,
        color: opponent.isFolded ? Colors.grey : Colors.white,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (opponent.isBot) ...[
            Icon(Icons.smart_toy, size: 10, color: Colors.purple.shade300),
            const SizedBox(width: 2),
          ],
          Text(
            opponent.name,
            style: TextStyle(
              color: opponent.isBot ? Colors.purple.shade200 : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = <Widget>[];

    if (opponent.status != null) {
      stats.add(_buildStatusBadge(opponent.status!));
    }

    if (opponent.bet != null) {
      stats.add(
        Text(
          'Bet: ${opponent.bet}',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      );
    }

    if (opponent.bid != null && opponent.tricksWon != null) {
      stats.add(
        Text(
          '${opponent.tricksWon}/${opponent.bid}',
          style: TextStyle(
            color: (opponent.tricksWon ?? 0) >= (opponent.bid ?? 0)
                ? Colors.green
                : Colors.amber,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (opponent.score != null) {
      stats.add(
        Text(
          'Score: ${opponent.score}',
          style: const TextStyle(color: Colors.amber, fontSize: 10),
        ),
      );
    }

    if (opponent.cardCount > 0) {
      stats.add(_buildCardCount());
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(spacing: 4, children: stats),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(config.emoji, style: const TextStyle(fontSize: 10)),
    );
  }

  Widget _buildCardCount() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        opponent.cardCount.clamp(0, 5),
        (i) => Transform.translate(
          offset: Offset(-4.0 * i, 0),
          child: Container(
            width: 12,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A0080), Color(0xFF2D004D)],
              ),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.white24, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'blind':
        return _StatusConfig(emoji: '🙈', color: Colors.blue);
      case 'seen':
        return _StatusConfig(emoji: '👀', color: Colors.orange);
      case 'folded':
        return _StatusConfig(emoji: '🏳️', color: Colors.grey);
      case 'pass':
        return _StatusConfig(emoji: '⏭️', color: Colors.grey);
      case 'bet':
        return _StatusConfig(emoji: '💰', color: Colors.green);
      default:
        return _StatusConfig(emoji: '❓', color: Colors.white);
    }
  }
}

class _StatusConfig {
  final String emoji;
  final Color color;
  const _StatusConfig({required this.emoji, required this.color});
}

/// A row of opponents for games with 2-3 opponents
class OpponentRow extends StatelessWidget {
  final List<GameOpponent> opponents;
  final double avatarSize;

  const OpponentRow({super.key, required this.opponents, this.avatarSize = 50});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Changed to min to work inside scroll
        mainAxisAlignment: MainAxisAlignment.center, // Center contents
        children: opponents.map((opponent) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GameOpponentWidget(opponent: opponent, size: avatarSize),
          );
        }).toList(),
      ),
    );
  }
}

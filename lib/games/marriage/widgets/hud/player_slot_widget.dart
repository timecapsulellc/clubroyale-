import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Professional player slot widget for 8-player table layout
/// Shows avatar, name, card count, turn indicator, and timer
class PlayerSlotWidget extends StatelessWidget {
  final String playerName;
  final String? avatarUrl;
  final int cardCount;
  final bool isCurrentTurn;
  final bool hasVisited;
  final int? maalPoints;
  final int? timerSeconds;
  final int? timerTotal;
  final bool isMe;
  final VoidCallback? onTap;

  const PlayerSlotWidget({
    super.key,
    required this.playerName,
    this.avatarUrl,
    required this.cardCount,
    this.isCurrentTurn = false,
    this.hasVisited = false,
    this.maalPoints,
    this.timerSeconds,
    this.timerTotal,
    this.isMe = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentTurn
                ? CasinoColors.gold
                : (isMe ? Colors.blue : Colors.white24),
            width: isCurrentTurn ? 2 : 1,
          ),
          boxShadow: isCurrentTurn
              ? [
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with card count badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getAvatarColor(),
                    border: Border.all(
                      color: hasVisited ? Colors.green : Colors.white30,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildAvatarIcon(),
                          ),
                        )
                      : _buildAvatarIcon(),
                ),

                // Card count badge (top-right)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CasinoColors.gold,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      '$cardCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Visited indicator (bottom-right)
                if (hasVisited)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Player name
            Text(
              _displayName,
              style: TextStyle(
                color: isMe ? Colors.blue[200] : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Maal points (if visited)
            if (maalPoints != null && hasVisited)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$maalPoints Maal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Turn timer (if current turn)
            if (isCurrentTurn && timerSeconds != null && timerTotal != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: _buildMiniTimer(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarIcon() {
    return Center(
      child: Text(
        playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMiniTimer() {
    final progress = timerSeconds! / timerTotal!;
    final color = progress > 0.5
        ? Colors.green
        : (progress > 0.2 ? Colors.orange : Colors.red);

    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Text(
            '$timerSeconds',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor() {
    if (isMe) return Colors.blue[800]!;
    // Generate consistent color from player name
    final hash = playerName.hashCode;
    final colors = [
      Colors.purple[700]!,
      Colors.teal[700]!,
      Colors.orange[700]!,
      Colors.pink[700]!,
      Colors.indigo[700]!,
      Colors.cyan[700]!,
      Colors.amber[700]!,
      Colors.deepPurple[700]!,
    ];
    return colors[hash.abs() % colors.length];
  }

  String get _displayName {
    if (isMe) return 'YOU';
    if (playerName.length > 8) {
      return '${playerName.substring(0, 6)}..';
    }
    return playerName;
  }
}

/// Compact version for smaller screens or many players
class PlayerSlotCompact extends StatelessWidget {
  final String playerName;
  final int cardCount;
  final bool isCurrentTurn;
  final bool hasVisited;

  const PlayerSlotCompact({
    super.key,
    required this.playerName,
    required this.cardCount,
    this.isCurrentTurn = false,
    this.hasVisited = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget slot = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.5),
        border: Border.all(
          color: isCurrentTurn ? CasinoColors.gold : Colors.white30,
          width: isCurrentTurn ? 2 : 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Card count badge
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: CasinoColors.gold,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$cardCount',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Visited indicator
          if (hasVisited)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 8),
              ),
            ),
        ],
      ),
    );

    if (isCurrentTurn) {
      slot = slot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 800.ms,
          );
    }

    return slot;
  }
}

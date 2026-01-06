/// Circular Opponent Widget
///
/// Premium UI component for displaying opponents in Marriage game
/// Features:
/// - Circular avatar with gold border
/// - Circular turn timer progress
/// - Card count badge
/// - Active turn glow effect
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

import 'package:clubroyale/core/widgets/game_opponent_widget.dart';

class CircularOpponentWidget extends StatelessWidget {
  final GameOpponent opponent;
  final double size;
  final int cardCount;
  final double? turnProgress; // 0.0 to 1.0 (null if not turn)

  const CircularOpponentWidget({
    super.key,
    required this.opponent,
    this.size = 60.0,
    this.cardCount = 0,
    this.turnProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isTurn = opponent.isCurrentTurn;
    final status = opponent.status;
    
    // Compact size for mobile landscape (40px row height)
    final compactSize = size.clamp(30.0, 36.0);

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with Timer Ring (compact)
          SizedBox(
            width: compactSize + 4,
            height: compactSize + 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Active Glow
                if (isTurn)
                  Container(
                    width: compactSize + 4,
                    height: compactSize + 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),

                // Timer Ring
                if (isTurn && turnProgress != null)
                  SizedBox(
                    width: compactSize + 2,
                    height: compactSize + 2,
                    child: CircularProgressIndicator(
                      value: turnProgress,
                      strokeWidth: 2,
                      backgroundColor: Colors.grey.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    ),
                  ),

                // Avatar Circle
                Container(
                  width: compactSize,
                  height: compactSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D1B4E),
                    border: Border.all(
                      color: isTurn ? Colors.greenAccent : CasinoColors.gold,
                      width: isTurn ? 2 : 1,
                    ),
                    image: DecorationImage(
                      image: AssetImage(_getAvatarAsset(opponent.name)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opponent.name.isNotEmpty ? opponent.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: CasinoColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: compactSize * 0.35,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card Count Badge
                if (cardCount > 0)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: CasinoColors.velvetRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 0.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Center(
                        child: Text(
                          '$cardCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Name Badge (compact)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTurn ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opponent.name.length > 6 ? '${opponent.name.substring(0, 6)}...' : opponent.name,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
                if (status != null && status.isNotEmpty)
                  Text(
                    status,
                    style: TextStyle(
                      color: isTurn ? Colors.greenAccent : Colors.white70,
                      fontSize: 7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAvatarAsset(String name) {
    const avatars = [
      'assets/images/bots/cardshark.png',
      'assets/images/bots/deepthink.png',
      'assets/images/bots/luckydice.png',
      'assets/images/bots/royalace.png',
      'assets/images/bots/trickmaster.png',
    ];
    // Use name hash to pick a consistent avatar
    final index = name.hashCode.abs() % avatars.length;
    return avatars[index];
  }
}

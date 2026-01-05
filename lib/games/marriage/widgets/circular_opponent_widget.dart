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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with Timer Ring
        SizedBox(
          width: size + 10,
          height: size + 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Active Glow
              if (isTurn)
                Container(
                  width: size + 10,
                  height: size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Timer Ring
              if (isTurn && turnProgress != null)
                SizedBox(
                  width: size + 8,
                  height: size + 8,
                  child: CircularProgressIndicator(
                    value: turnProgress,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                ),

              // Avatar Circle
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D1B4E), // Deep purple bg
                  border: Border.all(
                    color: isTurn ? Colors.greenAccent : CasinoColors.gold,
                    width: isTurn ? 2 : 1.5,
                  ),
                  image: DecorationImage(
                    image: AssetImage(_getAvatarAsset(opponent.name)),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    opponent.name.isNotEmpty ? opponent.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: CasinoColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.4,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: Offset(1, 1),
                        ),
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CasinoColors.velvetRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '$cardCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Name & Status
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isTurn ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                opponent.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (status != null && status.isNotEmpty)
                Text(
                  status,
                  style: TextStyle(
                    color: isTurn ? Colors.greenAccent : Colors.white70,
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
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

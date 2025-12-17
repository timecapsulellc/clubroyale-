import 'package:flutter/material.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/engine/widgets/playing_card_widget.dart';

/// Widget to display the trick table (center play area)
class TrickTableWidget extends StatelessWidget {
  final Trick? currentTrick;
  final List<Player> players;
  final String currentUserId;

  const TrickTableWidget({
    super.key,
    this.currentTrick,
    required this.players,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Arrange players: current user at bottom, others around the table
    final playerPositions = _getPlayerPositions();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Card(
          color: Colors.green.shade700,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Center table decoration
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade800,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                   child: Center(
                    child: Icon(
                      Icons.casino_outlined,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 40,
                    ),
                  ),
                ),
              ),
              // Cards played in trick
              if (currentTrick != null)
                ...currentTrick!.cards.map((playedCard) {
                  final position = playerPositions[playedCard.playerId];
                  if (position == null) return const SizedBox.shrink();

                  return Positioned(
                    top: position.top,
                    bottom: position.bottom,
                    left: position.left,
                    right: position.right,
                    child: Center(
                      child: PlayingCardWidget(
                        card: playedCard.card,
                        width: 70,
                        height: 105,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, CardPosition> _getPlayerPositions() {
    final positions = <String, CardPosition>{};

    // Find current user index
    final currentUserIndex =
        players.indexWhere((p) => p.id == currentUserId);

    if (currentUserIndex == -1) return positions;

    // Arrange players: current user bottom, then left, top, right
    final arrangement = [
      currentUserIndex, // bottom
      (currentUserIndex + 1) % players.length, // left
      (currentUserIndex + 2) % players.length, // top
      (currentUserIndex + 3) % players.length, // right
    ];

    final positionConfigs = [
      CardPosition(bottom: 20, left: null, right: null, top: null), // bottom
      CardPosition(left: 20, top: null, bottom: null, right: null), // left
      CardPosition(top: 20, left: null, right: null, bottom: null), // top
      CardPosition(right: 20, top: null, bottom: null, left: null), // right
    ];

    for (int i = 0; i < arrangement.length && i < players.length; i++) {
      final playerIndex = arrangement[i];
      if (playerIndex < players.length) {
        positions[players[playerIndex].id] = positionConfigs[i];
      }
    }

    return positions;
  }
}

class CardPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  CardPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
  });
}

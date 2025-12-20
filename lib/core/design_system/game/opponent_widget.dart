/// Opponent Widget - Display opponent info on game table
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/core/design_system/game/table_meld_widget.dart';

/// Data model for opponent display
class OpponentData {
  final String playerId;
  final String name;
  final String? avatarUrl;
  final int cardCount;
  final int maalPoints;
  final bool isVisited;
  final bool isConnected;
  final List<Meld> melds;

  const OpponentData({
    required this.playerId,
    required this.name,
    this.avatarUrl,
    required this.cardCount,
    this.maalPoints = 0,
    this.isVisited = false,
    this.isConnected = true,
    this.melds = const [],
  });
}

/// Widget to display an opponent on the table
class OpponentWidget extends StatelessWidget {
  final OpponentData data;
  final bool isCurrentTurn;
  final bool showMaal;

  const OpponentWidget({
    super.key,
    required this.data,
    this.isCurrentTurn = false,
    this.showMaal = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with indicators
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentTurn
                      ? const Color(0xFFD4AF37)
                      : data.isVisited
                          ? Colors.green
                          : Colors.white24,
                  width: isCurrentTurn ? 3 : 2,
                ),
                boxShadow: isCurrentTurn
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: data.avatarUrl != null
                    ? NetworkImage(data.avatarUrl!)
                    : null,
                backgroundColor: const Color(0xFF2d1b4e),
                child: data.avatarUrl == null
                    ? Text(
                        data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),

            // Card count badge
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a0a2e),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.style,
                      color: Colors.white70,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${data.cardCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Visit status
            if (data.isVisited)
              Positioned(
                top: -2,
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

            // Disconnected overlay
            if (!data.isConnected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 4),

        // Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            data.name,
            style: TextStyle(
              color: isCurrentTurn ? const Color(0xFFD4AF37) : Colors.white70,
              fontSize: 11,
              fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Maal points
        if (showMaal && data.maalPoints > 0) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '💎 ${data.maalPoints}',
              style: const TextStyle(
                color: Colors.purple,
                fontSize: 9,
              ),
            ),
          ),
        ],

        // Declared Melds (if visited)
        if (data.melds.isNotEmpty) ...[
          const SizedBox(height: 8),
          TableMeldsWidget(
            melds: data.melds,
            scale: 0.4, // Small scale for opponent melds
            showLabels: false,
          ),
        ],
      ],
    );

    // Turn animation
    if (isCurrentTurn) {
      widget = widget
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 800.ms,
          );
    }

    return widget;
  }
}

/// Compact opponent widget for smaller screens
class OpponentWidgetCompact extends StatelessWidget {
  final OpponentData data;
  final bool isCurrentTurn;

  const OpponentWidgetCompact({
    super.key,
    required this.data,
    this.isCurrentTurn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: isCurrentTurn
            ? Border.all(color: const Color(0xFFD4AF37), width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini avatar
          CircleAvatar(
            radius: 12,
            backgroundImage: data.avatarUrl != null
                ? NetworkImage(data.avatarUrl!)
                : null,
            backgroundColor: const Color(0xFF2d1b4e),
            child: data.avatarUrl == null
                ? Text(
                    data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 4),

          // Card count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${data.cardCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

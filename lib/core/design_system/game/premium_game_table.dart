/// Premium Game Table - Full casino-style table layout
/// 
/// Features:
/// - Felt texture background
/// - Ambient lighting effects
/// - Table edge decoration
/// - Ellipse-based opponent positioning
/// - Turn indicator with glow
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/design_system/game/felt_texture_painter.dart';
import 'package:clubroyale/core/design_system/game/opponent_widget.dart';

/// Premium game table with felt background and opponent positioning
class PremiumGameTable extends StatelessWidget {
  final Widget centerContent;
  final List<OpponentData> opponents;
  final Widget playerHand;
  final Widget? actionBar;
  final Widget? statusOverlay;
  final String? currentTurnPlayerId;
  final String myPlayerId;
  final bool isMyTurn;
  final Function(String cardId)? onCardDroppedOnDiscard;

  const PremiumGameTable({
    super.key,
    required this.centerContent,
    required this.opponents,
    required this.playerHand,
    this.actionBar,
    this.statusOverlay,
    this.currentTurnPlayerId,
    required this.myPlayerId,
    this.isMyTurn = false,
    this.onCardDroppedOnDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Premium felt background
        const FeltBackground(
          showTexture: true,
          showAmbientLight: true,
          child: SizedBox.expand(),
        ),

        // 2. Table edge decoration
        _buildTableEdge(),

        // 3. Game layout
        SafeArea(
          child: Column(
            children: [
              // Status overlay (Tiplu, Visit, Maal)
              if (statusOverlay != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: statusOverlay!,
                ),

              // Opponents area
              Expanded(
                flex: 3,
                child: _buildOpponentsArea(),
              ),

              // Center area (deck, discard, tiplu)
              Expanded(
                flex: 3,
                child: Center(
                  child: TableCenterArea(
                    deckWidget: (centerContent as TableCenterArea).deckWidget,
                    tipluWidget: (centerContent as TableCenterArea).tipluWidget,
                    discardWidget: (centerContent as TableCenterArea).discardWidget,
                    deckCount: (centerContent as TableCenterArea).deckCount,
                    onDeckTap: (centerContent as TableCenterArea).onDeckTap,
                    onDiscardTap: (centerContent as TableCenterArea).onDiscardTap,
                    onCardDroppedOnDiscard: onCardDroppedOnDiscard,
                  ),
                ),
              ),

              // Player hand
              playerHand,

              // Action bar
              if (actionBar != null) actionBar!,
            ],
          ),
        ),

        // 4. Turn indicator overlay
        if (isMyTurn) _buildMyTurnIndicator(),
      ],
    );
  }

  Widget _buildTableEdge() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B4513).withValues(alpha: 0.4),
          width: 6,
        ),
        boxShadow: [
          // Inner shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: -4,
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentsArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (opponents.isEmpty) {
          return const SizedBox.shrink();
        }
        return Stack(
          clipBehavior: Clip.none,
          children: _positionOpponents(
            constraints.maxWidth,
            constraints.maxHeight,
          ),
        );
      },
    );
  }

  List<Widget> _positionOpponents(double width, double height) {
    if (opponents.isEmpty) return [];

    final widgets = <Widget>[];
    final count = opponents.length;

    // Ellipse parameters
    final centerX = width / 2;
    final centerY = height * 0.65;
    final radiusX = width * 0.42;
    final radiusY = height * 0.5;

    // Step calculation - distribute evenly from left to right through top
    final step = math.pi / (count + 1);

    for (int i = 0; i < count; i++) {
      // Calculate angle (from left π to right 0)
      final angle = math.pi - (step * (i + 1));

      // Calculate position on ellipse
      final x = centerX + radiusX * math.cos(angle);
      final y = centerY - radiusY * math.sin(angle).abs();

      final opponent = opponents[i];
      final isCurrentTurn = opponent.playerId == currentTurnPlayerId;

      widgets.add(
        Positioned(
          left: x - 45,
          top: y - 35,
          child: OpponentWidget(
            data: opponent,
            isCurrentTurn: isCurrentTurn,
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildMyTurnIndicator() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37),
              width: 3,
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 2000.ms,
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        );
  }
}

/// Center area widget for deck, discard pile, and tiplu display
class TableCenterArea extends StatelessWidget {
  final Widget? deckWidget;
  final Widget? discardWidget;
  final Widget? tipluWidget;
  final int deckCount;
  final VoidCallback? onDeckTap;
  final VoidCallback? onDiscardTap;
  final Function(String cardId)? onCardDroppedOnDiscard;

  const TableCenterArea({
    super.key,
    this.deckWidget,
    this.discardWidget,
    this.tipluWidget,
    this.deckCount = 0,
    this.onDeckTap,
    this.onDiscardTap,
    this.onCardDroppedOnDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Deck
          if (deckWidget != null) ...[
            GestureDetector(
              onTap: onDeckTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  deckWidget!,
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$deckCount',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],

          // Tiplu (center wild card)
          if (tipluWidget != null) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7c3aed).withValues(alpha: 0.6),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: tipluWidget!,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7c3aed).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TIPLU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
          ],

          // Discard pile
          if (discardWidget != null)
            DragTarget<String>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                onCardDroppedOnDiscard?.call(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                return GestureDetector(
                  onTap: onDiscardTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: isHovering
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              )
                            : null,
                        child: discardWidget!,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (isHovering ? Colors.red : Colors.black)
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DISCARD',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

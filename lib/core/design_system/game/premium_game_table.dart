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
              Expanded(flex: 3, child: _buildOpponentsArea()),

              // Center area (deck, discard, tiplu)
              Expanded(
                flex: 3,
                child: Center(
                  child: TableCenterArea(
                    deckWidget: (centerContent as TableCenterArea).deckWidget,
                    tipluWidget: (centerContent as TableCenterArea).tipluWidget,
                    discardWidget:
                        (centerContent as TableCenterArea).discardWidget,
                    deckCount: (centerContent as TableCenterArea).deckCount,
                    onDeckTap: (centerContent as TableCenterArea).onDeckTap,
                    onDiscardTap:
                        (centerContent as TableCenterArea).onDiscardTap,
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
    final aspectRatio = width / height;
    final isLandscape = aspectRatio > 1.2;

    // Responsive Ellipse Parameters
    final centerX = width / 2;
    // Push center up slightly to make room for player hand
    final centerY = height * (isLandscape ? 0.6 : 0.55);

    // Adjust radius based on screen shape and player count
    // Tighter ellipse for more players to fit them in view
    double radiusX = width * (isLandscape ? 0.4 : 0.45);
    double radiusY = height * (isLandscape ? 0.4 : 0.35);

    // Dynamic scale factor for opponent widgets based on count
    // 8 players needs slightly smaller widgets or tighter packing
    // But we'll keep widget size fixed for consistency and adjust position

    // Distribution logic:
    // We want to distribute players along the top arc of the ellipse
    // From angle PI (left) to 0 (right), but represented as 0 to PI in math terms usually.
    // Let's use standard unit circle: 0 is right, PI is left.
    // We want them from PI (left) to 0 (right).
    // Actually, let's use a range from PI - margin to 0 + margin

    // Define the visible arc for opponents (excluding self at bottom)
    // We want roughly 180 degrees (PI) coverage at the top
    const startAngle = math.pi; // Left
    const endAngle = 0.0; // Right
    final totalSweep = startAngle - endAngle;

    // Evenly distribute
    // If we have N opponents, we have N+1 gaps if we want padding on sides
    // Or we can distribute them at specific points

    for (int i = 0; i < count; i++) {
      // Linear interpolation for angle
      // i=0 -> left-most, i=count-1 -> right-most
      double t;
      if (count == 1) {
        t = 0.5; // Single opponent at top center
      } else {
        t = i / (count - 1);
      }

      // Calculate angle
      // We add some padding at edges so players aren't exactly at 0 and PI (hard edges)
      // 10% padding on each side of the arc
      final padding = totalSweep * 0.1;
      final effectiveSweep = totalSweep - (2 * padding);
      final angle = startAngle - padding - (t * effectiveSweep);

      // Positioning
      final x = centerX + radiusX * math.cos(angle);
      // For Y, we want the top half of ellipse, so -sin(angle)
      // Since screen Y grows downwards, center - (radius * sin) is correct for top arc
      final y = centerY - radiusY * math.sin(angle);

      final opponent = opponents[i];
      final isCurrentTurn = opponent.playerId == currentTurnPlayerId;

      // For 8 players (7 opponents), use compact widget on smaller screens
      final bool useCompact = count > 5 && width < 600;

      widgets.add(
        Positioned(
          left: x - (useCompact ? 40 : 45), // center align fix approx
          top: y - (useCompact ? 25 : 35),
          child: useCompact
              ? OpponentWidgetCompact(
                  data: opponent,
                  isCurrentTurn: isCurrentTurn,
                )
              : OpponentWidget(data: opponent, isCurrentTurn: isCurrentTurn),
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
                border: Border.all(color: const Color(0xFFD4AF37), width: 3),
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
                          style: TextStyle(color: Colors.white70, fontSize: 9),
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

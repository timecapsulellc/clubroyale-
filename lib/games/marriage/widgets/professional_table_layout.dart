import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Professional table layout with wooden rail border
/// Optimized for 2-8 players around an elliptical table
class ProfessionalTableLayout extends StatelessWidget {
  final Widget centerArea;
  final List<Widget> opponents;
  final Widget myHand;
  final int playerCount;
  final int currentPlayerIndex; // 0 = me, 1-7 = opponents

  const ProfessionalTableLayout({
    super.key,
    required this.centerArea,
    required this.opponents,
    required this.myHand,
    this.playerCount = 5,
    this.currentPlayerIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Detect platform context for optimal layout
        final isDesktop = width > 1000 && height > 600;
        final isLandscapeMobile = width > height && height < 500;
        final isTablet = !isDesktop && !isLandscapeMobile && width > 600;
        
        // Hand takes different ratios based on screen type
        // Desktop: 35% (more space for cards), Mobile: 25%, Tablet: 38%
        final double handHeightRatio;
        if (isDesktop) {
          handHeightRatio = 0.35;
        } else if (isLandscapeMobile) {
          handHeightRatio = 0.25;
        } else if (isTablet) {
          handHeightRatio = 0.38;
        } else {
          handHeightRatio = 0.42; // Portrait mobile
        }
        
        final handHeight = height * handHeightRatio;
        final tableHeight = height * (1.0 - handHeightRatio);
        final railWidth = isDesktop ? 16.0 : 12.0;

        return Stack(
          children: [
            // 1. Table Rail Border (bottom layer)
            Positioned(
              left: railWidth,
              top: railWidth,
              right: railWidth,
              bottom: handHeight, // Hand overlaps slightly or touches bottom of rail
              child: _buildTableRail(),
            ),

            // 2. Felt Surface
            Positioned(
              left: railWidth + 4,
              top: railWidth + 4,
              right: railWidth + 4,
              bottom: handHeight + 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: CasinoColors.greenFeltGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Center Area (Deck/Discard)
            Positioned(
              left: width / 2 - 140,
              top: tableHeight * (isLandscapeMobile ? 0.30 : 0.35),
              width: 280,
              child: centerArea,
            ),

            // 4. Opponents positioned around the arc
            ..._buildOpponentPositions(
              width: width,
              tableHeight: tableHeight,
              railWidth: railWidth,
              isMobile: isLandscapeMobile,
              isDesktop: isDesktop,
            ),

            // 5. My Hand (fixed at bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: handHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: myHand,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableRail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5a3a20), // Lighter wood
            Color(0xFF3d2410), // Dark wood
            Color(0xFF5a3a20), // Lighter wood
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8b6914).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: CasinoColors.gold.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOpponentPositions({
    required double width,
    required double tableHeight,
    required double railWidth,
    required bool isMobile,
    bool isDesktop = false,
  }) {
    if (opponents.isEmpty) return [];

    final widgets = <Widget>[];
    final count = opponents.length;

    // Calculate ellipse center and radii for opponent placement
    final cx = width / 2;
    // Push opponents higher on mobile to clear center area
    final cy = tableHeight * (isMobile ? 0.30 : 0.40); 
    final rx = (width - railWidth * 2) * 0.44; // Slightly wider
    final ry = tableHeight * (isMobile ? 0.25 : 0.30);

    // Calculate optimal positions based on player count
    final positions = _getOptimalPositions(count);

    for (int i = 0; i < count && i < positions.length; i++) {
      final angle = positions[i];
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);

      // Adjust widget size based on player count and screen size
      double baseSize = count > 5 ? 60.0 : 80.0;
      if (isDesktop) {
        baseSize *= 1.2; // Scale UP for larger desktop screens
      } else if (isMobile) {
        baseSize *= 0.85; // Scale down for mobile
      }
      final slotSize = baseSize;

      widgets.add(
        Positioned(
          left: x - slotSize / 2,
          top: y - slotSize / 2,
          width: slotSize,
          child: opponents[i],
        ),
      );
    }

    return widgets;
  }

  /// Get optimal angle positions based on opponent count
  List<double> _getOptimalPositions(int count) {
    // Angles in radians, measured from 3 o'clock position
    // -π/2 = top, π = left, 0 = right

    switch (count) {
      case 1:
        return [-math.pi / 2]; // Top center
      case 2:
        return [
          -math.pi * 0.7, // Top-left
          -math.pi * 0.3, // Top-right
        ];
      case 3:
        return [
          -math.pi * 0.8, // Left
          -math.pi / 2, // Top
          -math.pi * 0.2, // Right
        ];
      case 4:
        return [
          math.pi * 0.85, // Far left
          -math.pi * 0.7, // Top-left
          -math.pi * 0.3, // Top-right
          -math.pi * 0.15, // Far right
        ];
      case 5:
        return [
          math.pi * 0.85, // Far left
          -math.pi * 0.75, // Upper-left
          -math.pi / 2, // Top
          -math.pi * 0.25, // Upper-right
          -math.pi * 0.15, // Far right
        ];
      case 6:
        return [
          math.pi * 0.9, // Left-bottom
          math.pi * 0.7, // Left-top
          -math.pi * 0.7, // Top-left
          -math.pi * 0.3, // Top-right
          -math.pi * 0.1, // Right-top
          0.1, // Right-bottom
        ];
      case 7:
        return [
          math.pi * 0.9, // Left-bottom
          math.pi * 0.7, // Left-mid
          -math.pi * 0.8, // Upper-left
          -math.pi / 2, // Top
          -math.pi * 0.2, // Upper-right
          0.0, // Right-mid
          0.1, // Right-bottom
        ];
      default:
        // For 8+ players, distribute evenly
        final positions = <double>[];
        final startAngle = math.pi * 0.9; // Start from left-bottom
        final endAngle = 0.1; // End at right-bottom
        final totalArc =
            startAngle - endAngle + math.pi; // Going around the top
        final step = totalArc / (count + 1);

        for (int i = 0; i < count; i++) {
          var angle = startAngle - (step * (i + 1));
          // Normalize to -π to π range
          while (angle < -math.pi) {
            angle += 2 * math.pi;
          }
          positions.add(angle);
        }
        return positions;
    }
  }
}

/// Simple table rail decorator for existing layouts
class TableRailBorder extends StatelessWidget {
  final Widget child;
  final double railWidth;

  const TableRailBorder({
    super.key,
    required this.child,
    this.railWidth = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5a3a20), Color(0xFF3d2410), Color(0xFF5a3a20)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(railWidth),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: CasinoColors.greenFeltGradient,
        ),
        child: child,
      ),
    );
  }
}

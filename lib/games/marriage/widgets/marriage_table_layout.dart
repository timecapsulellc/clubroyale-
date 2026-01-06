import 'dart:math' as math;
import 'package:flutter/material.dart';

class MarriageTableLayout extends StatelessWidget {
  final Widget centerArea;
  final List<Widget> opponents;
  final Widget myHand;
  final Widget myAvatar; // Optional: if we want to show "Me" avatar separately

  const MarriageTableLayout({
    super.key,
    required this.centerArea,
    required this.opponents,
    required this.myHand,
    this.myAvatar = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isMobileLandscape = height < 500;

        // For mobile landscape, use a simpler layout with clear space division
        if (isMobileLandscape) {
          return _buildMobileLandscapeLayout(width, height);
        }

        // Desktop/Tablet layout with ellipse positioning
        final centerX = width / 2;
        final centerY = height * 0.45;
        final radiusX = width * 0.45;
        final radiusY = height * 0.35;

        return Stack(
          children: [
            // 1. Center Area (Deck/Discard)
            Positioned(
              left: centerX - 160,
              top: centerY - 100,
              width: 320,
              height: 200,
              child: Center(child: centerArea),
            ),

            // 2. Opponents
            ..._buildOpponentPositions(centerX, centerY, radiusX, radiusY),

            // 3. My Hand - 35% height at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: height * 0.35,
              child: myHand,
            ),
          ],
        );
      },
    );
  }

  /// Optimized layout for mobile landscape (height < 500)
  /// Matches reference app proportions:
  /// - Opponents: 40px (compact row of avatars)
  /// - Center: Flexible (deck/discard area)  
  /// - Hand: 180px max (cards with grouping)
  Widget _buildMobileLandscapeLayout(double width, double height) {
    const opponentRowHeight = 40.0;
    const maxHandHeight = 180.0;
    
    // Hand takes minimum of maxHandHeight or 45% of screen
    final handHeight = (height * 0.45).clamp(120.0, maxHandHeight);
    final centerAreaHeight = height - opponentRowHeight - handHeight;

    return Column(
      children: [
        // Top Row: Opponents in horizontal row (compact, clipped to prevent overflow)
        ClipRect(
          child: SizedBox(
            height: opponentRowHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: opponents
                  .map((o) => SizedBox(
                        height: opponentRowHeight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: o,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Center Area: Deck/Discard (flexible height)
        Expanded(
          child: SizedBox(
            width: width,
            child: Center(
              child: Transform.scale(scale: 0.7, child: centerArea),
            ),
          ),
        ),

        // Bottom: Hand Cards (capped at maxHandHeight)
        SizedBox(
          height: handHeight,
          width: width,
          child: ClipRect(child: myHand),
        ),
      ],
    );
  }

  List<Widget> _buildOpponentPositions(
    double cx,
    double cy,
    double rx,
    double ry,
  ) {
    if (opponents.isEmpty) return [];

    final widgets = <Widget>[];
    final count = opponents.length;

    // Distribute evenly along the upper arc
    // Start Angle: 3.14 (Left/9oclock)
    // End Angle: 0 (Right/3oclock)
    // Note: In Flutter/Canvas, 0 is Right, negative angles go Counter-Clockwise (Up)

    // We want to span from Left (Pi) through Top (-Pi/2) to Right (0)
    // Actually, traditionally seat 1 is left of dealer...

    // Simple distribution: From Angle ~190 degrees to ~-10 degrees?

    // Let's use a restricted arc to keep them visible and not too low
    // Start: 180 degrees (Pi) -> Left
    // End: 0 degrees -> Right
    // Range: Pi

    // If we have many players, we might need to go slightly below the equator

    // Updated for Bhoos Layout: Top Row Semi-Circle
    // We want opponents positioned strictly along the top arc.
    // Angles in Flutter (Y down):
    // -Pi (Left) -> -Pi/2 (Top) -> 0 (Right)
    
    // Top-Left start: ~ -2.6 rad (-150 deg)
    // Top-Right end: ~ -0.5 rad (-30 deg)
    double startAngle = -2.6; 
    double endAngle = -0.5;

    // Distribute available opponents evenly across this arc
    double step;
    if (count <= 1) {
      // Single opponent at Top-Center
      startAngle = -math.pi / 2;
      endAngle = -math.pi / 2;
      step = 0;
    } else {
      step = (endAngle - startAngle) / (count - 1);
    }

    for (int i = 0; i < count; i++) {
      double angle;
      if (count <= 1) {
        angle = startAngle;
      } else {
        angle = startAngle + (step * i);
      }

      // Calculate position
      // Using an ellipse equation: x = a cos(t), y = b sin(t)
      // Note: y is inverted in screen coords (down is positive), so -sin(t) typically for "up"
      // But since our angle definitions (Pi to 0) cover the "Top" half relative to standard circle if using -sin?
      // Let's stick to standard cos/sin and debug.

      // Angle Pi (Left) -> Cos = -1, Sin = 0. X = -r, Y = 0.
      // Angle -Pi/2 (Top) -> Cos = 0, Sin = -1. X = 0, Y = -r.

      // We want Y to be relative to CenterY.
      // If we use `y = cy + ry * sin(angle)`:
      // At Pi (Left): y = cy (Mid). Correct.
      // At -Pi/2 (Top): sin(-Pi/2) = -1. y = cy - ry (Top). Correct.

      double x = cx + rx * math.cos(angle);
      double y = cy + ry * math.sin(angle);

      // Adjust for avatar size (centering the widget)
      double avatarSize = 60.0; // Assume avg avatar size

      widgets.add(
        Positioned(
          left: x - (avatarSize / 2),
          top: y - (avatarSize / 2),
          // Just give explicit constraints?
          child: opponents[i],
        ),
      );
    }

    return widgets;
  }
}

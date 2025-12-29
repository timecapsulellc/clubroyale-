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
        
        // Define ellipse properties
        // We want an arc from approx 8 o'clock to 4 o'clock (clockwise)
        // 0 radians is 3 o'clock (Right)
        // Pi/2 is 6 o'clock (Bottom)
        // Pi is 9 o'clock (Left)
        // 3Pi/2 is 12 o'clock (Top)
        
        // We want to place opponents from ~Left-Bottom to ~Right-Bottom going upwards/clockwise?
        
        // Better visualization for a card table:
        // "Me" is at Bottom Center.
        // Opponents sit in a semi-circle/oval on the Top/Sides.
        // Let's define the arc from Left (9 o'clock / Pi) -> Top (12 o'clock / 3Pi/2 / -Pi/2) -> Right (3 o'clock / 0)
        
        // Let's us standard Flutter Coordinate system offset angle:
        // 0 is Right.
        // -Pi/2 is Top.
        // Pi is Left.
        // Pi/2 is Bottom.
        
        // Arc start: Left-Side slightly down? say 160 degrees (approx 2.8 rad)
        // Arc end: Right-Side slightly down? say 20 degrees (approx 0.35 rad)
        // But we go "around" the top.
        // So Loop from PI (Left) -> -PI/2 (Top) -> 0 (Right).
        
        final centerX = width / 2;
        final centerY = height * 0.40; // Shift table up (was 0.5) to give space for hand
        
        final radiusX = width * 0.40; // Horizontal radius
        final radiusY = height * 0.35; // Vertical radius
        
        // Calculate max height for the hand area to prevent overflow
        final maxHandHeight = height * 0.40;
        
        return Stack(
          children: [
            // 1. Center Area (Deck/Discard)
            Positioned(
              left: centerX - 160, // Half width of center area
              top: centerY - 90,  // Centered on new centerY (180/2)
              width: 320,
              height: 180,
              child: Center(child: centerArea),
            ),
            
            // 2. Opponents
            ..._buildOpponentPositions(centerX, centerY, radiusX, radiusY),

            // 3. My Hand (Fixed at bottom with constrained height)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHandHeight,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: myHand,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  List<Widget> _buildOpponentPositions(double cx, double cy, double rx, double ry) {
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
    
    double startAngle = math.pi; // Left
    double endAngle = 0.0;       // Right
    
    // Extend slightly for more players?
    // startAngle = math.pi + 0.2;
    // endAngle = -0.2;
    
    // Step calculation
    // If 1 opponent, place at -Pi/2 (Top)
    double step = (startAngle - endAngle) / (count + 1);
    
    for (int i = 0; i < count; i++) {
      // Calculate angle
      // i=0 -> First opponent. Place them on Left side? Or Right?
      // Usually "Left" (Clockwise) order.
      // So index 0 is at StartAngle - step
      
      double angle = startAngle - (step * (i + 1));
      
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
      
      widgets.add(Positioned(
        left: x - (avatarSize / 2),
        top: y - (avatarSize / 2),
        // Just give explicit constraints?
        child: opponents[i],
      ));
    }
    
    return widgets;
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class RightArcGameController extends StatelessWidget {
  final VoidCallback? onShowCards; // "SHOW" or "Show Cards"
  final VoidCallback? onSequence; // "SEQ" or "Show Sequence"
  final VoidCallback? onDublee; // "DUB" or "Show Dublee" - Optional
  final VoidCallback? onCancel; // "CAN" or "Cancel"
  final bool isShowEnabled;
  final bool isSequenceEnabled;
  final bool isDubleeEnabled;
  final bool isCancelEnabled;

  const RightArcGameController({
    super.key,
    this.onShowCards,
    this.onSequence,
    this.onDublee,
    this.onCancel,
    this.isShowEnabled = false, // Controls SHOW button state
    this.isSequenceEnabled = false,
    this.isDubleeEnabled = false,
    this.isCancelEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // We want an arc on the right side.
    // The reference shows buttons arranged roughly in a semi-circle.
    // Let's use a custom layout or just a Stack with precise positioning.

    // Center point of the arc is roughly off-screen to the right-center.

    return SizedBox(
      width: 120, // Width of the control area
      height: 350, // Height of the control area
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          // Background "Arc" visual (optional, wireframe in reference)
          Positioned(
            right: -50,
            child: Container(
              width: 150,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Buttons positioned along the arc
          // Top-most: DUB (Dublee)
          // Upper-Mid: SEQ (Sequence)
          // Lower-Mid: SHOW (Show Cards / Finish)
          // Bottom: CAN (Cancel)
          _buildArcPositioned(
            angleDegrees: -45, // Top
            child: _ArcButton(
              label: 'DUB',
              onTap: onDublee,
              isEnabled: isDubleeEnabled,
            ),
          ),

          _buildArcPositioned(
            angleDegrees: -15, // Upper Mid
            child: _ArcButton(
              label: 'SEQ',
              onTap: onSequence,
              isEnabled: isSequenceEnabled,
            ),
          ),

          _buildArcPositioned(
            angleDegrees: 15, // Lower Mid (Main action really)
            child: _ArcButton(
              label: 'SHOW',
              labelVertical: true,
              isLarge: true,
              onTap: onShowCards,
              isEnabled: isShowEnabled,
            ),
          ),

          _buildArcPositioned(
            angleDegrees: 45, // Bottom
            child: _ArcButton(
              label: 'CAN',
              onTap: onCancel,
              isEnabled: isCancelEnabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArcPositioned({
    required double angleDegrees,
    required Widget child,
  }) {
    // Radius of our virtual arc
    const double radius = 80;

    // Convert angle to radians
    final angle = angleDegrees * (math.pi / 180);

    // Calculate x, y based on angle relative to center-right
    // 0 degrees is directly Left of the center point (since arc is on Right)
    // Wait, let's simplify.
    // We just want vertically distributed with slight x-offset.

    // Simple approach: Use Positioned relative to the container.
    // Container is 120w x 350h. Center is (60, 175).

    double yOffset = 0;
    double xOffset = 0;

    if (angleDegrees == -45) {
      yOffset = -120;
      xOffset = 20;
    }
    if (angleDegrees == -15) {
      yOffset = -40;
      xOffset = 0;
    }
    if (angleDegrees == 15) {
      yOffset = 60;
      xOffset = 0;
    }
    if (angleDegrees == 45) {
      yOffset = 140;
      xOffset = 20;
    }

    return Positioned(
      right: 16 + xOffset, // Pushed against right edge
      top: 175 + yOffset - 30, // CenterY + Offset - HalfHeight
      child: child,
    );
  }
}

class _ArcButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLarge;
  final bool labelVertical;

  const _ArcButton({
    required this.label,
    this.onTap,
    this.isEnabled = false,
    this.isLarge = false,
    this.labelVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 70.0 : 55.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Gradient fill
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isEnabled
                  ? [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.8),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.4),
                    ],
            ),
            border: Border.all(
              color: isEnabled ? Colors.white : Colors.white24,
              width: 1.5,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: labelVertical
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: label
                      .split('')
                      .map(
                        (c) => Text(
                          c,
                          style: TextStyle(
                            color: isEnabled ? Colors.white : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: isLarge ? 14 : 12,
                          ),
                        ),
                      )
                      .toList(),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: isLarge ? 14 : 12,
                  ),
                ),
        ),
      ),
    );
  }
}

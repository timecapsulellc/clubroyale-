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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive radius based on height
        final height = constraints.maxHeight > 0 ? constraints.maxHeight : 350.0;
        final radius = (height * 0.4).clamp(60.0, 100.0);
        final centerY = height / 2;
        
        return SizedBox(
          width: 120,
          height: height,
          child: Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            children: [
              // Background "Arc" visual
              Positioned(
                right: -radius * 0.6,
                top: centerY - (radius * 2.5),
                child: Container(
                  width: radius * 2,
                  height: radius * 5,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              _buildArcPositioned(
                angleDegrees: -45, // Top
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'DUB',
                  onTap: onDublee,
                  isEnabled: isDubleeEnabled,
                ),
              ),

              _buildArcPositioned(
                angleDegrees: -15, // Upper Mid
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'SEQ',
                  onTap: onSequence,
                  isEnabled: isSequenceEnabled,
                ),
              ),

              _buildArcPositioned(
                angleDegrees: 15, // Lower Mid
                centerY: centerY,
                radius: radius,
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
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'CAN',
                  onTap: onCancel,
                  isEnabled: isCancelEnabled,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArcPositioned({
    required double angleDegrees,
    required double centerY,
    required double radius,
    required Widget child,
  }) {
    // 0 degrees is horizontal right.
    // -45 is up, +45 is down.
    
    // Simple vertical distribution with curve
    // Height diff calculation
    // Y = Sin(angle) * Radius
    // X = Cos(angle) * Radius (offset from right edge)
    
    // We want the curve to bow out to the left
    
    double yOffset;
    double xOffset;
    
    // Custom mapping for layout fit
     if (angleDegrees == -45) {
      yOffset = -radius * 1.5;
      xOffset = 16;
    } else if (angleDegrees == -15) {
      yOffset = -radius * 0.5;
      xOffset = 0;
    } else if (angleDegrees == 15) {
      yOffset = radius * 0.7; // Larger gap for SHOW button
      xOffset = 0;
    } else { // 45
      yOffset = radius * 1.8;
      xOffset = 16;
    }

    return Positioned(
      right: 16 + xOffset,
      top: centerY + yOffset - 30, 
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

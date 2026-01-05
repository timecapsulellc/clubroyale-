import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/services/localization_service.dart';

class RightArcGameController extends ConsumerWidget {
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We want an arc on the right side.
    // The reference shows buttons arranged roughly in a semi-circle.
    // Let's use a custom layout or just a Stack with precise positioning.

    // Center point of the arc is roughly off-screen to the right-center.

    return LayoutBuilder(
      builder: (context, constraints) {
          // Calculate responsive radius based on height AND width
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobilePortrait = screenWidth < 600;
        
        final height = constraints.maxHeight > 0 ? constraints.maxHeight : 350.0;
        
        // On mobile portrait, be much more conservative with radius
        // The previous (height * 0.4) was resulting in ~270px visible width on 360px screens
        final radius = isMobilePortrait 
            ? (height * 0.25).clamp(50.0, 70.0) 
            : (height * 0.4).clamp(60.0, 100.0);
            
        final centerY = height / 2;
        
        return SizedBox(
          width: isMobilePortrait ? 100 : 120, // Reduced width on mobile
          height: height,
          child: Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            children: [
              // Background "Arc" visual
              // Background "Arc" visual (Solid Semi-Circle)
              Positioned(
                right: isMobilePortrait ? -radius * 1.2 : -radius * 0.8, // Push further right on mobile
                top: centerY - (radius * 3.0),
                child: Container(
                  width: radius * 3.5, // Larger circle
                  height: radius * 6.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Solid dark grey like reference
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              _buildArcPositioned(
                angleDegrees: -45, // Top
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'btn_dublee'.tr(ref),
                  onTap: onDublee,
                  isEnabled: isDubleeEnabled,
                ),
              ),

              _buildArcPositioned(
                angleDegrees: -15, // Upper Mid
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'btn_sequence'.tr(ref),
                  onTap: onSequence,
                  isEnabled: isSequenceEnabled,
                ),
              ),

              _buildArcPositioned(
                angleDegrees: 15, // Lower Mid
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'btn_show'.tr(ref),
                  labelVertical: false, 
                  isLarge: true,
                  onTap: onShowCards,
                  isEnabled: isShowEnabled,
                ),
                  onTap: onShowCards,
                  isEnabled: isShowEnabled,
                ),
              ),

              _buildArcPositioned(
                angleDegrees: 45, // Bottom
                centerY: centerY,
                radius: radius,
                child: _ArcButton(
                  label: 'btn_cancel'.tr(ref),
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: isLarge ? 12 : 10, // Adjusted for potentially longer text
                  ),
                ),
        ),
      ),
    );
  }
}

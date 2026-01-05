import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SkeletonGameCard extends StatelessWidget {
  final double width;
  final double height;
  final double scale;

  const SkeletonGameCard({
    super.key,
    this.width = 75.0,
    this.height = 110.0,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * scale,
      height: height * scale,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: (width * 0.6) * scale,
          height: (height * 0.6) * scale,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
        ),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(
      duration: 1200.ms,
      color: Colors.white.withValues(alpha: 0.2),
      angle: 0.5, // Diagonal shimmer
    );
  }
}

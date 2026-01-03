/// Felt Texture Painter - Custom painter for casino table felt
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter that creates a subtle felt texture overlay
class FeltTexturePainter extends CustomPainter {
  final int seed;
  final double density;
  final double opacity;

  FeltTexturePainter({this.seed = 42, this.density = 800, this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Draw random small dots to create texture
    for (int i = 0; i < density; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.3 + random.nextDouble() * 0.4;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Add some subtle lines for fabric texture
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final length = 5 + random.nextDouble() * 15;
      final angle = random.nextDouble() * math.pi;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + math.cos(angle) * length,
          startY + math.sin(angle) * length,
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FeltTexturePainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.density != density ||
        oldDelegate.opacity != opacity;
  }
}

/// Premium felt background widget
class FeltBackground extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showTexture;
  final bool showAmbientLight;

  const FeltBackground({
    super.key,
    required this.child,
    this.primaryColor = const Color(0xFF1a4d2e),
    this.secondaryColor = const Color(0xFF0a2814),
    this.showTexture = true,
    this.showAmbientLight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base felt gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                primaryColor,
                Color.lerp(primaryColor, secondaryColor, 0.5)!,
                secondaryColor,
              ],
            ),
          ),
        ),

        // Felt texture overlay
        if (showTexture)
          CustomPaint(painter: FeltTexturePainter(), size: Size.infinite),

        // Ambient light from above
        if (showAmbientLight)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 0.8,
                colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),

        // Content
        child,
      ],
    );
  }
}

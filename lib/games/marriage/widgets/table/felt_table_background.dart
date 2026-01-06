/// Premium Felt Table Background
///
/// Casino-quality felt texture with gradient and wood border
/// Supports multiple themes
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Marriage game themes
enum MarriageTableTheme {
  royalGreen,
  deepPurple,
  oceanBlue,
  crimsonRed,
  emeraldForest,
}

/// Theme configuration for table
class TableThemeConfig {
  final String name;
  final Color feltPrimary;
  final Color feltSecondary;
  final Color accentGold;
  final Color borderColor;
  final List<Color> gradientColors;

  const TableThemeConfig({
    required this.name,
    required this.feltPrimary,
    required this.feltSecondary,
    required this.accentGold,
    required this.borderColor,
    required this.gradientColors,
  });

  static const royalGreen = TableThemeConfig(
    name: 'Royal Green',
    feltPrimary: Color(0xFF0B5A3E),
    feltSecondary: Color(0xFF094531),
    accentGold: Color(0xFFFFD700),
    borderColor: Color(0xFF5D4037),
    gradientColors: [Color(0xFF0D6B4A), Color(0xFF073829)],
  );

  static const deepPurple = TableThemeConfig(
    name: 'Deep Purple',
    feltPrimary: Color(0xFF4A148C),
    feltSecondary: Color(0xFF311B92),
    accentGold: Color(0xFFE1BEE7),
    borderColor: Color(0xFF3E2723),
    gradientColors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
  );

  static const oceanBlue = TableThemeConfig(
    name: 'Ocean Blue',
    feltPrimary: Color(0xFF0D47A1),
    feltSecondary: Color(0xFF1A237E),
    accentGold: Color(0xFFFFD54F),
    borderColor: Color(0xFF37474F),
    gradientColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
  );

  static const crimsonRed = TableThemeConfig(
    name: 'Crimson Red',
    feltPrimary: Color(0xFF7F0000),
    feltSecondary: Color(0xFF5D0000),
    accentGold: Color(0xFFFFD700),
    borderColor: Color(0xFF3E2723),
    gradientColors: [Color(0xFFB71C1C), Color(0xFF7F0000)],
  );

  static const emeraldForest = TableThemeConfig(
    name: 'Emerald Forest',
    feltPrimary: Color(0xFF1B5E20),
    feltSecondary: Color(0xFF0A3D0C),
    accentGold: Color(0xFFFFD700),
    borderColor: Color(0xFF4E342E),
    gradientColors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  );

  static TableThemeConfig fromTheme(MarriageTableTheme theme) {
    switch (theme) {
      case MarriageTableTheme.royalGreen:
        return royalGreen;
      case MarriageTableTheme.deepPurple:
        return deepPurple;
      case MarriageTableTheme.oceanBlue:
        return oceanBlue;
      case MarriageTableTheme.crimsonRed:
        return crimsonRed;
      case MarriageTableTheme.emeraldForest:
        return emeraldForest;
    }
  }
}

/// Premium felt table background with radial gradient and texture
class FeltTableBackground extends StatelessWidget {
  final Widget child;
  final MarriageTableTheme theme;
  final bool showWoodBorder;
  final bool showInnerGlow;

  const FeltTableBackground({
    super.key,
    required this.child,
    this.theme = MarriageTableTheme.royalGreen,
    this.showWoodBorder = true,
    this.showInnerGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = TableThemeConfig.fromTheme(theme);

    return Container(
      decoration: BoxDecoration(
        // Base gradient
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: config.gradientColors,
          stops: const [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Felt texture overlay
          Positioned.fill(
            child: CustomPaint(
              painter: FeltTexturePainter(
                color: config.feltPrimary,
              ),
            ),
          ),

          // Inner glow (vignette effect)
          if (showInnerGlow)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

          // Wood border effect
          if (showWoodBorder)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: config.borderColor,
                    width: 12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

          // Gold inner border
          if (showWoodBorder)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: config.accentGold.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          // Child content
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for felt texture
class FeltTexturePainter extends CustomPainter {
  final Color color;
  
  FeltTexturePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Create subtle noise pattern for felt texture
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    // Draw subtle horizontal lines for texture
    for (var y = 0.0; y < size.height; y += 3) {
      final opacity = (y % 6 == 0) ? 0.05 : 0.02;
      paint.color = Colors.black.withValues(alpha: opacity);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple gradient background for performance
class SimpleTableBackground extends StatelessWidget {
  final Widget child;

  const SimpleTableBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: CasinoColors.greenFeltGradient,
      ),
      child: child,
    );
  }
}

/// Theme selector widget
class TableThemeSelector extends StatelessWidget {
  final MarriageTableTheme selected;
  final ValueChanged<MarriageTableTheme> onChanged;

  const TableThemeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TABLE THEME',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: MarriageTableTheme.values.map((theme) {
              final config = TableThemeConfig.fromTheme(theme);
              final isSelected = theme == selected;
              
              return GestureDetector(
                onTap: () => onChanged(theme),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: config.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.amber : Colors.white24,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            TableThemeConfig.fromTheme(selected).name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

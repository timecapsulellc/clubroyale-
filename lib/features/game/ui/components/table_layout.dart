import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/core/theme/game_themes.dart';
import 'package:clubroyale/features/store/theme_store_provider.dart';

/// Dynamic table layout that uses the user's selected theme
class TableLayout extends ConsumerWidget {
  final Widget child;
  
  const TableLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(selectedThemeProvider);
    
    return Container(
      decoration: BoxDecoration(
        gradient: theme.gradient,
      ),
      child: Stack(
        children: [
          // The Table Felt Drawing
          Positioned.fill(
            child: CustomPaint(
              painter: TableFeltPainter(theme: theme),
            ),
          ),
          // Content (Cards, Players, etc.)
          child,
        ],
      ),
    );
  }
}

/// Painter for the table felt with dynamic theme support
class TableFeltPainter extends CustomPainter {
  final GameTheme theme;
  
  TableFeltPainter({required this.theme});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Lighter version of primary color for oval outline
    final ovalColor = Color.lerp(theme.primaryColor, Colors.white, 0.3) ?? Colors.white;
    
    final paint = Paint()
      ..color = ovalColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw the main oval table line
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.9,
      height: size.height * 0.7,
    );
    
    canvas.drawOval(rect, paint);
    
    // Draw the "Dealer/Pot" Area circle in the center
    final centerCirclePaint = Paint()
      ..color = ovalColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, size.height * 0.25, centerCirclePaint);
    
    // Accent border for the center area
    final accentPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
   canvas.drawCircle(center, size.height * 0.25, accentPaint);
  }

  @override
  bool shouldRepaint(covariant TableFeltPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}

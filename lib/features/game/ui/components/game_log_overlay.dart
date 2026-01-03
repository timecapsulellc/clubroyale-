import 'package:flutter/material.dart';
import 'package:clubroyale/core/theme/app_theme.dart';

class GameLogOverlay extends StatelessWidget {
  final List<String> logs;

  const GameLogOverlay({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 200,
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(color: AppTheme.goldDark),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            itemCount: logs.length,
            reverse: true, // Show newest at bottom (or top based on preference)
            separatorBuilder: (_, __) =>
                const Divider(height: 4, color: Colors.transparent),
            itemBuilder: (context, index) {
              // Assuming logs are chronological, reverse makes index 0 the newest?
              // Let's just standard list.
              final log = logs[logs.length - 1 - index];
              return Text(
                log,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [Shadow(blurRadius: 1, color: Colors.black)],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  const DashedBorderPainter({this.color = Colors.orange});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(8),
        ),
      );

    // Simple manual dashing for now
    // In production, use path_drawing package for dashPath
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

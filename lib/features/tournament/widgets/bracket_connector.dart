import 'package:flutter/material.dart';

class BracketConnector extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double gap;

  const BracketConnector({
    super.key,
    required this.itemCount, // Number of matches in the PREVIOUS round
    this.itemHeight = 100.0, // Height of _MatchCard + padding
    this.gap = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(24, (itemHeight * itemCount) + (gap * (itemCount - 1))),
      painter: _ConnectorPainter(
        itemCount: itemCount,
        itemHeight: itemHeight,
        gap: gap,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;
  final double gap;
  final Color color;

  _ConnectorPainter({
    required this.itemCount,
    required this.itemHeight,
    required this.gap,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // We assume pairs of matches flow into one match in the next round.
    // Loop through pairs: (0,1), (2,3), etc.
    for (int i = 0; i < itemCount; i += 2) {
      if (i + 1 >= itemCount) break;

      // Top match center Y
      final y1 = (i * (itemHeight + gap)) + (itemHeight / 2);
      // Bottom match center Y
      final y2 = ((i + 1) * (itemHeight + gap)) + (itemHeight / 2);

      // Destination match center Y (midpoint)
      final yDest = (y1 + y2) / 2;

      // Draw structure:
      //  |
      //  +----
      //  |

      const double xStart = 0;
      final double xEnd = size.width;
      const double xMid = 12; // bend point

      // Top line
      final path1 = Path();
      path1.moveTo(xStart, y1);
      path1.cubicTo(
        xMid,
        y1, // control 1
        xMid,
        yDest, // control 2
        xEnd,
        yDest, // end
      );
      canvas.drawPath(path1, paint);

      // Bottom line
      final path2 = Path();
      path2.moveTo(xStart, y2);
      path2.cubicTo(xMid, y2, xMid, yDest, xEnd, yDest);
      canvas.drawPath(path2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

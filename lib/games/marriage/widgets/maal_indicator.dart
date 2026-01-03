import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/theme/app_theme.dart';

/// A HUD widget to display Maal points
class MaalIndicator extends StatelessWidget {
  final int points;
  final bool hasMarriage;

  const MaalIndicator({
    super.key,
    required this.points,
    this.hasMarriage = false,
  });

  @override
  Widget build(BuildContext context) {
    if (points <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasMarriage
            ? Colors.purple.withOpacity(0.8)
            : Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasMarriage ? Colors.purpleAccent : AppTheme.gold,
          width: hasMarriage ? 2 : 1,
        ),
        boxShadow: hasMarriage
            ? [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasMarriage ? Icons.volunteer_activism : Icons.diamond,
            color: hasMarriage ? Colors.white : AppTheme.gold,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
              .animate(key: ValueKey(points))
              .scale(duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 4),
          const Text(
            'Maal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

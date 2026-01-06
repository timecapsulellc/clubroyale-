import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AchievementType {
  firstWin,
  streak,
  highScorer,
  vip,
}

class AchievementBadge extends StatelessWidget {
  final AchievementType type;
  final bool animate;

  const AchievementBadge({
    super.key,
    required this.type,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case AchievementType.firstWin:
        icon = Icons.emoji_events;
        color = Colors.amber;
        label = 'First Win';
        break;
      case AchievementType.streak:
        icon = Icons.local_fire_department;
        color = Colors.orangeAccent;
        label = 'Streak';
        break;
      case AchievementType.highScorer:
        icon = Icons.star;
        color = Colors.lightBlueAccent;
        label = 'Top Player';
        break;
      case AchievementType.vip:
        icon = Icons.diamond;
        color = Colors.purpleAccent;
        label = 'VIP';
        break;
    }

    Widget badge = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 20),
    );

    if (animate) {
      badge = badge.animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(end: 1.1, duration: 1000.ms, curve: Curves.easeInOut)
          .then()
          .boxShadow(
            begin: BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
            end: BoxShadow(
              color: color.withValues(alpha: 0.0),
              blurRadius: 12,
              spreadRadius: 4,
            ),
            duration: 1000.ms,
          );
    }

    return Tooltip(
      message: label,
      child: badge,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

class ComboCelebration extends StatelessWidget {
  final String comboName;
  final int points;
  final VoidCallback? onComplete;

  const ComboCelebration({
    super.key,
    required this.comboName,
    required this.points,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            comboName.toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: CasinoColors.gold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).then(delay: 1.seconds).fadeOut(duration: 300.ms),
          
          Text(
            '+$points Points',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate(delay: 200.ms, onComplete: (_) => onComplete?.call()).fadeIn().slideY(begin: 0.5, end: 0).then(delay: 800.ms).fadeOut(),
        ],
      ),
    );
  }
}

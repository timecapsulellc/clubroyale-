/// Maal Badge Widget - Visual indicator for Maal card types
///
/// Displays color-coded badges for Tiplu, Jhiplu, Poplu, Alter, and Man cards
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/core/design_system/animations/rive_animations.dart';

/// Badge colors and icons for each Maal type
class MaalBadgeWidget extends StatelessWidget {
  final MaalType type;
  final double size;
  final bool showLabel;

  const MaalBadgeWidget({
    super.key,
    required this.type,
    this.size = 16,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (type == MaalType.none) return const SizedBox.shrink();

    // If it's a special card (Tiplu/Alter/Man), show Rive animated star
    // Poplu/Jhiplu can stay simple or also use star with different colors
    if (type == MaalType.tiplu ||
        type == MaalType.alter ||
        type == MaalType.man) {
      return SizedBox(
        width: size * 1.5,
        height: size * 1.5,
        child: RiveStar(size: size * 1.5),
      );
    }

    final config = _getMaalConfig(type);

    return Container(
      padding: EdgeInsets.all(size * 0.15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [config.color, config.color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.6),
            blurRadius: size * 0.4,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(config.icon, style: TextStyle(fontSize: size * 0.7)),
          if (showLabel) ...[
            SizedBox(width: size * 0.2),
            Text(
              config.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _MaalConfig _getMaalConfig(MaalType type) {
    return switch (type) {
      MaalType.tiplu => const _MaalConfig(
        color: Color(0xFF7C3AED), // Purple
        icon: '👑',
        label: 'T',
      ),
      MaalType.poplu => const _MaalConfig(
        color: Color(0xFF2563EB), // Blue
        icon: '⬆️',
        label: 'P',
      ),
      MaalType.jhiplu => const _MaalConfig(
        color: Color(0xFF0891B2), // Cyan
        icon: '⬇️',
        label: 'J',
      ),
      MaalType.alter => const _MaalConfig(
        color: Color(0xFFEA580C), // Orange
        icon: '💎',
        label: 'A',
      ),
      MaalType.man => const _MaalConfig(
        color: Color(0xFF16A34A), // Green
        icon: '🃏',
        label: 'M',
      ),
      MaalType.none => const _MaalConfig(
        color: Colors.transparent,
        icon: '',
        label: '',
      ),
    };
  }
}

class _MaalConfig {
  final Color color;
  final String icon;
  final String label;

  const _MaalConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}

/// Get the glow color for a Maal type
Color getMaalGlowColor(MaalType type) {
  return switch (type) {
    MaalType.tiplu => const Color(0xFF7C3AED),
    MaalType.poplu => const Color(0xFF2563EB),
    MaalType.jhiplu => const Color(0xFF0891B2),
    MaalType.alter => const Color(0xFFEA580C),
    MaalType.man => const Color(0xFF16A34A),
    MaalType.none => Colors.transparent,
  };
}

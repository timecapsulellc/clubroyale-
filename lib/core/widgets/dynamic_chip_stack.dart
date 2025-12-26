/// Dynamic Chip Stack Widget
/// 
/// Displays chip stacks that dynamically change based on pot size.
/// Uses the chip assets for visual variety.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Chip stack size thresholds
enum ChipStackSize {
  small,  // Under 100
  medium, // 100-500
  large,  // 500-1000
  massive, // Over 1000
}

/// A dynamic chip stack widget that changes appearance based on amount
class DynamicChipStack extends StatelessWidget {
  final int amount;
  final bool showAmount;
  final double width;
  final double height;
  final bool animate;

  const DynamicChipStack({
    super.key,
    required this.amount,
    this.showAmount = true,
    this.width = 80,
    this.height = 80,
    this.animate = true,
  });

  ChipStackSize get stackSize {
    if (amount >= 1000) return ChipStackSize.massive;
    if (amount >= 500) return ChipStackSize.large;
    if (amount >= 100) return ChipStackSize.medium;
    return ChipStackSize.small;
  }

  String get _imagePath {
    switch (stackSize) {
      case ChipStackSize.small:
        return 'assets/images/chips/stack_small.png';
      case ChipStackSize.medium:
        return 'assets/images/chips/stack_medium.png';
      case ChipStackSize.large:
        return 'assets/images/chips/stack_large.png';
      case ChipStackSize.massive:
        return 'assets/images/chips/stack_large.png'; // Use large for massive too
    }
  }

  Color get _glowColor {
    switch (stackSize) {
      case ChipStackSize.small:
        return Colors.grey;
      case ChipStackSize.medium:
        return Colors.green;
      case ChipStackSize.large:
        return Colors.amber;
      case ChipStackSize.massive:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget stack = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _glowColor.withValues(alpha: 0.3),
            blurRadius: stackSize == ChipStackSize.massive ? 20 : 10,
            spreadRadius: stackSize == ChipStackSize.massive ? 4 : 2,
          ),
        ],
      ),
      child: Image.asset(
        _imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackStack(),
      ),
    );

    if (animate && stackSize == ChipStackSize.massive) {
      stack = stack
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 2.seconds, color: Colors.amber.withValues(alpha: 0.3));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        stack,
        if (showAmount)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _glowColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                _formatAmount(amount),
                style: TextStyle(
                  color: _glowColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackStack() {
    // Fallback using individual chips
    final chipCount = (stackSize.index + 1).clamp(1, 4);
    return Stack(
      alignment: Alignment.center,
      children: List.generate(chipCount, (i) {
        return Positioned(
          bottom: i * 6.0,
          child: Image.asset(
            'assets/images/chips/chip_red.png',
            width: width * 0.8,
            height: height * 0.3,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}

/// A simple pot display widget with chip stack
class PotDisplay extends StatelessWidget {
  final int potAmount;
  final String? label;
  final double size;

  const PotDisplay({
    super.key,
    required this.potAmount,
    this.label,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 4),
        DynamicChipStack(
          amount: potAmount,
          width: size,
          height: size,
        ),
      ],
    );
  }
}

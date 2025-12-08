// Loading Skeleton Widgets
//
// Shimmer loading placeholders for async operations.
// Creates polished loading states instead of spinners.

import 'package:flutter/material.dart';

/// Shimmer effect widget
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((e) => (e + 2) / 4).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton box placeholder
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton circle placeholder (for avatars)
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Room card skeleton
class RoomCardSkeleton extends StatelessWidget {
  const RoomCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonCircle(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120, height: 16),
                        const SizedBox(height: 8),
                        SkeletonBox(width: 80, height: 12),
                      ],
                    ),
                  ),
                  SkeletonBox(width: 60, height: 32, borderRadius: 16),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SkeletonBox(width: 60, height: 24),
                  const SizedBox(width: 8),
                  SkeletonBox(width: 60, height: 24),
                  const Spacer(),
                  SkeletonBox(width: 100, height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Player list skeleton
class PlayerListSkeleton extends StatelessWidget {
  final int count;

  const PlayerListSkeleton({
    super.key,
    this.count = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: List.generate(count, (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const SkeletonCircle(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 100, height: 14),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 60, height: 10),
                  ],
                ),
              ),
              SkeletonBox(width: 40, height: 24, borderRadius: 4),
            ],
          ),
        )),
      ),
    );
  }
}

/// Game card skeleton
class GameCardSkeleton extends StatelessWidget {
  const GameCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        height: 160,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SkeletonBox(width: 80, height: 20),
              const SizedBox(height: 8),
              SkeletonBox(width: 120, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

/// Score table skeleton
class ScoreTableSkeleton extends StatelessWidget {
  final int rows;

  const ScoreTableSkeleton({
    super.key,
    this.rows = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(child: SkeletonBox(height: 16)),
                const SizedBox(width: 16),
                SkeletonBox(width: 40, height: 16),
                const SizedBox(width: 16),
                SkeletonBox(width: 40, height: 16),
              ],
            ),
          ),
          // Rows
          ...List.generate(rows, (index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const SkeletonCircle(size: 32),
                const SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 14)),
                const SizedBox(width: 16),
                SkeletonBox(width: 40, height: 14),
                const SizedBox(width: 16),
                SkeletonBox(width: 40, height: 14),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Loading wrapper widget
class LoadingWrapper<T> extends StatelessWidget {
  final Future<T>? future;
  final T? data;
  final bool isLoading;
  final Widget Function(T data) builder;
  final Widget? skeleton;
  final Widget? errorWidget;

  const LoadingWrapper({
    super.key,
    this.future,
    this.data,
    this.isLoading = false,
    required this.builder,
    this.skeleton,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (future != null) {
      return FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return skeleton ?? const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return errorWidget ?? _buildError(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            return builder(snapshot.data as T);
          }
          return skeleton ?? const SizedBox.shrink();
        },
      );
    }

    if (isLoading) {
      return skeleton ?? const Center(child: CircularProgressIndicator());
    }

    if (data != null) {
      return builder(data as T);
    }

    return skeleton ?? const SizedBox.shrink();
  }

  Widget _buildError(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

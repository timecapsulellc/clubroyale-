// Skeleton Loading Widgets - Premium shimmer loading placeholders
//
// Use these instead of CircularProgressIndicator for a more premium feel.
// The shimmer effect gives users a sense of the content layout while loading.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Base shimmer container
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
    .animate(onPlay: (c) => c.repeat())
    .shimmer(
      duration: 1500.ms,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

/// Circle skeleton for avatars
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
      ),
    )
    .animate(onPlay: (c) => c.repeat())
    .shimmer(
      duration: 1500.ms,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

/// Game card skeleton - for game room list
class SkeletonGameCard extends StatelessWidget {
  const SkeletonGameCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const SkeletonCircle(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 16),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 80, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 60, height: 28, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 16),
          // Player avatars row
          Row(
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SkeletonCircle(size: 32),
            )),
          ),
        ],
      ),
    );
  }
}

/// Player list item skeleton
class SkeletonPlayerTile extends StatelessWidget {
  const SkeletonPlayerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SkeletonCircle(size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100, height: 16),
                const SizedBox(height: 6),
                SkeletonBox(width: 60, height: 12),
              ],
            ),
          ),
          SkeletonBox(width: 40, height: 16),
        ],
      ),
    );
  }
}

/// Leaderboard skeleton
class SkeletonLeaderboard extends StatelessWidget {
  final int itemCount;

  const SkeletonLeaderboard({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SkeletonPlayerTile(),
      )),
    );
  }
}

/// Full screen loading skeleton
class SkeletonScreen extends StatelessWidget {
  final String? title;

  const SkeletonScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.deepPurple,
      appBar: title != null ? AppBar(
        title: Text(title!),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              SkeletonBox(width: 200, height: 28),
              const SizedBox(height: 8),
              SkeletonBox(width: 300, height: 16),
              
              const SizedBox(height: 32),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) => Column(
                  children: [
                    SkeletonBox(width: 60, height: 40),
                    const SizedBox(height: 8),
                    SkeletonBox(width: 50, height: 12),
                  ],
                )),
              ),
              
              const SizedBox(height: 32),
              
              // List items
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (_, i) => const SkeletonGameCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile page skeleton 
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.deepPurple,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              const SkeletonCircle(size: 100),
              const SizedBox(height: 16),
              
              // Name
              SkeletonBox(width: 150, height: 24),
              const SizedBox(height: 8),
              SkeletonBox(width: 100, height: 14),
              
              const SizedBox(height: 32),
              
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) => Column(
                  children: [
                    SkeletonBox(width: 50, height: 30),
                    const SizedBox(height: 6),
                    SkeletonBox(width: 40, height: 12),
                  ],
                )),
              ),
              
              const SizedBox(height: 32),
              
              // Recent games
              Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 120, height: 18),
              ),
              const SizedBox(height: 16),
              ...List.generate(3, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonGameCard(),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clubroyale/config/casino_theme.dart';

class GameLoadingSkeleton extends StatelessWidget {
  const GameLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.background,
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Bar / Sidebar Placeholder
                Row(
                  children: [
                    _buildBox(height: 40, width: 40, shape: BoxShape.circle),
                    const Spacer(),
                    _buildBox(height: 30, width: 100),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Opponents Area (Top arc)
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOpponentSkeleton(),
                      _buildOpponentSkeleton(),
                      _buildOpponentSkeleton(),
                    ],
                  ),
                ),
                
                // Center Table
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(100), // Elliptical
                    ),
                  ),
                ),
                
                // Player Hand
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        10,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 40,
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpponentSkeleton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBox(height: 48, width: 48, shape: BoxShape.circle),
        const SizedBox(height: 8),
        _buildBox(height: 12, width: 60),
      ],
    );
  }

  Widget _buildBox({required double height, required double width, BoxShape shape = BoxShape.rectangle}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(4) : null,
      ),
    );
  }
}

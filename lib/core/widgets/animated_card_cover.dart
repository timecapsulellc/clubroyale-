import 'package:flutter/material.dart';

class AnimatedCardCover extends StatefulWidget {
  final BorderRadius? borderRadius;
  final Duration duration;
  final Duration interval; // Time between shimmers
  final bool autoPlay;

  const AnimatedCardCover({
    super.key,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 2000),
    this.interval = const Duration(seconds: 4),
    this.autoPlay = true,
  });

  @override
  State<AnimatedCardCover> createState() => _AnimatedCardCoverState();
}

class _AnimatedCardCoverState extends State<AnimatedCardCover> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (widget.autoPlay) {
      _startLoop();
    }
  }

  void _startLoop() async {
    while (mounted) {
      if(!_controller.isAnimating) {
        await Future.delayed(widget.interval);
        if (mounted) {
          await _controller.forward(from: 0.0);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.value == 0 || _controller.value == 1) return const SizedBox.shrink();
            
            return CustomPaint(
              painter: _ShimmerPainter(_controller.value),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double percent;
  _ShimmerPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();
    
    // Create a tilted gradient effect
    // We adjust the alignment slightly to give it a diagonal feel
    // and move the stops based on the percent.
    
    final gradient = LinearGradient(
      begin: Alignment(-1.5 + (percent * 0.5), -0.5), // Subtle movement in alignment
      end: Alignment(1.5 + (percent * 0.5), 0.5),
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.03),
        Colors.white.withValues(alpha: 0.12), // Glossy peak
        Colors.white.withValues(alpha: 0.03),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: [
        (percent * 1.5) - 0.5, // Start before 0
        (percent * 1.5) - 0.25,
        (percent * 1.5),       // Center at percent
        (percent * 1.5) + 0.25,
        (percent * 1.5) + 0.5, // End after 1
      ],
      tileMode: TileMode.clamp, // Don't repeat
    );
    
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) => oldDelegate.percent != percent;
}

/// Emote Widget - In-game social interactions
///
/// Features:
/// - Circular emote picker menu
/// - Expanding/collapsing animation
/// - Pre-defined emote sets (Tomato, Heart, Clap, etc.)
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Standard emotes used in the game
enum GameEmote {
  thumbsUp('👍', 'Good Game'),
  heart('❤️', 'Love it'),
  laugh('😂', 'Haha'),
  angry('😡', 'Angry'),
  clap('👏', 'Well Played'),
  tomato('🍅', 'Boo!'),
  cry('😭', 'Sad'),
  surprised('😮', 'Wow');

  final String emoji;
  final String label;
  const GameEmote(this.emoji, this.label);
}

/// Circular picker for emotes
class EmotePicker extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(GameEmote) onEmoteSelected;

  const EmotePicker({super.key, this.onClose, required this.onEmoteSelected});

  @override
  State<EmotePicker> createState() => _EmotePickerState();
}

class _EmotePickerState extends State<EmotePicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.8),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center close button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: widget.onClose,
              ),

              // Emotes in circle
              ..._buildEmoteButtons(),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
      ),
    );
  }

  List<Widget> _buildEmoteButtons() {
    final emotes = GameEmote.values;
    final count = emotes.length;
    final step = (2 * math.pi) / count;

    return List.generate(count, (index) {
      final angle = (index * step) - (math.pi / 2); // Start from top

      // Use Align for simpler positioning relative to center
      return Align(
        alignment: Alignment(
          math.cos(angle) * 0.7, // Scale to keep inside
          math.sin(angle) * 0.7,
        ),
        child: _EmoteButton(
          emote: emotes[index],
          onTap: () => widget.onEmoteSelected(emotes[index]),
        ),
      );
    });
  }
}

class _EmoteButton extends StatelessWidget {
  final GameEmote emote;
  final VoidCallback onTap;

  const _EmoteButton({required this.emote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      emote.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emote.label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2.seconds, delay: 1.seconds),
    );
  }
}

/// Widget that animates a flying emote from start position to end position
class FlyingEmoteAnimation extends StatefulWidget {
  final GameEmote emote;
  final Offset startOffset;
  final Offset endOffset;
  final VoidCallback onComplete;

  const FlyingEmoteAnimation({
    super.key,
    required this.emote,
    required this.startOffset,
    required this.endOffset,
    required this.onComplete,
  });

  @override
  State<FlyingEmoteAnimation> createState() => _FlyingEmoteAnimationState();
}

class _FlyingEmoteAnimationState extends State<FlyingEmoteAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _positionAnimation =
        Tween<Offset>(begin: widget.startOffset, end: widget.endOffset).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    // Scale up then down
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 2.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                widget.emote.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        );
      },
    );
  }
}

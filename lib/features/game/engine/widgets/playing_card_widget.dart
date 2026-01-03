import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clubroyale/core/models/playing_card.dart';

/// Widget to display a single playing card with flip animation
class PlayingCardWidget extends StatefulWidget {
  final PlayingCard? card;
  final bool isFaceDown;
  final bool isSelected;
  final bool isPlayable;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool isLoading;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.isFaceDown = false,
    this.isSelected = false,
    this.isPlayable = true,
    this.onTap,
    this.width = 60,
    this.height = 90,
    this.isLoading = false,
  });

  @override
  State<PlayingCardWidget> createState() => _PlayingCardWidgetState();
}

class _PlayingCardWidgetState extends State<PlayingCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Track previous face-down state to trigger sound or haptic if needed
  late bool _wasFaceDown;

  @override
  void initState() {
    super.initState();
    _wasFaceDown = widget.isFaceDown;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: widget.isFaceDown ? 1.0 : 0.0, // Initial state
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(PlayingCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceDown != oldWidget.isFaceDown) {
      if (widget.isFaceDown) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _wasFaceDown = widget.isFaceDown;
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Get the asset path for a playing card
  String _getCardAssetPath(PlayingCard card) {
    // Map rank to file naming convention
    final String rankName;
    switch (card.rank) {
      case CardRank.ace:
        rankName = 'ace';
      case CardRank.king:
        rankName = 'king';
      case CardRank.queen:
        rankName = 'queen';
      case CardRank.jack:
        rankName = 'jack';
      default:
        rankName = card.rank.value.toString(); // 2-10
    }
    final suit = card.suit.name; // clubs, diamonds, hearts, spades
    return 'assets/cards/png/${rankName}_of_$suit.png';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Main interaction wrapper
    return Semantics(
      label: widget.card != null
          ? '${widget.card!.rank.displayString} of ${widget.card!.suit.name}'
          : 'Card Back',
      button: true,
      enabled: widget.isPlayable,
      child: GestureDetector(
        onTap: widget.isPlayable && !widget.isFaceDown && !widget.isLoading
            ? widget.onTap
            : null,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Calculate rotation
            final double angle = _animation.value * pi;
            final bool isBackVisible = angle >= pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(angle),
              alignment: Alignment.center,
              child: widget.isSelected
                  ? Transform.translate(
                      offset: const Offset(0, -12),
                      child: _buildCardContent(
                        isBackVisible,
                        theme,
                        isRotated: isBackVisible,
                      ),
                    )
                  : _buildCardContent(
                      isBackVisible,
                      theme,
                      isRotated: isBackVisible,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardContent(
    bool isBackVisible,
    ThemeData theme, {
    bool isRotated = false,
  }) {
    // If showing back, we are rotated 180 degrees (pi).
    // To show the back image correctly (upright), we need to rotate it back IF the flip rotation inverted it.
    // Standard Card Flip: Back is usually rendered mirrored if we just rotate logic.
    // Actually:
    // 0 deg: Front (Normal)
    // 180 deg: Back (Mirrored horizontally)
    // So if rendering Back, we should Wrap in Transform(rotateY(pi)) to un-mirror it relative to the viewer.

    return Transform(
      alignment: Alignment.center,
      transform: isRotated ? Matrix4.rotationY(pi) : Matrix4.identity(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: widget.isSelected ? 3 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isBackVisible
                  ? _buildCardBack(theme)
                  : widget.card != null
                  ? _buildCardFace(widget.card!, theme)
                  : _buildEmptyCard(theme),
            ),
            if (widget.isLoading && !isBackVisible)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme) {
    return Image.asset(
      'assets/cards/png/back.png',
      fit: BoxFit.cover,
      width: widget.width,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.blue.shade800,
          child: Center(
            child: Icon(
              Icons.casino,
              color: Colors.white,
              size: widget.width * 0.4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardFace(PlayingCard card, ThemeData theme) {
    return Opacity(
      opacity: widget.isPlayable ? 1.0 : 0.5,
      child: Image.asset(
        _getCardAssetPath(card),
        fit: BoxFit.cover,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          return _buildCustomCardFace(card, theme);
        },
      ),
    );
  }

  Widget _buildCustomCardFace(PlayingCard card, ThemeData theme) {
    final color = card.suit.isRed ? Colors.red.shade700 : Colors.black87;
    final isDisabled = !widget.isPlayable;

    return Container(
      color: Colors.white,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top rank and suit
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.rank.displayString,
                      style: TextStyle(
                        fontSize: widget.width * 0.25,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      card.suit.symbol,
                      style: TextStyle(
                        fontSize: widget.width * 0.25,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Center suit symbol
              Text(
                card.suit.symbol,
                style: TextStyle(
                  fontSize: widget.width * 0.5,
                  color: color.withValues(alpha: 0.3),
                ),
              ),
              // Bottom rank and suit (rotated)
              Align(
                alignment: Alignment.bottomRight,
                child: Transform.rotate(
                  angle: pi,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.rank.displayString,
                        style: TextStyle(
                          fontSize: widget.width * 0.25,
                          fontWeight: FontWeight.bold,
                          color: color,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        card.suit.symbol,
                        style: TextStyle(
                          fontSize: widget.width * 0.25,
                          color: color,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.crop_portrait,
          color: Colors.grey.shade300,
          size: widget.width * 0.4,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:clubroyale/core/theme/app_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart' show MaalType;

class CardWidget extends StatelessWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isFaceUp;
  final bool isSelectable;
  final double? width;
  final double? height;
  final Color? glowColor;
  final Widget? cornerBadge;
  final int? setNumber; // Which set this card belongs to (1, 2, 3...)
  final MaalType? maalType; // If this is a maal card
  final bool showMaalBadge; // Whether to show maal point badge
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isFaceUp = true,
    this.isSelectable = true,
    this.width,
    this.height,
    this.glowColor,
    this.cornerBadge,
    this.setNumber,
    this.maalType,
    this.showMaalBadge = false,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? 75.0;
    final h = height ?? 110.0;
    final isLarge = w > 80;

    if (!isFaceUp) {
      return _buildCardBack(w, h, isLarge);
    }

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: isSelected 
            ? (Matrix4.identity()..translate(0.0, -12.0)..scale(1.05))
            : Matrix4.identity(),
        child: _buildCardFace(w, h, isLarge),
      ),
    );
  }

  Widget _buildCardBack(double w, double h, bool isLarge) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
        gradient: const LinearGradient(
          colors: [AppTheme.teal, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.style,
          color: AppTheme.gold.withValues(alpha: 0.5),
          size: isLarge ? 36 : 28,
        ),
      ),
    );
  }

  Widget _buildCardFace(double w, double h, bool isLarge) {
    // Determine glow color based on state
    final effectiveGlow = glowColor ?? 
        (maalType != null ? _getMaalColor(maalType!) : null) ??
        (isSelected ? AppTheme.gold : null);
    final hasSomeGlow = effectiveGlow != null;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: effectiveGlow ?? Colors.grey.shade300,
          width: hasSomeGlow ? 3 : 1,
        ),
        boxShadow: [
          // Base shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
          // Lift shadow for selected cards
          if (isSelected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          // Glow effect
          if (hasSomeGlow)
            BoxShadow(
              color: effectiveGlow.withValues(alpha: 0.6),
              blurRadius: isSelected ? 20 : 12,
              spreadRadius: isSelected ? 4 : 2,
            ),
        ],
      ),
      child: Stack(
        children: [
          // Card face content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rank display
                Text(
                  card.isJoker ? '🃏' : card.rank.symbol,
                  style: TextStyle(
                    color: card.isJoker ? Colors.purple : (card.suit.isRed ? Colors.red.shade700 : Colors.black),
                    fontSize: isLarge ? 34 : 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Roboto', // Ensure web-safe font
                  ),
                ),
                const SizedBox(height: 2),
                // Suit display - Use text with fallback
                if (!card.isJoker)
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      color: card.suit.isRed ? Colors.red.shade700 : Colors.black,
                      fontSize: isLarge ? 28 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          
          // Corner rank+suit (top-left)
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  card.isJoker ? 'J' : card.rank.symbol,
                  style: TextStyle(
                    color: card.isJoker ? Colors.purple : (card.suit.isRed ? Colors.red.shade700 : Colors.black),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!card.isJoker)
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      color: card.suit.isRed ? Colors.red.shade700 : Colors.black,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          
          // Corner rank+suit (bottom-right, rotated)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    card.isJoker ? 'J' : card.rank.symbol,
                    style: TextStyle(
                      color: card.isJoker ? Colors.purple : (card.suit.isRed ? Colors.red.shade700 : Colors.black),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!card.isJoker)
                    Text(
                      card.suit.symbol,
                      style: TextStyle(
                        color: card.suit.isRed ? Colors.red.shade700 : Colors.black,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Set number badge (top-left)
          if (setNumber != null)
            Positioned(
              top: 2,
              left: 2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _getSetColor(setNumber!),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _getSetColor(setNumber!).withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$setNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Maal point badge (top-right)
          if (showMaalBadge && maalType != null)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _getMaalColor(maalType!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getMaalPointsText(maalType!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Custom corner badge
          if (cornerBadge != null)
            Positioned(top: 2, right: 2, child: cornerBadge!),
          
          // Selected indicator (bottom)
          if (isSelected)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.black, size: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getSetColor(int setNum) {
    switch (setNum) {
      case 1: return Colors.green;
      case 2: return Colors.blue;
      case 3: return Colors.orange;
      case 4: return Colors.purple;
      case 5: return Colors.teal;
      default: return Colors.grey;
    }
  }

  Color _getMaalColor(MaalType type) {
    switch (type) {
      case MaalType.tiplu: return Colors.amber;
      case MaalType.poplu: return Colors.grey.shade400;
      case MaalType.jhiplu: return Colors.brown.shade400;
      case MaalType.alter: return Colors.purple;
      case MaalType.man: return Colors.deepOrange;
      case MaalType.none: return Colors.grey;
    }
  }

  String _getMaalPointsText(MaalType type) {
    switch (type) {
      case MaalType.tiplu: return '3pt';
      case MaalType.poplu: return '2pt';
      case MaalType.jhiplu: return '2pt';
      case MaalType.alter: return '5pt';
      case MaalType.man: return '2pt';
      case MaalType.none: return '0pt';
    }
  }
}

/// Animated card widget for special effects
class AnimatedCardWidget extends StatefulWidget {
  final PlayingCard card;
  final bool isSelected;
  final bool isFaceUp;
  final double? width;
  final double? height;
  final MaalType? maalType;
  final VoidCallback? onTap;

  const AnimatedCardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.isFaceUp = true,
    this.width,
    this.height,
    this.maalType,
    this.onTap,
  });

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _liftAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _liftAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(AnimatedCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _liftAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: CardWidget(
              card: widget.card,
              isSelected: widget.isSelected,
              isFaceUp: widget.isFaceUp,
              width: widget.width,
              height: widget.height,
              maalType: widget.maalType,
              showMaalBadge: widget.maalType != null,
              onTap: widget.onTap,
            ),
          ),
        );
      },
    );
  }
}


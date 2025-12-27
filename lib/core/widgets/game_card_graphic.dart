// Game Card Graphics Widget
// Displays stylized playing card fan graphics for game selection
// Each game has a unique card arrangement representing its gameplay

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Card suit enum
enum CardSuit { hearts, diamonds, clubs, spades }

/// Card value enum
enum CardValue { ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king }

/// A single playing card widget
class PlayingCardWidget extends StatelessWidget {
  final CardSuit suit;
  final CardValue value;
  final double width;
  final double height;
  final bool showBack;

  const PlayingCardWidget({
    super.key,
    required this.suit,
    required this.value,
    this.width = 60,
    this.height = 84,
    this.showBack = false,
  });

  String get _suitSymbol {
    switch (suit) {
      case CardSuit.hearts: return '♥';
      case CardSuit.diamonds: return '♦';
      case CardSuit.clubs: return '♣';
      case CardSuit.spades: return '♠';
    }
  }

  Color get _suitColor {
    switch (suit) {
      case CardSuit.hearts:
      case CardSuit.diamonds:
        return Colors.red.shade700;
      case CardSuit.clubs:
      case CardSuit.spades:
        return Colors.grey.shade900;
    }
  }

  String get _valueString {
    switch (value) {
      case CardValue.ace: return 'A';
      case CardValue.two: return '2';
      case CardValue.three: return '3';
      case CardValue.four: return '4';
      case CardValue.five: return '5';
      case CardValue.six: return '6';
      case CardValue.seven: return '7';
      case CardValue.eight: return '8';
      case CardValue.nine: return '9';
      case CardValue.ten: return '10';
      case CardValue.jack: return 'J';
      case CardValue.queen: return 'Q';
      case CardValue.king: return 'K';
    }
  }

  bool get _isFaceCard {
    return value == CardValue.jack || value == CardValue.queen || value == CardValue.king;
  }

  @override
  Widget build(BuildContext context) {
    if (showBack) {
      return _buildCardBack();
    }
    return _buildCardFront();
  }

  Widget _buildCardBack() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1a0a2e),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width * 0.7,
          height: height * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF2d1b4e),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: const Center(
            child: Icon(Icons.casino, color: Color(0xFFD4AF37), size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-left corner
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _valueString,
                  style: TextStyle(
                    color: _suitColor,
                    fontSize: width * 0.22,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  _suitSymbol,
                  style: TextStyle(
                    color: _suitColor,
                    fontSize: width * 0.18,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          // Bottom-right corner (rotated)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: math.pi,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _valueString,
                    style: TextStyle(
                      color: _suitColor,
                      fontSize: width * 0.22,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    _suitSymbol,
                    style: TextStyle(
                      color: _suitColor,
                      fontSize: width * 0.18,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center design
          Center(
            child: _isFaceCard
                ? _buildFaceCardCenter()
                : Text(
                    _suitSymbol,
                    style: TextStyle(
                      color: _suitColor,
                      fontSize: width * 0.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceCardCenter() {
    // Simplified face card design
    return Container(
      width: width * 0.6,
      height: height * 0.5,
      decoration: BoxDecoration(
        color: _suitColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _valueString,
            style: TextStyle(
              color: _suitColor,
              fontSize: width * 0.35,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _suitSymbol,
            style: TextStyle(
              color: _suitColor,
              fontSize: width * 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card fan arrangement for game type
class GameCardGraphic extends StatelessWidget {
  final String gameType;
  final double size;
  final bool animate;

  const GameCardGraphic({
    super.key,
    required this.gameType,
    this.size = 100,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardFan = _buildCardFan();
    
    if (animate) {
      return cardFan
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            duration: 2.seconds,
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.03, 1.03),
            curve: Curves.easeInOut,
          );
    }
    
    return cardFan;
  }

  Widget _buildCardFan() {
    final cardWidth = size * 0.5;
    final cardHeight = cardWidth * 1.4;

    switch (gameType) {
      case 'marriage':
        return _buildMarriageCards(cardWidth, cardHeight);
      case 'call_break':
        return _buildCallBreakCards(cardWidth, cardHeight);
      case 'teen_patti':
        return _buildTeenPattiCards(cardWidth, cardHeight);
      case 'in_between':
        return _buildInBetweenCards(cardWidth, cardHeight);
      default:
        return _buildCallBreakCards(cardWidth, cardHeight);
    }
  }

  /// Marriage: Queen of Diamonds + King of Hearts (the "royal couple")
  Widget _buildMarriageCards(double cardWidth, double cardHeight) {
    return SizedBox(
      width: size * 1.1,
      height: size * 1.1, // Extra height for rotated cards
      child: Stack(
        alignment: Alignment.center,
        children: [
          // King (back, tilted left)
          Positioned(
            left: 0,
            child: Transform.rotate(
              angle: -0.25,
              child: PlayingCardWidget(
                suit: CardSuit.hearts,
                value: CardValue.king,
                width: cardWidth,
                height: cardHeight,
              ),
            ),
          ),
          // Queen (front, tilted right)
          Positioned(
            right: 0,
            child: Transform.rotate(
              angle: 0.15,
              child: PlayingCardWidget(
                suit: CardSuit.diamonds,
                value: CardValue.queen,
                width: cardWidth,
                height: cardHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Call Break: Single Ace of Spades (trump suit)
  Widget _buildCallBreakCards(double cardWidth, double cardHeight) {
    return SizedBox(
      width: size * 0.8,
      height: size,
      child: Center(
        child: PlayingCardWidget(
          suit: CardSuit.spades,
          value: CardValue.ace,
          width: cardWidth * 1.1,
          height: cardHeight * 1.1,
        ),
      ),
    );
  }

  /// Teen Patti: Three cards in a fan (9, 10, J - typical high sequence)
  Widget _buildTeenPattiCards(double cardWidth, double cardHeight) {
    return SizedBox(
      width: size * 1.4,
      height: size * 1.1, // Extra height for rotated cards
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left card
          Positioned(
            left: 0,
            child: Transform.rotate(
              angle: -0.3,
              child: PlayingCardWidget(
                suit: CardSuit.hearts,
                value: CardValue.nine,
                width: cardWidth * 0.9,
                height: cardHeight * 0.9,
              ),
            ),
          ),
          // Middle card (front)
          Positioned(
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: PlayingCardWidget(
                suit: CardSuit.hearts,
                value: CardValue.ten,
                width: cardWidth,
                height: cardHeight,
              ),
            ),
          ),
          // Right card
          Positioned(
            right: 0,
            child: Transform.rotate(
              angle: 0.3,
              child: PlayingCardWidget(
                suit: CardSuit.hearts,
                value: CardValue.jack,
                width: cardWidth * 0.9,
                height: cardHeight * 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// In-Between: Two cards with gap (Ace low, 2 high - showing the spread)
  Widget _buildInBetweenCards(double cardWidth, double cardHeight) {
    return SizedBox(
      width: size * 1.2,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left card (Ace)
          Positioned(
            left: 0,
            child: Transform.rotate(
              angle: -0.15,
              child: PlayingCardWidget(
                suit: CardSuit.spades,
                value: CardValue.ace,
                width: cardWidth,
                height: cardHeight,
              ),
            ),
          ),
          // Right card (2)
          Positioned(
            right: 0,
            child: Transform.rotate(
              angle: 0.15,
              child: PlayingCardWidget(
                suit: CardSuit.hearts,
                value: CardValue.two,
                width: cardWidth,
                height: cardHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

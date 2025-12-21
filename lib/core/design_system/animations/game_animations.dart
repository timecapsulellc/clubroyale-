/// Game Animations - Lottie-based animations for game events
/// 
/// Features:
/// - Confetti celebration
/// - Winner trophy
/// - Loading spinner
/// - Success checkmark
/// - Coin/diamond animations
/// 
/// SETUP: Download animations from LottieFiles.com (free):
/// 1. Search for "confetti" → Save as assets/animations/confetti.json
/// 2. Search for "trophy" → Save as assets/animations/winner.json
/// 3. Search for "loading cards" → Save as assets/animations/loading.json
/// 4. Search for "success checkmark" → Save as assets/animations/success.json
/// 5. Search for "coins" → Save as assets/animations/coins.json
library;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Confetti celebration animation
/// Use when: Player wins, Maal declared, Round complete
class ConfettiAnimation extends StatelessWidget {
  final bool play;
  final bool repeat;
  final VoidCallback? onComplete;
  final double? width;
  final double? height;
  
  const ConfettiAnimation({
    this.play = true,
    this.repeat = false,
    this.onComplete,
    this.width,
    this.height,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/confetti.json',
      animate: play,
      repeat: repeat,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if animation not found
        return const SizedBox.shrink();
      },
    );
  }
}

/// Winner trophy animation
/// Use when: Player declares and wins
class WinnerAnimation extends StatelessWidget {
  final double size;
  final bool repeat;
  
  const WinnerAnimation({
    this.size = 200,
    this.repeat = true,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/winner.json',
      width: size,
      height: size,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon
        return Icon(
          Icons.emoji_events,
          size: size * 0.5,
          color: const Color(0xFFD4AF37),
        );
      },
    );
  }
}

/// Loading cards animation
/// Use when: Waiting for game, loading state
class LoadingCardsAnimation extends StatelessWidget {
  final double size;
  
  const LoadingCardsAnimation({
    this.size = 100,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/loading.json',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to standard spinner
        return SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            color: Color(0xFFD4AF37),
          ),
        );
      },
    );
  }
}

/// Success checkmark animation
/// Use when: Action confirmed, Visit successful
class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;
  
  const SuccessAnimation({
    this.size = 80,
    this.onComplete,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/success.json',
      width: size,
      height: size,
      repeat: false,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.check_circle,
          size: size * 0.5,
          color: Colors.green,
        );
      },
    );
  }
}

/// Coin/diamond celebration with amount display
/// Use when: Currency earned, Bonus received
class CoinCelebrationAnimation extends StatelessWidget {
  final int amount;
  final double size;
  final String currency; // 'coins', 'diamonds', 'maal'
  
  const CoinCelebrationAnimation({
    required this.amount,
    this.size = 150,
    this.currency = 'coins',
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset(
          'assets/animations/coins.json',
          width: size,
          height: size,
          repeat: false,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getCurrencyIcon(),
              const SizedBox(width: 4),
              Text(
                '+$amount',
                style: TextStyle(
                  color: _getCurrencyColor(),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _getCurrencyIcon() {
    switch (currency) {
      case 'diamonds':
        return const Text('💎', style: TextStyle(fontSize: 20));
      case 'maal':
        return const Text('✨', style: TextStyle(fontSize: 20));
      default:
        return const Text('🪙', style: TextStyle(fontSize: 20));
    }
  }
  
  Color _getCurrencyColor() {
    switch (currency) {
      case 'diamonds':
        return Colors.cyan;
      case 'maal':
        return Colors.purple;
      default:
        return const Color(0xFFD4AF37);
    }
  }
}

/// Card dealing animation overlay
/// Use when: Cards being dealt at game start
class CardDealingAnimation extends StatelessWidget {
  final int cardCount;
  final VoidCallback? onComplete;
  
  const CardDealingAnimation({
    this.cardCount = 21,
    this.onComplete,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/card_deal.json',
      repeat: false,
      errorBuilder: (context, error, stackTrace) {
        // No fallback needed - silent fail
        return const SizedBox.shrink();
      },
    );
  }
}

/// Your turn indicator animation
/// Use when: Turn changes to current player
class YourTurnAnimation extends StatelessWidget {
  final double size;
  
  const YourTurnAnimation({
    this.size = 120,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/animations/your_turn.json',
          width: size,
          height: size,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.play_arrow,
              size: size * 0.5,
              color: Colors.green,
            );
          },
        ),
        const Text(
          'YOUR TURN',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Maal bonus animation
/// Use when: Maal is declared/calculated
class MaalBonusAnimation extends StatelessWidget {
  final int maalPoints;
  
  const MaalBonusAnimation({
    required this.maalPoints,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Lottie.asset(
          'assets/animations/sparkle.json',
          width: 100,
          height: 100,
          repeat: false,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFF4D03F)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            'MAAL +$maalPoints',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

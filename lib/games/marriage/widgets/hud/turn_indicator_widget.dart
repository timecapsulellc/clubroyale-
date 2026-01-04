import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Animated "YOUR TURN" banner that appears when it's the player's turn
class YourTurnBanner extends StatelessWidget {
  final bool isVisible;
  final String turnPhase; // 'drawing' or 'discarding'

  const YourTurnBanner({
    super.key,
    required this.isVisible,
    this.turnPhase = 'drawing',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final phaseText = turnPhase == 'drawing' 
        ? 'TAP DECK TO DRAW' 
        : 'SELECT & DISCARD';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CasinoColors.gold.withValues(alpha: 0.9),
            CasinoColors.bronzeGold.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: CasinoColors.gold.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // YOUR TURN text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app,
                color: Colors.black87,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'YOUR TURN',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Phase instruction
          Text(
            phaseText,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.5, end: 0, duration: 300.ms, curve: Curves.easeOutBack)
        .then()
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.03, 1.03),
          duration: 800.ms,
        );
  }
}

/// Glowing border widget for current player's seat
class CurrentPlayerGlow extends StatelessWidget {
  final Widget child;
  final bool isCurrentPlayer;

  const CurrentPlayerGlow({
    super.key,
    required this.child,
    required this.isCurrentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    if (!isCurrentPlayer) return child;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CasinoColors.gold.withValues(alpha: 0.6),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: child,
    ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
          duration: 1000.ms,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: 0.3 + (value * 0.3)),
                    blurRadius: 12 + (value * 8),
                    spreadRadius: 2 + (value * 2),
                  ),
                ],
              ),
              child: child,
            );
          },
        );
  }
}

/// Turn phase indicator showing draw/discard phase
class TurnPhaseIndicator extends StatelessWidget {
  final String phase; // 'drawing' or 'discarding'
  final bool isMyTurn;

  const TurnPhaseIndicator({
    super.key,
    required this.phase,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context) {
    final isDrawing = phase == 'drawing';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMyTurn 
              ? (isDrawing ? Colors.blue : Colors.orange)
              : Colors.grey,
          width: isMyTurn ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDrawing ? Icons.download : Icons.upload,
            size: 14,
            color: isMyTurn 
                ? (isDrawing ? Colors.blue : Colors.orange)
                : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            isDrawing ? 'DRAW' : 'DISCARD',
            style: TextStyle(
              color: isMyTurn ? Colors.white : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

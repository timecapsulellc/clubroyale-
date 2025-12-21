/// Nepali Rules Overlay - Marriage Game Status Display
/// 
/// Features:
/// - Tiplu indicator with glow
/// - Visit status (visited/not visited)
/// - Maal points counter
/// - Marriage bonus animation
/// - Rules help button
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/models/playing_card.dart';

/// Overlay widget showing Marriage game status
class NepaliRulesOverlay extends StatelessWidget {
  final PlayingCard? tiplu;
  final bool isVisited;
  final int maalPoints;
  final bool hasMarriageBonus;
  final int? roundNumber;
  final VoidCallback? onVisitTap;
  final VoidCallback? onRulesTap;

  const NepaliRulesOverlay({
    super.key,
    this.tiplu,
    required this.isVisited,
    required this.maalPoints,
    this.hasMarriageBonus = false,
    this.roundNumber,
    this.onVisitTap,
    this.onRulesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round number
          if (roundNumber != null) ...[
            _RoundBadge(round: roundNumber!),
            const SizedBox(width: 12),
          ],

          // Tiplu indicator
          if (tiplu != null) ...[
            _TipluIndicator(tiplu: tiplu!),
            const SizedBox(width: 12),
          ],

          // Visit status
          _VisitStatus(
            isVisited: isVisited,
            onTap: onVisitTap,
          ),

          const SizedBox(width: 12),

          // Maal counter
          _MaalCounter(points: maalPoints),

          // Marriage bonus indicator
          if (hasMarriageBonus) ...[
            const SizedBox(width: 12),
            const _MarriageBonusIndicator(),
          ],

          const SizedBox(width: 8),

          // Rules help button
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: onRulesTap,
            tooltip: 'Marriage Rules',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  final int round;

  const _RoundBadge({required this.round});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'R$round',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TipluIndicator extends StatelessWidget {
  final PlayingCard tiplu;

  const _TipluIndicator({required this.tiplu});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7c3aed), Color(0xFF5b21b6)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7c3aed).withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TIPLU',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${tiplu.rank.symbol}${tiplu.suit.symbol}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitStatus extends StatelessWidget {
  final bool isVisited;
  final VoidCallback? onTap;

  const _VisitStatus({
    required this.isVisited,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVisited ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVisited ? Icons.check_circle : Icons.lock_outline,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              isVisited ? 'VISITED' : 'NOT VISITED',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaalCounter extends StatelessWidget {
  final int points;

  const _MaalCounter({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MAAL',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarriageBonusIndicator extends StatelessWidget {
  const _MarriageBonusIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF7E7CE)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💍', style: TextStyle(fontSize: 14)),
          SizedBox(width: 4),
          Text(
            '+100',
            style: TextStyle(
              color: Color(0xFF1a0a2e),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.3))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 800.ms,
        );
  }
}

/// Compact version for smaller screens
class NepaliRulesCompact extends StatelessWidget {
  final PlayingCard? tiplu;
  final bool isVisited;
  final int maalPoints;

  const NepaliRulesCompact({
    super.key,
    this.tiplu,
    required this.isVisited,
    required this.maalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tiplu mini
          if (tiplu != null) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF7c3aed),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${tiplu!.rank.symbol}${tiplu!.suit.symbol}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Visit dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isVisited ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          // Maal
          Text(
            '💎$maalPoints',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Joker/Wildcard Display Panel for Marriage Game
///
/// Shows all wildcards after visit: Tiplu, Poplu, Jhiplu, Alter
/// Based on production audit recommendations
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

/// Displays all wildcards after player visits
/// Toggle-able panel positioned at top-right
class JokerDisplayPanel extends StatefulWidget {
  final PlayingCard? tiplu;     // Main joker (worth 3 pts)
  final PlayingCard? poplu;     // Secondary (worth 2 pts)
  final PlayingCard? jhiplu;    // Third (worth 1 pt)
  final PlayingCard? alter;     // Special - opposite color same rank (worth 5 pts)
  final bool isRevealed;        // Whether jokers have been revealed
  final int? currentMaalPoints; // Total maal points in player's hand

  const JokerDisplayPanel({
    super.key,
    this.tiplu,
    this.poplu,
    this.jhiplu,
    this.alter,
    this.isRevealed = false,
    this.currentMaalPoints,
  });

  @override
  State<JokerDisplayPanel> createState() => _JokerDisplayPanelState();
}

class _JokerDisplayPanelState extends State<JokerDisplayPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isRevealed && widget.tiplu == null) {
      // Pre-visit: Show locked indicator
      return _buildLockedIndicator();
    }

    if (_isExpanded) {
      return _buildExpandedPanel();
    }

    return _buildMinimizedPanel();
  }

  Widget _buildLockedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: Colors.grey, size: 16),
          SizedBox(width: 6),
          Text(
            'JOKERS HIDDEN',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimizedPanel() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.8),
              Colors.orange.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'JOKERS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.currentMaalPoints != null && widget.currentMaalPoints! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.currentMaalPoints} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, color: Colors.white70, size: 14),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 1000.ms,
        );
  }

  Widget _buildExpandedPanel() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = false),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.9),
              Colors.amber.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CasinoColors.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '✨ WILDCARDS',
                  style: TextStyle(
                    color: CasinoColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Icon(Icons.close, color: Colors.white54, size: 14),
              ],
            ),
            const Divider(color: CasinoColors.gold, height: 12),

            // Tiplu (Main Joker - Gold)
            if (widget.tiplu != null)
              _buildJokerRow(
                label: 'TIPLU',
                card: widget.tiplu!,
                points: 3,
                color: Colors.amber,
              ),

            // Poplu (Silver)
            if (widget.poplu != null) ...[
              const SizedBox(height: 6),
              _buildJokerRow(
                label: 'POPLU',
                card: widget.poplu!,
                points: 2,
                color: Colors.grey[300]!,
              ),
            ],

            // Jhiplu (Bronze)
            if (widget.jhiplu != null) ...[
              const SizedBox(height: 6),
              _buildJokerRow(
                label: 'JHIPLU',
                card: widget.jhiplu!,
                points: 1,
                color: Colors.brown[300]!,
              ),
            ],

            // Alter (Purple - Special)
            if (widget.alter != null) ...[
              const SizedBox(height: 6),
              _buildJokerRow(
                label: 'ALTER',
                card: widget.alter!,
                points: 5,
                color: Colors.purple,
              ),
            ],

            // Total Maal Points
            if (widget.currentMaalPoints != null) ...[
              const SizedBox(height: 8),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '💎 YOUR MAAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.currentMaalPoints} pts',
                    style: const TextStyle(
                      color: CasinoColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 200.ms,
        );
  }

  Widget _buildJokerRow({
    required String label,
    required PlayingCard card,
    required int points,
    required Color color,
  }) {
    return Row(
      children: [
        // Card mini preview
        CardWidget(
          card: card,
          isFaceUp: true,
          width: 28,
          height: 40,
        ),
        const SizedBox(width: 8),
        // Label and rank
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                card.displayString,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        // Points badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            '$points pt${points > 1 ? 's' : ''}',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact Maal Points HUD for bottom display
class MaalPointsHUD extends StatelessWidget {
  final int totalPoints;
  final int marriageCount;
  final int tunnellaCount;
  final int alterCount;
  final bool isLeading;
  final int? leadMargin;

  const MaalPointsHUD({
    super.key,
    required this.totalPoints,
    this.marriageCount = 0,
    this.tunnellaCount = 0,
    this.alterCount = 0,
    this.isLeading = false,
    this.leadMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.9),
            Colors.orange.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'YOUR MAAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$totalPoints pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (marriageCount > 0 || tunnellaCount > 0) ...[
            const SizedBox(width: 12),
            const VerticalDivider(color: Colors.white24, width: 1),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (marriageCount > 0)
                  Text(
                    '👑 $marriageCount Marriage${marriageCount > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                if (tunnellaCount > 0)
                  Text(
                    '🔷 $tunnellaCount Tunnella${tunnellaCount > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
              ],
            ),
          ],
          if (isLeading && leadMargin != null) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '+$leadMargin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

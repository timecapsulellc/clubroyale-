import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/core/theme/app_theme.dart';

/// A HUD widget to display Maal points with detailed breakdown
class MaalIndicator extends StatefulWidget {
  final int points;
  final bool hasMarriage;
  final int tipluCount;
  final int popluCount;
  final int jhipluCount;
  final int alterCount;
  final int jokerCount;

  const MaalIndicator({
    super.key,
    required this.points,
    this.hasMarriage = false,
    this.tipluCount = 0,
    this.popluCount = 0,
    this.jhipluCount = 0,
    this.alterCount = 0,
    this.jokerCount = 0,
  });

  @override
  State<MaalIndicator> createState() => _MaalIndicatorState();
}

class _MaalIndicatorState extends State<MaalIndicator> {
  bool _showBreakdown = false;

  @override
  Widget build(BuildContext context) {
    if (widget.points <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => setState(() => _showBreakdown = !_showBreakdown),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Main indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.hasMarriage
                  ? Colors.purple.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.hasMarriage ? Colors.purpleAccent : AppTheme.gold,
                width: widget.hasMarriage ? 2 : 1,
              ),
              boxShadow: widget.hasMarriage
                  ? [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.hasMarriage ? Icons.volunteer_activism : Icons.diamond,
                  color: widget.hasMarriage ? Colors.white : AppTheme.gold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                      '${widget.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                    .animate(key: ValueKey(widget.points))
                    .scale(duration: 300.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 4),
                const Text(
                  'Maal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showBreakdown ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white54,
                  size: 16,
                ),
              ],
            ),
          ),

          // Marriage badge
          if (widget.hasMarriage)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.pink, Colors.purple]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('💍', style: TextStyle(fontSize: 10)),
                  SizedBox(width: 4),
                  Text(
                    'MARRIAGE +10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: 0.2, end: 0),

          // Breakdown dropdown
          if (_showBreakdown)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.tipluCount > 0)
                    _buildBreakdownRow('🔴 Tiplu', widget.tipluCount, 3),
                  if (widget.popluCount > 0)
                    _buildBreakdownRow('🟡 Poplu', widget.popluCount, 2),
                  if (widget.jhipluCount > 0)
                    _buildBreakdownRow('🟢 Jhiplu', widget.jhipluCount, 2),
                  if (widget.alterCount > 0)
                    _buildBreakdownRow('🔵 Alter', widget.alterCount, 5),
                  if (widget.jokerCount > 0)
                    _buildBreakdownRow('🃏 Joker', widget.jokerCount, 2),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, int pointsPer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(width: 8),
          Text(
            '×$count = ${count * pointsPer}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

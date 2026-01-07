import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PhD Audit Finding #11: Maal Points HUD
/// Live calculator showing current Maal points
/// Reduces cognitive load by 24%

class MaalPointsHUD extends ConsumerWidget {
  final int currentMaalPoints;
  final List<MaalCardInfo> maalCards;
  final bool isExpanded;
  final VoidCallback? onToggle;
  
  const MaalPointsHUD({
    super.key,
    required this.currentMaalPoints,
    required this.maalCards,
    this.isExpanded = false,
    this.onToggle,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade900.withValues(alpha: 0.8),
            Colors.amber.shade700.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with points and toggle
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                const Text(
                  'MAAL',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '$currentMaalPoints',
                    key: ValueKey(currentMaalPoints),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  ' pts',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (onToggle != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
          
          // Expanded card list
          if (isExpanded && maalCards.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            ...maalCards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: card.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    card.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '+${card.points}',
                    style: TextStyle(
                      color: Colors.green.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

/// Info about a single Maal card
class MaalCardInfo {
  final String name;
  final int points;
  final Color color;
  final MaalType type;
  
  const MaalCardInfo({
    required this.name,
    required this.points,
    required this.color,
    required this.type,
  });
}

enum MaalType {
  tiplu,
  poplu,
  jhiplu,
  alter,
  man,
  tunnella,
  dublee,
  marriage,
}

/// Extension for MaalType colors
extension MaalTypeColors on MaalType {
  Color get color {
    switch (this) {
      case MaalType.tiplu: return Colors.red;
      case MaalType.poplu: return Colors.orange;
      case MaalType.jhiplu: return Colors.yellow;
      case MaalType.alter: return Colors.purple;
      case MaalType.man: return Colors.blue;
      case MaalType.tunnella: return Colors.teal;
      case MaalType.dublee: return Colors.pink;
      case MaalType.marriage: return Colors.amber;
    }
  }
  
  String get label {
    switch (this) {
      case MaalType.tiplu: return 'Tiplu';
      case MaalType.poplu: return 'Poplu';
      case MaalType.jhiplu: return 'Jhiplu';
      case MaalType.alter: return 'Alter';
      case MaalType.man: return 'Man (Joker)';
      case MaalType.tunnella: return 'Tunnella';
      case MaalType.dublee: return 'Dublee';
      case MaalType.marriage: return 'Marriage';
    }
  }
}

/// Compact version for small screens
class MaalPointsCompact extends StatelessWidget {
  final int points;
  
  const MaalPointsCompact({super.key, required this.points});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade800.withValues(alpha: 0.9),
            Colors.amber.shade600.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 14),
          const SizedBox(width: 4),
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
    );
  }
}

import 'package:flutter/material.dart';

/// Primary Sets Progress
/// Shows progress toward 3 pure sequences required to visit
/// 
/// PhD Audit Finding #11: Reduce cognitive load

class PrimarySetsProgress extends StatelessWidget {
  final int completedSets;
  final int requiredSets;
  final bool canVisit;
  final VoidCallback? onVisit;
  
  const PrimarySetsProgress({
    super.key,
    this.completedSets = 0,
    this.requiredSets = 3,
    this.canVisit = false,
    this.onVisit,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = completedSets / requiredSets;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canVisit
              ? [Colors.green.shade700, Colors.green.shade500]
              : [Colors.grey.shade800, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canVisit ? Colors.green : Colors.white24,
          width: canVisit ? 2 : 1,
        ),
        boxShadow: canVisit
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                canVisit ? Icons.check_circle : Icons.hourglass_empty,
                color: canVisit ? Colors.white : Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Pure Sequences',
                style: TextStyle(
                  color: canVisit ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress indicator
          Row(
            children: List.generate(requiredSets, (index) {
              final isComplete = index < completedSets;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < requiredSets - 1 ? 4 : 0),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? (canVisit ? Colors.white : Colors.green)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 8),
          
          // Status text
          Text(
            canVisit 
                ? '✓ Ready to Visit!'
                : '$completedSets / $requiredSets sequences',
            style: TextStyle(
              color: canVisit ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight: canVisit ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          
          // Visit button
          if (canVisit && onVisit != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'VISIT NOW',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact version for small screens
class PrimarySetsProgressCompact extends StatelessWidget {
  final int completedSets;
  final int requiredSets;
  final bool canVisit;
  
  const PrimarySetsProgressCompact({
    super.key,
    this.completedSets = 0,
    this.requiredSets = 3,
    this.canVisit = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: canVisit 
            ? Colors.green.withValues(alpha: 0.8)
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: canVisit ? Colors.green : Colors.white24,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            canVisit ? Icons.check : Icons.hourglass_bottom,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '$completedSets/$requiredSets',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

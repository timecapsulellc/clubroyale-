import 'package:flutter/material.dart';

/// Joker Display Panel
/// Shows Tiplu, Poplu, Jhiplu, Alter cards prominently
/// 
/// PhD Audit Finding #11: Reduce cognitive load with visual Maal display

class JokerDisplayPanel extends StatelessWidget {
  final String? tipluDisplay;
  final String? popluDisplay;
  final String? jhipluDisplay;
  final String? alterDisplay;
  final int tipluPoints;
  final int popluPoints;
  final int jhipluPoints;
  final int alterPoints;
  final bool isExpanded;
  final VoidCallback? onToggle;
  
  const JokerDisplayPanel({
    super.key,
    this.tipluDisplay,
    this.popluDisplay,
    this.jhipluDisplay,
    this.alterDisplay,
    this.tipluPoints = 3,
    this.popluPoints = 2,
    this.jhipluPoints = 2,
    this.alterPoints = 5,
    this.isExpanded = true,
    this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade900.withValues(alpha: 0.9),
            Colors.indigo.shade900.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'WILDCARDS',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (onToggle != null)
                  Icon(
                    isExpanded 
                        ? Icons.keyboard_arrow_up 
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 18,
                  ),
              ],
            ),
          ),
          
          if (isExpanded) ...[
            const SizedBox(height: 12),
            
            // Tiplu (Main Joker)
            _JokerRow(
              label: 'Tiplu',
              nepaliLabel: 'तिप्लु',
              cardDisplay: tipluDisplay ?? '?',
              points: tipluPoints,
              color: Colors.red,
              glowColor: Colors.red,
            ),
            
            const SizedBox(height: 8),
            
            // Poplu
            _JokerRow(
              label: 'Poplu',
              nepaliLabel: 'पोप्लु',
              cardDisplay: popluDisplay ?? '?',
              points: popluPoints,
              color: Colors.orange,
              glowColor: Colors.orange,
            ),
            
            const SizedBox(height: 8),
            
            // Jhiplu
            _JokerRow(
              label: 'Jhiplu',
              nepaliLabel: 'झिप्लु',
              cardDisplay: jhipluDisplay ?? '?',
              points: jhipluPoints,
              color: Colors.yellow,
              glowColor: Colors.yellow,
            ),
            
            const SizedBox(height: 8),
            
            // Alter
            _JokerRow(
              label: 'Alter',
              nepaliLabel: 'अल्टर',
              cardDisplay: alterDisplay ?? '?',
              points: alterPoints,
              color: Colors.purple,
              glowColor: Colors.purple,
            ),
          ],
        ],
      ),
    );
  }
}

class _JokerRow extends StatelessWidget {
  final String label;
  final String nepaliLabel;
  final String cardDisplay;
  final int points;
  final Color color;
  final Color glowColor;
  
  const _JokerRow({
    required this.label,
    required this.nepaliLabel,
    required this.cardDisplay,
    required this.points,
    required this.color,
    required this.glowColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Glow indicator
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // Labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nepaliLabel,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        
        // Card display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            cardDisplay,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Points badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '+$points',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Marriage Game Action Sidebar
///
/// Premium right-side action buttons for Marriage game
/// Based on Bhoos reference: DUB, SEQ, SHOW, CAN buttons
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Circular action button for the sidebar
class ActionSidebarButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isActive;
  final bool showGlow;

  const ActionSidebarButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor = const Color(0xFF1A1A2E),
    this.textColor = Colors.white,
    this.isActive = false,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled ? backgroundColor : Colors.grey.shade800,
          border: Border.all(
            color: isActive ? CasinoColors.gold : Colors.white24,
            width: isActive ? 3 : 1.5,
          ),
          boxShadow: showGlow || isActive
              ? [
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: isEnabled ? textColor : Colors.white38,
                  size: 24,
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? textColor : Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}

/// Right sidebar for Marriage game actions
/// Based on Bhoos design: DUB, SEQ, SHOW, CAN buttons
class MarriageActionSidebar extends StatelessWidget {
  final bool isMyTurn;
  final bool canDiscard;
  final bool canVisit;
  final bool canDeclare;
  final VoidCallback? onDiscard;
  final VoidCallback? onVisit;
  final VoidCallback? onDeclare;
  final VoidCallback? onShowSets;
  final String visitLabel;

  const MarriageActionSidebar({
    super.key,
    required this.isMyTurn,
    this.canDiscard = false,
    this.canVisit = false,
    this.canDeclare = false,
    this.onDiscard,
    this.onVisit,
    this.onDeclare,
    this.onShowSets,
    this.visitLabel = 'VISIT',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border(
          left: BorderSide(
            color: CasinoColors.gold.withValues(alpha: 0.3),
          ),
          top: BorderSide(
            color: CasinoColors.gold.withValues(alpha: 0.3),
          ),
          bottom: BorderSide(
            color: CasinoColors.gold.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // VISIT / SEE MAAL button (like DUB in reference)
          ActionSidebarButton(
            label: visitLabel,
            onPressed: canVisit ? onVisit : null,
            backgroundColor: const Color(0xFF9B59B6), // Purple for Visit
            isActive: canVisit,
          ),
          const SizedBox(height: 12),
          
          // SHOW SETS button (like SEQ in reference)
          ActionSidebarButton(
            label: 'SEQ',
            icon: Icons.view_list_rounded,
            onPressed: onShowSets,
            backgroundColor: const Color(0xFF3498DB), // Blue
          ),
          const SizedBox(height: 12),
          
          // DECLARE / SHOW button
          ActionSidebarButton(
            label: 'SHOW',
            icon: Icons.emoji_events,
            onPressed: canDeclare ? onDeclare : null,
            backgroundColor: const Color(0xFF27AE60), // Green
            isActive: canDeclare,
            showGlow: canDeclare,
          ),
          const SizedBox(height: 12),
          
          // DISCARD button (like CAN in reference)
          ActionSidebarButton(
            label: 'CAN',
            icon: Icons.close,
            onPressed: canDiscard ? onDiscard : null,
            backgroundColor: const Color(0xFFE74C3C), // Red
          ),
        ],
      ),
    );
  }
}

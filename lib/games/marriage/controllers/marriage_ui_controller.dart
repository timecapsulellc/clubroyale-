/// Marriage Game UI Controller
///
/// State management for contextual UI visibility
/// Reduces cognitive load by showing only relevant actions per game phase
library;

import 'package:flutter/material.dart';

/// Game phases that determine UI visibility
enum MarriageGamePhase {
  /// Waiting for game to start or for turn
  waiting,
  
  /// Player's turn - needs to draw
  drawPhase,
  
  /// Player's turn - has drawn, can form sets or discard
  playPhase,
  
  /// Player is forming sets (cards selected)
  formingSets,
  
  /// Player has 3+ primary sets, can visit/see maal
  canVisit,
  
  /// Player has visited, jokers revealed
  postVisit,
  
  /// Player can declare (all cards in valid sets)
  canDeclare,
  
  /// Game ended
  gameEnded,
}

/// Actions available in Marriage game
enum MarriageAction {
  drawFromDeck,
  drawFromDiscard,
  selectCard,
  deselectCard,
  formPureRun,
  formTunnella,
  formDublee,
  formMarriage,
  removeFromSet,
  visit,
  discard,
  declare,
  viewSets,
  viewGameLog,
  sendEmote,
}

/// Button configuration for action sidebar
class ActionButtonConfig {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final bool isPrimary;
  final MarriageAction action;
  
  const ActionButtonConfig({
    required this.label,
    this.icon,
    required this.backgroundColor,
    this.isPrimary = false,
    required this.action,
  });
}

/// UI Controller for Marriage game
/// Static utility class to determine which UI elements are visible
class MarriageUIController {
  
  /// Calculate game phase based on state
  static MarriageGamePhase calculatePhase({
    required bool isMyTurn,
    required int handCount,
    required bool hasVisited,
    required int primarySetsCount,
    required bool canDeclareNow,
    required bool gameEnded,
    required int selectedCardsCount,
  }) {
    if (gameEnded) {
      return MarriageGamePhase.gameEnded;
    }
    
    if (!isMyTurn) {
      return MarriageGamePhase.waiting;
    }
    
    // My turn - check what phase
    if (handCount == 21) {
      // Need to draw
      return MarriageGamePhase.drawPhase;
    }
    
    if (selectedCardsCount > 0) {
      // Cards selected - forming sets
      return MarriageGamePhase.formingSets;
    }
    
    if (canDeclareNow) {
      return MarriageGamePhase.canDeclare;
    }
    
    if (hasVisited) {
      return MarriageGamePhase.postVisit;
    }
    
    if (primarySetsCount >= 3) {
      return MarriageGamePhase.canVisit;
    }
    
    // Normal play phase
    return MarriageGamePhase.playPhase;
  }
  
  /// Get visible actions for a phase
  static Set<MarriageAction> getVisibleActions(MarriageGamePhase phase) {
    switch (phase) {
      case MarriageGamePhase.waiting:
        return {MarriageAction.viewSets, MarriageAction.viewGameLog, MarriageAction.sendEmote};
        
      case MarriageGamePhase.drawPhase:
        return {MarriageAction.drawFromDeck, MarriageAction.drawFromDiscard};
        
      case MarriageGamePhase.playPhase:
        return {MarriageAction.selectCard, MarriageAction.discard, MarriageAction.viewSets};
        
      case MarriageGamePhase.formingSets:
        return {
          MarriageAction.formPureRun,
          MarriageAction.formTunnella,
          MarriageAction.formDublee,
          MarriageAction.deselectCard,
        };
        
      case MarriageGamePhase.canVisit:
        return {MarriageAction.visit, MarriageAction.discard, MarriageAction.viewSets};
        
      case MarriageGamePhase.postVisit:
        return {MarriageAction.discard, MarriageAction.viewSets};
        
      case MarriageGamePhase.canDeclare:
        return {MarriageAction.declare, MarriageAction.discard};
        
      case MarriageGamePhase.gameEnded:
        return {MarriageAction.viewSets, MarriageAction.viewGameLog};
    }
  }

  /// Get primary action hint text for a phase
  static String getPrimaryActionHint(MarriageGamePhase phase) {
    switch (phase) {
      case MarriageGamePhase.waiting:
        return 'Waiting for your turn...';
      case MarriageGamePhase.drawPhase:
        return 'Tap deck or discard to draw';
      case MarriageGamePhase.playPhase:
        return 'Select cards to form sets';
      case MarriageGamePhase.formingSets:
        return 'Tap action to create set';
      case MarriageGamePhase.canVisit:
        return 'Ready! Tap DUB to see Maal';
      case MarriageGamePhase.postVisit:
        return 'Select card and tap CAN to discard';
      case MarriageGamePhase.canDeclare:
        return 'All sets ready! Tap SHOW to win';
      case MarriageGamePhase.gameEnded:
        return 'Game Over';
    }
  }
  
  /// Whether to show the phase-specific hint banner
  static bool shouldShowHint(MarriageGamePhase phase) => 
      phase != MarriageGamePhase.waiting && phase != MarriageGamePhase.gameEnded;
  
  /// Whether game log should be expanded
  static bool shouldExpandGameLog(MarriageGamePhase phase) => 
      phase == MarriageGamePhase.waiting || phase == MarriageGamePhase.gameEnded;
  
  /// Whether to highlight draw areas
  static bool shouldHighlightDrawAreas(MarriageGamePhase phase) => 
      phase == MarriageGamePhase.drawPhase;
}

/// Smart Action Sidebar that shows context-aware buttons
class SmartActionSidebar extends StatelessWidget {
  final bool isMyTurn;
  final bool canDiscard;
  final bool canVisit;
  final bool canDeclare;
  final VoidCallback? onDiscard;
  final VoidCallback? onVisit;
  final VoidCallback? onDeclare;
  final VoidCallback? onShowSets;
  final String visitLabel;
  final bool compact;
  final MarriageGamePhase phase;

  const SmartActionSidebar({
    super.key,
    required this.isMyTurn,
    this.canDiscard = false,
    this.canVisit = false,
    this.canDeclare = false,
    this.onDiscard,
    this.onVisit,
    this.onDeclare,
    this.onShowSets,
    this.visitLabel = 'DUB',
    this.compact = false,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonSize = compact ? 40 : 60;
    final double spacing = compact ? 6 : 12;

    // Determine which buttons to show based on phase
    final showVisit = phase == MarriageGamePhase.canVisit || 
                      (isMyTurn && canVisit);
    final showDeclare = phase == MarriageGamePhase.canDeclare || 
                        phase == MarriageGamePhase.postVisit;
    final showDiscard = phase == MarriageGamePhase.playPhase || 
                        phase == MarriageGamePhase.postVisit ||
                        (isMyTurn && canDiscard);
    const showSets = true; // Always show view sets

    return Container(
      width: compact ? 56 : 76,
      padding: EdgeInsets.symmetric(vertical: compact ? 8 : 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border(
          left: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
          top: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
          bottom: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // VISIT / DUB button (only when can visit)
          if (showVisit)
            _buildButton(
              label: visitLabel,
              onPressed: canVisit ? onVisit : null,
              backgroundColor: const Color(0xFF9B59B6),
              isActive: canVisit,
              size: buttonSize,
              isPrimary: phase == MarriageGamePhase.canVisit,
            ),
          if (showVisit) SizedBox(height: spacing),
          
          // SEQ / View Sets button
          if (showSets)
            _buildButton(
              label: 'SEQ',
              icon: Icons.view_list_rounded,
              onPressed: onShowSets,
              backgroundColor: const Color(0xFF3498DB),
              size: buttonSize,
            ),
          if (showSets) SizedBox(height: spacing),
          
          // SHOW / Declare button (only when can declare)
          if (showDeclare)
            _buildButton(
              label: 'SHOW',
              icon: Icons.emoji_events,
              onPressed: canDeclare ? onDeclare : null,
              backgroundColor: const Color(0xFF27AE60),
              isActive: canDeclare,
              size: buttonSize,
              isPrimary: phase == MarriageGamePhase.canDeclare,
            ),
          if (showDeclare) SizedBox(height: spacing),
          
          // CAN / Discard button (only when has card selected)
          if (showDiscard)
            _buildButton(
              label: 'CAN',
              icon: Icons.close,
              onPressed: canDiscard ? onDiscard : null,
              backgroundColor: const Color(0xFFE74C3C),
              isActive: canDiscard,
              size: buttonSize,
            ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    IconData? icon,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    bool isActive = false,
    required double size,
    bool isPrimary = false,
  }) {
    final isEnabled = onPressed != null;
    
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled ? backgroundColor : Colors.grey.shade800,
          border: Border.all(
            color: isPrimary ? Colors.amber : (isActive ? Colors.amber : Colors.white24),
            width: isPrimary ? 3 : (isActive ? 2 : 1.5),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ]
              : isActive
                  ? [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.4),
                        blurRadius: 8,
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
                  color: isEnabled ? Colors.white : Colors.white38,
                  size: size * 0.4,
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.white38,
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}

/// Phase Action Hint Banner
/// Shows contextual hints based on current game phase
class PhaseActionHint extends StatelessWidget {
  final MarriageGamePhase phase;
  
  const PhaseActionHint({super.key, required this.phase});
  
  @override
  Widget build(BuildContext context) {
    if (phase == MarriageGamePhase.waiting || phase == MarriageGamePhase.gameEnded) {
      return const SizedBox.shrink();
    }
    
    final hint = _getHintForPhase(phase);
    final color = _getColorForPhase(phase);
    final icon = _getIconForPhase(phase);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            hint,
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
  
  String _getHintForPhase(MarriageGamePhase phase) {
    switch (phase) {
      case MarriageGamePhase.drawPhase:
        return 'TAP DECK OR DISCARD TO DRAW';
      case MarriageGamePhase.playPhase:
        return 'SELECT CARDS TO FORM SETS';
      case MarriageGamePhase.formingSets:
        return 'TAP ACTION TO CREATE SET';
      case MarriageGamePhase.canVisit:
        return '✨ READY! TAP DUB TO SEE MAAL';
      case MarriageGamePhase.postVisit:
        return 'SELECT CARD & TAP CAN TO DISCARD';
      case MarriageGamePhase.canDeclare:
        return '🏆 ALL SETS READY! TAP SHOW TO WIN';
      default:
        return '';
    }
  }
  
  Color _getColorForPhase(MarriageGamePhase phase) {
    switch (phase) {
      case MarriageGamePhase.drawPhase:
        return Colors.blue;
      case MarriageGamePhase.playPhase:
        return Colors.teal;
      case MarriageGamePhase.formingSets:
        return Colors.orange;
      case MarriageGamePhase.canVisit:
        return Colors.purple;
      case MarriageGamePhase.postVisit:
        return Colors.green;
      case MarriageGamePhase.canDeclare:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getIconForPhase(MarriageGamePhase phase) {
    switch (phase) {
      case MarriageGamePhase.drawPhase:
        return Icons.touch_app;
      case MarriageGamePhase.playPhase:
        return Icons.select_all;
      case MarriageGamePhase.formingSets:
        return Icons.category;
      case MarriageGamePhase.canVisit:
        return Icons.visibility;
      case MarriageGamePhase.postVisit:
        return Icons.swap_horiz;
      case MarriageGamePhase.canDeclare:
        return Icons.emoji_events;
      default:
        return Icons.info;
    }
  }
}

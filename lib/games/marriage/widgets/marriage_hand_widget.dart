import 'package:flutter/material.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/core/card_engine/meld.dart';

import 'package:clubroyale/core/theme/app_theme.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart'; // For Maal badges
import 'package:clubroyale/games/marriage/marriage_config.dart';

class MarriageHandWidget extends StatefulWidget {
  final List<PlayingCard> cards;
  final String? selectedCardId;
  final Function(String?) onCardSelected;
  final PlayingCard? tiplu;
  final MarriageGameConfig config;

  const MarriageHandWidget({
    super.key,
    required this.cards,
    required this.selectedCardId,
    required this.onCardSelected,
    this.tiplu,
    this.config = MarriageGameConfig.nepaliStandard,
  });

  @override
  State<MarriageHandWidget> createState() => _MarriageHandWidgetState();
}

class _MarriageHandWidgetState extends State<MarriageHandWidget> {
  // Local state for groups
  // We sync this with widget.cards whenever widget.cards changes meaningfully (e.g. count)
  List<List<PlayingCard>> _groups = [];
  
  @override
  void initState() {
    super.initState();
    _syncGroups();
  }

  @override
  void didUpdateWidget(MarriageHandWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the card list changed (e.g. draw/discard), we need to update groups
    // Simple logic: If count changed, or if cards don't match flattened groups, re-sync.
    // Ideally we want to preserve user structure.
    if (!_areCardsEqual(widget.cards, _flattenGroups())) {
       _reconcileGroups(oldWidget.cards, widget.cards);
    }
  }

  bool _areCardsEqual(List<PlayingCard> list1, List<PlayingCard> list2) {
    if (list1.length != list2.length) return false;
    final ids1 = list1.map((c) => c.id).toSet();
    final ids2 = list2.map((c) => c.id).toSet();
    return ids1.containsAll(ids2);
  }

  List<PlayingCard> _flattenGroups() {
    return _groups.expand((g) => g).toList();
  }

  void _syncGroups() {
    // Initial load: Smart group
    if (widget.cards.isEmpty) {
      _groups = [];
    } else {
       _smartGroupCards();
    }
  }
  
  void _reconcileGroups(List<PlayingCard> oldHand, List<PlayingCard> newHand) {
    // 1. Detect added cards
    final oldIds = oldHand.map((c) => c.id).toSet();
    final newCards = newHand.where((c) => !oldIds.contains(c.id)).toList();
    
    // 2. Detect removed cards
    final newIds = newHand.map((c) => c.id).toSet();
    
    setState(() {
      // Remove deleted cards from groups
      for (var group in _groups) {
        group.removeWhere((c) => !newIds.contains(c.id));
      }
      _groups.removeWhere((g) => g.isEmpty);
      
      // Add new cards to a "New" group at the end, or append to last group
      if (newCards.isNotEmpty) {
        if (_groups.isEmpty) {
          _groups.add(newCards);
        } else {
             // Create a new group for drawn card to make it obvious
             _groups.add(newCards);
        }
      }
      
      // Safety: If totally out of sync (rare), hard reset
      if (!_areCardsEqual(newHand, _flattenGroups())) {
        // Fallback
        _syncGroups(); 
      }
    });
  }

  void _onReorder(int oldGroupIndex, int oldIndex, int newGroupIndex, int newIndex) {
    setState(() {
      final card = _groups[oldGroupIndex].removeAt(oldIndex);
      _groups[newGroupIndex].insert(newIndex, card);
      
      // Clean up empty groups (unless it's the only one?)
      // Actually keep empty groups as drop targets? No, drag targets handle creation.
      if (_groups[oldGroupIndex].isEmpty) {
        _groups.removeAt(oldGroupIndex);
        // Adjust index if needed
      }
    });
  }
  
  void _autoSort() {
    setState(() {
       _smartGroupCards();
    });
  }
  
  void _smartGroupCards() {
    List<PlayingCard> pool = List.from(widget.cards);
    List<List<PlayingCard>> newGroups = [];
    
    // 1. Detect all possible melds
    final melds = MeldDetector.findAllMelds(pool, tiplu: widget.tiplu);
    
    // 2. Greedy selection Strategy:
    // Prioritize Tunnels > Pure Runs > Sets > Marriages
    melds.sort((a, b) {
       // Custom priority score
       int scoreA = _getMeldPriority(a);
       int scoreB = _getMeldPriority(b);
       return scoreB.compareTo(scoreA); // Descending
    });
    
    // 3. Pick Melds
    for (final meld in melds) {
      // Check if all cards for this meld are still in pool
      bool canForm = meld.cards.every((c) => pool.any((p) => p.id == c.id));
      if (canForm) {
         // Form group
         // Use actual card instances from pool to ensure consistency
         final groupCards = meld.cards.map((c) => pool.firstWhere((p) => p.id == c.id)).toList();
         newGroups.add(groupCards);
         
         // Remove from pool
         for (var c in groupCards) pool.remove(c);
      }
    }
    
    // 4. Remaining cards (Deadwood)
    // Sort by Suit/Rank
    if (pool.isNotEmpty) {
       pool.sort((a, b) {
         int suitParams = a.suit.index.compareTo(b.suit.index);
         if (suitParams != 0) return suitParams;
         return a.rank.index.compareTo(b.rank.index);
       });
       newGroups.add(pool);
    }
    
    _groups = newGroups;
  }
  
  int _getMeldPriority(Meld meld) {
    switch (meld.type) {
      case MeldType.tunnel: return 100;
      case MeldType.marriage: return 90;
      case MeldType.run: return 80; // Pure sequence
      case MeldType.set: return 60;
      case MeldType.impureRun: return 50;
      case MeldType.impureSet: return 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls (Sort)
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _autoSort,
                icon: const Icon(Icons.auto_awesome, size: 16, color: AppTheme.gold),
                label: const Text('AUTO GROUP', style: TextStyle(color: AppTheme.gold, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.gold),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              const Text(
                'Drag cards to group them',
                style: TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        
        // Horizontal Scrollable Hand
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _groups.length; i++) ...[
                _buildGroup(i),
                const SizedBox(width: 12), // Space between groups
              ],
              
              // New Group Drop Target (Empty Area)
              DragTarget<PlayingCard>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  _moveCardToNewGroup(details.data);
                },
                builder: (context, candidates, rejects) {
                  return Container(
                    width: 50,
                    height: 145,
                    decoration: BoxDecoration(
                      color: candidates.isNotEmpty ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: candidates.isNotEmpty ? Border.all(color: Colors.white24, style: BorderStyle.solid) : null,
                    ),
                    child: Center(
                       child: candidates.isNotEmpty 
                           ? const Icon(Icons.add, color: Colors.white) 
                           : null, // Invisible target usually
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _moveCardToNewGroup(PlayingCard card) {
    setState(() {
      // Find and remove from old group
      for (var g in _groups) {
        if (g.remove(card)) break;
      }
      _groups.removeWhere((g) => g.isEmpty);
      
      // Add to new group
      _groups.add([card]);
    });
  }

  Widget _buildGroup(int groupIndex) {
    final group = _groups[groupIndex];
    
    // Validate Meld
    // We use MeldDetector
    // Note: Single card is never a valid meld, but we don't show "Invalid" for just 1 card to avoid noise
    Meld? meld;
    if (group.length >= 3) {
      // Try to find best meld
      // We assume user intends one meld per group
      // Check Pure melds first, then Impure
      final run = RunMeld(group);
      final set = SetMeld(group);
      final tunnel = TunnelMeld(group);
      
      if (run.isValid) {
        meld = run;
      } else if (set.isValid) {
        meld = set;
      } else if (tunnel.isValid) {
        meld = tunnel;
      } else if (widget.tiplu != null) {
        // Check for Impure melds (with wildcards)
        final impureRun = ImpureRunMeld(group, tiplu: widget.tiplu);
        final impureSet = ImpureSetMeld(group, tiplu: widget.tiplu);
        
        if (impureRun.isValid) {
          meld = impureRun;
        } else if (impureSet.isValid) {
          meld = impureSet;
        }
      }
    }
    
    // Determine Label
    String labelText = '';
    Color labelColor = Colors.transparent;
    
    if (group.length >= 3) {
      if (meld != null) {
        if (meld is RunMeld) {
           labelText = 'PURE RUN';
           labelColor = Colors.green;
        } else if (meld is SetMeld) {
           labelText = 'SET';
           labelColor = Colors.blue; 
        } else if (meld is TunnelMeld) {
            labelText = 'TUNNEL';
           labelColor = Colors.purple;
        } else if (meld is ImpureRunMeld) {
           labelText = 'IMPURE RUN';
           labelColor = Colors.orange;
        } else if (meld is ImpureSetMeld) {
           labelText = 'IMPURE SET';
           labelColor = Colors.teal;
        }
      } else {
        labelText = 'INVALID';
        labelColor = Colors.red.withValues(alpha: 0.8);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          height: 20,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: labelText.isNotEmpty ? labelColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            labelText,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        
        // Cards Stack (Fan)
        // Using a custom stack to render overlapping cards
        SizedBox(
          height: 145, // Card Height + Fan effect
          width: 40.0 + (group.length * 45.0), // Dynamic width for larger cards
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Drop Target for this group
              Positioned.fill(
                child: DragTarget<PlayingCard>(
                  onWillAcceptWithDetails: (details) => !group.contains(details.data),
                  onAcceptWithDetails: (details) {
                    final card = details.data;
                    setState(() {
                         // Remove from old
                         for (var g in _groups) { g.remove(card); }
                         _groups.removeWhere((g) => g.isEmpty);
                         // Add to this group
                         _groups[groupIndex].add(card);
                    });
                  },
                  builder: (context, candidates, rejects) {
                    return Container(
                      decoration: BoxDecoration(
                        color: candidates.isNotEmpty ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),
              
              // Render Cards
              for (int i = 0; i < group.length; i++)
                Positioned(
                  left: i * 45.0,
                  top: 0,
                  child: LongPressDraggable<PlayingCard>(
                    data: group[i],
                    delay: const Duration(milliseconds: 150),
                    hapticFeedbackOnStart: true,
                    feedback: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(8),
                      child: Transform.scale(
                        scale: 1.15,
                        child: CardWidget(card: group[i], isFaceUp: true),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3, 
                      child: CardWidget(card: group[i], isFaceUp: true)
                    ),
                    onDragStarted: () {
                      // Provide haptic feedback
                    },
                    child: GestureDetector(
                       onTap: () => widget.onCardSelected(group[i].id),
                       behavior: HitTestBehavior.opaque,
                       child: _buildCardWithBadges(group[i]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardWithBadges(PlayingCard card) {
    final isSelected = widget.selectedCardId == card.id;
        
    // Calculator for rendering badges (Copied logic from screen for consistency)
    final calculator = widget.tiplu != null 
        ? MarriageMaalCalculator(tiplu: widget.tiplu!, config: widget.config) 
        : null;
        
    Color? glowColor;
    Widget? badgeIcon;
    
    if (calculator != null) {
      final type = calculator.getMaalType(card);
      if (type != MaalType.none) {
         glowColor = Colors.amberAccent; // Simplified glo
         badgeIcon = const Icon(Icons.star, color: Colors.amber, size: 10);
      }
    }
    
    return CardWidget(
      card: card,
      isFaceUp: true,
      isSelected: isSelected,
      glowColor: glowColor,
      cornerBadge: badgeIcon,
    );
  }
}

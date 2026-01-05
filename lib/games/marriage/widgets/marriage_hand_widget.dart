import 'package:flutter/material.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';
import 'package:clubroyale/features/game/ui/components/card_preview_overlay.dart';
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';

import 'package:clubroyale/core/theme/app_theme.dart';
import 'package:clubroyale/core/services/haptic_service.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart'; // For Maal badges
import 'package:clubroyale/games/marriage/marriage_config.dart';

import 'package:clubroyale/features/game/ui/components/skeleton_game_card.dart';

class MarriageHandWidget extends StatefulWidget {
  final List<PlayingCard> cards;
  final String? selectedCardId;
  final Function(String?) onCardSelected;
  final VoidCallback? onCardDoubleTap;
  final bool isMyTurn;
  final PlayingCard? tiplu;
  final MarriageGameConfig config;
  final double scale;
  final bool isLoading;

  const MarriageHandWidget({
    super.key,
    required this.cards,
    required this.selectedCardId,
    required this.onCardSelected,
    this.onCardDoubleTap,
    this.isMyTurn = false,
    this.tiplu,
    this.config = MarriageGameConfig.nepaliStandard,
    this.scale = 1.0,
    this.isLoading = false,
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

  void _onReorder(
    int oldGroupIndex,
    int oldIndex,
    int newGroupIndex,
    int newIndex,
  ) {
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
        final groupCards = meld.cards
            .map((c) => pool.firstWhere((p) => p.id == c.id))
            .toList();
        newGroups.add(groupCards);

        // Remove from pool
        for (var c in groupCards) {
          pool.remove(c);
        }
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
      case MeldType.tunnel:
        return 100;
      case MeldType.marriage:
        return 90;
      case MeldType.run:
        return 80; // Pure sequence
      case MeldType.set:
        return 60;
      case MeldType.impureRun:
        return 50;
      case MeldType.impureSet:
        return 40;
      case MeldType.dublee:
        return 70; // Priority for Dublee
    }
  }

  @override
  Widget build(BuildContext context) {
     if (widget.isLoading) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            13, // Show 13 skeletons
            (index) => Padding(
              padding: const EdgeInsets.only(right: 8), // Tighter overlap or spacing?
              // For skeletons, spacing is better than overlap to show amount
              child: SkeletonGameCard(
                scale: widget.scale,
              ),
            ),
          ),
        ),
      );
    }
    
    // Debug: Track if cards are being received
    debugPrint('🃏 MarriageHandWidget: ${widget.cards.length} cards, ${_groups.length} groups');
    
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // Horizontal Scrollable Hand
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), // Top pad for sort button space
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
                  HapticService.meldFormed(); // Medium impact
                  SoundService.playCardPlace();
                },
                builder: (context, candidates, rejects) {
                  return Container(
                    width: 50,
                    height: 145,
                    decoration: BoxDecoration(
                      color: candidates.isNotEmpty
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: candidates.isNotEmpty
                          ? Border.all(
                              color: Colors.white24,
                              style: BorderStyle.solid,
                            )
                          : null,
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

        // Floating Sort Button (Minimalist)
        Positioned(
          top: 0,
          left: 16,
          child: GestureDetector(
            onTap: _autoSort,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.gold, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'GROUP',
                    style: TextStyle(color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
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
        } else if (meld is DubleeMeld) {
          labelText = 'DUBLEE';
          labelColor = Colors.indigo;
        }
      } else {
        labelText = 'INVALID';
        labelColor = Colors.redAccent.withValues(alpha: 0.9); // More visible Red
      }
    }

    // Visual Alert for Invalid Groups (Red Border)
    final isInvalid = labelText == 'INVALID';

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
            border: isInvalid ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: Text(
            labelText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Cards Stack (Fan)
        // Using a custom stack to render overlapping cards
        SizedBox(
          height: 145 * widget.scale, // Scaled height
          width: (40.0 + (group.length * 45.0)) * widget.scale, // Scaled width
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Drop Target for this group
              Positioned.fill(
                child: DragTarget<PlayingCard>(
                  onWillAcceptWithDetails: (details) =>
                      !group.contains(details.data),
                  onAcceptWithDetails: (details) {
                    final card = details.data;
                    setState(() {
                      // Remove from old
                      for (var g in _groups) {
                        g.remove(card);
                      }
                      _groups.removeWhere((g) => g.isEmpty);
                      // Add to this group
                      _groups[groupIndex].add(card);
                      
                      // Feedback
                      HapticService.meldFormed();
                      SoundService.playCardPlace();
                    });
                  },
                  builder: (context, candidates, rejects) {
                    return Container(
                      decoration: BoxDecoration(
                        color: candidates.isNotEmpty
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                ),
              ),

              // Render Cards with Arc/Fan Effect (using helper for calculation)
              ...List.generate(group.length, (i) => _buildArcCard(i, group.length, group[i])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArcCard(int index, int totalCount, PlayingCard card) {
    // Calculate Fan Transformation
    final centerIndex = (totalCount - 1) / 2.0;
    final relativePos = index - centerIndex;

    // Rotation: -0.06 to 0.06 radians per card step
    final double angle = relativePos * 0.06;

    // Y-Offset: Arch effect (edges lower than center)
    final double yArcOffset = (relativePos * relativePos) * 2.0;

    // X-Offset: slightly tighter overlap for fanned look
    final double xOffset = index * 42.0 * widget.scale;

    return Positioned(
      left: xOffset,
      top: yArcOffset + 10, // Base offset + arc
      child: Transform.rotate(
        angle: angle,
        child: LongPressDraggable<PlayingCard>(
          data: card,
          delay: const Duration(milliseconds: 150),
          hapticFeedbackOnStart: true,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Transform.scale(
              scale: 1.15 * widget.scale,
              child: CardWidget(card: card, isFaceUp: true),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: Transform.scale(
              scale: widget.scale,
              alignment: Alignment.topLeft,
              child: CardWidget(card: card, isFaceUp: true),
            ),
          ),
          onDragStarted: () {
            HapticService.cardTap();
          },
          child: GestureDetector(
            onTap: () {
              HapticService.cardTap();
              widget.onCardSelected(card.id);
            },
            onDoubleTap: widget.isMyTurn ? widget.onCardDoubleTap : null,
            behavior: HitTestBehavior.opaque,
            child: Transform.scale(
              scale: widget.scale,
              alignment: Alignment.topLeft,
              child: _buildCardWithBadges(card),
            ),
          ),
        ),
      ),
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
      switch (type) {
        case MaalType.tiplu:
          glowColor = AppTheme.gold;
          badgeIcon = const Icon(Icons.stars, color: AppTheme.gold, size: 14); // Major Maal
          break;
        case MaalType.poplu:
        case MaalType.jhiplu:
          glowColor = Colors.cyanAccent;
          badgeIcon = const Icon(Icons.star, color: Colors.cyanAccent, size: 12);
          break;
        case MaalType.alter:
          glowColor = Colors.amber;
          badgeIcon = const Icon(Icons.monetization_on, color: Colors.amber, size: 12);
          break;
        case MaalType.man:
          glowColor = Colors.purpleAccent;
          badgeIcon = const Icon(Icons.person, color: Colors.purpleAccent, size: 12);
          break;
        case MaalType.none:
          break;
      }
    }

    return CardWithPreview(
      card: card,
      child: CardWidget(
        card: card,
        isFaceUp: true,
        isSelected: isSelected,
        glowColor: glowColor,
        cornerBadge: badgeIcon,
      ),
    );
  }
}

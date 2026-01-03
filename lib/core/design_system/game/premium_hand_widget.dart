/// Premium Hand Widget - Expandable Card Hand Display
///
/// Features:
/// - Compact mode with overlapping cards
/// - Expanded grid view for 21+ cards
/// - Sort by suit/rank toggle
/// - Drag-to-rearrange support
/// - Maal card highlighting
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/games/marriage/marriage_maal_calculator.dart';
import 'package:clubroyale/core/design_system/game/premium_card_widget.dart';

/// Expandable hand widget with drag-to-rearrange
class PremiumHandWidget extends StatefulWidget {
  final List<PlayingCard> cards;
  final String? selectedCardId;
  final PlayingCard? tiplu;
  final Set<String> highlightedCardIds;
  final bool isMyTurn;
  final bool canSelect;
  final Function(PlayingCard)? onCardTap;
  final Function(int fromIndex, int toIndex)? onCardReorder;

  const PremiumHandWidget({
    super.key,
    required this.cards,
    this.selectedCardId,
    this.tiplu,
    this.highlightedCardIds = const {},
    this.isMyTurn = false,
    this.canSelect = true,
    this.onCardTap,
    this.onCardReorder,
  });

  @override
  State<PremiumHandWidget> createState() => _PremiumHandWidgetState();
}

class _PremiumHandWidgetState extends State<PremiumHandWidget> {
  bool _isExpanded = false;
  SortMode _sortMode = SortMode.suit;
  MarriageMaalCalculator? _maalCalculator;

  @override
  void didUpdateWidget(PremiumHandWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tiplu != widget.tiplu) {
      _updateMaalCalculator();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateMaalCalculator();
  }

  void _updateMaalCalculator() {
    if (widget.tiplu != null) {
      _maalCalculator = MarriageMaalCalculator(tiplu: widget.tiplu!);
    } else {
      _maalCalculator = null;
    }
  }

  List<PlayingCard> get _sortedCards {
    final cards = List<PlayingCard>.from(widget.cards);

    switch (_sortMode) {
      case SortMode.suit:
        cards.sort((a, b) {
          final suitCompare = a.suit.index.compareTo(b.suit.index);
          if (suitCompare != 0) return suitCompare;
          return a.rank.value.compareTo(b.rank.value);
        });
      case SortMode.rank:
        cards.sort((a, b) {
          final rankCompare = a.rank.value.compareTo(b.rank.value);
          if (rankCompare != 0) return rankCompare;
          return a.suit.index.compareTo(b.suit.index);
        });
      case SortMode.maal:
        if (_maalCalculator != null) {
          cards.sort((a, b) {
            final aMaal = _maalCalculator!.getMaalType(a);
            final bMaal = _maalCalculator!.getMaalType(b);
            final maalCompare = bMaal.index.compareTo(
              aMaal.index,
            ); // Maal first
            if (maalCompare != 0) return maalCompare;
            return a.suit.index.compareTo(b.suit.index);
          });
        }
    }

    return cards;
  }

  MaalType? _getMaalType(PlayingCard card) {
    if (_maalCalculator == null) return null;
    final type = _maalCalculator!.getMaalType(card);
    return type == MaalType.none ? null : type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Controls bar
          _buildControlsBar(),

          // Cards display
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? 220 : 120,
            child: _isExpanded ? _buildExpandedHand() : _buildCompactHand(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    final maalPoints = _maalCalculator?.calculateMaalPoints(widget.cards) ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Card count + Maal points
          Row(
            children: [
              _InfoBadge(
                icon: Icons.style,
                value: '${widget.cards.length}',
                color: const Color(0xFFD4AF37),
              ),
              if (maalPoints > 0) ...[
                const SizedBox(width: 8),
                _InfoBadge(
                  icon: Icons.diamond,
                  value: '$maalPoints',
                  color: const Color(0xFF7C3AED),
                ),
              ],
            ],
          ),

          // Sort options
          Row(
            children: [
              _SortButton(
                icon: Icons.category,
                label: 'Suit',
                isActive: _sortMode == SortMode.suit,
                onTap: () => setState(() => _sortMode = SortMode.suit),
              ),
              const SizedBox(width: 8),
              _SortButton(
                icon: Icons.format_list_numbered,
                label: 'Rank',
                isActive: _sortMode == SortMode.rank,
                onTap: () => setState(() => _sortMode = SortMode.rank),
              ),
              if (_maalCalculator != null) ...[
                const SizedBox(width: 8),
                _SortButton(
                  icon: Icons.star,
                  label: 'Maal',
                  isActive: _sortMode == SortMode.maal,
                  onTap: () => setState(() => _sortMode = SortMode.maal),
                ),
              ],
            ],
          ),

          // Expand/collapse button
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isExpanded = !_isExpanded);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHand() {
    final cards = _sortedCards;
    const cardWidth = 55.0;
    const cardHeight = 82.0;

    // Calculate overlap based on card count
    final overlap = cards.length > 15 ? 25.0 : 30.0;
    final totalWidth = cardWidth + (cards.length - 1) * overlap;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: totalWidth,
          height: cardHeight + 20, // Extra space for selection pop
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: List.generate(cards.length, (index) {
              final card = cards[index];
              final isSelected = card.id == widget.selectedCardId;
              final isHighlighted = widget.highlightedCardIds.contains(card.id);
              final maalType = _getMaalType(card);

              return Positioned(
                left: index * overlap,
                child: Draggable<String>(
                  data: card.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: PremiumCardWidget(
                      card: card,
                      width: cardWidth * 1.1,
                      height: cardHeight * 1.1,
                      isSelected: true,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: PremiumCardWidget(
                      card: card,
                      isSelected: isSelected,
                      isHighlighted: isHighlighted,
                      maalType: maalType,
                      isPlayable: widget.canSelect && widget.isMyTurn,
                      width: cardWidth,
                      height: cardHeight,
                    ),
                  ),
                  child: PremiumCardWidget(
                    card: card,
                    isSelected: isSelected,
                    isHighlighted: isHighlighted,
                    maalType: maalType,
                    isPlayable: widget.canSelect && widget.isMyTurn,
                    width: cardWidth,
                    height: cardHeight,
                    onTap: () => widget.onCardTap?.call(card),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedHand() {
    final cards = _sortedCards;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ReorderableGridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
        childAspectRatio: 0.65,
        onReorder: (oldIndex, newIndex) {
          HapticFeedback.mediumImpact();
          widget.onCardReorder?.call(oldIndex, newIndex);
        },
        children: List.generate(cards.length, (index) {
          final card = cards[index];
          final maalType = _getMaalType(card);

          return ReorderableGridDragStartListener(
            key: ValueKey(card.id),
            index: index,
            child: PremiumCardWidget(
              card: card,
              isSelected: card.id == widget.selectedCardId,
              isHighlighted: widget.highlightedCardIds.contains(card.id),
              maalType: maalType,
              isPlayable: widget.canSelect && widget.isMyTurn,
              width: 48,
              height: 72,
              onTap: () => widget.onCardTap?.call(card),
            ),
          );
        }),
      ),
    );
  }
}

enum SortMode { suit, rank, maal }

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SortButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF7c3aed).withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF7c3aed) : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reorderable Grid View for expanded hand
class ReorderableGridView extends StatelessWidget {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final List<Widget> children;
  final void Function(int, int) onReorder;

  const ReorderableGridView.count({
    super.key,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    required this.children,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Drag start listener for reorderable grid
class ReorderableGridDragStartListener extends StatelessWidget {
  final int index;
  final Widget child;

  const ReorderableGridDragStartListener({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.1, child: child),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }
}

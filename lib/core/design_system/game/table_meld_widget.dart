/// Table Meld Widget - Display declared melds on game table
///
/// Used to show:
/// 1. Opponent's open cards after they 'Visit'
/// 2. Player's own declared melds
/// 3. Winner's hand after 'Go Royale'
library;

import 'package:flutter/material.dart';
import 'package:clubroyale/core/card_engine/pile.dart' as engine;
import 'package:clubroyale/core/card_engine/meld.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
import 'package:clubroyale/core/design_system/game/premium_card_widget.dart';

/// Display a collection of melds on the table
class TableMeldsWidget extends StatelessWidget {
  final List<Meld> melds;
  final double scale;
  final bool showLabels;

  const TableMeldsWidget({
    super.key,
    required this.melds,
    this.scale = 0.6,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    if (melds.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: melds.map((meld) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLabels) ...[
                  _MeldLabel(type: meld.type),
                  const SizedBox(height: 4),
                ],
                _MeldCards(cards: meld.cards, scale: scale),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MeldCards extends StatelessWidget {
  final List<engine.Card> cards;
  final double scale;

  const _MeldCards({required this.cards, required this.scale});

  @override
  Widget build(BuildContext context) {
    const originalWidth = 60.0;
    const originalHeight = 90.0;
    final width = originalWidth * scale;
    final height = originalHeight * scale;
    final overlap = width * 0.4;

    return SizedBox(
      height: height,
      width: width + (cards.length - 1) * overlap,
      child: Stack(
        children: List.generate(cards.length, (index) {
          return Positioned(
            left: index * overlap,
            child: PremiumCardWidget(
              card: cards[index],
              width: width,
              height: height,
              isPlayable: false,
              // Maal badges handled internally by cards if needed,
              // but usually not shown on opponent melds unless relevant
            ),
          );
        }),
      ),
    );
  }
}

class _MeldLabel extends StatelessWidget {
  final MeldType type;

  const _MeldLabel({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _getMeldColor(type);
    final label = GameTerminology.getMeldTypeName(type.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getMeldColor(MeldType type) {
    switch (type) {
      case MeldType.set:
        return Colors.blue;
      case MeldType.run:
        return Colors.green;
      case MeldType.tunnel:
        return Colors.orange;
      case MeldType.marriage:
        return Colors.pink;
      case MeldType.impureRun:
        return Colors.orange.shade300;
      case MeldType.impureSet:
        return Colors.teal;
      case MeldType.dublee:
        return Colors.indigo;
    }
  }
}

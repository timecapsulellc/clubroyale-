import 'package:flutter/material.dart';
import 'package:clubroyale/core/models/playing_card.dart';
import 'package:clubroyale/features/game/ui/components/card_widget.dart';

class PlayedSetsWidget extends StatelessWidget {
  final List<List<PlayingCard>> sets;
  final double scale;

  const PlayedSetsWidget({
    super.key,
    required this.sets,
    this.scale = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: '${sets.length} declared card sets',
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title or just sets? Just sets usually.
        // Wrap sets if too many?
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: sets.map((set) => _buildSet(set)).toList(),
        ),
      ],
      ),
    );
  }

  Widget _buildSet(List<PlayingCard> set) {
    // Overlapping row of cards
    return SizedBox(
      width: (20.0 + (set.length * 20.0)) * scale,
      height: 60 * scale,
      child: Stack(
        children: List.generate(set.length, (i) {
          return Positioned(
            left: i * 18.0 * scale,
            top: 0,
            child: CardWidget(
              card: set[i],
              isFaceUp: true,
              width: 35 * scale,
              height: 50 * scale,
            ),
          );
        }),
      ),
    );
  }
}

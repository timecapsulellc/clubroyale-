import 'package:flutter/material.dart';

/// Dialog for players to place their bid (1-13 tricks)
class BiddingDialog extends StatefulWidget {
  final String playerName;
  final int minBid;
  final int maxBid;
  final ValueChanged<int> onBidPlaced;

  const BiddingDialog({
    super.key,
    required this.playerName,
    this.minBid = 1,
    this.maxBid = 13,
    required this.onBidPlaced,
  });

  @override
  State<BiddingDialog> createState() => _BiddingDialogState();
}

class _BiddingDialogState extends State<BiddingDialog> {
  late int _selectedBid;

  @override
  void initState() {
    super.initState();
    _selectedBid = widget.minBid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: const Icon(Icons.gavel, size: 48),
      title: Text('${widget.playerName}\'s Bid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How many tricks will you win?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Bid selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decrease button
                IconButton(
                  onPressed: _selectedBid > widget.minBid
                      ? () => setState(() => _selectedBid--)
                      : null,
                  icon: const Icon(Icons.remove_circle),
                  iconSize: 36,
                ),

                // Current bid
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_selectedBid',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                // Increase button
                IconButton(
                  onPressed: _selectedBid < widget.maxBid
                      ? () => setState(() => _selectedBid++)
                      : null,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 36,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick bid buttons
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4, 5].map((bid) {
              return ChoiceChip(
                label: Text('$bid'),
                selected: _selectedBid == bid,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedBid = bid);
                },
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            widget.onBidPlaced(_selectedBid);
            Navigator.pop(context);
          },
          child: Text('Bid $_selectedBid trick${_selectedBid > 1 ? 's' : ''}'),
        ),
      ],
    );
  }
}

/// Show bidding dialog
Future<int?> showBiddingDialog({
  required BuildContext context,
  required String playerName,
}) async {
  int? result;
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BiddingDialog(
      playerName: playerName,
      onBidPlaced: (bid) => result = bid,
    ),
  );
  return result;
}

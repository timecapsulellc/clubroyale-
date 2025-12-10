import 'package:flutter/material.dart';
import 'package:clubroyale/features/game/models/game_state.dart';
import 'package:clubroyale/features/game/services/card_validation_service.dart';
import 'package:clubroyale/features/game/engine/models/card.dart';

/// Widget for bidding phase
class BidInputWidget extends StatefulWidget {
  final List<PlayingCard> playerHand;
  final Map<String, Bid> existingBids;
  final List<String> playerNames; // In turn order
  final String currentTurnPlayerId;
  final String currentUserId;
  final Function(int) onBidSubmit;

  const BidInputWidget({
    super.key,
    required this.playerHand,
    required this.existingBids,
    required this.playerNames,
    required this.currentTurnPlayerId,
    required this.currentUserId,
    required this.onBidSubmit,
  });

  @override
  State<BidInputWidget> createState() => _BidInputWidgetState();
}

class _BidInputWidgetState extends State<BidInputWidget> {
  late int _selectedBid;

  @override
  void initState() {
    super.initState();
    // Suggest a bid based on hand strength
    _selectedBid = CardValidationService.suggestBid(widget.playerHand);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMyTurn = widget.currentTurnPlayerId == widget.currentUserId;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.gavel,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bidding Phase',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Existing bids
            if (widget.existingBids.isNotEmpty) ...[
              Text(
                'Bids so far:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.existingBids.entries.map((entry) {
                  final playerName = _getPlayerName(entry.key);
                  return Chip(
                    label: Text('$playerName: ${entry.value.amount}'),
                    avatar: const Icon(Icons.person, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Turn indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMyTurn
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isMyTurn ? Icons.person : Icons.hourglass_empty,
                    color: isMyTurn
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isMyTurn
                          ? 'Your turn to bid'
                          : 'Waiting for ${_getPlayerName(widget.currentTurnPlayerId)} to bid...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isMyTurn ? FontWeight.bold : null,
                        color: isMyTurn
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isMyTurn) ...[
              const SizedBox(height: 24),
              // Bid selector
              Text(
                'Select your bid (1-13):',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _selectedBid > 1
                        ? () => setState(() => _selectedBid--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: Slider(
                      value: _selectedBid.toDouble(),
                      min: 1,
                      max: 13,
                      divisions: 12,
                      label: _selectedBid.toString(),
                      onChanged: (value) {
                        setState(() => _selectedBid = value.round());
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedBid < 13
                        ? () => setState(() => _selectedBid++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              Center(
                child: Text(
                  _selectedBid.toString(),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Confirm button
              FilledButton.icon(
                onPressed: () => widget.onBidSubmit(_selectedBid),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirm Bid'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPlayerName(String playerId) {
    final index = widget.playerNames.indexOf(playerId);
    if (index == -1) return 'Player';
    return 'Player ${index + 1}';
  }
}

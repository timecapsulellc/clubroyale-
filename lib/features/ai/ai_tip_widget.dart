import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taasclub/features/ai/ai_service.dart';

/// Widget that displays AI game tip suggestions
class AiTipWidget extends ConsumerStatefulWidget {
  final List<String> hand;
  final List<String> trickCards;
  final int tricksNeeded;
  final int tricksWon;
  final int bid;
  final String? ledSuit;
  final VoidCallback? onCardSuggested;

  const AiTipWidget({
    super.key,
    required this.hand,
    required this.trickCards,
    required this.tricksNeeded,
    required this.tricksWon,
    required this.bid,
    this.ledSuit,
    this.onCardSuggested,
  });

  @override
  ConsumerState<AiTipWidget> createState() => _AiTipWidgetState();
}

class _AiTipWidgetState extends ConsumerState<AiTipWidget> {
  GameTipResult? _tip;
  bool _isLoading = false;
  String? _error;
  bool _isVisible = false;

  Future<void> _requestTip() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.getGameTip(
        hand: widget.hand,
        trickCards: widget.trickCards,
        tricksNeeded: widget.tricksNeeded,
        tricksWon: widget.tricksWon,
        bid: widget.bid,
        ledSuit: widget.ledSuit,
      );

      setState(() {
        _tip = result;
        _isVisible = true;
      });

      widget.onCardSuggested?.call();
    } catch (e) {
      setState(() {
        _error = 'Unable to get AI tip';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getConfidenceColor(String confidence) {
    switch (confidence) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ask AI button
        if (!_isVisible && !_isLoading)
          FilledButton.tonal(
            onPressed: _requestTip,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 18),
                SizedBox(width: 8),
                Text('Ask AI for Tip'),
              ],
            ),
          ),

        // Loading state
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Thinking...'),
              ],
            ),
          ),

        // Error state
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),

        // AI Tip card
        if (_isVisible && _tip != null)
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Suggestion',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Confidence badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(_tip!.confidence)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _tip!.confidence.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getConfidenceColor(_tip!.confidence),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _isVisible = false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Suggested card
                  Row(
                    children: [
                      const Text('Play: '),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _tip!.suggestedCard,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      if (_tip!.alternativeCard != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(or ${_tip!.alternativeCard})',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Reasoning
                  Text(
                    _tip!.reasoning,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget for AI bid suggestion during bidding phase
class AiBidSuggestionWidget extends ConsumerStatefulWidget {
  final List<String> hand;
  final int position;
  final List<int>? previousBids;
  final ValueChanged<int>? onBidSelected;

  const AiBidSuggestionWidget({
    super.key,
    required this.hand,
    required this.position,
    this.previousBids,
    this.onBidSelected,
  });

  @override
  ConsumerState<AiBidSuggestionWidget> createState() =>
      _AiBidSuggestionWidgetState();
}

class _AiBidSuggestionWidgetState extends ConsumerState<AiBidSuggestionWidget> {
  BidSuggestionResult? _suggestion;
  bool _isLoading = false;
  bool _isVisible = false;

  Future<void> _requestSuggestion() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.getBidSuggestion(
        hand: widget.hand,
        position: widget.position,
        previousBids: widget.previousBids,
      );

      setState(() {
        _suggestion = result;
        _isVisible = true;
      });
    } catch (e) {
      // Silently fail - AI is optional
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'very_strong':
        return Colors.purple;
      case 'strong':
        return Colors.green;
      case 'average':
        return Colors.orange;
      case 'weak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isVisible && !_isLoading)
          TextButton.icon(
            onPressed: _requestSuggestion,
            icon: const Icon(Icons.lightbulb_outline, size: 16),
            label: const Text('Get AI bid suggestion'),
          ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),

        if (_isVisible && _suggestion != null)
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Suggests: ',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        '${_suggestion!.suggestedBid}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStrengthColor(_suggestion!.handStrength)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _suggestion!.handStrength.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStrengthColor(_suggestion!.handStrength),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _suggestion!.reasoning,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: () =>
                          widget.onBidSelected?.call(_suggestion!.suggestedBid),
                      child: Text('Use bid ${_suggestion!.suggestedBid}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

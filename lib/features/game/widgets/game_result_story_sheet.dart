import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/stories/services/story_service.dart';
import 'package:clubroyale/core/services/share_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

/// Widget shown after game completion to share result as a story
class GameResultStorySheet extends ConsumerStatefulWidget {
  final String gameType;
  final String winnerId;
  final String winnerName;
  final Map<String, int> scores;
  final bool isCurrentUserWinner;

  const GameResultStorySheet({
    super.key,
    required this.gameType,
    required this.winnerId,
    required this.winnerName,
    required this.scores,
    required this.isCurrentUserWinner,
  });

  /// Show as bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String gameType,
    required String winnerId,
    required String winnerName,
    required Map<String, int> scores,
    required bool isCurrentUserWinner,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GameResultStorySheet(
        gameType: gameType,
        winnerId: winnerId,
        winnerName: winnerName,
        scores: scores,
        isCurrentUserWinner: isCurrentUserWinner,
      ),
    );
  }

  @override
  ConsumerState<GameResultStorySheet> createState() => _GameResultStorySheetState();
}

class _GameResultStorySheetState extends ConsumerState<GameResultStorySheet> {
  bool _isPosting = false;
  String? _caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (widget.isCurrentUserWinner) ...[
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'VICTORY!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ] else ...[
                  const Text(
                    '🎮',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'GAME COMPLETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _getGameDisplayName(widget.gameType),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Scores
          _buildScoreCard(),
          const SizedBox(height: 16),
          // Caption input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
              onChanged: (value) => _caption = value,
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Share to Story
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPosting ? null : _postToStory,
                    icon: _isPosting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_stories),
                    label: const Text('Post to Story'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Share to chat/social
                IconButton(
                  onPressed: _shareViaSystem,
                  icon: const Icon(Icons.share, color: Colors.white70),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Skip button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    // Sort scores
    final sortedScores = widget.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sortedScores.length; i++)
            _buildScoreRow(
              rank: i + 1,
              name: sortedScores[i].key,
              score: sortedScores[i].value,
              isWinner: sortedScores[i].key == widget.winnerName,
            ),
        ],
      ),
    );
  }

  Widget _buildScoreRow({
    required int rank,
    required String name,
    required int score,
    required bool isWinner,
  }) {
    final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '   ';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(medal, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isWinner ? Colors.amber : Colors.white,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            '$score pts',
            style: TextStyle(
              color: isWinner ? Colors.amber : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postToStory() async {
    setState(() => _isPosting = true);

    try {
      final storyService = ref.read(storyServiceProvider);
      await storyService.createGameResultStory(
        gameType: widget.gameType,
        winnerId: widget.winnerId,
        winnerName: widget.winnerName,
        scores: widget.scores,
        caption: _caption,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Posted to your story!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _shareViaSystem() {
    final buffer = StringBuffer();
    
    if (widget.isCurrentUserWinner) {
      buffer.writeln('🏆 I WON! 🏆');
    }
    buffer.writeln('🎴 ${_getGameDisplayName(widget.gameType)} Results');
    buffer.writeln('${'─' * 20}');
    
    // Sort and display scores
    final sortedScores = widget.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (var i = 0; i < sortedScores.length; i++) {
      final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '  ';
      buffer.writeln('$medal ${sortedScores[i].key}: ${sortedScores[i].value} pts');
    }
    
    buffer.writeln('${'─' * 20}');
    if (_caption != null && _caption!.isNotEmpty) {
      buffer.writeln('💬 $_caption');
      buffer.writeln();
    }
    buffer.writeln('📱 Play with me on ClubRoyale!');
    buffer.writeln('🔗 clubroyale.app');

    ShareService.shareText(
      text: buffer.toString(),
      context: context,
    );
  }

  String _getGameDisplayName(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'marriage':
        return 'Marriage';
      case 'call_break':
      case 'callbreak':
        return 'Call Break';
      case 'teen_patti':
      case 'teenpatti':
        return 'Teen Patti';
      case 'rummy':
        return 'Rummy';
      case 'poker':
        return 'Poker';
      case 'in_between':
      case 'inbetween':
        return 'In Between';
      default:
        return gameType;
    }
  }
}

/// Quick action button to trigger story share
class ShareToStoryButton extends StatelessWidget {
  final VoidCallback onTap;
  
  const ShareToStoryButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.pink],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Share to Story',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

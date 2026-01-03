/// Replay Player Screen
///
/// Plays back recorded game replays with controls
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/replay/replay_model.dart';
import 'package:clubroyale/features/replay/replay_service.dart';

class ReplayPlayerScreen extends ConsumerStatefulWidget {
  final String replayId;

  const ReplayPlayerScreen({super.key, required this.replayId});

  @override
  ConsumerState<ReplayPlayerScreen> createState() => _ReplayPlayerScreenState();
}

class _ReplayPlayerScreenState extends ConsumerState<ReplayPlayerScreen> {
  GameReplay? _replay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReplay();
  }

  Future<void> _loadReplay() async {
    final replay = await ref
        .read(replayServiceProvider)
        .loadReplay(widget.replayId);
    if (mounted) {
      setState(() {
        _replay = replay;
        _isLoading = false;
      });

      if (replay != null) {
        ref.read(replayPlaybackProvider.notifier).loadReplay(replay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_replay == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Replay not found')),
      );
    }

    final playbackState = ref.watch(replayPlaybackProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_replay!.title ?? 'Replay'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Main replay view
          Expanded(
            child: _ReplayView(replay: _replay!, playbackState: playbackState),
          ),
          // Playback controls
          _PlaybackControls(replay: _replay!, playbackState: playbackState),
        ],
      ),
    );
  }
}

class _ReplayView extends StatelessWidget {
  final GameReplay replay;
  final ReplayPlaybackState playbackState;

  const _ReplayView({required this.replay, required this.playbackState});

  @override
  Widget build(BuildContext context) {
    // Get events up to current time
    final visibleEvents = replay.events
        .where((e) => e.timestamp <= playbackState.currentTime)
        .toList();

    return Stack(
      children: [
        // Game state visualization
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Players
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: replay.playerNames.asMap().entries.map((entry) {
                  final isWinner =
                      replay.winnerId == replay.playerIds[entry.key];
                  return _PlayerDisplay(
                    name: entry.value,
                    score: replay.finalScores?[entry.value] ?? 0,
                    isWinner: isWinner,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Event log
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: visibleEvents.length,
                    itemBuilder: (context, index) {
                      final event =
                          visibleEvents[visibleEvents.length - 1 - index];
                      return _EventTile(event: event);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Playback overlay
        if (!playbackState.isPlaying)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.pause_circle_filled,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _PlayerDisplay extends StatelessWidget {
  final String name;
  final int score;
  final bool isWinner;

  const _PlayerDisplay({
    required this.name,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(radius: 28, child: Text(name[0].toUpperCase())),
            if (isWinner)
              const Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('$score pts'),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final ReplayEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getEventVisual();

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        event.description ?? _getDefaultDescription(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        _formatTime(event.timestamp),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  (IconData, Color) _getEventVisual() {
    switch (event.type) {
      case ReplayEventType.gameStart:
        return (Icons.play_arrow, Colors.green);
      case ReplayEventType.cardPlayed:
        return (Icons.style, Colors.blue);
      case ReplayEventType.cardDrawn:
        return (Icons.add_card, Colors.orange);
      case ReplayEventType.meldDeclared:
        return (Icons.check_circle, Colors.purple);
      case ReplayEventType.turnChange:
        return (Icons.swap_horiz, Colors.grey);
      case ReplayEventType.scoreUpdate:
        return (Icons.score, Colors.amber);
      case ReplayEventType.roundEnd:
        return (Icons.flag, Colors.red);
      case ReplayEventType.gameEnd:
        return (Icons.emoji_events, Colors.amber);
      case ReplayEventType.chat:
        return (Icons.chat, Colors.teal);
    }
  }

  String _getDefaultDescription() {
    switch (event.type) {
      case ReplayEventType.gameStart:
        return 'Game started';
      case ReplayEventType.cardPlayed:
        return '${event.playerName} played a card';
      case ReplayEventType.cardDrawn:
        return '${event.playerName} drew a card';
      case ReplayEventType.meldDeclared:
        return '${event.playerName} declared a meld';
      case ReplayEventType.turnChange:
        return "It's ${event.playerName}'s turn";
      case ReplayEventType.scoreUpdate:
        return 'Scores updated';
      case ReplayEventType.roundEnd:
        return 'Round ended';
      case ReplayEventType.gameEnd:
        return 'Game ended';
      case ReplayEventType.chat:
        return '${event.playerName}: Message';
    }
  }

  String _formatTime(int ms) {
    final seconds = (ms / 1000).round();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _PlaybackControls extends ConsumerWidget {
  final GameReplay replay;
  final ReplayPlaybackState playbackState;

  const _PlaybackControls({required this.replay, required this.playbackState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(replayPlaybackProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Row(
              children: [
                Text(
                  _formatTime(playbackState.currentTime),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Expanded(
                  child: Slider(
                    value: playbackState.currentTime.toDouble(),
                    max: playbackState.totalDuration.toDouble(),
                    onChanged: (v) => controller.seekTo(v.round()),
                  ),
                ),
                Text(
                  _formatTime(playbackState.totalDuration),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Speed selector
                DropdownButton<double>(
                  value: playbackState.playbackSpeed,
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                    DropdownMenuItem(value: 1.0, child: Text('1x')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                    DropdownMenuItem(value: 2.0, child: Text('2x')),
                  ],
                  onChanged: (v) {
                    if (v != null) controller.setSpeed(v);
                  },
                ),
                const SizedBox(width: 16),
                // Skip back
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () => controller.skipBackward(10),
                ),
                // Play/Pause
                IconButton.filled(
                  iconSize: 48,
                  icon: Icon(
                    playbackState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: () => controller.togglePlayPause(),
                ),
                // Skip forward
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () => controller.skipForward(10),
                ),
                const SizedBox(width: 16),
                // Restart
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: () => controller.restart(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int ms) {
    final seconds = (ms / 1000).round();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

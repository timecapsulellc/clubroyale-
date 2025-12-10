import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/features/stories/models/story.dart';
import 'package:clubroyale/features/stories/services/story_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Full-screen story viewer with progress bar and navigation
class StoryViewerScreen extends ConsumerStatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  final bool isOwn;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.isOwn = false,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _progressController;
  Timer? _autoAdvanceTimer;
  bool _isPaused = false;

  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    );
    _startProgress();
    _markAsViewed();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(_storyDuration, _goToNext);
  }

  void _markAsViewed() {
    if (!widget.isOwn) {
      final story = widget.stories[_currentIndex];
      ref.read(storyServiceProvider).markAsViewed(story.id);
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startProgress();
      _markAsViewed();
    } else {
      context.pop();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _startProgress();
      _markAsViewed();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (_isPaused) {
      _progressController.stop();
      _autoAdvanceTimer?.cancel();
    } else {
      _progressController.forward();
      final remaining = _storyDuration * (1 - _progressController.value);
      _autoAdvanceTimer = Timer(remaining, _goToNext);
    }
  }

  Story get _currentStory => widget.stories[_currentIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final tapX = details.globalPosition.dx;
          if (tapX < size.width / 3) {
            _goToPrevious();
          } else if (tapX > size.width * 2 / 3) {
            _goToNext();
          } else {
            _togglePause();
          }
        },
        onLongPressStart: (_) => _togglePause(),
        onLongPressEnd: (_) => _togglePause(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story media
            _currentStory.mediaType == StoryMediaType.video
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : Image.network(
                    _currentStory.mediaUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white54,
                      ),
                    ),
                  ),

            // Gradient overlay at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Progress bars
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Row(
                children: List.generate(widget.stories.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: index < _currentIndex
                            ? Container(color: Colors.white)
                            : index == _currentIndex
                                ? AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, child) {
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _progressController.value,
                                        child: Container(color: Colors.white),
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // User info header
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: _currentStory.userPhotoUrl != null
                        ? NetworkImage(_currentStory.userPhotoUrl!)
                        : null,
                    child: _currentStory.userPhotoUrl == null
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStory.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatTime(_currentStory.createdAt),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  if (widget.isOwn)
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showStoryOptions(context),
                    ),
                ],
              ),
            ),

            // Caption/text overlay
            if (_currentStory.caption != null ||
                _currentStory.textOverlay != null)
              Positioned(
                bottom: 100,
                left: 16,
                right: 16,
                child: Text(
                  _currentStory.textOverlay ?? _currentStory.caption ?? '',
                  style: TextStyle(
                    color: _currentStory.textColor != null
                        ? Color(
                            int.parse(_currentStory.textColor!, radix: 16) +
                                0xFF000000)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 300.ms),
              ),

            // View count for own stories
            if (widget.isOwn)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showViewers(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_currentStory.viewCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Reply button for others' stories
            if (!widget.isOwn)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Reply to ${_currentStory.userName}...',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Send reaction
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Open reply DM
                      },
                    ),
                  ],
                ),
              ),

            // Pause indicator
            if (_isPaused)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 48,
                  ),
                ).animate().scale(duration: 200.ms),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showStoryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Story'),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(storyServiceProvider)
                    .deleteStory(_currentStory.id);
                if (mounted) context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View Stats'),
              onTap: () {
                Navigator.pop(context);
                _showViewers(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showViewers(BuildContext context) async {
    final viewers = await ref
        .read(storyServiceProvider)
        .getStoryViewers(_currentStory.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined),
                  const SizedBox(width: 8),
                  Text(
                    '${viewers.length} views',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: viewers.isEmpty
                  ? const Center(
                      child: Text('No one has viewed this story yet'),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: viewers.length,
                      itemBuilder: (context, index) {
                        final viewer = viewers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: viewer.photoUrl != null
                                ? NetworkImage(viewer.photoUrl!)
                                : null,
                            child: viewer.photoUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(viewer.name),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

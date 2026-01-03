// Picture-in-Picture Video Overlay Widget
//
// Floating draggable video window that displays active video call
// participants while user navigates other screens or plays games.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:clubroyale/features/video/services/pip_service.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Floating PiP video overlay widget
///
/// Wrap your main app content with this widget to enable PiP functionality.
/// The floating window will appear when a video call is minimized.
class PipVideoOverlay extends ConsumerWidget {
  final Widget child;

  const PipVideoOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipState = ref.watch(pipServiceProvider);
    final isPipShowing = pipState.isPipShowing;

    return Stack(
      children: [
        // Main app content
        child,

        // Floating PiP window
        if (isPipShowing)
          _FloatingPipWindow(
            pipState: pipState,
            onPositionChanged: (pos) {
              ref.read(pipServiceProvider.notifier).updatePosition(pos);
            },
            onDragEnd: () {
              final screenSize = MediaQuery.of(context).size;
              ref.read(pipServiceProvider.notifier).snapToCorner(screenSize);
            },
            onMaximize: () {
              ref.read(pipServiceProvider.notifier).maximize();
            },
            onClose: () {
              ref.read(pipServiceProvider.notifier).disablePip();
            },
          ),
      ],
    );
  }
}

/// The actual floating window widget
class _FloatingPipWindow extends StatefulWidget {
  final PipState pipState;
  final ValueChanged<Offset> onPositionChanged;
  final VoidCallback onDragEnd;
  final VoidCallback onMaximize;
  final VoidCallback onClose;

  const _FloatingPipWindow({
    required this.pipState,
    required this.onPositionChanged,
    required this.onDragEnd,
    required this.onMaximize,
    required this.onClose,
  });

  @override
  State<_FloatingPipWindow> createState() => _FloatingPipWindowState();
}

class _FloatingPipWindowState extends State<_FloatingPipWindow> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.pipState.position;
  }

  @override
  void didUpdateWidget(covariant _FloatingPipWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pipState.position != widget.pipState.position) {
      _position = widget.pipState.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.pipState.size;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onDoubleTap: widget.onMaximize,
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              _position.dx + details.delta.dx,
              _position.dy + details.delta.dy,
            );
          });
          widget.onPositionChanged(_position);
        },
        onPanEnd: (_) => widget.onDragEnd(),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CasinoColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: CasinoColors.gold.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video content
                _buildVideoContent(),

                // Controls overlay
                Positioned(
                  top: 4,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Maximize button
                      _buildControlButton(
                        icon: Icons.fullscreen,
                        onTap: widget.onMaximize,
                        tooltip: 'Maximize',
                      ),
                      const SizedBox(width: 4),
                      // Close button
                      _buildControlButton(
                        icon: Icons.close,
                        onTap: widget.onClose,
                        tooltip: 'Close',
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                // Participant count badge
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.pipState.participants.length + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Drag hint
                Center(
                  child: Icon(
                    Icons.drag_indicator,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }

  Widget _buildVideoContent() {
    final participants = widget.pipState.participants;
    final room = widget.pipState.activeRoom;

    if (room == null || participants.isEmpty) {
      // No video - show placeholder
      return Container(
        color: CasinoColors.darkPurple,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam, color: Colors.white54, size: 32),
              SizedBox(height: 4),
              Text(
                'No video',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    // Show first participant's video
    final firstParticipant = participants.first;
    final videoPublication = firstParticipant.videoTrackPublications
        .where((pub) => pub.track != null && pub.subscribed)
        .firstOrNull;
    final videoTrack = videoPublication?.track as VideoTrack?;

    if (videoTrack != null) {
      return VideoTrackRenderer(
        videoTrack,
        fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    }

    // No video track - show avatar
    return Container(
      color: CasinoColors.deepPurple,
      child: Center(
        child: CircleAvatar(
          radius: 30,
          backgroundColor: CasinoColors.gold,
          child: Text(
            firstParticipant.name.isNotEmpty
                ? firstParticipant.name[0].toUpperCase()
                : 'U',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.8)
                : Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

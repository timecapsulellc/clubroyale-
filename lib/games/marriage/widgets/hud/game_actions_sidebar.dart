import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/games/marriage/widgets/hud/primary_set_progress.dart';

class GameActionsSidebar extends ConsumerWidget {
  final String? roomId;
  final String? userId;
  final VoidCallback? onShowSequence;
  final VoidCallback? onShowDublee;
  final VoidCallback? onFinishGame;
  final VoidCallback? onCancelAction;
  final VoidCallback? onGetTunela;
  final VoidCallback? onQuitGame;
  final VoidCallback? onSettings;
  final VoidCallback? onHelp;
  final VoidCallback? onToggleChat;
  final VoidCallback? onToggleVideo;
  final int? pureSetCount;

  const GameActionsSidebar({
    super.key,
    this.roomId,
    this.userId,
    this.onShowSequence,
    this.onShowDublee,
    this.onFinishGame,
    this.onCancelAction,
    this.onGetTunela,
    this.onQuitGame,
    this.onSettings,
    this.onHelp,
    this.onToggleChat,
    this.onToggleVideo,
    this.pureSetCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200, // Fixed width matching reference
      decoration: BoxDecoration(
        color: const Color(
          0xFF2F4F4F,
        ).withValues(alpha: 0.9), // Dark Slate Gray / Greenish
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header - Maal Card Placeholder
          Container(
            height: 140, // Adjust based on card size
            decoration: BoxDecoration(
              color: const Color(0xFF1a2f2f),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Maal Card',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Placeholder for Maal Card Image
                Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(Icons.style, color: Colors.green, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Action Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF3a5f5f),
            alignment: Alignment.center,
            child: const Text(
              'Game Actions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Primary Sets Progress
          if (pureSetCount != null)
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: PrimarySetProgress(count: pureSetCount!),
             ),
          
          // Media Controls (Compact Row)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFF2a4444),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MediaIconButton(icon: Icons.chat, onTap: onToggleChat, tooltip: 'Chat'),
                _MediaIconButton(icon: Icons.videocam, onTap: onToggleVideo, tooltip: 'Video'),
                // Audio: Use AudioFloatingButton if roomId/userId available
                if (roomId != null && userId != null)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: AudioFloatingButton(roomId: roomId!, userId: userId!),
                  )
                else
                  _MediaIconButton(icon: Icons.volume_up, onTap: null, tooltip: 'Audio'),
                _MediaIconButton(icon: Icons.help_outline, onTap: onHelp, tooltip: 'Help'),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _SidebarButton(label: 'SHOW SEQUENCE', onTap: onShowSequence),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: 'SHOW DUBLEE', onTap: onShowDublee),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: 'FINISH GAME', onTap: onFinishGame),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: 'CANCEL ACTION', onTap: onCancelAction),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(
                    label: 'GET TUNELA IN HAND',
                    onTap: onGetTunela,
                  ),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: 'SETTINGS', onTap: onSettings),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: 'QUIT GAME', onTap: onQuitGame),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SidebarButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _MediaIconButton({
    required this.icon,
    this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 22),
      onPressed: onTap,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black26,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

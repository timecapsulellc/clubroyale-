import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/core/widgets/scale_button.dart';

class UnifiedGameSidebar extends ConsumerWidget {
  final String? roomId;
  final String? userId;
  final Widget? headerContent;
  final List<Widget> gameActions;
  final VoidCallback? onSettings;
  final VoidCallback? onHelp;
  final VoidCallback? onToggleChat;
  final VoidCallback? onToggleVideo;
  final VoidCallback? onQuitGame;

  const UnifiedGameSidebar({
    super.key,
    this.roomId,
    this.userId,
    this.headerContent,
    this.gameActions = const [],
    this.onSettings,
    this.onHelp,
    this.onToggleChat,
    this.onToggleVideo,
    this.onQuitGame,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF2F4F4F).withValues(alpha: 0.95), // Solid professional look
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(2, 0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Optional - e.g. Maal, Stats)
          if (headerContent != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: headerContent,
            ),

          // Menu Title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Text(
              'GAME MENU',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Media Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MediaIconButton(icon: Icons.chat_bubble_outline, onTap: onToggleChat, tooltip: 'Chat'),
                _MediaIconButton(icon: Icons.videocam_outlined, onTap: onToggleVideo, tooltip: 'Video'),
                // Audio: Use AudioFloatingButton if roomId/userId available
                if (roomId != null && userId != null)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: AudioFloatingButton(roomId: roomId!, userId: userId!),
                  )
                else
                  _MediaIconButton(icon: Icons.volume_up_outlined, onTap: null, tooltip: 'Audio'),
                _MediaIconButton(icon: Icons.help_outline, onTap: onHelp, tooltip: 'Help'),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // Game Specific Actions
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ...gameActions,
                  if (gameActions.isNotEmpty)
                    const Divider(height: 24, color: Colors.white10),
                  
                  // App Actions
                  _SidebarListTile(
                    icon: Icons.settings_outlined,
                    label: 'SETTINGS',
                    onTap: onSettings,
                  ),
                  _SidebarListTile(
                    icon: Icons.exit_to_app,
                    label: 'QUIT GAME', 
                    onTap: onQuitGame,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isDestructive;

  const SidebarActionButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SidebarListTile(
      label: label,
      onTap: onTap,
      icon: icon,
      isDestructive: isDestructive,
    );
  }
}

class _SidebarListTile extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isDestructive;

  const _SidebarListTile({
    required this.label,
    this.onTap,
    this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: Colors.transparent, // Required for hit test if container is empty otherwise
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isDestructive ? Colors.redAccent : Colors.white70,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
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
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

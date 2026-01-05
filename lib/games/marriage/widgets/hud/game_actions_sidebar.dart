import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/features/rtc/widgets/audio_controls.dart';
import 'package:clubroyale/games/marriage/widgets/hud/primary_set_progress.dart';
import 'package:clubroyale/core/localization/marriage_strings.dart';

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
  final int? dubleeCount; // Number of dublees in hand

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
    this.dubleeCount,
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


          // Action Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF3a5f5f),
            alignment: Alignment.center,
            child: Text(
              LocalizedStrings.gameActions,
              style: const TextStyle(
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
                _MediaIconButton(icon: Icons.chat, onTap: onToggleChat, tooltip: LocalizedStrings.chat),
                _MediaIconButton(icon: Icons.videocam, onTap: onToggleVideo, tooltip: LocalizedStrings.video),
                // Audio: Use AudioFloatingButton if roomId/userId available
                if (roomId != null && userId != null)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: AudioFloatingButton(roomId: roomId!, userId: userId!),
                  )
                else
                  _MediaIconButton(icon: Icons.volume_up, onTap: null, tooltip: LocalizedStrings.audio),
                _MediaIconButton(icon: Icons.help_outline, onTap: onHelp, tooltip: LocalizedStrings.help),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _SidebarButton(label: LocalizedStrings.showSequence, onTap: onShowSequence),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(
                    label: dubleeCount != null && dubleeCount! >= 7 
                        ? LocalizedStrings.show7Dublees 
                        : LocalizedStrings.showDublee,
                    onTap: onShowDublee,
                    isRecommended: dubleeCount != null && dubleeCount! >= 7,
                  ),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(
                    label: LocalizedStrings.finishGame, 
                    onTap: onFinishGame,
                    isRecommended: onFinishGame != null, // Pulse if available
                  ),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: LocalizedStrings.cancelAction, onTap: onCancelAction),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(
                    label: LocalizedStrings.getTunela,
                    onTap: onGetTunela,
                  ),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: LocalizedStrings.settings, onTap: onSettings),
                  const Divider(height: 1, color: Colors.white24),
                  _SidebarButton(label: LocalizedStrings.quitGame, onTap: onQuitGame),
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
  final bool isRecommended;

  const _SidebarButton({
    required this.label, 
    this.onTap,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      alignment: Alignment.centerLeft,
      color: isRecommended 
          ? CasinoColors.gold.withValues(alpha: 0.15) 
          : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isEnabled 
                    ? (isRecommended ? CasinoColors.gold : Colors.white) 
                    : Colors.white38,
                fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          if (isRecommended && isEnabled)
            Icon(Icons.arrow_left, color: CasinoColors.gold, size: 20)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveX(begin: 0, end: -4, duration: 600.ms),
        ],
      )
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
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

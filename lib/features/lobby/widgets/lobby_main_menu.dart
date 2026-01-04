import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LobbyMainMenu extends ConsumerWidget {
  final VoidCallback onSinglePlayer;
  final VoidCallback onLocalMultiplayer;
  final VoidCallback onOnlinePublic;
  final VoidCallback onOnlinePrivate;

  const LobbyMainMenu({
    super.key,
    required this.onSinglePlayer,
    required this.onLocalMultiplayer,
    required this.onOnlinePublic,
    required this.onOnlinePrivate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280, // Fixed width for the menu panel
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: CasinoColors.tableGreenDark.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(
            color: CasinoColors.gold.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game Logo/Brand
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Logo Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CasinoColors.tableGreenMid,
                    border: Border.all(color: CasinoColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: CasinoColors.gold.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    size: 40,
                    color: CasinoColors.gold,
                  ),
                ),
                const SizedBox(height: 12),
                // Brand Text
                Text(
                  'Marriage',
                  style: GoogleFonts.oswald(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: CasinoColors.gold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Nepali Card Game',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _MainMenuButton(
            icon: Icons.person,
            label: "Single Player",
            onTap: onSinglePlayer,
          ),
          const SizedBox(height: 16),

          _MainMenuButton(
            icon: Icons.wifi, // Symbolizes local/nearby
            label: "Local MultiPlayer",
            onTap: onLocalMultiplayer,
          ),
          const SizedBox(height: 16),

          _MainMenuButton(
            icon: Icons.public,
            label: "Online Public Room",
            onTap: onOnlinePublic,
          ),
          const SizedBox(height: 16),

          _MainMenuButton(
            icon: Icons.vpn_key, // Symbolizes private/code
            label: "Online Private Room",
            onTap: onOnlinePrivate,
          ),

          const Spacer(),

          // Version Text (like reference)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'version: 1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: CasinoColors.gold.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MainMenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_MainMenuButton> createState() => _MainMenuButtonState();
}

class _MainMenuButtonState extends State<_MainMenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            // Green Pill Gradient
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _isHovered
                  ? [CasinoColors.tableGreenLight, CasinoColors.tableGreenMid]
                  : [
                      const Color(0xFF0F3D29), // Darker Green
                      const Color(0xFF0A2F1F), // Even Darker
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? CasinoColors.gold
                  : CasinoColors.gold.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.zillaSlab(
                    // Using serif-like font for "Classic" feel if available, else Roboto
                    fontSize: 20,
                    fontWeight: FontWeight.bold, // Italic in reference?
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: Colors.black45,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

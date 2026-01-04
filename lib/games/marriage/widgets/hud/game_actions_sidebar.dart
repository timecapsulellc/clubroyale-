import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

class GameActionsSidebar extends StatelessWidget {
  final VoidCallback? onShowSequence;
  final VoidCallback? onShowDublee;
  final VoidCallback? onFinishGame;
  final VoidCallback? onCancelAction;
  final VoidCallback? onGetTunela;
  final VoidCallback? onQuitGame;

  const GameActionsSidebar({
    super.key,
    this.onShowSequence,
    this.onShowDublee,
    this.onFinishGame,
    this.onCancelAction,
    this.onGetTunela,
    this.onQuitGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Fixed width matching reference
      decoration: BoxDecoration(
        color: const Color(0xFF2F4F4F).withValues(alpha: 0.9), // Dark Slate Gray / Greenish
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
                   child: const Center(child: Icon(Icons.style, color: Colors.green, size: 20)),
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
               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                   _SidebarButton(label: 'GET TUNELA IN HAND', onTap: onGetTunela),
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

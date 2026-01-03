import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart'; // Correct import for CasinoColors

class GameTopBar extends StatelessWidget {
  final String roomName;
  final String roomId;
  final String points;
  final String balance;
  final VoidCallback onExit;
  final VoidCallback onSettings;

  const GameTopBar({
    super.key,
    required this.roomName,
    required this.roomId,
    required this.points,
    required this.balance,
    required this.onExit,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exit Button
            _buildCircleButton(Icons.exit_to_app, onExit),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Connection / Room Info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CasinoColors.gold.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi,
                            color: Colors.greenAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '#$roomId',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 12,
                            width: 1,
                            color: Colors.white24,
                          ),
                          Flexible(
                            flex: 2,
                            child: Text(
                              roomName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: 12,
                            width: 1,
                            color: Colors.white24,
                          ),
                          // Balance/Points
                          Icon(
                            Icons.monetization_on,
                            color: CasinoColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            balance,
                            style: TextStyle(
                              color: CasinoColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Extra info if needed (Round number etc)
                  ],
                ),
              ),
            ),

            // Help & Settings
            _buildCircleButton(Icons.info_outline, () {}), // Help placeholder
            const SizedBox(width: 8),
            _buildCircleButton(Icons.settings, onSettings),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}

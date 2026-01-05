import 'package:flutter/material.dart';

class GameLogOverlay extends StatelessWidget {
  final List<String> logs;

  const GameLogOverlay({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Show only last 4 logs
    final visibleLogs = logs.length > 4 ? logs.sublist(logs.length - 4) : logs;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.white54, size: 14),
                SizedBox(width: 6),
                Text(
                  'GAME LOG',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Log entries
          ...visibleLogs.map((log) {
            // Parse: "Player: action"
            final parts = log.split(':');
            final name = parts.isNotEmpty ? parts[0] : '';
            final action = parts.length > 1 ? parts.sublist(1).join(':') : '';
            
            // Color-code by player type
            final isBot = name.toLowerCase().contains('bot');
            final isYou = name.toLowerCase() == 'you' || name.toLowerCase() == 'guest';
            final nameColor = isYou 
                ? const Color(0xFFFFD700) // Gold for player
                : (isBot ? Colors.white70 : const Color(0xFF87CEEB)); // White for bots, sky blue for others

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 11),
                  children: [
                    TextSpan(
                      text: name,
                      style: TextStyle(
                        color: nameColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: action.isEmpty ? '' : ':$action',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

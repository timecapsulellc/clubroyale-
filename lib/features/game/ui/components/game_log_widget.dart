import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

class GameLogEntry {
  final String message;
  final DateTime timestamp;
  final Color? color;
  final IconData? icon;

  GameLogEntry({
    required this.message,
    DateTime? timestamp,
    this.color,
    this.icon,
  }) : timestamp = timestamp ?? DateTime.now();
}

class GameLogWidget extends StatelessWidget {
  final List<GameLogEntry> logs;
  final double height;
  final double width;

  const GameLogWidget({
    super.key,
    required this.logs,
    this.height = 100,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Game Log',
            style: TextStyle(
              color: CasinoColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              reverse: true, // Show newest at bottom
              itemCount: logs.length,
              itemBuilder: (context, index) {
                // Since we want newest at bottom visualy, but list is reversed to keep scroll at bottom...
                // Wait, if reverse: true, index 0 is at bottom.
                // So logs[0] should be oldest or newest?
                // Usually logs are appended.
                // Let's assume logs[0] is oldest.
                // We want to show logs.reversed.toList()[index]
                final entry = logs.reversed.toList()[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      if (entry.icon != null) ...[
                        Icon(entry.icon, size: 10, color: entry.color ?? Colors.white70),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          entry.message,
                          style: TextStyle(
                            color: entry.color ?? Colors.white70,
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

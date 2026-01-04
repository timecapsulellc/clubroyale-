import 'package:flutter/material.dart';

class GameLogOverlay extends StatelessWidget {
  final List<String> logs;

  const GameLogOverlay({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Show only last 4 logs
    final visibleLogs = logs.length > 4 ? logs.sublist(logs.length - 4) : logs;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: visibleLogs.map((log) {
          // Parse rudimentary markdown styling from reference image logic?
          // Reference: "Bot 1: picked card from deck" (Yellow/White)

          final parts = log.split(':');
          final name = parts.isNotEmpty ? parts[0] : '';
          final action = parts.length > 1 ? parts.sublist(1).join(':') : '';

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                    ), // Gold name
                  ),
                  TextSpan(
                    text: action.isEmpty ? '' : ':$action',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

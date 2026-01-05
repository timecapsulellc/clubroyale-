import 'package:flutter/material.dart';
import 'package:clubroyale/config/casino_theme.dart';

class MarriageScoreTable extends StatelessWidget {
  final Map<String, int> scores;
  final Map<String, dynamic> scoreDetails; // Details for badges etc
  final String? declarerId;
  final String currentUserId;
  final String? winnerId;

  const MarriageScoreTable({
    super.key,
    required this.scores,
    required this.scoreDetails,
    this.declarerId,
    required this.currentUserId,
    this.winnerId,
  });

  @override
  Widget build(BuildContext context) {
    // Sort scores: Winner/Declarer first, then by score descending
    final sortedEntries = scores.entries.toList()
      ..sort((a, b) {
        if (a.key == declarerId) return -1;
        if (b.key == declarerId) return 1;
        return b.value.compareTo(a.value);
      });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CasinoColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              color: CasinoColors.feltGreenDark,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Expanded(flex: 3, child: _HeaderCell('PLAYER')),
                  Expanded(flex: 1, child: _HeaderCell('MAAL')),
                  Expanded(flex: 1, child: _HeaderCell('GAME')),
                  Expanded(flex: 1, child: _HeaderCell('TOTAL')),
                ],
              ),
            ),
            
            // Divider
            const Divider(height: 1, color: CasinoColors.gold),

            // Rows
            ...sortedEntries.map((entry) {
              final playerId = entry.key;
              final score = entry.value;
              final details = scoreDetails[playerId] as Map<String, dynamic>? ?? {};
              final isMe = playerId == currentUserId;
              final isDeclarer = playerId == declarerId;
              
              final maalPoints = details['maalPoints'] as int? ?? 0;
              final gamePoints = details['gamePoints'] as int? ?? 0; // Use details if available

              return Container(
                decoration: BoxDecoration(
                   color: isMe 
                       ? CasinoColors.gold.withValues(alpha: 0.1)
                       : isDeclarer 
                           ? Colors.green.withValues(alpha: 0.1) 
                           : Colors.transparent,
                   border: Border(
                     bottom: BorderSide(
                       color: Colors.white.withValues(alpha: 0.1), 
                       width: 0.5,
                     ),
                   ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Row(
                  children: [
                    // Player Name & Badges
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Icon(
                            isDeclarer ? Icons.emoji_events : (isMe ? Icons.person : Icons.person_outline),
                            color: isDeclarer ? CasinoColors.gold : Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? 'You' : 'Player ${playerId.substring(0, 4)}',
                                  style: TextStyle(
                                    color: isDeclarer ? CasinoColors.gold : Colors.white,
                                    fontWeight: (isMe || isDeclarer) ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Badges
                                if (isDeclarer || (details['hasPureSequence'] == true))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        if (isDeclarer) 
                                           _Badge(text: 'WINNER', color: Colors.green),
                                        if (details['hasPureSequence'] == true && !isDeclarer) 
                                           const _Badge(text: 'PURE', color: Colors.blue),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Maal Points
                    Expanded(
                      flex: 1, 
                      child: Center(
                        child: Text(
                          '$maalPoints',
                          style: const TextStyle(color: Colors.purpleAccent, fontSize: 13),
                        ),
                      ),
                    ),
                    
                    // Game Points (approx derived from total - maal usually, or just show text)
                    Expanded(
                      flex: 1, 
                      child: Center(
                        child: Text(
                         // If details map missing gamePoints, we might deduce or just show '-'
                         // Assuming structure is simple for now
                         (score - maalPoints).toString(), 
                         style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ),
                    
                    // Total Score
                    Expanded(
                      flex: 1, 
                      child: Center(
                         child: Text(
                          score > 0 ? '+$score' : '$score',
                          style: TextStyle(
                            color: score > 0 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: CasinoColors.gold,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(text, style: TextStyle(fontSize: 7, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

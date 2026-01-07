import 'package:flutter/material.dart';

/// PhD Audit Finding #5: Terminology Glossary
/// In-game reference for Nepali Marriage terms

class MarriageGlossary {
  static const Map<String, GlossaryEntry> terms = {
    'tiplu': GlossaryEntry(
      nepali: 'तिप्लु',
      english: 'Tiplu',
      definition: 'The main wild card (joker) selected from deck middle',
      points: 3,
      example: 'If 8♠ is Tiplu, it acts as a joker in any meld',
    ),
    'poplu': GlossaryEntry(
      nepali: 'पोप्लु',
      english: 'Poplu',
      definition: 'Card one rank ABOVE Tiplu in same suit',
      points: 2,
      example: 'If 8♠ is Tiplu, then 9♠ is Poplu',
    ),
    'jhiplu': GlossaryEntry(
      nepali: 'झिप्लु',
      english: 'Jhiplu',
      definition: 'Card one rank BELOW Tiplu in same suit',
      points: 2,
      example: 'If 8♠ is Tiplu, then 7♠ is Jhiplu',
    ),
    'alter': GlossaryEntry(
      nepali: 'अल्टर',
      english: 'Alter',
      definition: 'Same rank as Tiplu, same color, different suit',
      points: 5,
      example: 'If 8♠ is Tiplu (black), then 8♣ is Alter',
    ),
    'maal': GlossaryEntry(
      nepali: 'माल',
      english: 'Maal',
      definition: 'All point-scoring cards (Tiplu, Poplu, Jhiplu, Alter, etc.)',
      points: null,
      example: 'Collect Maal to score more points!',
    ),
    'tunnella': GlossaryEntry(
      nepali: 'टनेल',
      english: 'Tunnella',
      definition: 'Three identical cards (same rank AND suit)',
      points: 5,
      example: '7♥, 7♥, 7♥ = Pure Tunnella',
    ),
    'dublee': GlossaryEntry(
      nepali: 'डब्ली',
      english: 'Dublee',
      definition: 'A pair of identical cards (same rank and suit)',
      points: null,
      example: '5♦, 5♦ = Dublee',
    ),
    'marriage': GlossaryEntry(
      nepali: 'म्यारिज',
      english: 'Marriage',
      definition: 'Combo of Tiplu + Poplu + Jhiplu in same suit',
      points: 15,
      example: 'If 8♠ Tiplu: 7♠ + 8♠ + 9♠ = Marriage (15 pts played)',
    ),
    'visit': GlossaryEntry(
      nepali: 'घुम्ने',
      english: 'Visit',
      definition: 'Show 3 pure sequences to unlock your Maal points',
      points: null,
      example: 'You must VISIT before someone finishes, or lose all points!',
    ),
    'kidnap': GlossaryEntry(
      nepali: 'किडनाप',
      english: 'Kidnap',
      definition: 'Penalty when you fail to visit before game ends',
      points: -10,
      example: 'If game ends and you haven\'t visited = -10 penalty',
    ),
    'murder': GlossaryEntry(
      nepali: 'मर्डर',
      english: 'Murder',
      definition: 'Severe penalty: lose ALL points if no pure sequence',
      points: null,
      example: 'Regional variant: Must have at least 1 pure sequence',
    ),
    'man': GlossaryEntry(
      nepali: 'म्यान',
      english: 'Man (Joker)',
      definition: 'The printed joker cards in the deck',
      points: 2,
      example: 'Jokers are wild but worth 2 points as Maal',
    ),
  };
  
  /// Show glossary bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a0a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '📚 Marriage Glossary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Terms list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: terms.length,
                itemBuilder: (context, index) {
                  final key = terms.keys.elementAt(index);
                  final entry = terms[key]!;
                  return _GlossaryCard(entry: entry);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlossaryEntry {
  final String nepali;
  final String english;
  final String definition;
  final int? points;
  final String example;
  
  const GlossaryEntry({
    required this.nepali,
    required this.english,
    required this.definition,
    this.points,
    required this.example,
  });
}

class _GlossaryCard extends StatelessWidget {
  final GlossaryEntry entry;
  
  const _GlossaryCard({required this.entry});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                entry.english,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${entry.nepali})',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              if (entry.points != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: entry.points! > 0 ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entry.points! > 0 ? '+' : ''}${entry.points} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.definition,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '💡 ${entry.example}',
            style: TextStyle(color: Colors.blue.shade200, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

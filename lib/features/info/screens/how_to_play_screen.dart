import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';

/// How to Play Marriage Screen - Complete Game Guide
class HowToPlayMarriageScreen extends ConsumerWidget {
  const HowToPlayMarriageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'How to Play Marriage',
          style: TextStyle(
            color: themeColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Game Header
            _buildGameHeader(themeColors),
            const SizedBox(height: 24),

            // Overview
            _buildSection(
              title: '📋 Overview',
              content:
                  'Marriage (Royal Meld in ClubRoyale) is a popular rummy-style card game '
                  'from Nepal and South Asia. The goal is to form valid melds (sets and sequences) '
                  'and reduce your points to zero.',
              themeColors: themeColors,
            ),

            // Players & Deck
            _buildSection(
              title: '👥 Players & Deck',
              content:
                  '• 2-8 players\n'
                  '• Uses multiple decks based on player count:\n'
                  '  - 2-5 players: 3 decks (156 cards)\n'
                  '  - 6 players: 4 decks (208 cards)\n'
                  '  - 7-8 players: 5 decks (260 cards)\n'
                  '• Each player gets 21 cards',
              themeColors: themeColors,
            ),

            // Wild Cards
            _buildSection(
              title: '🃏 Wild Cards (Tiplu System)',
              content:
                  'Wild cards are determined by the card shown beneath the closed deck:\n\n'
                  '• **Tiplu (Wild)**: The shown card\'s value\n'
                  '• **Poplu (High Wild)**: One rank above Tiplu\n'
                  '• **Jhiplu (Low Wild)**: One rank below Tiplu\n\n'
                  '🌟 Example: If 7♠ is shown:\n'
                  '• All 7s become Tiplu\n'
                  '• All 8s become Poplu\n'
                  '• All 6s become Jhiplu\n\n'
                  'Wild cards can substitute any card in melds.',
              themeColors: themeColors,
            ),

            // Types of Melds
            _buildSection(
              title: '🎯 Types of Melds',
              content:
                  '**1. Pure Sequence (Tunnela)**\n'
                  '3+ consecutive cards of same suit, NO wildcards\n'
                  'Example: 4♥ 5♥ 6♥ 7♥\n\n'
                  '**2. Sequence (Dirty)**\n'
                  '3+ consecutive cards, wildcards allowed\n'
                  'Example: 4♥ 5♥ [Tiplu] 7♥\n\n'
                  '**3. Set (Triplets/Quartets)**\n'
                  '3-4 cards of same rank, different suits\n'
                  'Example: 9♠ 9♥ 9♦\n\n'
                  '**4. Marriage (Royal Sequence)**\n'
                  'K-Q of Tiplu suit + Tiplu card\n'
                  'Worth 10 bonus points!\n'
                  'Example: K♠ Q♠ 7♠ (if 7 is Tiplu)',
              themeColors: themeColors,
            ),

            // Gameplay
            _buildSection(
              title: '▶️ Gameplay',
              content:
                  '1. **Draw Phase**: Pick from closed deck OR open deck\n\n'
                  '2. **Optional Meld**: Lay down valid melds\n\n'
                  '3. **Discard Phase**: Discard one card to open deck\n\n'
                  'Play continues clockwise until someone declares.',
              themeColors: themeColors,
            ),

            // Declaring
            _buildSection(
              title: '🏆 Winning (Declaring)',
              content:
                  'To declare, you need:\n\n'
                  '✅ At least 1 Pure Sequence (Tunnela)\n'
                  '✅ All remaining cards in valid melds\n'
                  '✅ 0 points in hand\n\n'
                  'Tap "Go Royale" (Declare) when ready!',
              themeColors: themeColors,
            ),

            // Scoring
            _buildSection(
              title: '📊 Scoring',
              content:
                  '**Card Values:**\n'
                  '• Ace, K, Q, J, 10 = 10 points each\n'
                  '• 2-9 = Face value\n'
                  '• Joker = 0 points\n'
                  '• Wild cards when unused = 0 points\n\n'
                  '**Maximum Points:** 80 per hand\n\n'
                  '**Settlement:**\n'
                  'Winner gets sum of all other players\' points.',
              themeColors: themeColors,
            ),

            // Tips
            _buildSection(
              title: '💡 Pro Tips',
              content:
                  '1. **Prioritize Pure Sequences** - You need at least one!\n\n'
                  '2. **Remember Wilds** - Track Tiplu, Poplu, Jhiplu\n\n'
                  '3. **Watch Discards** - Note what opponents pick\n\n'
                  '4. **Marriage Bonus** - Aim for the K-Q-Tiplu combo\n\n'
                  '5. **Reduce Points** - Even if you can\'t win, minimize score',
              themeColors: themeColors,
            ),

            // Terminology
            _buildTerminologyTable(themeColors),

            const SizedBox(height: 40),

            // Play Now Button
            _buildPlayButton(context, themeColors),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHeader(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColors.surface,
            themeColors.surfaceLight.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColors.gold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: themeColors.gold.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: themeColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.style, size: 40, color: themeColors.gold),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Royal Meld',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Marriage / मैरेज',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge('2-8 Players', themeColors),
                    const SizedBox(width: 8),
                    _buildBadge('Rummy Style', themeColors),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: themeColors.gold, fontSize: 11),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required ThemeColors themeColors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(color: themeColors.textPrimary, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminologyTable(ThemeColors themeColors) {
    final terms = [
      ['Term', 'Global', 'Traditional'],
      ['Game Name', 'Royal Meld', 'Marriage'],
      ['Wild Card', 'Wild', 'Tiplu'],
      ['High Wild', 'High Wild', 'Poplu'],
      ['Low Wild', 'Low Wild', 'Jhiplu'],
      ['Pure Sequence', 'Tunnela', 'Tunnela'],
      ['Declare', 'Go Royale', 'Declare'],
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 Terminology',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: terms.asMap().entries.map((entry) {
              final isHeader = entry.key == 0;
              return TableRow(
                decoration: BoxDecoration(
                  color: isHeader
                      ? themeColors.gold.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
                children: entry.value
                    .map(
                      (cell) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          cell,
                          style: TextStyle(
                            color: isHeader
                                ? themeColors.gold
                                : themeColors.textPrimary,
                            fontWeight: isHeader
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, ThemeColors themeColors) {
    return ElevatedButton(
      onPressed: () => context.go('/marriage'),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeColors.gold,
        foregroundColor: themeColors.background,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow),
          SizedBox(width: 8),
          Text(
            'Play Royal Meld Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Screen displaying rules and FAQ for the Marriage card game
class MarriageRulesScreen extends ConsumerWidget {
  const MarriageRulesScreen({super.key});

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
        title: Text('How to Play', style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quick Reference Card (highlighted)
            _buildQuickReferenceCard(themeColors),
            const SizedBox(height: 24),
            
            // Detailed Sections
            _buildSectionHeader('Game Basics', themeColors),
            _buildExpandableTile(
              title: 'Overview & Objective',
              content: _buildOverviewContent(themeColors),
              themeColors: themeColors,
            ),
            _buildExpandableTile(
              title: 'Card Values & Terminology',
              content: _buildTerminologyContent(themeColors),
              themeColors: themeColors,
            ),
            
            _buildSectionHeader('Gameplay', themeColors),
            _buildExpandableTile(
              title: 'Turn Structure',
              content: _buildTurnStructureContent(themeColors),
              themeColors: themeColors,
            ),
            _buildExpandableTile(
              title: 'Visiting (Gatekeeper) System',
              content: _buildVisitingContent(themeColors),
              themeColors: themeColors,
              initiallyExpanded: true,
            ),
            
            _buildSectionHeader('Scoring & Maal', themeColors),
            _buildExpandableTile(
              title: 'Maal Cards & Values',
              content: _buildMaalContent(themeColors),
              themeColors: themeColors,
            ),
            _buildExpandableTile(
              title: 'Winning & Points',
              content: _buildScoringContent(themeColors),
              themeColors: themeColors,
            ),
            
            _buildSectionHeader('Advanced', themeColors),
            _buildExpandableTile(
              title: 'Kidnap, Murder & Variations',
              content: _buildAdvancedContent(themeColors),
              themeColors: themeColors,
            ),
            
             const SizedBox(height: 40),
            _buildSectionHeader('FAQ', themeColors),
            _buildFAQSection(themeColors),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeColors themeColors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: themeColors.gold,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildQuickReferenceCard(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColors.gold.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Quick Reference',
                style: TextStyle(
                  color: themeColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildQuickRow('Cards', '21 per player (3 decks)'),
          _buildQuickRow('Tiplu', 'Center card = Wild 👑'),
          _buildQuickRow('Objective', 'Melds: Sequences, Sets, pairs'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VISITING REQUIREMENTS (Choose 1)', 
                  style: TextStyle(color: themeColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildCheckItem('3 Pure Sequences (No Wilds)'),
                _buildCheckItem('7 Dublees (Pairs)'),
                _buildCheckItem('3 Tunnels (Triple identical)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildExpandableTile({
    required String title,
    required Widget content,
    required ThemeColors themeColors,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(
            title,
            style: TextStyle(
              color: themeColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: themeColors.gold,
          collapsedIconColor: Colors.white60,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  // --- Content Builders ---

  Widget _buildOverviewContent(ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marriage is a 3-deck rummy game where players draw and discard to form melds. The goal is to arrange all 21 cards into valid sets and sequences.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 12),
        _buildBullet('Players: 2-6'),
        _buildBullet('Cards: 21 per player'),
        _buildBullet('Decks: 3 standard decks with Jokers'),
      ],
    );
  }

  Widget _buildTerminologyContent(ThemeColors themeColors) {
    return Column(
      children: [
        _buildTermRow('Tiplu (Teen)', 'Wild Card (Center)'),
        _buildTermRow('Jhiplu (Low)', 'Wild -1 Rank'),
        _buildTermRow('Poplu (High)', 'Wild +1 Rank'),
        _buildTermRow('Alter', 'Same Rank+Color, Diff Suit'),
        _buildTermRow('Maal', 'Value Cards (Bonus Points)'),
        _buildTermRow('Dublee', 'Pair (Two identical cards)'),
      ],
    );
  }

  Widget _buildTurnStructureContent(ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Each turn consists of:', style: TextStyle(color: themeColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildStep(1, 'DRAW', 'Take a card from Deck or Discard pile.'),
        _buildStep(2, 'ACTION', 'You may attempt to "Visit" if you have the requirements.'),
        _buildStep(3, 'DISCARD', 'Place one card on the discard pile to end turn.'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: const Text(
            '⚠️ IMPORTANT: You cannot pick from the discard pile until you have Visited (Nepali Variant Rule).',
            style: TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitingContent(ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '"Visiting" is the most important phase. It unlocks your Maal points and allows you to pick discarded cards.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text('REQUIREMENTS', style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        const Text('You must show ONE of the following:', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        _buildBullet('3 Pure Sequences (e.g. 5♠6♠7♠, J♥Q♥K♥, A♣2♣3♣) - No wilds allowed!'),
        _buildBullet('7 Dublees (Pairs of identical cards)'),
        const SizedBox(height: 12),
        Text('BENEFITS', style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildBenefitRow('🔓 Maal Points', 'Active (Counted)'),
        _buildBenefitRow('🔓 Discard Pile', 'Can pick cards'),
        _buildBenefitRow('🔓 Loss Penalty', 'Reduced to 3 pts'),
      ],
    );
  }

  Widget _buildMaalContent(ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maal cards are worth bonus points. In the app, they glow with specific colors:',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 12),
        _buildMaalRow('👑 Tiplu', '3 pts', Colors.purple, 'The center card'),
        _buildMaalRow('⬆️ Poplu', '2 pts', Colors.blue, 'Rank +1 (Same Suit)'),
        _buildMaalRow('⬇️ Jhiplu', '2 pts', Colors.cyan, 'Rank -1 (Same Suit)'),
        _buildMaalRow('💎 Alter', '5 pts', Colors.orange, 'Same Rank & Color'),
        _buildMaalRow('🃏 Man', '2 pts', Colors.green, 'Printed Joker'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [themeColors.gold.withOpacity(0.3), Colors.transparent]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: themeColors.gold.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MARRIAGE BONUS', style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold)),
                    const Text('Jhiplu + Tiplu + Poplu sequence = 100 POINTS!', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoringContent(ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scores are calculated at the end of every round.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 12),
        _buildScoreRow('Winner', 'Collects from all losers'),
        _buildScoreRow('Visited Loser', 'Pays 3 points'),
        _buildScoreRow('Unvisited Loser', 'Pays 10 points (Flat Penalty)'),
        const Divider(color: Colors.white24, height: 24),
        const Text('Maal Exchange', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          'Players exchange the difference in Maal points. Unvisited players have 0 effective Maal.',
          style: TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
  
  Widget _buildAdvancedContent(ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAdvancedItem('Kidnap Rule', 'If you haven\'t visited when the game ends, your Maal points are treated as 0, even if you hold Maal cards.'),
        _buildAdvancedItem('Murder Rule', 'In strict variants (optional), unvisited players lose their Maal cards to the winner.'),
        _buildAdvancedItem('Joker Block', 'You cannot start a discard pile with a printed Joker.'),
      ],
    );
  }

  Widget _buildFAQSection(ThemeColors themeColors) {
    return Column(
      children: [
        _buildFAQItem('How many decks?', '3 standard decks are used.'),
        _buildFAQItem('Do I need to visit to win?', 'No, but unvisited players pay a high penalty (10 pts) and get 0 Maal points.'),
        _buildFAQItem('Can I use Jokers to visit?', 'No! Visiting sequences must be PURE (natural cards only).'),
        _buildFAQItem('What if I have 7 pairs?', 'You can Visit! Show your 7 Dublees to unlock Maal.'),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
  
  Widget _buildStep(int num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Text('$num', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: desc, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermRow(String term, String def) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(term, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text(def, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
  
  Widget _buildBenefitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMaalRow(String name, String points, Color color, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(4),
              color: color.withOpacity(0.1),
            ),
            child: Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Text(points, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12))),
        ],
      ),
    );
  }
  
  Widget _buildScoreRow(String role, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(role, style: const TextStyle(color: Colors.white70)),
          Text(points, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildAdvancedItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q: $q', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('A: $a', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

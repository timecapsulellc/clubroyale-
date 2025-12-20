import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';
import 'package:clubroyale/config/casino_theme.dart';

/// Screen displaying rules and FAQ for the Marriage card game
/// Enhanced with "Nano Banner" style infographics for intuitive learning.
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
            // Quick Reference "Nano Hero" Card
            _buildHeroSection(themeColors),
            const SizedBox(height: 24),
            
            // Visual Visiting Flowchart (Priority 1)
            _buildSectionHeader('Key Requirement', themeColors, Icons.vpn_key),
            _buildVisitingInfographic(themeColors),
            
             // Visual Maal Guide (Priority 2)
            _buildSectionHeader('Know Your Maal', themeColors, Icons.diamond),
            _buildMaalInfographic(themeColors),
            
             // Detailed Rules Expandables
            const SizedBox(height: 16),
            _buildSectionHeader('Detailed Rules', themeColors, Icons.menu_book),
            
            _buildExpandableTile(
              title: 'Game Basics & Terms',
              icon: Icons.info_outline,
              content: _buildBasicsContent(themeColors),
              themeColors: themeColors,
            ),
            _buildExpandableTile(
              title: 'Turn Structure & Tips',
              icon: Icons.sync,
              content: _buildTurnContent(themeColors),
              themeColors: themeColors,
            ),
            _buildExpandableTile(
              title: 'Advanced: Kidnap & Murder',
              icon: Icons.dangerous,
              content: _buildAdvancedContent(themeColors),
              themeColors: themeColors,
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader('FAQ', themeColors, Icons.help_outline),
            _buildFAQSection(themeColors),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Hero Section ---

  Widget _buildHeroSection(ThemeColors theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.gold.withOpacity(0.2), theme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.gold.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.gold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('👑', style: TextStyle(fontSize: 32)),
            ),
            title: Text(
              'Marriage (Royal Meld)',
              style: TextStyle(
                color: theme.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'The King of Rummy Games',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeroStat('21', 'Cards', Icons.style),
                _buildHeroStat('3', 'Decks', Icons.copy),
                _buildHeroStat('2-6', 'Players', Icons.people),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  // --- Visiting Infographic ---

  Widget _buildVisitingInfographic(ThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            'Keepers of the Gate: To "Visit" and unlock Maal, you need listed melds.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildVisitChoice('3x', 'Pure Segments', 'No Wilds Allowed', Icons.check_circle_outline, Colors.blue)),
              const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 8),
                 child: Text('OR', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: _buildVisitChoice('7x', 'Dublees', 'Pairs of same card', Icons.copy, Colors.orange)),
              const Padding(
                 padding: EdgeInsets.symmetric(horizontal: 8),
                 child: Text('OR', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: _buildVisitChoice('3x', 'Tunnels', 'Triplets of same card', Icons.filter_3, Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_open, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('UNLOCKS: Maal Points & Discard Pickup', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitChoice(String count, String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 9), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // --- Maal Infographic ---

  Widget _buildMaalInfographic(ThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniCard('Tiplu', '👑', '+3', Colors.purple),
              _buildMiniCard('Poplu', '⬆️', '+2', Colors.blue),
              _buildMiniCard('Jhiplu', '⬇️', '+2', Colors.cyan),
              _buildMiniCard('Alter', '💎', '+5', Colors.orange),
              _buildMiniCard('Man', '🃏', '+2', Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('MARRIAGE BONUS', style: TextStyle(color: theme.gold, fontWeight: FontWeight.bold)),
                     const Text('Hold Tiplu + Poplu + Jhiplu sequence for 100 Points!', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: theme.gold, borderRadius: BorderRadius.circular(4)),
                child: const Text('100 PTS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String label, String icon, String points, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              Positioned(
                top: 2, right: 3,
                child: Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        Text(points, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- Expandable Content ---

  Widget _buildBasicsContent(ThemeColors theme) {
    return Column(
      children: [
        _buildTermRow('Objective', 'Arrange 21 cards into valid sets/sequences. 0 penalty wins.'),
        _buildTermRow('Pure Sequence', 'Consecutive cards of same suit. NO WILDS. Essential for visiting.'),
        _buildTermRow('Wilds', 'Tiplu (Center) and its neighbors help complete impure sets.'),
        _buildTermRow('Tunnel', 'Three identical cards (e.g. 7♠ 7♠ 7♠). Can convert to checking.'),
      ],
    );
  }
  
  Widget _buildTurnContent(ThemeColors theme) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRuleStep(1, 'Draw', 'From Deck (Always allowed) or Discard (Only if Visited).'),
        _buildRuleStep(2, 'Check/Visit', 'If you have 3 Pure Sequences, show them to unlock Maal.'),
        _buildRuleStep(3, 'Discard', 'Throw one card to end turn.'),
      ],
    );
  }
  
  Widget _buildAdvancedContent(ThemeColors theme) {
    return Column(
      children: [
        Container(
           padding: const EdgeInsets.all(12),
           margin: const EdgeInsets.only(bottom: 12),
           decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
           child: Row(
             children: const [
               Icon(Icons.person_off, color: Colors.red),
               SizedBox(width: 12),
               Expanded(
                 child: Text('KIDNAP RULE: If a player wins and you haven\'t visited, your Maal cards are worth NOTHING (0 pts).', style: TextStyle(color: Colors.white, fontSize: 13)),
               ),
             ],
           ),
        ),
         Container(
           padding: const EdgeInsets.all(12),
           decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
           child: Row(
             children: const [
               Icon(Icons.dangerous, color: Colors.red),
               SizedBox(width: 12),
               Expanded(
                 child: Text('MURDER RULE: In strict games, unvisited players give their Maal cards to the winner!', style: TextStyle(color: Colors.white, fontSize: 13)),
               ),
             ],
           ),
        ),
      ],
    );
  }
  
  Widget _buildRuleStep(int n, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
            child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Standard Sections ---

  Widget _buildSectionHeader(String title, ThemeColors themeColors, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: themeColors.gold),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: themeColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: themeColors.gold.withOpacity(0.3))),
        ],
      ),
    );
  }
  
  Widget _buildExpandableTile({
    required String title,
    required Widget content,
    required ThemeColors themeColors,
    required IconData icon,
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
          leading: Icon(icon, color: Colors.white60),
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
  
  Widget _buildTermRow(String term, String def) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(term, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(def, style: const TextStyle(color: Colors.white70, fontSize: 13))),
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
}

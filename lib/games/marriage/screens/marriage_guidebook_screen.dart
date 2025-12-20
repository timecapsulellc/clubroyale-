import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/core/theme/multi_theme.dart'; // Keep for themeColors provider if needed, but styling with CasinoDecoration

/// A Dedicated, High-Fidelity Guidebook for Marriage Card Game
/// "Chief Architect" Design: Tabbed interface for structured learning.
/// - Tab 1: Basics (Objective, Setup)
/// - Tab 2: Gameplay (Turn flow, Visiting)
/// - Tab 3: Maal (Visual Card Grid)
/// - Tab 4: Rules (Advanced Regulations)
class MarriageGuidebookScreen extends ConsumerStatefulWidget {
  const MarriageGuidebookScreen({super.key});

  @override
  ConsumerState<MarriageGuidebookScreen> createState() => _MarriageGuidebookScreenState();
}

class _MarriageGuidebookScreenState extends ConsumerState<MarriageGuidebookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We can use themeColors for basic structure but override with CasinoTheme for Branding
    final themeColors = ref.watch(themeColorsProvider); 

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: CasinoColors.primaryGradient),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight + MediaQuery.of(context).padding.top),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _BasicsTab(),
                  _GameplayTab(),
                  _MaalTab(),
                  _RulesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: CasinoColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.menu_book, color: CasinoColors.gold, size: 20),
          SizedBox(width: 8),
          Text(
            'ROYAL MELD GUIDE',
            style: TextStyle(
              color: CasinoColors.gold,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CasinoColors.deepPurple,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: CasinoColors.gold.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: CasinoColors.gold,
          borderRadius: BorderRadius.circular(25),
          boxShadow: CasinoColors.goldGlow,
        ),
        labelColor: Colors.black,
        unselectedLabelColor: CasinoColors.gold,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [
          Tab(text: 'BASICS'),
          Tab(text: 'FLOW'),
          Tab(text: 'MAAL'),
          Tab(text: 'RULES'),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: BASICS
// ==========================================

class _BasicsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeroHeader(),
        const SizedBox(height: 20),
        _buildInfoCard('Objective', 'Arrange 21 cards into Sets and Sequences. Reduce points to zero.', Icons.flag),
        _buildInfoCard('The Setup', '• 3 Decks (Standard)\n• 2-6 Players\n• 21 Cards Hand\n• 3 Jokers per Deck\n• Tiplu (Wild) in Center', Icons.casino),
        _buildInfoCard('Melds', 'Valid combinations:\n• Pure Sequence (Run)\n• Sequence (Dirty Run)\n• Dublee (Pair)\n• Tunnel (Triplet)', Icons.style),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: CasinoDecorations.goldAccentCard(borderRadius: 24),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: CasinoColors.gold),
          const SizedBox(height: 12),
          const Text(
            'MASTER THE GAME',
            style: TextStyle(color: CasinoColors.gold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const Padding(
             padding: EdgeInsets.symmetric(vertical: 8),
             child: Divider(color: CasinoColors.gold),
          ),
          const Text(
            'Marriage (Royal Meld) is a skillful Rummy variant played with 3 decks. It combines strategy, memory, and calculated risk.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: CasinoDecorations.glassCard(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: CasinoColors.gold.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: CasinoColors.gold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: GAMEPLAY FLOW
// ==========================================

class _GameplayTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
         Text('TURN SEQUENCE', style: _headerStyle),
         const SizedBox(height: 16),
         _buildStep(1, 'DRAW', 'Take from Deck OR Discard pile (conditions apply).'),
         _buildArrow(),
         _buildStep(2, 'VISIT (Optional)', 'Show 3 Pure Sequences to unlock Maal.'),
         _buildArrow(),
         _buildStep(3, 'DISCARD', 'Throw a card to end turn.'),
         
         const SizedBox(height: 32),
         Text('THE GATEKEEPER', style: _headerStyle),
         const SizedBox(height: 8),
         const Text('You cannot calculate Maal points until you "Visit".', 
            style: TextStyle(color: Colors.white60, fontSize: 12, fontStyle: FontStyle.italic)),
         const SizedBox(height: 16),
         
         _buildVisitingVisual(),
      ],
    );
  }
  
  TextStyle get _headerStyle => const TextStyle(color: CasinoColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.2);

  Widget _buildStep(int n, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CasinoColors.richPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
           Text('$n', style: const TextStyle(color: CasinoColors.gold, fontSize: 32, fontWeight: FontWeight.bold)),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                 Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return const Center(child: Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Icon(Icons.arrow_downward, color: Colors.white24),
    ));
  }
  
  Widget _buildVisitingVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CasinoDecorations.glassCard(borderColor: CasinoColors.neonPink.withOpacity(0.5)),
      child: Column(
        children: [
          const Text('VISITING REQUIREMENTS', style: TextStyle(color: CasinoColors.neonPink, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Choose ONE path:', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          _buildPath('PATH A', '3 PURE SEQUENCES', Icons.check_circle_outline, Colors.blue),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('OR', style: TextStyle(color: Colors.white24))),
          _buildPath('PATH B', '7 DUBLEES (PAIRS)', Icons.copy, Colors.orange),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('OR', style: TextStyle(color: Colors.white24))),
          _buildPath('PATH C', '3 TUNNELS', Icons.filter_3, Colors.purple),
        ],
      ),
    );
  }
  
  Widget _buildPath(String label, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 3: MAAL (VISUAL)
// ==========================================

class _MaalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Maal cards are the currency of the game. Value depends on the "Tiplu" (Center Card).',
          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMaalCard('TIPLU', 'Center Card', '3 pts', Colors.purple, Icons.emoji_events),
            _buildMaalCard('POPLU', 'Tiplu +1 Rank', '2 pts', Colors.blue, Icons.arrow_upward),
            _buildMaalCard('JHIPLU', 'Tiplu -1 Rank', '2 pts', Colors.cyan, Icons.arrow_downward),
            _buildMaalCard('ALTER', 'Same Rank+Col', '5 pts', Colors.orange, Icons.diamond),
          ],
        ),
        
        const SizedBox(height: 12),
        _buildMaalCard('MAN', 'Print Joker', '2 pts', Colors.green, Icons.sentiment_very_satisfied),
        
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CasinoDecorations.goldAccentCard(),
          child: Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('MARRIAGE BONUS', style: TextStyle(color: CasinoColors.gold, fontWeight: FontWeight.bold)),
                    Text('Tiplu + Poplu + Jhiplu = 100 PTS', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMaalCard(String title, String desc, String pts, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _neuroMorphicDecoration(color),
      child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Icon(icon, color: color, size: 28),
           const SizedBox(height: 8),
           Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
           Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
           const SizedBox(height: 4),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
             decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
             child: Text(pts, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
           ),
         ],
      ),
    );
  }

  BoxDecoration _neuroMorphicDecoration(Color color) {
     return BoxDecoration(
       color: CasinoColors.cardBackgroundLight,
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: color.withOpacity(0.3), width: 1),
       boxShadow: [
         BoxShadow(color: color.withOpacity(0.1), offset: const Offset(-2, -2), blurRadius: 4),
         BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(4, 4), blurRadius: 8),
       ],
     );
   }
}

// ==========================================
// TAB 4: RULES & FAQ
// ==========================================

class _RulesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection('SCORING', [
          _buildText('• Winner: Collects points from all losers.'),
          _buildText('• Unvisited Loser: Pays 10 pts (Flat Penalty).'),
          _buildText('• Visited Loser: Pays 3 pts.'),
          _buildText('• Maal Exchange: Points difference paid between players.'),
        ]),
        
        _buildSection('ADVANCED RULES', [
          _buildAlert('KIDNAP RULE', 'If you lose unvisited, your Maal cards are effectively worth 0 points.'),
          _buildAlert('MURDER RULE', 'In strict games, unvisited players surrender Maal cards to winner.'),
          _buildText('• Joker Block: Cannot start discard with Joker.'),
        ]),
        
        _buildSection('FAQ', [
          _buildFAQ('Can I pick from discard?', 'Only after you have Visited.'),
          _buildFAQ('What is "Tunnel"?', 'Three identical cards (e.g. 8♠ 8♠ 8♠). It counts as a sequence.'),
        ]),
      ],
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: const TextStyle(color: CasinoColors.gold, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CasinoDecorations.glassCard(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }
  
  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, height: 1.4)),
    );
  }
  
  Widget _buildAlert(String label, String text) {
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.red.withOpacity(0.1),
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: Colors.red.withOpacity(0.3)),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(label, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
           const SizedBox(height: 4),
           Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
         ],
       ),
     );
  }
  
  Widget _buildFAQ(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q: $q', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(a, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Core of NanoBanan Pro
import 'package:clubroyale/config/casino_theme.dart';

/// "NanoBanan Pro" Guidebook Screen
/// Features high-fidelity animations, shimmers, and interactive motion.
class MarriageGuidebookScreen extends ConsumerStatefulWidget {
  const MarriageGuidebookScreen({super.key});

  @override
  ConsumerState<MarriageGuidebookScreen> createState() =>
      _MarriageGuidebookScreenState();
}

class _MarriageGuidebookScreenState
    extends ConsumerState<MarriageGuidebookScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: CasinoColors.primaryGradient),
        child: Column(
          children: [
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            _buildTabBar()
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),
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
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book, color: CasinoColors.gold, size: 20)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(
            'ROYAL MELD GUIDE',
            style: TextStyle(
              color: CasinoColors.gold,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(duration: 800.ms).shimmer(duration: 2000.ms),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
// TAB 1: BASICS (Hero & Intro)
// ==========================================

class _BasicsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeroHeader()
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),

        const SizedBox(height: 20),

        _buildInfoCard(
          'Objective',
          'Arrange 21 cards into Sets and Sequences. Reduce points to zero.',
          Icons.flag,
          1,
        ),
        _buildInfoCard(
          'The Setup',
          '• 3 Decks (Standard)\n• 2-6 Players\n• 21 Cards Hand\n• 3 Jokers per Deck\n• Tiplu (Wild) in Center',
          Icons.casino,
          2,
        ),
        _buildInfoCard(
          'Melds',
          'Valid combinations:\n• Pure Sequence (Run)\n• Sequence (Dirty Run)\n• Dublee (Pair)\n• Tunnel (Triplet)',
          Icons.style,
          3,
        ),

        const SizedBox(height: 20),
        _buildVideoPlaceholder().animate().fadeIn(delay: 600.ms).scale(),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: CasinoDecorations.goldAccentCard(borderRadius: 24),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: CasinoColors.gold)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
              ),
          const SizedBox(height: 12),
          const Text(
                'MASTER THE GAME',
                style: TextStyle(
                  color: CasinoColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 3000.ms, color: Colors.white),
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

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    int delayValues,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: CasinoDecorations.glassCard(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CasinoColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: CasinoColors.gold),
          ).animate().rotate(duration: 600.ms, delay: (200 * delayValues).ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * delayValues).ms).slideX(begin: 0.2);
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CasinoColors.neonPink.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CasinoColors.neonPink.withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_circle_fill,
              color: CasinoColors.neonPink,
              size: 48,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'WATCH TUTORIAL',
                  style: TextStyle(
                    color: CasinoColors.neonPink,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Coming Soon: A full video guide to mastering Royal Meld.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: GAMEPLAY FLOW (Interactive Timeline)
// ==========================================

class _GameplayTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('TURN SEQUENCE', style: _headerStyle).animate().fadeIn(),
        const SizedBox(height: 16),
        _buildStep(
          1,
          'DRAW',
          'Take from Deck OR Discard pile (conditions apply).',
          1,
        ),
        _buildArrow(1),
        _buildStep(
          2,
          'VISIT (Optional)',
          'Show 3 Pure Sequences to unlock Maal.',
          2,
        ),
        _buildArrow(2),
        _buildStep(3, 'DISCARD', 'Throw a card to end turn.', 3),

        const SizedBox(height: 32),
        Text(
          'THE GATEKEEPER',
          style: _headerStyle,
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 8),
        const Text(
          'You cannot calculate Maal points until you "Visit".',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),

        _buildVisitingVisual()
            .animate()
            .fadeIn(delay: 700.ms)
            .slideY(begin: 0.1),
      ],
    );
  }

  TextStyle get _headerStyle => const TextStyle(
    color: CasinoColors.gold,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  Widget _buildStep(int n, String title, String desc, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CasinoColors.richPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(
            '$n',
            style: const TextStyle(
              color: CasinoColors.gold,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (200 * index).ms).slideX();
  }

  Widget _buildArrow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: const Icon(Icons.arrow_downward, color: Colors.white24)
          .animate(onPlay: (c) => c.repeat())
          .moveY(begin: -5, end: 5, duration: 1000.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildVisitingVisual() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CasinoDecorations.glassCard(
        borderColor: CasinoColors.neonPink.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_open,
                color: CasinoColors.neonPink,
              ).animate().shake(delay: 1000.ms),
              const SizedBox(width: 8),
              const Text(
                'VISITING REQUIREMENTS',
                style: TextStyle(
                  color: CasinoColors.neonPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose ONE path to UNLOCK:',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          _buildPath(
            'PATH A',
            '3 PURE SEQUENCES',
            Icons.check_circle_outline,
            Colors.blue,
            1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'OR',
              style: TextStyle(color: Colors.white24),
            ).animate().fadeIn(delay: 1200.ms),
          ),
          _buildPath(
            'PATH B',
            '7 DUBLEES (PAIRS)',
            Icons.copy,
            Colors.orange,
            2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'OR',
              style: TextStyle(color: Colors.white24),
            ).animate().fadeIn(delay: 1400.ms),
          ),
          _buildPath('PATH C', '3 TUNNELS', Icons.filter_3, Colors.purple, 3),
        ],
      ),
    );
  }

  Widget _buildPath(
    String label,
    String title,
    IconData icon,
    Color color,
    int index,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ).animate().scale(delay: (1000 + (200 * index)).ms),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: (1000 + (200 * index)).ms).slideX(begin: 0.1);
  }
}

// ==========================================
// TAB 3: MAAL (Interactive Grid)
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
        ).animate().fadeIn(),
        const SizedBox(height: 24),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio:
              1.2, // Adjusted to prevent overflow on small screens
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildMaalCard(
              'TIPLU',
              'Center Card',
              '3 pts',
              Colors.purple,
              Icons.emoji_events,
              0,
            ),
            _buildMaalCard(
              'POPLU',
              'Tiplu +1 Rank',
              '2 pts',
              Colors.blue,
              Icons.arrow_upward,
              1,
            ),
            _buildMaalCard(
              'JHIPLU',
              'Tiplu -1 Rank',
              '2 pts',
              Colors.cyan,
              Icons.arrow_downward,
              2,
            ),
            _buildMaalCard(
              'ALTER',
              'Same Rank+Col',
              '5 pts',
              Colors.orange,
              Icons.diamond,
              3,
            ),
          ],
        ),

        const SizedBox(height: 12),
        _buildMaalCard(
          'MAN',
          'Print Joker',
          '2 pts',
          Colors.green,
          Icons.sentiment_very_satisfied,
          4,
        ),

        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CasinoDecorations.goldAccentCard(),
          child: Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 32))
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 1500.ms,
                  ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                          'MARRIAGE BONUS',
                          style: TextStyle(
                            color: CasinoColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 2000.ms),
                    const Text(
                      'Tiplu + Poplu + Jhiplu = 100 PTS',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildMaalCard(
    String title,
    String desc,
    String pts,
    Color color,
    IconData icon,
    int index,
  ) {
    return Container(
          padding: const EdgeInsets.all(12),
          decoration: _neuroMorphicDecoration(color),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28)
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  ) // Breathing icon
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms,
                  ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pts,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  BoxDecoration _neuroMorphicDecoration(Color color) {
    return BoxDecoration(
      color: CasinoColors.cardBackgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
      ],
    );
  }
}

// ==========================================
// TAB 4: RULES (Detailed Lists)
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
          _buildText(
            '• Maal Exchange: Points difference paid between players.',
          ),
        ], 1),

        _buildSection('ADVANCED RULES', [
          _buildAlert(
            'KIDNAP RULE',
            'If you lose unvisited, your Maal cards are effectively worth 0 points.',
          ),
          _buildAlert(
            'MURDER RULE',
            'In strict games, unvisited players surrender Maal cards to winner.',
          ),
          _buildText('• Joker Block: Cannot start discard with Joker.'),
        ], 2),

        _buildSection('FAQ', [
          _buildFAQ('Can I pick from discard?', 'Only after you have Visited.'),
          _buildFAQ(
            'What is "Tunnel"?',
            'Three identical cards (e.g. 8♠ 8♠ 8♠). It counts as a sequence.',
          ),
        ], 3),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: CasinoColors.gold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CasinoDecorations.glassCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ).animate().fadeIn(delay: (200 * index).ms).slideY(begin: 0.1);
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, height: 1.4),
      ),
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
              Text(
                label,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3000.ms, color: Colors.white10);
  }

  Widget _buildFAQ(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: $q',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(a, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }
}

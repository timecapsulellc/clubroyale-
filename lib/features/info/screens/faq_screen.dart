import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';

/// FAQ Screen - Frequently Asked Questions
class FAQScreen extends ConsumerWidget {
  const FAQScreen({super.key});

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
        title: Text('FAQ', style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(themeColors),
            const SizedBox(height: 24),
            
            // General FAQ
            _buildSection('General', [
              _FAQItem(
                question: 'What is ClubRoyale?',
                answer: 'ClubRoyale is your private card club - a premium multiplayer card game platform. '
                    'Host private rooms, play popular card games with friends, and settle scores seamlessly.',
              ),
              _FAQItem(
                question: 'Is ClubRoyale free to play?',
                answer: 'Yes! ClubRoyale uses a FREE diamond system. You earn diamonds daily through login bonuses, '
                    'watching ads, completing games, and referrals. No real money purchases required.',
              ),
              _FAQItem(
                question: 'What games are available?',
                answer: 'We currently offer 4 complete games:\n'
                    '• Royal Meld (Marriage) - 2-8 players\n'
                    '• Call Break - 4 players\n'
                    '• Teen Patti - 2-8 players\n'
                    '• In-Between - 2-6 players',
              ),
              _FAQItem(
                question: 'Can I play with friends?',
                answer: 'Absolutely! Create a private room, share the 6-digit room code with friends, '
                    'and they can join instantly. You can also use voice and video chat during games.',
              ),
            ], themeColors),
            
            // Diamond Economy
            _buildSection('Diamonds 💎', [
              _FAQItem(
                question: 'How do I earn diamonds?',
                answer: '• Welcome Bonus: 100 💎\n'
                    '• Daily Login: 10 💎\n'
                    '• Watch Ad: 20 💎 (up to 6x/day)\n'
                    '• Complete Game: 5 💎\n'
                    '• Refer a Friend: 50 💎',
              ),
              _FAQItem(
                question: 'What can I use diamonds for?',
                answer: '• Create Room: 10 💎\n'
                    '• Ad-Free Game: 5 💎\n'
                    'Diamonds are for convenience only and have no real-world value.',
              ),
              _FAQItem(
                question: 'Can I buy diamonds with real money?',
                answer: 'Diamond purchases are optional. The game is fully playable for free with daily bonuses.',
              ),
            ], themeColors),
            
            // Games
            _buildSection('Gameplay', [
              _FAQItem(
                question: 'How does matchmaking work?',
                answer: 'ClubRoyale uses ELO-based matchmaking to pair you with players of similar skill level. '
                    'You can also create private rooms to play with specific friends.',
              ),
              _FAQItem(
                question: 'What are AI bots?',
                answer: 'When there aren\'t enough players, AI-powered bots fill empty seats. '
                    'Our bots use GenKit AI to make intelligent moves.',
              ),
              _FAQItem(
                question: 'What is the Settlement feature?',
                answer: 'After each game, ClubRoyale calculates "who owes whom" and generates a settlement summary. '
                    'You can share this to WhatsApp for easy offline settlement with friends.',
              ),
            ], themeColors),
            
            // Technical
            _buildSection('Technical', [
              _FAQItem(
                question: 'Can I install ClubRoyale on my phone?',
                answer: 'Yes! On Android, you can download our APK or install as a PWA from the browser. '
                    'On iPhone, add to Home Screen from Safari.',
              ),
              _FAQItem(
                question: 'Is my data safe?',
                answer: 'We take privacy seriously. We collect minimal data and never share with third parties. '
                    'See our Privacy Policy for details.',
              ),
              _FAQItem(
                question: 'How do I change themes?',
                answer: 'Go to Settings > Appearance to choose from 5 beautiful color themes. '
                    'You can also toggle Day/Night mode.',
              ),
            ], themeColors),
            
            const SizedBox(height: 40),
            
            // Contact
            _buildContactSection(themeColors),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 48, color: themeColors.gold),
          const SizedBox(height: 12),
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about ClubRoyale',
            style: TextStyle(
              color: themeColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<_FAQItem> items, ThemeColors themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: themeColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...items.map((item) => _FAQTile(item: item, themeColors: themeColors)),
      ],
    );
  }
  
  Widget _buildContactSection(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Still have questions?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact us at support@clubroyale.app',
            style: TextStyle(
              color: themeColors.gold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  
  _FAQItem({required this.question, required this.answer});
}

class _FAQTile extends StatefulWidget {
  final _FAQItem item;
  final ThemeColors themeColors;
  
  const _FAQTile({required this.item, required this.themeColors});
  
  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded 
              ? widget.themeColors.gold.withOpacity(0.5) 
              : Colors.transparent,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            widget.item.question,
            style: TextStyle(
              color: widget.themeColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.remove : Icons.add,
            color: widget.themeColors.gold,
          ),
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.answer,
                style: TextStyle(
                  color: widget.themeColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

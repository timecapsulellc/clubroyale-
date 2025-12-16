import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';

/// Landing Page - Beautiful introduction with features and roadmap
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ref.watch(themeColorsProvider);
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: themeColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(themeColors, screenSize),
              
              // Games Section
              _buildGamesSection(themeColors),
              
              // Features Section
              _buildFeaturesSection(themeColors),
              
              // Architecture Section
              _buildArchitectureSection(themeColors),
              
              // Roadmap Section
              _buildRoadmapSection(themeColors),
              
              // CTA Section
              _buildCTASection(themeColors),
              
              // Footer
              _buildFooter(themeColors),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeroSection(ThemeColors themeColors, Size screenSize) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: screenSize.width > 600 ? 80 : 60,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColors.primary.withValues(alpha: 0.8),
              themeColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Logo
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: themeColors.accentGradient,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: themeColors.gold.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 32),
            
            // Title
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [themeColors.gold, Colors.white, themeColors.gold],
              ).createShader(bounds),
              child: const Text(
                'ClubRoyale',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tagline
            Text(
              'Your Private Card Club',
              style: TextStyle(
                fontSize: 20,
                color: themeColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            
            // Description
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                'Experience the ultimate card gaming platform with AI-powered gameplay, '
                'real-time multiplayer, and beautiful customizable themes.',
                style: TextStyle(
                  fontSize: 16,
                  color: themeColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            // CTA Buttons
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColors.gold,
                    foregroundColor: themeColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 8),
                      Text('Play Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/about'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColors.gold,
                    side: BorderSide(color: themeColors.gold),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Learn More', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Stats Row
            Wrap(
              spacing: 40,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem('4', 'Games', themeColors),
                _buildStatItem('64K', 'Lines of Code', themeColors),
                _buildStatItem('5', 'Themes', themeColors),
                _buildStatItem('99', 'Quality Score', themeColors),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String value, String label, ThemeColors themeColors) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: themeColors.gold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: themeColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGamesSection(ThemeColors themeColors) {
    final games = [
      {'name': 'Royal Meld', 'subtitle': 'Marriage', 'players': '2-8', 'icon': '♦️'},
      {'name': 'Call Break', 'subtitle': 'Trick Taking', 'players': '4', 'icon': '♠️'},
      {'name': 'Teen Patti', 'subtitle': '3-Card Poker', 'players': '2-8', 'icon': '♥️'},
      {'name': 'In-Between', 'subtitle': 'Quick Bet', 'players': '2-6', 'icon': '♣️'},
    ];
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          _buildSectionTitle('🎮 Games', 'Four complete card games with AI opponents', themeColors),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: games.map((game) => _buildGameCard(game, themeColors)).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameCard(Map<String, String> game, ThemeColors themeColors) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColors.gold.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(game['icon']!, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            game['name']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          Text(
            game['subtitle']!,
            style: TextStyle(
              fontSize: 12,
              color: themeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: themeColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${game['players']} players',
              style: TextStyle(color: themeColors.gold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesSection(ThemeColors themeColors) {
    final features = [
      {'icon': Icons.palette, 'title': '5 Themes', 'desc': 'Beautiful color presets with day/night mode'},
      {'icon': Icons.smart_toy, 'title': 'AI Bots', 'desc': 'GenKit-powered intelligent opponents'},
      {'icon': Icons.videocam, 'title': 'Voice & Video', 'desc': 'Real-time chat with LiveKit'},
      {'icon': Icons.diamond, 'title': 'Free Diamonds', 'desc': 'Earn daily rewards without purchases'},
      {'icon': Icons.share, 'title': 'Settlement', 'desc': 'Auto-calculate and share to WhatsApp'},
      {'icon': Icons.install_mobile, 'title': 'PWA', 'desc': 'Install on any device'},
    ];
    
    return Container(
      padding: const EdgeInsets.all(40),
      color: themeColors.surface.withValues(alpha: 0.2),
      child: Column(
        children: [
          _buildSectionTitle('✨ Features', 'Everything you need for the ultimate card experience', themeColors),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: features.map((f) => _buildFeatureCard(f, themeColors)).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(Map<String, dynamic> feature, ThemeColors themeColors) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: themeColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature['icon'] as IconData, color: themeColors.gold),
          ),
          const SizedBox(height: 12),
          Text(
            feature['title'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature['desc'] as String,
            style: TextStyle(
              fontSize: 12,
              color: themeColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildArchitectureSection(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          _buildSectionTitle('🏗️ Architecture', 'Built with modern tech for scale and performance', themeColors),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeColors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeColors.gold.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                _buildArchRow('PRESENTATION', 'Flutter 3.38 • 30+ Screens • 5 Themes', themeColors, true),
                _buildArchRow('STATE', 'Riverpod 3.x • NotifierProvider Pattern', themeColors, false),
                _buildArchRow('BUSINESS', '22 Services • 4 Game Engines', themeColors, true),
                _buildArchRow('BACKEND', 'Firebase • 12 Cloud Functions', themeColors, false),
                _buildArchRow('AI', 'GenKit + Gemini Pro • 6 Flows', themeColors, true),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArchRow(String layer, String desc, ThemeColors themeColors, bool highlight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? themeColors.gold.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? themeColors.gold.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              layer,
              style: TextStyle(
                color: themeColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoadmapSection(ThemeColors themeColors) {
    final roadmap = [
      {'phase': 'Now', 'title': 'Current', 'items': ['4 Games', '5 Themes', 'AI Bots', 'Voice/Video'], 'done': true},
      {'phase': 'Q1', 'title': '2025', 'items': ['Tournaments', 'Clubs/Guilds', 'Season Pass', 'Spectator Mode'], 'done': false},
      {'phase': 'Q2', 'title': '2025', 'items': ['AI Coach', 'Replay System', 'Video Highlights', 'Creator Economy'], 'done': false},
      {'phase': 'Q3', 'title': '2025', 'items': ['eSports', 'Multi-Region', '1M MAU', 'Poker/Rummy'], 'done': false},
    ];
    
    return Container(
      padding: const EdgeInsets.all(40),
      color: themeColors.surface.withValues(alpha: 0.2),
      child: Column(
        children: [
          _buildSectionTitle('🗺️ Roadmap', 'Our vision for the future of ClubRoyale', themeColors),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: roadmap.map((r) => _buildRoadmapCard(r, themeColors)).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoadmapCard(Map<String, dynamic> phase, ThemeColors themeColors) {
    final isDone = phase['done'] as bool;
    
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDone 
            ? themeColors.gold.withValues(alpha: 0.1) 
            : themeColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? themeColors.gold : themeColors.gold.withValues(alpha: 0.3),
          width: isDone ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                phase['phase'] as String,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeColors.gold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                phase['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: themeColors.textSecondary,
                ),
              ),
              if (isDone) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: themeColors.gold, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...(phase['items'] as List).map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check : Icons.arrow_right,
                  size: 14,
                  color: isDone ? themeColors.gold : themeColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  item,
                  style: TextStyle(
                    color: themeColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildCTASection(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Text(
            'Ready to Play?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of players enjoying ClubRoyale',
            style: TextStyle(
              fontSize: 16,
              color: themeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColors.gold,
              foregroundColor: themeColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Start Playing Free',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: themeColors.surface.withValues(alpha: 0.5),
      child: Column(
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.push('/faq'),
                child: Text('FAQ', style: TextStyle(color: themeColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => context.push('/how-to-play'),
                child: Text('How to Play', style: TextStyle(color: themeColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => context.push('/terms'),
                child: Text('Terms', style: TextStyle(color: themeColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => context.push('/privacy'),
                child: Text('Privacy', style: TextStyle(color: themeColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => context.push('/about'),
                child: Text('About', style: TextStyle(color: themeColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 Metaweb Technologies • Made with ❤️',
            style: TextStyle(color: themeColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, String subtitle, ThemeColors themeColors) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: themeColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

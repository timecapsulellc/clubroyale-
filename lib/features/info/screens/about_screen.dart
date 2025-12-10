import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';

/// About Screen - App information, architecture, and team
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

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
          'About ClubRoyale',
          style: TextStyle(color: themeColors.gold, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // App Logo & Version
            _buildAppHeader(themeColors),
            const SizedBox(height: 32),
            
            // About App
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'About',
              content: 'ClubRoyale is your private card club - a premium multiplayer card game platform '
                  'that digitizes the "Home Game" experience. Host private rooms, play popular card games '
                  'with friends, and settle scores seamlessly.\n\n'
                  'Built with ❤️ for card game enthusiasts worldwide.',
              themeColors: themeColors,
            ),
            
            // Stats Card
            _buildStatsCard(themeColors),
            
            // Features
            _buildInfoCard(
              icon: Icons.star_outline,
              title: 'Features',
              content: '🃏 4 Card Games: Marriage, Call Break, Teen Patti, In-Between\n'
                  '👥 2-8 Players per room\n'
                  '🤖 AI-Powered Bots (GenKit + Gemini)\n'
                  '💬 Real-time Chat, Voice & Video\n'
                  '🎨 5 Beautiful Theme Presets\n'
                  '🌙 Day/Night Mode\n'
                  '💎 Free Diamond Economy\n'
                  '📊 Smart Settlement Calculator\n'
                  '📱 PWA - Install on any device',
              themeColors: themeColors,
            ),
            
            // Tech Stack
            _buildTechStackCard(themeColors),
            
            // Architecture
            _buildArchitectureCard(themeColors),
            
            // Legal Links
            _buildLegalCard(context, themeColors),
            
            // Credits
            _buildCreditsCard(themeColors),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppHeader(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColors.surface, themeColors.surfaceLight.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColors.gold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: themeColors.gold.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: themeColors.accentGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: themeColors.gold.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '♠',
                style: TextStyle(
                  fontSize: 48,
                  color: themeColors.background,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // App Name
          Text(
            'ClubRoyale',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: themeColors.gold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Private Card Club',
            style: TextStyle(
              fontSize: 16,
              color: themeColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: themeColors.gold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard(ThemeColors themeColors) {
    final stats = [
      {'label': 'Games', 'value': '4', 'icon': Icons.games},
      {'label': 'Code', 'value': '64K', 'icon': Icons.code},
      {'label': 'Files', 'value': '222', 'icon': Icons.folder},
      {'label': 'Score', 'value': '99', 'icon': Icons.star},
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: themeColors.gold),
              const SizedBox(width: 8),
              Text(
                'Project Stats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats.map((stat) => Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: themeColors.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat['icon'] as IconData, color: themeColors.gold),
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeColors.gold,
                  ),
                ),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeColors.textSecondary,
                  ),
                ),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required ThemeColors themeColors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColors.gold),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: themeColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTechStackCard(ThemeColors themeColors) {
    final techs = [
      {'name': 'Flutter', 'version': '3.38.4'},
      {'name': 'Dart', 'version': '3.10'},
      {'name': 'Firebase', 'version': 'Latest'},
      {'name': 'Riverpod', 'version': '3.x'},
      {'name': 'GenKit', 'version': 'Gemini Pro'},
      {'name': 'LiveKit', 'version': 'Video'},
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_outlined, color: themeColors.gold),
              const SizedBox(width: 8),
              Text(
                'Tech Stack',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: techs.map((tech) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColors.gold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tech['name']!,
                    style: TextStyle(
                      color: themeColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tech['version']!,
                    style: TextStyle(
                      color: themeColors.gold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArchitectureCard(ThemeColors themeColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.architecture, color: themeColors.gold),
              const SizedBox(width: 8),
              Text(
                'Architecture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildArchLayer('PRESENTATION', '30+ Screens • 5 Themes • PWA', themeColors),
          _buildArchLayer('BUSINESS LOGIC', '22 Services • 4 Game Engines', themeColors),
          _buildArchLayer('DATA', 'Firestore • 12 Functions • AI', themeColors),
        ],
      ),
    );
  }
  
  Widget _buildArchLayer(String name, String details, ThemeColors themeColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: TextStyle(
                color: themeColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              details,
              style: TextStyle(
                color: themeColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegalCard(BuildContext context, ThemeColors themeColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.policy_outlined, color: themeColors.gold),
              const SizedBox(width: 8),
              Text(
                'Legal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLegalLink('Terms & Conditions', () => context.push('/terms'), themeColors),
          _buildLegalLink('Privacy Policy', () => context.push('/privacy'), themeColors),
          _buildLegalLink('FAQ', () => context.push('/faq'), themeColors),
        ],
      ),
    );
  }
  
  Widget _buildLegalLink(String title, VoidCallback onTap, ThemeColors themeColors) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: themeColors.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: themeColors.gold),
      onTap: onTap,
    );
  }
  
  Widget _buildCreditsCard(ThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '© 2025 TimeCapsule LLC',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Made with ❤️ in India',
            style: TextStyle(color: themeColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🇮🇳', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text('🇳🇵', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text('🌍', style: TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }
}

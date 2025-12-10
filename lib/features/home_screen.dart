
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'auth/auth_service.dart';
import 'package:taasclub/features/wallet/diamond_service.dart';
import 'package:taasclub/config/casino_theme.dart';
import 'package:taasclub/config/visual_effects.dart';
import 'package:taasclub/features/game/services/test_game_service.dart';
import 'package:taasclub/features/game/widgets/player_avatar.dart';
import 'package:taasclub/core/responsive/responsive_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: CasinoColors.darkPurple,
      bottomNavigationBar: GameBottomNav(
        onAccountTap: () => context.go('/profile'),
        onSettingsTap: () => context.go('/settings'),
        onStoreTap: () => context.go('/wallet'),
        onBackTap: () async {
          await authService.signOut();
          if (context.mounted) context.go('/auth');
        },
      ),
      body: ParticleBackground(
        primaryColor: CasinoColors.gold,
        secondaryColor: CasinoColors.richPurple,
        particleCount: 35,
        child: SafeArea(
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium App Bar
            SliverAppBar(
              expandedHeight: 240,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: CasinoColors.deepPurple,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                title: Text(
                  'ClubRoyale',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/casino_bg_dark.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback gradient when image fails to load
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CasinoColors.deepPurple,
                                CasinoColors.richPurple,
                                CasinoColors.darkPurple,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient Overlay for text contrast
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Hero Icon (Optional - keeping small if banner is busy, or removing)
                    // Removing Hero Icon to let the banner art shine.
                  ],
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => context.go('/profile'),
                    tooltip: 'Profile',
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await authService.signOut();
                      if (context.mounted) context.go('/auth');
                    },
                    tooltip: 'Sign Out',
                  ),
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome Message
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: CasinoDecorations.goldAccentCard(),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CasinoColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.waving_hand_rounded,
                            color: CasinoColors.gold,
                            size: 32,
                          ).animate().shake(delay: 500.ms),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: CasinoColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.displayName ?? user?.email?.split('@').first ?? 'Player',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: 32),

                  // Quick Actions Title
                  Text(
                    'Start Playing',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Main Play Card
                  _PrimaryActionCard(
                    icon: Icons.play_arrow_rounded,
                    title: 'Enter Lobby',
                    subtitle: 'Join or create a new game session',
                    gradientColors: [CasinoColors.gold, CasinoColors.bronzeGold],
                    onTap: () => context.go('/lobby'),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  // Quick Test Game Button (Test Mode Only)
                  if (TestMode.isEnabled) ...[
                    const SizedBox(height: 12),
                    _PrimaryActionCard(
                      icon: Icons.science_rounded,
                      title: '🧪 Quick Test Game',
                      subtitle: 'Start instantly with 3 bots',
                      gradientColors: [CasinoColors.feltGreen, const Color(0xFF1a4f2e)],
                      onTap: () => _startQuickTestGame(context, ref, user?.uid ?? 'test_user', user?.displayName ?? 'Test Player'),
                    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
                  ],

                  const SizedBox(height: 32),

                  // ===== GAME SELECTOR SECTION =====
                  Text(
                    'Select Game',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  
                  const SizedBox(height: 12),

                  // Game Type Cards - Row 1
                  Row(
                    children: [
                      Expanded(
                        child: _GameTypeCard(
                          icon: Icons.style_rounded,
                          title: 'Call Break',
                          subtitle: 'Trick-taking',
                          color: CasinoColors.gold,
                          onTap: () => context.go('/lobby'),
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GameTypeCard(
                          icon: Icons.layers_rounded,
                          title: 'Marriage',
                          subtitle: 'Rummy-style',
                          color: Colors.pink,
                          onTap: () => context.go('/marriage'),
                        ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Game Type Cards - Row 2
                  Row(
                    children: [
                      Expanded(
                        child: _GameTypeCard(
                          icon: Icons.casino_rounded,
                          title: 'Teen Patti',
                          subtitle: '3 Card Poker',
                          color: Colors.orange,
                          isNew: true,
                          onTap: () => context.go('/lobby'),
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GameTypeCard(
                          icon: Icons.unfold_more_rounded,
                          title: 'In Between',
                          subtitle: 'Quick Bet',
                          color: Colors.green,
                          isNew: true,
                          onTap: () => context.go('/lobby'),
                        ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ===== CARD DEMO SECTION =====
                  Text(
                    'Featured Cards',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  
                  const SizedBox(height: 12),

                  _CardDemoCarousel().animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 32),

                  // ===== HOW TO PLAY SECTION =====
                  _HowToPlayCard(
                    onTap: () => _showHowToPlayDialog(context),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                  Text(
                    'Activities',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 16),

                  // Enhanced Activity Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: context.responsive(mobile: 2, tablet: 3, desktop: 4),
                    mainAxisSpacing: context.scaledSpacing(12),
                    crossAxisSpacing: context.scaledSpacing(12),
                    childAspectRatio: context.isMobile ? 0.72 : 0.85,
                    children: [
                      _EnhancedActivityCard(
                        icon: Icons.history_rounded,
                        title: 'History',
                        subtitle: 'View past games',
                        gradientColors: [CasinoColors.richPurple, CasinoColors.deepPurple],
                        previewWidget: _HistoryPreview(),
                        onTap: () => context.go('/history'),
                      ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                      
                      _EnhancedActivityCard(
                        icon: Icons.leaderboard_rounded,
                        title: 'Leaderboard',
                        subtitle: 'Top players',
                        gradientColors: [CasinoColors.gold, CasinoColors.bronzeGold],
                        previewWidget: _LeaderboardPreview(),
                        onTap: () => context.go('/leaderboard'),
                      ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                      
                      _EnhancedActivityCard(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        subtitle: 'Preferences',
                        gradientColors: [CasinoColors.cardBackgroundLight, CasinoColors.cardBackground],
                        previewWidget: _SettingsPreview(),
                        onTap: () => context.go('/profile'),
                      ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.9, 0.9)),

                      _WalletCard(
                        onTap: () => context.go('/wallet'),
                      ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

/// Start a quick test game with 3 bots
void _startQuickTestGame(BuildContext context, WidgetRef ref, String playerId, String playerName) {
  final testGameService = ref.read(testGameServiceProvider);
  testGameService.createQuickGame(playerId, playerName);
  context.go('/test-game');
}

// Primary action card (Enter Lobby)
class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: CasinoColors.gold.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: CasinoColors.goldGlow,
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced activity card with gradient and preview
class _EnhancedActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Widget previewWidget;
  final VoidCallback onTap;

  const _EnhancedActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.previewWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CasinoColors.cardBackgroundLight,
                CasinoColors.cardBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradientColors.first.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Preview content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: previewWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enriched History Preview with recent matches list
class _HistoryPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recentMatches = [
      {'result': 'Won', 'score': '+120', 'color': Colors.green},
      {'result': '2nd', 'score': '+45', 'color': Colors.blue},
      {'result': 'Lost', 'score': '-50', 'color': Colors.red},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
             _MiniDashboardStat(label: 'Win Rate', value: '45%', icon: Icons.trending_up, color: Colors.green),
             Container(width: 1, height: 20, color: Colors.grey.withValues(alpha: 0.3)),
             _MiniDashboardStat(label: 'Total', value: '12', icon: Icons.games, color: Colors.indigo),
          ],
        ),
        const SizedBox(height: 8),
        // Recent Match List - compact
        ...recentMatches.map((match) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: match['color'] as Color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(match['result'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade800)),
              const Spacer(),
              Text(match['score'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: match['color'] as Color)),
            ],
          ),
        )),
      ],
    );
  }
}

class _MiniDashboardStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniDashboardStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}

// Enriched Leaderboard Preview with Top 3 list
class _LeaderboardPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPlayers = [
      {'name': 'KingDavid', 'score': '2450', 'medal': '🥇', 'color': Colors.amber},
      {'name': 'Sarah_W', 'score': '2180', 'medal': '🥈', 'color': Colors.grey.shade400},
      {'name': 'ProGamer', 'score': '1950', 'medal': '🥉', 'color': Colors.brown.shade400},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: topPlayers.map((player) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: (player['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Text(player['medal'] as String, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              CircleAvatar(radius: 8, backgroundColor: (player['color'] as Color)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  player['name'] as String,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.grey.shade800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('★${player['score']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.orange.shade700)),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;
  const _RankBadge({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
    );
  }
}

// Settings preview widget (Enhanced with colors and badges)
class _SettingsPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: [
         _SettingsActionBtn(
           icon: Icons.person_rounded,
           label: 'Profile',
           color: Colors.blue,
           badge: '✓',
         ),
         _SettingsActionBtn(
           icon: Icons.notifications_rounded,
           label: 'Alerts',
           color: Colors.orange,
           badge: '3',
         ),
         _SettingsActionBtn(
           icon: Icons.security_rounded,
           label: 'Privacy',
           color: Colors.green,
         ),
         _SettingsActionBtn(
           icon: Icons.help_center_rounded,
           label: 'Help',
           color: Colors.purple,
         ),
      ],
    );
  }
}

class _SettingsActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  
  const _SettingsActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Enriched Wallet card with live balance and quick actions
class _WalletCard extends ConsumerWidget {
  final VoidCallback onTap;

  const _WalletCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.currentUser?.uid;
    final diamondService = ref.watch(diamondServiceProvider);

    return Card(
      elevation: 4,
      shadowColor: Colors.green.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade500, Colors.teal.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Wallet',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Text('+ ADD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              // Balance preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: userId == null
                      ? _WalletEmptyState()
                      : StreamBuilder(
                          stream: diamondService.watchWallet(userId),
                          builder: (context, snapshot) {
                            final balance = snapshot.data?.balance ?? 0;
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Image.asset(
                                      'assets/images/diamond_3d.png', 
                                      width: 28, 
                                      height: 28,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Text('💎', style: TextStyle(fontSize: 24));
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$balance',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.green.shade800,
                                        fontSize: 28,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Mini transaction preview
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _MiniTransaction(type: 'Win', amount: '+120', time: '5m', isPositive: true),
                                        _MiniTransaction(type: 'Entry', amount: '-50', time: '1h', isPositive: false),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Quick Actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _WalletQuickAction(icon: Icons.history, label: 'Log', color: Colors.blueGrey),
                                    _WalletQuickAction(icon: Icons.currency_exchange, label: 'Send', color: Colors.green),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _WalletQuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WalletEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.login, color: Colors.green.shade300, size: 32),
        const SizedBox(height: 8),
        Text(
          'Sign in to view',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.green.shade500,
          ),
        ),
      ],
    );
  }
}

// Mini transaction row for wallet preview
class _MiniTransaction extends StatelessWidget {
  final String type;
  final String amount;
  final String time;
  final bool isPositive;
  
  const _MiniTransaction({
    required this.type,
    required this.amount,
    required this.time,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}



// ============ FLOATING CARD DECORATION ============
class _FloatingCardDecor extends StatelessWidget {
  final String suit;
  final int delay;

  const _FloatingCardDecor({required this.suit, required this.delay});

  @override
  Widget build(BuildContext context) {
    final color = (suit == '♥' || suit == '♦') ? Colors.red.shade200 : Colors.white;
    return Text(
      suit,
      style: TextStyle(
        fontSize: 40,
        color: color,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .moveY(begin: -10, end: 10, duration: 2000.ms, delay: delay.ms, curve: Curves.easeInOut);
  }
}

// ============ CARD DEMO CAROUSEL ============
class _CardDemoCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use actual card PNG assets
    final cards = [
      {'file': 'ace_of_spades.png', 'rank': 'A', 'suit': '♠', 'color': Colors.black},
      {'file': 'king_of_hearts.png', 'rank': 'K', 'suit': '♥', 'color': Colors.red},
      {'file': 'queen_of_diamonds.png', 'rank': 'Q', 'suit': '♦', 'color': Colors.red},
      {'file': 'jack_of_clubs.png', 'rank': 'J', 'suit': '♣', 'color': Colors.black},
      {'file': '10_of_spades.png', 'rank': '10', 'suit': '♠', 'color': Colors.black},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == cards.length - 1 ? 0 : 8,
            ),
            child: Container(
              width: 90,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/cards/png/${card['file']}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to styled card widget
                    return _FallbackCard(
                      rank: card['rank'] as String,
                      suit: card['suit'] as String,
                      color: card['color'] as Color,
                    );
                  },
                ),
              ),
            ).animate(delay: (100 * index).ms)
                .fadeIn()
                .scale(begin: const Offset(0.8, 0.8)),
          );
        },
      ),
    );
  }
}

// Fallback card widget when image fails to load
class _FallbackCard extends StatelessWidget {
  final String rank;
  final String suit;
  final Color color;

  const _FallbackCard({required this.rank, required this.suit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rank, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(suit, style: TextStyle(fontSize: 32, color: color)),
        ],
      ),
    );
  }
}


class _DemoPlayingCard extends StatelessWidget {
  final String rank;
  final String suit;
  final Color color;

  const _DemoPlayingCard({
    required this.rank,
    required this.suit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Top left
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              children: [
                Text(
                  rank,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  suit,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Center suit
          Center(
            child: Text(
              suit,
              style: TextStyle(
                fontSize: 36,
                color: color.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Bottom right (rotated)
          Positioned(
            bottom: 8,
            right: 8,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    suit,
                    style: TextStyle(
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ HOW TO PLAY CARD ============
class _HowToPlayCard extends StatelessWidget {
  final VoidCallback onTap;

  const _HowToPlayCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.purple.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade50,
                Colors.deepPurple.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Play',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Learn Call Break rules & get started',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.purple.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ HOW TO PLAY DIALOG ============
void _showHowToPlayDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [CasinoColors.cardBackgroundLight, CasinoColors.darkPurple],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: CasinoColors.gold.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CasinoColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school, color: CasinoColors.gold, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How to Play Call Break',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Steps
              _HowToPlayStep(
                number: 1,
                title: 'Enter the Lobby',
                description: 'Tap "Enter Lobby" on the home screen to see available rooms or create your own.',
                icon: Icons.meeting_room,
              ),
              
              _HowToPlayStep(
                number: 2,
                title: 'Create or Join a Room',
                description: 'Create a new room (costs diamonds) or join an existing room using a 6-digit code.',
                icon: Icons.add_circle,
              ),
              
              _HowToPlayStep(
                number: 3,
                title: 'Wait for Players',
                description: 'Wait for 4 players to join. You can also add bots to fill empty slots.',
                icon: Icons.people,
              ),
              
              _HowToPlayStep(
                number: 4,
                title: 'Place Your Bid',
                description: 'Each player bids how many tricks they expect to win (1-13). Spades are trump!',
                icon: Icons.gavel,
              ),
              
              _HowToPlayStep(
                number: 5,
                title: 'Play Your Cards',
                description: 'Follow suit when possible. The highest card (or trump) wins the trick.',
                icon: Icons.style,
              ),
              
              _HowToPlayStep(
                number: 6,
                title: 'Score Points',
                description: 'Meet your bid = earn points. Fail = lose points. Highest score after all rounds wins!',
                icon: Icons.emoji_events,
              ),
              
              const SizedBox(height: 24),
              
              // Quick tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Tips',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TipItem(text: 'Spades (♠) are always trump'),
                    _TipItem(text: 'You must follow the led suit if you can'),
                    _TipItem(text: 'Bid conservatively in early rounds'),
                    _TipItem(text: 'Save your high cards for key tricks'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Start playing button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/lobby');
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Playing Now'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HowToPlayStep extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final IconData icon;

  const _HowToPlayStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: Colors.purple.shade600),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.amber.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game type selection card
class _GameTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isNew;
  final VoidCallback onTap;

  const _GameTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isNew = false,
    required this.onTap,
  });

  // Get player count info based on game type
  String get _playerInfo {
    switch (title) {
      case 'Call Break': return '4 players';
      case 'Marriage': return '2-5 players';
      case 'Teen Patti': return '3-6 players';
      case 'In Between': return '2-8 players';
      default: return '2-6 players';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CasinoColors.cardBackground,
                color.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow effect
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Subtitle
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Player count
                  Row(
                    children: [
                      Icon(Icons.group, size: 12, color: color.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text(
                        _playerInfo,
                        style: TextStyle(
                          color: color.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // NEW badge
              if (isNew)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

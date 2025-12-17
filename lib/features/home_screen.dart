
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'auth/auth_service.dart';
import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/config/casino_theme.dart';
import 'package:clubroyale/config/visual_effects.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/features/game/services/test_game_service.dart';
import 'package:clubroyale/features/game/widgets/player_avatar.dart';
import 'package:clubroyale/core/responsive/responsive_utils.dart';
// Stories import
import 'package:clubroyale/features/stories/widgets/story_bar.dart';
import 'package:clubroyale/core/config/game_terminology.dart';
// Social-First Widgets
import 'package:clubroyale/features/social/widgets/online_friends_bar.dart';
import 'package:clubroyale/features/social/widgets/quick_social_actions.dart';
import 'package:clubroyale/features/social/widgets/social_feed_widget.dart';
import 'package:clubroyale/features/social/widgets/live_activity_section.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'package:clubroyale/features/stories/services/story_service.dart';
import 'package:clubroyale/features/home/widgets/compact_header.dart';
import 'package:clubroyale/core/widgets/social_bottom_nav.dart' as social_nav;


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📍 HomeScreen.build called');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final contentMaxWidth = 800.0;
        
        return Scaffold(
          backgroundColor: const Color(0xFF1a0a2e),
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a0a2e), Color(0xFF2d1b4e), Color(0xFF1a0a2e)],
                  ),
                ),
              ),
              
              // Main Content
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    children: [
                      // 1. Compact Header (Avatar + Name + Diamond + Settings)
                      const CompactHeader(),
                      
                      // 2. Scrollable Content
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(unreadChatsCountProvider);
                            ref.invalidate(onlineFriendsCountProvider);
                            ref.invalidate(activeVoiceRoomsProvider);
                            ref.invalidate(spectatorGamesProvider);
                            ref.invalidate(friendsStoriesProvider);
                            ref.invalidate(myStoriesProvider);
                            ref.invalidate(activityFeedProvider(5));
                          },
                          color: const Color(0xFFD4AF37),
                          backgroundColor: const Color(0xFF1a0a2e),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: EdgeInsets.only(bottom: isDesktop ? 120 : 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Story Bar
                                const StoryBar().animate().fadeIn(delay: 100.ms),
                                
                                const SizedBox(height: 8),
                                
                                // Live Activity Section
                                const LiveActivitySection().animate().fadeIn(delay: 150.ms),
                                
                                const SizedBox(height: 8),
                                
                                // Quick Actions
                                const QuickSocialActions().animate().fadeIn(delay: 200.ms),
                                
                                const SizedBox(height: 8),
                                
                                // Activity Feed (Glassmorphism)
                                const SocialFeedWidget(maxItems: 5).animate().fadeIn(delay: 250.ms),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 3. Bottom Navigation with Gold Play Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: isDesktop ? 24.0 : 0),
                  child: SizedBox(
                    width: isDesktop ? 450 : double.infinity,
                    child: social_nav.SocialBottomNav(
                      currentIndex: 0,
                      isFloating: isDesktop,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            color: (player['color'] as Color).withValues(alpha: 0.1),
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
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
                    color: color.withValues(alpha: 0.1),
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
                    color: color.withValues(alpha: 0.9),
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
                                      color: Colors.green.withValues(alpha: 0.05),
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
                    'How to Play Marriage',
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
                title: 'Objective',
                description: 'Collect 3 Tunnellas (sets of 3 cards) to unlock or end the game. Be the first to show your cards.',
                icon: Icons.emoji_events,
              ),
              
              _HowToPlayStep(
                number: 2,
                title: 'The Tunnellas',
                description: 'Pure Sequence (e.g., 2-3-4 ♥️), Tunnella (e.g., 7-7-7 ♦️), or Dublee (e.g., 9-9 ♣️). You need 3 combinations!',
                icon: Icons.style,
              ),
              
              _HowToPlayStep(
                number: 3,
                title: 'The Tiplu (Joker)',
                description: 'The Tiplu card can replace any other card to complete sets. Use it wisely!',
                icon: Icons.star,
              ),
              
              _HowToPlayStep(
                number: 4,
                title: 'Game Play',
                description: 'Draw a card, discard a card. Keep your hand organized into potential sets.',
                icon: Icons.swipe,
              ),
              
              _HowToPlayStep(
                number: 5,
                title: 'Points & Maal',
                description: 'Points are based on the value of cards in your sets (Maal). Tunnellas are worth the most.',
                icon: Icons.monetization_on,
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
                    _TipItem(text: 'Always check if you have a "Tiplu"'),
                    _TipItem(text: 'Focus on forming Pure Sequences first'),
                    _TipItem(text: 'Discard high-value cards if not useful'),
                    _TipItem(text: 'Watch what others discard!'),
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
                    context.go('/marriage');
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
  final bool isFeatured;
  final VoidCallback onTap;

  const _GameTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isNew = false,
    this.isFeatured = false,
    required this.onTap,
  });

  // Get player count info based on game type
  String get _playerInfo {
    switch (title) {
      case 'Marriage': return '2-8 players';
      case 'Call Break': return '4 players';
      case 'Teen Patti': return '3-6 players';
      case 'In Between': return '2-8 players';
      default: return '2-6 players';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use gold border/glow for featured games
    final borderColor = isFeatured ? ClubRoyaleTheme.gold : color.withValues(alpha: 0.4);
    final borderWidth = isFeatured ? 2.0 : 1.5;
    
    return Card(
      elevation: isFeatured ? 10 : 6,
      shadowColor: isFeatured ? ClubRoyaleTheme.gold.withValues(alpha: 0.5) : color.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFeatured
                  ? [ClubRoyaleTheme.deepPurple, color.withValues(alpha: 0.25)]
                  : [CasinoColors.cardBackground, color.withValues(alpha: 0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isFeatured ? [
              BoxShadow(
                color: ClubRoyaleTheme.gold.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : null,
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
                        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 10),
                  // Title with optional gold text for featured
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isFeatured ? ClubRoyaleTheme.gold : Colors.white,
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
                      Icon(Icons.group, size: 12, color: color.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(
                        _playerInfo,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Featured badge (crown icon)
              if (isFeatured)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ClubRoyaleTheme.gold, ClubRoyaleTheme.champagne],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ClubRoyaleTheme.gold.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFF2D1B4E),
                      size: 14,
                    ),
                  ),
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
                          color: Colors.green.withValues(alpha: 0.3),
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

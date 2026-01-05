import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';
import 'package:clubroyale/core/widgets/theme_selector.dart';
import 'package:clubroyale/features/settings/widgets/terminology_toggle.dart';
import 'package:clubroyale/core/services/feature_flags.dart';
import 'package:clubroyale/core/services/sound_service.dart';
import 'package:clubroyale/core/services/localization_service.dart';
import 'package:clubroyale/core/config/game_settings.dart';
import 'package:clubroyale/core/config/game_terminology.dart';

/// Settings Screen - Premium Edition
///
/// Enhanced UI/UX with:
/// - Hero Header
/// - Quick Action Grid (Wallet, Profile)
/// - Premium List Tiles
/// - Feature-specific settings (Strict Mode, Social)
/// - Feature-specific settings (Strict Mode, Social)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeColorsProvider);
    final currentLocale = ref.watch(localeProvider); // Watch locale for rebuilds

    return Scaffold(
      backgroundColor: themeColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, themeColors, ref), // Pass ref

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Prime Actions (Wallet & Profile)
                  _buildPrimeActionsGrid(context, themeColors, ref),
                  const SizedBox(height: 32),

                  // 2. Gameplay Settings (The Core Experience)
                  _buildSectionTitle('section_gameplay'.tr(ref), themeColors),
                  const SizedBox(height: 16),
                  
                  // LANGUAGE TOGGLE
                  _buildLanguageToggle(context, ref, themeColors),
                  const SizedBox(height: 12),
                  
                  TerminologyToggle(
                    onChanged: () => _showRestartSnackBar(context),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchTile(
                    title: 'Strict Mode (Nepali Variant)',
                    subtitle: 'Enable arcade penalties and precise Maal rules',
                    value: true,
                    onChanged: (val) {}, // Todo: wire up to provider
                    themeColors: themeColors,
                  ),

                  const SizedBox(height: 32),

                  // 3. Social & Privacy
                  if (featureFlags.socialEnabled) ...[
                    _buildSectionTitle('section_social'.tr(ref), themeColors),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      title: 'Public Story Visibility',
                      subtitle: 'Allow non-friends to view your victories',
                      value: true,
                      onChanged: (val) {},
                      themeColors: themeColors,
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationTile(
                      icon: Icons.notifications_active, // Dynamic icon?
                      title: 'Notifications',
                      subtitle: 'Game invites, friend requests',
                      onTap: () {},
                      themeColors: themeColors,
                    ),
                    const SizedBox(height: 32),
                  ],

                  const SizedBox(height: 32),

                  // 4. Audio Settings
                  _buildSectionTitle('section_audio'.tr(ref), themeColors),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        children: [
                          _buildSwitchTile(
                            title: 'Sound Effects',
                            subtitle: 'Card flips, chips, and wins',
                            value: SoundService.isSoundEnabled,
                            onChanged: (val) {
                              setState(() {
                                SoundService.toggleSound();
                              });
                            },
                            themeColors: themeColors,
                          ),
                          const SizedBox(height: 12),
                          _buildSwitchTile(
                            title: 'Background Music',
                            subtitle: 'Lobby and game ambience',
                            value: SoundService.isMusicEnabled,
                            onChanged: (val) {
                              setState(() {
                                SoundService.toggleMusic();
                              });
                            },
                            themeColors: themeColors,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // 5. Appearance
                  _buildSectionTitle('section_appearance'.tr(ref), themeColors),
                  const SizedBox(height: 16),
                  const ThemeSelectorWidget(),

                  const SizedBox(height: 32),

                  // 5. Support & Legal
                  _buildSectionTitle('section_support'.tr(ref), themeColors),
                  const SizedBox(height: 16),
                  _buildNavigationTile(
                    icon: Icons.school,
                    title: 'How to Play',
                    subtitle: 'Master the Royal Meld rules',
                    onTap: () => context.push('/how-to-play'),
                    themeColors: themeColors,
                  ),
                  const SizedBox(height: 12),
                  _buildNavigationTile(
                    icon: Icons.info_outline,
                    title: 'About ClubRoyale',
                    subtitle: 'v2.1.0 • ToT AI Enabled',
                    onTap: () => context.push('/about'),
                    themeColors: themeColors,
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeColors themeColors, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: themeColors.background,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
       title: Text(
          'settings'.tr(ref).toUpperCase(),
          style: TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(gradient: themeColors.primaryGradient),
          child: Stack(
            children: [
              // Subtle Pattern Overlay
              Positioned(
                right: -50,
                top: -50,
                child: Icon(
                  Icons.settings,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildPrimeActionsGrid(BuildContext context, ThemeColors themeColors, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            title: 'wallet'.tr(ref),
            subtitle: 'Manage Diamonds',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFFD4AF37), // Gold
            onTap: () => context.push('/wallet'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            title: 'profile'.tr(ref),
            subtitle: 'Edit Avatar',
            icon: Icons.person,
            color: const Color(0xFF2E7D32), // Green
            onTap: () => context.push('/profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeColors themeColors) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: themeColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: themeColors.accent,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeColors themeColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: SwitchListTile(
        activeThumbColor: themeColors.gold,
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeColors themeColors,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: themeColors.gold, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white24,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showRestartSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Language updated! Please restart the game.'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  }

  Widget _buildLanguageToggle(BuildContext context, WidgetRef ref, ThemeColors themeColors) {
    final currentLocale = ref.watch(localeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
           Icon(Icons.language, color: themeColors.gold),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'language'.tr(ref),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    currentLocale == AppLocale.ne ? 'Nepali' : 'English',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
             ),
           ),
           ToggleButtons(
             isSelected: [currentLocale == AppLocale.en, currentLocale == AppLocale.ne],
             onPressed: (index) async {
               final newLocale = index == 0 ? AppLocale.en : AppLocale.ne;
               await ref.read(localeProvider.notifier).setLocale(newLocale);
               
               // Auto-sync Game Terminology based on Language
               if (newLocale == AppLocale.ne) {
                 await ref.read(gameSettingsProvider.notifier).setRegion(GameRegion.southAsia);
               } else {
                  // Optional: stay on current region or reset to global?
                  // Keeping current region lets users play in English but with "Marriage" terms if they want
               }
             },
             borderRadius: BorderRadius.circular(8),
             selectedColor: Colors.black,
             fillColor: themeColors.gold,
             color: Colors.white70,
             renderBorder: false,
             constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
             children: const [
               Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('EN', style: TextStyle(fontWeight: FontWeight.bold))),
               Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('नेपाली', style: TextStyle(fontWeight: FontWeight.bold))), 
             ],
           ),
        ],
      ),
    );
  }
}

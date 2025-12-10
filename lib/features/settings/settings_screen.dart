import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/core/config/club_royale_theme.dart';
import 'package:clubroyale/core/theme/multi_theme.dart';
import 'package:clubroyale/core/widgets/theme_selector.dart';
import 'package:clubroyale/features/settings/widgets/terminology_toggle.dart';

/// Settings Screen
/// 
/// App-wide settings including game terminology, notifications, and account
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          ThemeToggleButton(), // Quick day/night toggle
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeColors.primaryGradient),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            
            // Theme Section Header
            _buildSectionHeader('Appearance', themeColors),
            
            // Theme Selector Widget
            const ThemeSelectorWidget(),
            
            const SizedBox(height: 24),
            
            // Game Section Header
            _buildSectionHeader('Game', themeColors),
            
            // Terminology Toggle
            TerminologyToggle(
              onChanged: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terminology updated! Restart the game for full effect.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Account Section Header
            _buildSectionHeader('Account', themeColors),
            
            // Profile Settings
            _buildListTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Change display name and avatar',
              onTap: () => context.push('/profile'),
              themeColors: themeColors,
            ),
            
            // Wallet
            _buildListTile(
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              subtitle: 'Manage diamonds and transactions',
              onTap: () => context.push('/wallet'),
              themeColors: themeColors,
            ),
            
            const SizedBox(height: 24),
            
            // App Section Header
            _buildSectionHeader('App', themeColors),
            
            // Notifications
            _buildListTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Game invites, friend requests',
              onTap: () {},
              themeColors: themeColors,
            ),
            
            // About
            _buildListTile(
              icon: Icons.info,
              title: 'About ClubRoyale',
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ClubRoyale',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 ClubRoyale',
                  children: [
                    const SizedBox(height: 16),
                    const Text('Your Private Card Club - The Ultimate Card Experience'),
                  ],
                );
              },
              themeColors: themeColors,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, ThemeColors themeColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: themeColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
  
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeColors themeColors,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: themeColors.gold),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
